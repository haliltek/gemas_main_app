import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gemas/constants.dart';
import 'package:gemas/models/product.dart';
import 'package:gemas/pages/product.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:gemas/widgets/gemas_app_bar.dart';

import 'product_search_delegate.dart';

class ProductSearchPage extends StatelessWidget {
  final String searchValue;

  const ProductSearchPage({required this.searchValue}) : super();

  TextSpan _highlight(
      BuildContext context, String source, String query, TextStyle style) {
    final lowerSource = source.toLowerCase();
    final lowerQuery = query.toLowerCase();
    if (lowerQuery.isEmpty || !lowerSource.contains(lowerQuery)) {
      return TextSpan(text: source, style: style);
    }
    final spans = <TextSpan>[];
    int start = 0;
    final highlightColor =
        Theme.of(context).colorScheme.secondaryContainer;
    while (true) {
      final index = lowerSource.indexOf(lowerQuery, start);
      if (index < 0) {
        spans.add(TextSpan(text: source.substring(start), style: style));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: source.substring(start, index), style: style));
      }
      spans.add(TextSpan(
          text: source.substring(index, index + query.length),
          style: style.copyWith(backgroundColor: highlightColor)));
      start = index + query.length;
    }
    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    Future<List<Product>> _getSearchProducts() async {
      try {
        var response = await http.get(Uri.parse("https://gemas.com.tr/api/v1/${"langCode".tr}/productSearch/" + searchValue));

        if (response.statusCode == 200) {
          return (json.decode(response.body) as List).map((productMap) => Product.fromJson(productMap)).toList();
        } else {
          throw Exception("Bağlantı hatası: ${response.statusCode}");
        }
      } catch (e) {
        await Future.delayed(Duration(seconds: 1));
        return _getSearchProducts();
      }
    }

    return Scaffold(
      appBar: GemasAppBar(title: searchValue),
      body: FutureBuilder<List<Product>>(
        future: _getSearchProducts(),
        builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
          if (snapshot.hasData) {
            return SearchResultsList(
              query: searchValue,
              products: snapshot.data!,
              highlightBuilder: _highlight,
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
