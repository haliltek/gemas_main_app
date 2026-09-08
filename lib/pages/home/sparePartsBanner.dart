import 'package:flutter/material.dart';
import 'package:gemas/pages/spare_parts_categories.dart';
import 'package:gemas/utils/responsive.dart';
import 'package:get/get.dart';

Container buildSparePartsBanner(BuildContext context) {
  Responsive responsive = Responsive(context);
  
  return Container(
    padding: EdgeInsets.all(20),
    width: responsive.wp(100),
    decoration: BoxDecoration(color: Colors.amber),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings,
            color: Colors.white,
            size: responsive.dp(7.0),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Text('sparePart'.tr.toUpperCase(), style: TextStyle(fontSize: responsive.dp(4.0), fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Text(
              'sparePartDesc'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: responsive.dp(1.7)),
            ),
          ),
          ElevatedButton(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical:8.0),
              child: Text(
                'view'.tr, style: TextStyle(fontSize: responsive.dp(1.7)),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SparePartsCategories(),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}