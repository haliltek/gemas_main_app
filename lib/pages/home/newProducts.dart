import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gemas/constants.dart';
import 'package:gemas/models/product.dart';
import 'package:gemas/pages/product.dart';
import 'package:gemas/utils/responsive.dart';

SizedBox buildNewProducts(BuildContext context, List<Product> newProducts) {
  Responsive responsive = Responsive(context);
  return SizedBox(
    height: MediaQuery.of(context).size.height * .32,
    child: ListView.builder(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      scrollDirection: Axis.horizontal,
      itemCount: newProducts.length,
      itemBuilder: (context, index) {
        var urun = newProducts[index];
        return Container(
          width: MediaQuery.of(context).size.width * 0.7,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductPage(product: urun),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: (urun.urunFoto != null && urun.urunFoto!.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: Constants.DOMAIN + urun.urunFoto!.first.foto,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              memCacheWidth: 600,
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/images/unnamed.png',
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              'assets/images/unnamed.png',
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.red,
                          child: Text(
                            'newBadge'.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: responsive.dp(1.2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            urun.ad != '' ? urun.ad : '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: responsive.dp(1.6),
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
