import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gemas/constants.dart';
import 'package:gemas/models/spare_part_category.dart';
import 'package:gemas/pages/spare_part_by_category.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:gemas/widgets/gemas_app_bar.dart';

class SparePartsCategories extends StatefulWidget {
  const SparePartsCategories({Key? key}) : super(key: key);

  @override
  State<SparePartsCategories> createState() => _SparePartsCategoriesState();
}

class _SparePartsCategoriesState extends State<SparePartsCategories> {
  static List<SparePartCategory>? _cachedSpareParts;
  static String? _cachedLang;

  late Future<List<SparePartCategory>> _sparePartsFuture;

  @override
  void initState() {
    super.initState();
    final lang = "langCode".tr;
    if (_cachedSpareParts != null && _cachedLang == lang) {
      _sparePartsFuture = Future.value(_cachedSpareParts!);
    } else {
      _sparePartsFuture = _getSpareParts();
    }
  }

  Future<List<SparePartCategory>> _getSpareParts({int retryCount = 0}) async {
    final lang = "langCode".tr;
    try {
      final response = await http
          .get(Uri.parse("https://gemas.com.tr/api/v1/$lang/spare_part_categories"))
          .timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final list = (json.decode(response.body) as List)
            .map((sparePartCategoryMap) => SparePartCategory.fromJson(sparePartCategoryMap))
            .toList();
        _cachedSpareParts = list;
        _cachedLang = lang;
        return list;
      } else {
        throw Exception("Bağlantı hatası: ${response.statusCode}");
      }
    } catch (error) {
      if (retryCount < 1) {
        await Future.delayed(const Duration(seconds: 2));
        return _getSpareParts(retryCount: retryCount + 1);
      }
      return _cachedSpareParts ?? [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GemasAppBar(title: 'partCategories'.tr),
      body: FutureBuilder<List<SparePartCategory>>(
        future: _sparePartsFuture,
        builder: (BuildContext context, AsyncSnapshot<List<SparePartCategory>> snapshot) {
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
                        _sparePartsFuture = _getSpareParts();
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
                    MaterialPageRoute(
                      builder: (context) => SparePartByCategoryPage(category: category),
                    ),
                  );
                },
                child: Card(
                  elevation: 0,
                  child: ListTile(
                    leading: SizedBox(
                      height: 80,
                      width: 90,
                      child: (category.image != null && category.image.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: Constants.DOMAIN + category.image,
                              fit: BoxFit.contain,
                              memCacheWidth: 250,
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
                      child: Text(category.yedekParcaCount.toString()),
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
