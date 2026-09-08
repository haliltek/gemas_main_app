import 'package:flutter/material.dart';
import 'package:gemas/models/dokuman_category.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gemas/widgets/gemas_app_bar.dart';

import 'dokuman_category.dart';

class DocumanCategoriesPage extends StatefulWidget {
  const DocumanCategoriesPage({Key? key}) : super(key: key);

  @override
  State<DocumanCategoriesPage> createState() => _DocumanCategoriesPageState();
}

class _DocumanCategoriesPageState extends State<DocumanCategoriesPage> {
  static List<DocumanCategory>? _cachedCategories;
  static String? _cachedLang;

  late Future<List<DocumanCategory>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    final lang = "langCode".tr;
    if (_cachedCategories != null && _cachedLang == lang) {
      _categoriesFuture = Future.value(_cachedCategories!);
    } else {
      _categoriesFuture = _getDocumanCategories();
    }
  }

  Future<List<DocumanCategory>> _getDocumanCategories({int retryCount = 0}) async {
    final lang = "langCode".tr;
    try {
      final response = await http
          .get(Uri.parse("https://gemas.com.tr/api/v1/$lang/dokuman-kategori"))
          .timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final list = (json.decode(response.body) as List)
            .map((documanCategoryMap) => DocumanCategory.fromJson(documanCategoryMap))
            .toList();
        _cachedCategories = list;
        _cachedLang = lang;
        return list;
      } else {
        throw Exception("Bağlantı hatası: ${response.statusCode}");
      }
    } catch (e) {
      if (retryCount < 1) {
        await Future.delayed(const Duration(seconds: 2));
        return _getDocumanCategories(retryCount: retryCount + 1);
      }
      return _cachedCategories ?? [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GemasAppBar(title: "documentCategories".tr),
      body: FutureBuilder<List<DocumanCategory>>(
        future: _categoriesFuture,
        builder: (BuildContext context, AsyncSnapshot<List<DocumanCategory>> snapshot) {
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
                        _categoriesFuture = _getDocumanCategories();
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
              return ListTile(
                leading: const Icon(Icons.category),
                title: Text(category.ad),
                trailing: const Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DocumanCategoryPage(catID: category.id, catName: category.ad),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
