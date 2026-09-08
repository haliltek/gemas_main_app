import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gemas/constants.dart';
import 'package:gemas/models/spare_part_category.dart';
import 'package:gemas/pages/spare_part_by_category.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:gemas/widgets/gemas_app_bar.dart';

class SparePartsCategories extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future<List<SparePartCategory>> _getSpareParts() async {
      try {
        final response = await http.get(
          Uri.parse("https://gemas.com.tr/api/v1/${"langCode".tr}/spare_part_categories"),
        );
        if (response.statusCode == 200) {
          return (json.decode(response.body) as List)
              .map((sparePartCategoryMap) => SparePartCategory.fromJson(sparePartCategoryMap))
              .toList();
        } else {
          throw Exception(
              "ABCD [spare_parts_categories.dart] Bağlantı hatası: ${response.statusCode}");
        }
      } catch (error) {
        await Future.delayed(Duration(seconds: 15));
        return _getSpareParts();
      }
    }

    return Scaffold(
      appBar: GemasAppBar(title: 'partCategories'.tr),
      body: FutureBuilder(
        future: _getSpareParts(),
        builder: (BuildContext context, AsyncSnapshot<List<SparePartCategory>> snapshot) {
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
                      MaterialPageRoute(
                        builder: (context) => SparePartByCategoryPage(category: category),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 0,
                    child: ListTile(
                      leading: Container(
                        height: 80,
                        width: 90,
                        child: category.image != null
                            ? CachedNetworkImage(
                                imageUrl: Constants.DOMAIN + category.image, fit: BoxFit.contain)
                            : Image.asset("assets/images/unnamed.png", fit: BoxFit.fill),
                      ),
                      title: Text(
                        category.ad,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      trailing: CircleAvatar(
                        child: Text(category.yedekParcaCount.toString()),
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
