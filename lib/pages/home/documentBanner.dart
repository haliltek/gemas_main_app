import 'package:flutter/material.dart';
import 'package:gemas/pages/dokuman_categories.dart';
import 'package:gemas/utils/responsive.dart';
import 'package:get/get.dart';

Container buildDocumentBanner(BuildContext context) {
  Responsive responsive = Responsive(context);

  return Container(
    padding: EdgeInsets.all(20),
    width: responsive.wp(100),
    decoration: BoxDecoration(color: Colors.purple),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb,
            color: Colors.white,
            size: responsive.dp(7.0),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Text('documents'.tr.toUpperCase(),
                style: TextStyle(
                    fontSize: responsive.dp(4.0),
                    fontWeight: FontWeight.bold,
                    color: Colors.white),),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Text(
              "documentDesc".tr,
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.white, fontSize: responsive.dp(1.7),),
            ),
          ),
          ElevatedButton(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'view'.tr,
                style: TextStyle(fontSize: responsive.dp(1.7),),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DocumanCategoriesPage(),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
