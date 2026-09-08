import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:gemas/constants.dart';
import 'package:gemas/models/product.dart';
import 'package:get/get.dart';
import 'package:gemas/widgets/gemas_app_bar.dart';

class ProductPage extends StatelessWidget {
  final Product? product;
  final int? productId;

  const ProductPage({this.product, this.productId}) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GemasAppBar(title: product!.ad),
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          children: [
            Container(
              height: 300,
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 30),
              child: product!.urunFoto!.length > 0
                  ? Swiper(
                      autoplay: product!.urunFoto!.length > 1 ? true : false,
                      itemCount: product!.urunFoto!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: CachedNetworkImage(
                            imageUrl: Constants.DOMAIN + product!.urunFoto![index].foto,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                      viewportFraction: 0.8,
                      scale: 0.8,
                      //pagination: SwiperPagination(),
                    )
                  : Image.asset("assets/images/unnamed.png"),
            ),
            Card(
              elevation: 0,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      product!.ad,
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  product!.aciklama != null
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: HtmlWidget(product!.aciklama),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text("descNotFound".tr),
                        )
                ],
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'modelList'.tr,
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: product!.malzemeler?.length == 0 ? 0 : product!.malzemeler?.length,
                    itemBuilder: (context, index) {
                      var malzeme = product!.malzemeler![index];
                      return Card(
                        elevation: 0,
                        child: ExpansionTile(
                          title: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                malzeme.stokKodu.toString(),
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                malzeme.aciklama == "" ? "" : malzeme.aciklama,
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width * .25,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text("price".tr, style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text("pieces".tr, style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text("weight".tr, style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text("volume".tr, style: TextStyle(fontWeight: FontWeight.bold))
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width * .75,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          malzeme.fiyat != null ? Text(": " + malzeme.fiyat.toString() + " €") : Text(":"),
                                          malzeme.paket != null ? Text(": " + malzeme.paket.toString()) : Text(":"),
                                          malzeme.agirlik != null ? Text(": " + malzeme.agirlik.toString() + " Kg") : Text(":"),
                                          malzeme.hacim != null ? Text(": " + malzeme.hacim.toString() + " m³") : Text(":"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Card(
              elevation: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'documentList'.tr,
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  ListView.builder(
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: product!.dokumanlar?.length == 0 ? 0 : product!.dokumanlar?.length,
                    itemBuilder: (context, index) {
                      var dokuman = product!.dokumanlar![index];

                      return dokuman.ad != null
                          ? Card(
                              elevation: 0,
                              child: ListTile(
                                leading: Icon(Icons.picture_as_pdf),
                                title: Text(dokuman.ad),
                                trailing: Icon(Icons.file_download),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                    builder: (_) => PDFViewerCachedFromUrl(url: Constants.DOMAIN + dokuman.file, title: dokuman.ad),
                                  ),
                                ),
                              ),
                            )
                          : Text('');
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PDFViewerCachedFromUrl extends StatelessWidget {
  const PDFViewerCachedFromUrl({required this.url, required this.title}) : super();

  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GemasAppBar(title: title),
      body: const PDF().cachedFromUrl(
        url,
        placeholder: (double progress) => Center(child: Text('$progress %')),
        errorWidget: (dynamic error) => Center(child: Text(error.toString())),
      ),
    );
  }
}
