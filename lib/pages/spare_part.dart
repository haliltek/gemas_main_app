import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:gemas/widgets/gemas_app_bar.dart';

class SparePartDetailPage extends StatefulWidget {
  final int id;
  final String stokKodu;
  final String aciklama;

  const SparePartDetailPage({
    required this.id,
    required this.stokKodu,
    required this.aciklama,
  }) : super();

  @override
  SparePartDetailPageState createState() => SparePartDetailPageState();
}

class SparePartDetailPageState extends State<SparePartDetailPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(
            "https://gemas.com.tr/${"langCode".tr}/mobil/yedek-parca/urun/${widget.id.toString()}"),
      );
  }

  @override
  Widget build(BuildContext context) {
    // build metodu çağrıldığında da print ile verileri göster
    print("Building SparePartDetailPage...");

    return Scaffold(
      appBar: GemasAppBar(title: widget.stokKodu),
      body: WebViewWidget(controller: controller),
    );
  }
}
