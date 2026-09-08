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

class CategoryPage extends StatefulWidget {
  final Category category;

  const CategoryPage({Key? key, required this.category}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _getCategoryProducts();
  }

  Future<List<Product>> _getCategoryProducts({int retryCount = 0}) async {
    try {
      final response = await http
          .get(Uri.parse("https://gemas.com.tr/api/v1/${"langCode".tr}/productsByCategoryV2/${widget.category.id}"))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return (json.decode(response.body) as List).map((productMap) => Product.fromJson(productMap)).toList();
      } else {
        throw Exception("Bağlantı hatası: ${response.statusCode}");
      }
    } catch (e) {
      if (retryCount < 2) {
        await Future.delayed(const Duration(seconds: 3));
        return _getCategoryProducts(retryCount: retryCount + 1);
      }
      return [];
    }
  }

  String _truncateText(String text, int maxLength) {
    return text.length <= maxLength ? text : text.substring(0, maxLength - 3) + '...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GemasAppBar(title: _truncateText(widget.category.ad, 28)),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text('tryAgain'.tr.isNotEmpty ? 'tryAgain'.tr : 'Tekrar Deneyin'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _productsFuture = _getCategoryProducts();
                      });
                    },
                    child: const Icon(Icons.refresh),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return Center(
              child: Text('noData'.tr.isNotEmpty ? 'noData'.tr : 'Ürün bulunamadı'),
            );
          }

          return ListView.builder(
            physics: const ClampingScrollPhysics(),
            itemCount: data.length,
            itemBuilder: (context, index) {
              var product = data[index];
              final photos = product.urunFoto ?? [];
              return Card(
                elevation: 1.0,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
                    child: photos.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: Constants.DOMAIN + photos.first.foto,
                            fit: BoxFit.cover,
                            memCacheWidth: 400,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade100,
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              "assets/images/unnamed.png",
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset("assets/images/unnamed.png", fit: BoxFit.cover),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.ad,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      if (product.alinti.isNotEmpty)
                        Text(product.alinti)
                      else if (product.aciklama.isNotEmpty)
                        Text(product.aciklama, maxLines: 4, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
