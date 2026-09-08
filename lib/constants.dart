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

Future<String> getPdfCatalogue(String locale) async {
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

  try {
    final response = await http.head(Uri.parse(pdfUrl));
    if (response.statusCode == 200) {
      return pdfUrl;
    } else {
      return "https://gemas.com.tr/download/app_catalogue/en/gemas_current_en_catalogue.pdf";
    }
  } catch (e) {
    return "https://gemas.com.tr/download/app_catalogue/en/gemas_current_en_catalogue.pdf";
  }
}
