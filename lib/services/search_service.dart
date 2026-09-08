import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';

class SearchService {
  // In-memory cache for blazing-fast instant search results
  static final Map<String, List<Product>> _cache = {};
  static const int _maxCacheEntries = 60;

  static String normalizeText(String? s) {
    if (s == null) return '';
    return s
        .replaceAll('İ', 'i')
        .replaceAll('I', 'i')
        .replaceAll('ı', 'i')
        .replaceAll('Ş', 's')
        .replaceAll('ş', 's')
        .replaceAll('Ğ', 'g')
        .replaceAll('ğ', 'g')
        .replaceAll('Ü', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('Ö', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('Ç', 'c')
        .replaceAll('ç', 'c')
        .toLowerCase()
        .replaceAll('\u0307', '')
        .replaceAll(RegExp(r'[\u0300-\u036f]'), '')
        .trim();
  }

  /// Fetches products from the search endpoint, caches them, and sorts with O(N) pre-computed scores.
  static Future<List<Product>> searchProducts(String query, {int retryCount = 0}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    final lang = "langCode".tr;
    final cacheKey = '$lang:$cleanQuery';

    // 1. Instant 0ms memory cache hit
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final encodedQuery = Uri.encodeComponent(cleanQuery);
      final url = Uri.parse('https://gemas.com.tr/api/v1/$lang/productSearch/$encodedQuery');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var products = (json.decode(response.body) as List)
            .map((productMap) => Product.fromJson(productMap))
            .toList();

        final cleanQ = cleanQuery.trim();
        final lower = cleanQ.toLowerCase();
        final normQ = normalizeText(cleanQ);
        final normCode = lower.replaceAll(RegExp(r'[\s\-_./]'), '');
        final queryWords = normQ.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

        bool containsText(String? text, String target) {
          if (text == null) return false;
          return normalizeText(text).contains(target);
        }

        bool exactStockMatch(Product p) =>
            p.malzemeler?.any((m) {
              final code = m.stokKodu.trim().toLowerCase();
              return code == lower ||
                  (normCode.isNotEmpty &&
                      code.replaceAll(RegExp(r'[\s\-_./]'), '') == normCode);
            }) ??
            false;

        bool stockMatch(Product p) =>
            p.malzemeler?.any(
                (m) => m.stokKodu.toLowerCase().contains(lower)) ??
            false;

        bool titleMatch(Product p) {
          final normAd = normalizeText(p.ad);
          if (normAd.contains(normQ)) return true;
          return queryWords.isNotEmpty && queryWords.every((w) => normAd.contains(w));
        }

        bool nameOrDescMatch(Product p) =>
            titleMatch(p) || containsText(p.alinti, normQ) || containsText(p.aciklama, normQ);

        products = products
            .where((p) => nameOrDescMatch(p) || stockMatch(p) || exactStockMatch(p))
            .toList();

        // High performance scoring: Precompute score O(N) once
        final Map<Product, int> scores = {};
        for (final p in products) {
          int s = 50;
          final normAd = normalizeText(p.ad);

          if (exactStockMatch(p)) {
            s = -100; // Top priority: Exact stock code
          } else if (normAd == normQ) {
            s = -80;  // Exact title match
          } else if (normAd.startsWith(normQ)) {
            s = -60;  // Title starts with query
          } else if (titleMatch(p)) {
            s = -40;  // Title contains all query words
          } else if (stockMatch(p)) {
            s = -10;  // Partial stock code
          } else if (containsText(p.alinti, normQ)) {
            s = 10;   // In summary
          } else if (containsText(p.aciklama, normQ)) {
            s = 20;   // In description
          }
          scores[p] = s;
        }

        products.sort((a, b) {
          final scoreDiff = scores[a]!.compareTo(scores[b]!);
          if (scoreDiff != 0) return scoreDiff;
          return a.ad.length.compareTo(b.ad.length);
        });

        // Manage LRU cache size
        if (_cache.length >= _maxCacheEntries) {
          _cache.remove(_cache.keys.first);
        }
        _cache[cacheKey] = products;

        return products;
      } else {
        throw Exception('Bağlantı hatası: ${response.statusCode}');
      }
    } catch (_) {
      if (retryCount < 1) {
        await Future.delayed(const Duration(milliseconds: 500));
        return searchProducts(query, retryCount: retryCount + 1);
      }
      return [];
    }
  }

  /// Clears the search cache if needed (e.g. language change)
  static void clearCache() {
    _cache.clear();
  }
}
