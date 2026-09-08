import 'package:flutter/material.dart';
import 'package:gemas/models/dokuman_category.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gemas/widgets/gemas_app_bar.dart';

import 'dokuman_category.dart';

class DocumanCategoriesPage extends StatefulWidget {
  @override
  _DocumanCategoriesPageState createState() => _DocumanCategoriesPageState();
}

class _DocumanCategoriesPageState extends State<DocumanCategoriesPage> {
  @override
  Widget build(BuildContext context) {
    Future<List<DocumanCategory>> _getDocumanCategories() async {
      try {
        var response = await http.get(
            Uri.parse("https://gemas.com.tr/api/v1/${"langCode".tr}/dokuman-kategori"));
        if (response.statusCode == 200) {
          return (json.decode(response.body) as List).map((documanCategoryMap) =>
              DocumanCategory.fromJson(documanCategoryMap)).toList();
        } else {
          throw Exception("Bağlantı hatası: ${response.statusCode}");
        }
      } catch (e) {
        await Future.delayed(Duration(seconds: 15));
        return _getDocumanCategories();
      }
    }

    return Scaffold(
      appBar: GemasAppBar(title: "documentCategories".tr),
      body: FutureBuilder(
        future: _getDocumanCategories(),
        builder: (BuildContext context, AsyncSnapshot<List<DocumanCategory>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                var category = snapshot.data![index];
                return ListTile(
                  leading: Icon(Icons.category),
                  title: Text(snapshot.data![index].ad),
                  trailing: Icon(Icons.arrow_right),
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
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
