import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Constants {
  static const String DOMAIN = "https://gemas.com.tr/";
  static const String BASE_API_URL = 'https://gemas.com.tr/api/v1/';
  static const Color gemasPrimaryTextColor=  Colors.white;
  static const Color gemasPrimaryBgColor=  Color.fromRGBO(33, 71, 139, 1);
}

String removeAllHtmlTags(String htmlText) {
  RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

  return htmlText.replaceAll(exp, '');
}

final Map<String, String> _pdfCatalogueCache = {};

Future<String> getPdfCatalogue(String locale) async {
  if (_pdfCatalogueCache.containsKey(locale)) {
    return _pdfCatalogueCache[locale]!;
  }

  String lang;

  switch (locale) {
    case "tr_TR":
      lang = "tr";
      break;
    case "ru_RU":
      lang = "ru";
      break;
    case "es_ES":
      lang = "es";
      break;
    case "fr_FR":
      lang = "fr";
      break;
    case "en_US":
      lang = "en";
      break;
    default:
      lang = "en";
  }

  String pdfUrl = "https://gemas.com.tr/download/app_catalogue/$lang/gemas_current_${lang}_catalogue.pdf";
  const defaultUrl = "https://gemas.com.tr/download/app_catalogue/en/gemas_current_en_catalogue.pdf";

  try {
    final response = await http.head(Uri.parse(pdfUrl)).timeout(const Duration(seconds: 3));
    if (response.statusCode == 200) {
      _pdfCatalogueCache[locale] = pdfUrl;
      return pdfUrl;
    } else {
      _pdfCatalogueCache[locale] = defaultUrl;
      return defaultUrl;
    }
  } catch (e) {
    _pdfCatalogueCache[locale] = defaultUrl;
    return defaultUrl;
  }
}
