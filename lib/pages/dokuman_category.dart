import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:gemas/models/documan_category_documan.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gemas/widgets/gemas_app_bar.dart';

class DocumanCategoryPage extends StatelessWidget {
  final int catID;
  final String catName;

  const DocumanCategoryPage({required this.catID, required this.catName}) : super();

  @override
  Widget build(BuildContext context) {
    Future<List<DocumanCategoryDocuman>> _getDocumanCategoryDocuman() async {
      try {
        var response = await http.get(Uri.parse("https://gemas.com.tr/api/v1/${"langCode".tr}/dokumanlar/${catID.toString()}"));
        if (response.statusCode == 200) {
          return (json.decode(response.body) as List).map((documanCategoryDocumanMap) => DocumanCategoryDocuman.fromJson(documanCategoryDocumanMap)).toList();
        } else {
          throw Exception("Bağlantı hatası: ${response.statusCode}");
        }
      } catch (e) {
        await Future.delayed(Duration(seconds: 15));
        return _getDocumanCategoryDocuman();
      }
    }

    return Scaffold(
      appBar: GemasAppBar(title: catName.tr),
      body: FutureBuilder(
        future: _getDocumanCategoryDocuman(),
        builder: (BuildContext context, AsyncSnapshot<List<DocumanCategoryDocuman>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              physics: ClampingScrollPhysics(),
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                var documan = snapshot.data![index];
                if (documan.urun.ad != null) {
                  return Card(
                    elevation: 0,
                    child: ListTile(
                      leading: Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                      title: documan.name != null ? Text(documan.name) : Text(''),
                      subtitle: documan.urun.ad == null ? Text('yok') : Text(documan.urun.ad),
                      trailing: Icon(Icons.arrow_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (_) => PDFViewerCachedFromUrl(url: documan.file, title: documan.name),
                        ),
                      ),
                    ),
                  );
                } else {
                  return null;
                }
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
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
