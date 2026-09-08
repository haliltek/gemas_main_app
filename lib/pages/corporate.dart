import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:gemas/models/kurumsal.dart';
import 'package:gemas/widgets/gemas_app_bar.dart';

class CorporatePage extends StatelessWidget {
  final Corporate corporate;

  const CorporatePage({required this.corporate}) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GemasAppBar(title: corporate.ad),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CachedNetworkImage(imageUrl: corporate.image, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                corporate.ad,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: HtmlWidget(corporate.icerik),
            ),
          ],
        ),
      ),
    );
  }
}
