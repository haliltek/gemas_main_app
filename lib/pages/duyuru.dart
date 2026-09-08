import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:gemas/models/duyuru.dart';
import 'package:get/get.dart';
import 'package:gemas/widgets/gemas_app_bar.dart';

class DuyuruPage extends StatelessWidget {
  final Duyuru duyuru;

  const DuyuruPage({required this.duyuru}) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GemasAppBar(title: 'news'.tr),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: duyuru.image,
              fit: BoxFit.cover,
            ),
            // check
            duyuru.aciklama != null ? HtmlWidget(duyuru.aciklama!) : Container(),
          ],
        ),
      ),
    );
  }
}
