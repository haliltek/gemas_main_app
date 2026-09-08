import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';

class SearchService {
  /// Fetches products from the search endpoint and sorts them so that
  /// matches in the product name appear before matches in the summary or
  /// description. Retries once if the request fails.
  static Future<List<Product>> searchProducts(String query) async {
    try {
      final url = Uri.parse(
          'https://gemas.com.tr/api/v1/${"langCode".tr}/productSearch/$query');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var products = (json.decode(response.body) as List)
            .map((productMap) => Product.fromJson(productMap))
            .toList();

        final lower = query.trim().toLowerCase();
        final normLower = lower.replaceAll(RegExp(r'[\s\-_./]'), '');

        bool contains(String? text) =>
            text?.toLowerCase().contains(lower) ?? false;

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

        int score(Product p) {
          if (exactStockMatch(p)) return -10;
          if (p.ad.trim().toLowerCase() == lower) return -5;

          int s = 3;
          if (stockMatch(p)) {
            s = 0;
          } else if (contains(p.ad)) {
            s = 1;
          } else if (contains(p.alinti)) {
            s = 2;
          } else if (contains(p.aciklama)) {
            s = 3;
          }
          return s;
        }

        products.sort((a, b) => score(a).compareTo(score(b)));

        return products;
      } else {
        throw Exception('Bağlantı hatası: ${response.statusCode}');
      }
    } catch (_) {
      await Future.delayed(const Duration(seconds: 1));
      return searchProducts(query);
    }
  }
}
