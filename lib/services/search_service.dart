import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';

class SearchService {
  // In-memory cache for blazing-fast instant search results
  static final Map<String, List<Product>> _cache = {};
  static const int _maxCacheEntries = 60;

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
      final url = Uri.parse('https://gemas.com.tr/api/v1/$lang/productSearch/$cleanQuery');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var products = (json.decode(response.body) as List)
            .map((productMap) => Product.fromJson(productMap))
            .toList();

        final lower = cleanQuery.toLowerCase();
        final normLower = lower.replaceAll(RegExp(r'[\s\-_./]'), '');

        bool contains(String? text) =>
            text != null && text.toLowerCase().contains(lower);

        bool exactStockMatch(Product p) =>
            p.malzemeler?.any((m) {
              final code = m.stokKodu.trim().toLowerCase();
              return code == lower ||
                  (normLower.isNotEmpty &&
                      code.replaceAll(RegExp(r'[\s\-_./]'), '') == normLower);
            }) ??
            false;

        bool stockMatch(Product p) =>
            p.malzemeler?.any(
                (m) => m.stokKodu.toLowerCase().contains(lower)) ??
            false;

        bool nameMatch(Product p) =>
            contains(p.ad) || contains(p.alinti) || contains(p.aciklama);

        products = products
            .where((p) => nameMatch(p) || stockMatch(p) || exactStockMatch(p))
            .toList();

        // High performance optimization: Precompute score O(N) once instead of O(N log N) during sort
        final Map<Product, int> scores = {};
        for (final p in products) {
          int s = 3;
          if (exactStockMatch(p)) {
            s = -10;
          } else if (p.ad.trim().toLowerCase() == lower) {
            s = -5;
          } else if (stockMatch(p)) {
            s = 0;
          } else if (contains(p.ad)) {
            s = 1;
          } else if (contains(p.alinti)) {
            s = 2;
          }
          scores[p] = s;
        }

        products.sort((a, b) => scores[a]!.compareTo(scores[b]!));

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
