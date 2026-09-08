import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gemas/constants.dart';
import 'package:gemas/models/product.dart';
import 'package:gemas/pages/product.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:gemas/widgets/gemas_app_bar.dart';

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

  String _matchReason(Product product, String q) {
    final lower = q.toLowerCase();
    bool contains(String? t) => t?.toLowerCase().contains(lower) ?? false;
    if (contains(product.ad)) return 'matchName'.tr;
    if (contains(product.alinti)) return 'matchSummary'.tr;
    if (contains(product.aciklama)) return 'matchDescription'.tr;
    if (product.malzemeler?.any((m) => contains(m.stokKodu)) ?? false) {
      return 'matchStock'.tr;
    }
    return '';
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
      body: FutureBuilder(
        future: _getSearchProducts(),
        builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
          if (snapshot.hasData) {
            final products = [...snapshot.data!];
            products.sort((a, b) {
              final aMatch = _matchReason(a, searchValue).isNotEmpty;
              final bMatch = _matchReason(b, searchValue).isNotEmpty;
              if (aMatch == bMatch) return 0;
              return aMatch ? -1 : 1;
            });
            return ListView.builder(
              physics: ClampingScrollPhysics(),
              itemCount: products.length,
              itemBuilder: (context, index) {
                var product = products[index];
                return Card(
                  elevation: 1.0,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductPage(
                            product: product,
                          ),
                        ),
                      );
                    },
                    leading: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: product.urunFoto!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: Constants.DOMAIN + product.urunFoto!.first.foto,
                              fit: BoxFit.cover,
                            )
                          : Image.asset('assets/images/unnamed.png', fit: BoxFit.cover),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: _highlight(
                            context,
                            product.ad,
                            searchValue,
                            TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        if (product.alinti.isNotEmpty)
                          RichText(
                            text: _highlight(
                              context,
                              product.alinti,
                              searchValue,
                              TextStyle(color: Theme.of(context).colorScheme.onSurface),
                            ),
                          )
                        else if (product.aciklama.isNotEmpty)
                          RichText(
                            text: _highlight(
                              context,
                              product.aciklama,
                              searchValue,
                              TextStyle(color: Theme.of(context).colorScheme.onSurface),
                            ),
                          ),
                        if (_matchReason(product, searchValue).isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _matchReason(product, searchValue),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
