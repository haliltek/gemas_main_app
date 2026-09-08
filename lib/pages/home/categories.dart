import 'package:flutter/material.dart';
import 'package:gemas/models/category.dart';
import 'package:gemas/pages/category.dart';
import 'package:gemas/utils/responsive.dart';

Row buildCategories(BuildContext context, List<Category> categoryList) {
  Responsive responsive = Responsive(context);

  return Row(
    children: [
      Container(
        color: Colors.white,
        margin: EdgeInsets.all(0),
        width: responsive.wp(100),
        height: responsive.hp(5),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categoryList.length,
          itemBuilder: (context, index) {
            var category = categoryList[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ActionChip(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                label: Text(
                  category.ad,
                  style: TextStyle(fontSize: responsive.dp(1.5)),
                ),
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryPage(category: category),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    ],
  );
}
