import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gemas/constants.dart';
import 'package:gemas/models/category.dart';
import 'package:gemas/models/product.dart';
import 'package:gemas/pages/product.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gemas/widgets/gemas_app_bar.dart';

class CategoryPage extends StatelessWidget {
  final Category category;

  const CategoryPage({required this.category}) : super();

  @override
  Widget build(BuildContext context) {
    Future<List<Product>> _getCategoryProducts() async {
      try {
        var response = await http.get(Uri.parse("https://gemas.com.tr/api/v1/${"langCode".tr}/productsByCategoryV2/${category.id}"));
        if (response.statusCode == 200) {
          return (json.decode(response.body) as List).map((productMap) => Product.fromJson(productMap)).toList();
        } else {
          throw Exception("Bağlantı hatası: ${response.statusCode}");
        }
      } catch (e) {
        await Future.delayed(Duration(seconds: 15));
        return _getCategoryProducts();
      }
    }

    String _truncateText(String text, int maxLength) {
      return text.length <= maxLength ? text : text.substring(0, maxLength - 3) + '...';
    }
    return Scaffold(
      appBar: GemasAppBar(title: _truncateText(category.ad, 28)),
      body: FutureBuilder(
        future: _getCategoryProducts(),
        builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              physics: ClampingScrollPhysics(),
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                var product = snapshot.data![index];
                debugPrint("https://gemas.com.tr/api/v1 index: $index");
                return Card(
                  elevation: 1.0,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductPage(product: product, productId: product.id),
                        ),
                      );
                    },

                    leading: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: product.urunFoto!.length > 0
                          ? CachedNetworkImage(imageUrl: Constants.DOMAIN + product.urunFoto!.first.foto, fit: BoxFit.cover)
                          : Image.asset("assets/images/unnamed.png", fit: BoxFit.cover)
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.ad,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        product.alinti != null ? Text(product.alinti) : product.aciklama != null ? Text(product.aciklama, maxLines: 4) : Text(''),
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
