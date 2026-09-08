import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gemas/constants.dart';
import 'package:gemas/models/category.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gemas/widgets/gemas_app_bar.dart';

import 'category.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _getCategoryList();
  }

  Future<List<Category>> _getCategoryList({int retryCount = 0}) async {
    try {
      final response = await http
          .get(Uri.parse("https://gemas.com.tr/api/v1/${"langCode".tr}/categoriesV2"))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((categoryMap) => Category.fromJson(categoryMap))
            .toList();
      } else {
        throw Exception("Bağlantı hatası: ${response.statusCode}");
      }
    } catch (e) {
      if (retryCount < 2) {
        await Future.delayed(const Duration(seconds: 3));
        return _getCategoryList(retryCount: retryCount + 1);
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GemasAppBar(title: 'categories'.tr),
      body: FutureBuilder<List<Category>>(
        future: _categoriesFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Category>> snapshot) {
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
                        _categoriesFuture = _getCategoryList();
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
              child: Text('noData'.tr.isNotEmpty ? 'noData'.tr : 'Kategori bulunamadı'),
            );
          }

          return ListView.builder(
            physics: const ClampingScrollPhysics(),
            itemCount: data.length,
            itemBuilder: (context, index) {
              var category = data[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CategoryPage(category: category)),
                  );
                },
                child: Card(
                  elevation: 0,
                  child: ListTile(
                    leading: SizedBox(
                      width: 90,
                      child: (category.image != null && category.image.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: Constants.DOMAIN + category.image,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                "assets/images/unnamed.png",
                                fit: BoxFit.fill,
                              ),
                            )
                          : Image.asset("assets/images/unnamed.png", fit: BoxFit.fill),
                    ),
                    title: Text(
                      category.ad,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    trailing: CircleAvatar(
                      child: Text(category.urunlerCount.toString()),
                    ),
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
