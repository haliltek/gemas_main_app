import 'package:flutter/material.dart';
import 'package:gemas/constants.dart';
import 'package:gemas/pages/dokuman_category.dart';
import 'package:gemas/utils/responsive.dart';
import 'package:get/get.dart';

Stack buildCatalogueBanner(BuildContext context) {
  Responsive responsive = Responsive(context);
  return Stack(
    children: [
      Image.asset(
        "assets/images/banner.jpg",
        fit: BoxFit.contain,
      ),
      Positioned(
        bottom: 10,
        child: Column(
          children: [
            Container(
                width: MediaQuery.of(context).size.width,
                child: Text('catalogueIsReady'.tr, style: TextStyle(fontSize: responsive.dp(2.5), color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
            Container(
              child: ElevatedButton(
                onPressed: () async {
                  final url = await getPdfCatalogue(Get.locale.toString());
                  Navigator.push(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (_) => PDFViewerCachedFromUrl(url: url, title: "catalogueIsReady".tr),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'download'.tr,
                    style: TextStyle(fontSize: responsive.dp(1.7), color: Colors.blue[850], fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
