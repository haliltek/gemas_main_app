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

        final lower = query.toLowerCase();

        bool contains(String? text) =>
            text?.toLowerCase().contains(lower) ?? false;

        bool stockMatch(Product p) => p.malzemeler?.any(
                (m) => m.stokKodu.toLowerCase().contains(lower)) ??
            false;

        bool nameMatch(Product p) =>
            contains(p.ad) || contains(p.alinti) || contains(p.aciklama);

        products =
            products.where((p) => nameMatch(p) || stockMatch(p)).toList();

        int score(Product p) {
          int s = 3;
          if (nameMatch(p)) {
            if (contains(p.ad)) {
              s = 0;
            } else if (contains(p.alinti)) {
              s = 1;
            } else if (contains(p.aciklama)) {
              s = 2;
            }
          }
          if (stockMatch(p)) {
            s = s < 0 ? s : 0;
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
