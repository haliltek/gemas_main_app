import 'package:flutter/material.dart';
import 'package:gemas/constants.dart';
import 'package:gemas/pages/categories.dart';
import 'package:gemas/pages/spare_parts_categories.dart';
import 'package:gemas/utils/responsive.dart';
import 'package:get/get.dart';

Container buildTopNavbar(BuildContext context) {
  Responsive responsive = Responsive(context);
  return Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary,
      border: Border(
        top: BorderSide(color: Colors.white, width: 0.2),
        bottom: BorderSide(color: Colors.white, width: 0.2),
      ),
    ),
    height: responsive.dp(5),
    width: MediaQuery.of(context).size.width,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextButton(
          child: Text(
            'products'.tr.toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: responsive.dp(1.5),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CategoriesPage()),
            );
          },
        ),
        TextButton(
          child: Text(
            'sparePart'.tr.toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: responsive.dp(1.5),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SparePartsCategories()),
            );
          },
        ),
      ],
    ),
  );
}
