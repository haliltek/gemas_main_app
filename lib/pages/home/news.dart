import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gemas/models/duyuru.dart';
import 'package:gemas/pages/duyuru.dart';
import 'package:gemas/utils/responsive.dart';
import 'package:get/get.dart';

Padding buildNews(BuildContext context, List<Duyuru> newsList) {
  Responsive responsive = Responsive(context);

  return Padding(
    padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('newsHeader'.tr,
            style: TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18)),
        SizedBox(height: 10),
        Container(
          width: responsive.wp(100.0),
          height: responsive.hp(50.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: newsList.length,
            padding: EdgeInsets.symmetric(horizontal: 20),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              var duyuru = newsList[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DuyuruPage(duyuru: duyuru),
                      ),
                    );
                  },
                  child: CachedNetworkImage(
                    imageUrl: duyuru.image,
                    fit: BoxFit.cover,
                    width: responsive.wp(95.0),
                    height: responsive.hp(100),
                    memCacheWidth: 800,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
