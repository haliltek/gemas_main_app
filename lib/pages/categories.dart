import 'package:flutter/material.dart';
import 'package:gemas/constants.dart';
import 'package:gemas/models/category.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gemas/widgets/gemas_app_bar.dart';

import 'category.dart';

class CategoriesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future<List<Category>> _getCategoryList() async {
      try {
        var response = await http.get(Uri.parse("https://gemas.com.tr/api/v1/${"langCode".tr}/categoriesV2"));
        if (response.statusCode == 200) {
          return (json.decode(response.body) as List)
              .map((categoryMap) => Category.fromJson(categoryMap))
              .toList();
        } else {
          throw Exception("Bağlantı hatası: ${response.statusCode}");
        }
      } catch (e) {
        await Future.delayed(Duration(seconds: 15));
        return _getCategoryList();
      }
    }

    return Scaffold(
      appBar: GemasAppBar(title: 'categories'.tr),
      body: FutureBuilder(
        future: _getCategoryList(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Category>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              physics: ClampingScrollPhysics(),
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                var category = snapshot.data![index];
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
                      leading: Container(
                        width: 90,
                        child: category.image != null
                            ? Image.network(Constants.DOMAIN + category.image, fit: BoxFit.contain)
                            //CachedNetworkImage(imageUrl: Constants.DOMAIN + category.image, fit: BoxFit.contain)
                            : Image.asset("assets/images/unnamed.png", fit: BoxFit.fill),
                      ),
                      title: Text(
                        category.ad,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      trailing: CircleAvatar(
                        child: Text(category.urunlerCount.toString()),
                      ),
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
