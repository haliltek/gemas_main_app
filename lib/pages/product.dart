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
  @override
  Widget build(BuildContext context) {
    final currentProduct = product;
    final title = currentProduct?.ad ?? '';
    final photos = currentProduct?.urunFoto ?? [];
    final materials = currentProduct?.malzemeler ?? [];
    final documents = currentProduct?.dokumanlar ?? [];

    return Scaffold(
      appBar: GemasAppBar(title: title),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            Container(
              height: 300,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: photos.isNotEmpty
                  ? Swiper(
                      autoplay: photos.length > 1,
                      itemCount: photos.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: CachedNetworkImage(
                            imageUrl: Constants.DOMAIN + photos[index].foto,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) =>
                                Image.asset("assets/images/unnamed.png", fit: BoxFit.cover),
                          ),
                        );
                      },
                      viewportFraction: 0.8,
                      scale: 0.8,
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
                      title,
                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  (currentProduct != null && currentProduct.aciklama.isNotEmpty)
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: HtmlWidget(currentProduct.aciklama),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text("descNotFound".tr),
                        )
                ],
              ),
            ),
            const SizedBox(height: 10),
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
                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: materials.length,
                    itemBuilder: (context, index) {
                      var malzeme = materials[index];
                      return Card(
                        elevation: 0,
                        child: ExpansionTile(
                          title: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                malzeme.stokKodu.toString(),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                malzeme.aciklama == "" ? "" : malzeme.aciklama,
                                style: const TextStyle(fontSize: 14),
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
                                        Text("price".tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text("pieces".tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text("weight".tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text("volume".tr, style: const TextStyle(fontWeight: FontWeight.bold))
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
                                          malzeme.fiyat != null ? Text(": " + malzeme.fiyat.toString() + " €") : const Text(":"),
                                          malzeme.paket != null ? Text(": " + malzeme.paket.toString()) : const Text(":"),
                                          malzeme.agirlik != null ? Text(": " + malzeme.agirlik.toString() + " Kg") : const Text(":"),
                                          malzeme.hacim != null ? Text(": " + malzeme.hacim.toString() + " m³") : const Text(":"),
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
                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  ListView.builder(
                    physics: const ClampingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      var dokuman = documents[index];

                      return dokuman.ad.isNotEmpty
                          ? Card(
                              elevation: 0,
                              child: ListTile(
                                leading: const Icon(Icons.picture_as_pdf),
                                title: Text(dokuman.ad),
                                trailing: const Icon(Icons.file_download),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                    builder: (_) => PDFViewerCachedFromUrl(url: Constants.DOMAIN + dokuman.file, title: dokuman.ad),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink();
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
