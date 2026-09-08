import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:gemas/models/documan_category_documan.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gemas/widgets/gemas_app_bar.dart';

class DocumanCategoryPage extends StatefulWidget {
  final int catID;
  final String catName;

  const DocumanCategoryPage({Key? key, required this.catID, required this.catName}) : super(key: key);

  @override
  State<DocumanCategoryPage> createState() => _DocumanCategoryPageState();
}

class _DocumanCategoryPageState extends State<DocumanCategoryPage> {
  late Future<List<DocumanCategoryDocuman>> _documanFuture;

  @override
  void initState() {
    super.initState();
    _documanFuture = _getDocumanCategoryDocuman();
  }

  Future<List<DocumanCategoryDocuman>> _getDocumanCategoryDocuman({int retryCount = 0}) async {
    try {
      final response = await http
          .get(Uri.parse("https://gemas.com.tr/api/v1/${"langCode".tr}/dokumanlar/${widget.catID}"))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((documanCategoryDocumanMap) => DocumanCategoryDocuman.fromJson(documanCategoryDocumanMap))
            .toList();
      } else {
        throw Exception("Bağlantı hatası: ${response.statusCode}");
      }
    } catch (e) {
      if (retryCount < 2) {
        await Future.delayed(const Duration(seconds: 3));
        return _getDocumanCategoryDocuman(retryCount: retryCount + 1);
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GemasAppBar(title: widget.catName.tr),
      body: FutureBuilder<List<DocumanCategoryDocuman>>(
        future: _documanFuture,
        builder: (BuildContext context, AsyncSnapshot<List<DocumanCategoryDocuman>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text('tryAgain'.tr.isNotEmpty ? 'tryAgain'.tr : 'Tekrar Deneyin'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _documanFuture = _getDocumanCategoryDocuman();
                      });
                    },
                    child: const Icon(Icons.refresh),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return Center(
              child: Text('noData'.tr.isNotEmpty ? 'noData'.tr : 'Doküman bulunamadı'),
            );
          }

          return ListView.builder(
            physics: const ClampingScrollPhysics(),
            itemCount: data.length,
            itemBuilder: (context, index) {
              var documan = data[index];
              if (documan.urun.ad != null) {
                return Card(
                  elevation: 0,
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                    title: Text(documan.name),
                    subtitle: Text(documan.urun.ad.isNotEmpty ? documan.urun.ad : 'yok'),
                    trailing: const Icon(Icons.arrow_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<dynamic>(
                        builder: (_) => PDFViewerCachedFromUrl(url: documan.file, title: documan.name),
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          );
        },
      ),
    );
  }
}

class PDFViewerCachedFromUrl extends StatelessWidget {
  const PDFViewerCachedFromUrl({Key? key, required this.url, required this.title}) : super(key: key);

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
