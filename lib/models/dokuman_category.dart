// To parse this JSON data, do
//
//     final documanCategory = documanCategoryFromJson(jsonString);

import 'dart:convert';

List<DocumanCategory> documanCategoryFromJson(String str) => List<DocumanCategory>.from(json.decode(str).map((x) => DocumanCategory.fromJson(x)));

String documanCategoryToJson(List<DocumanCategory> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));


class DocumanCategory {
  DocumanCategory({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.ad,
    required this.slug,
    required this.translations,
  });

  int id;
  DateTime createdAt;
  DateTime updatedAt;
  String ad;
  String slug;
  List<Translation> translations;

  factory DocumanCategory.fromJson(Map<String, dynamic> json) => DocumanCategory(
    id: json["id"] ?? 0,
    createdAt: DateTime.parse(json["created_at"] ?? DateTime.now().toString()),
    updatedAt: DateTime.parse(json["updated_at"] ?? DateTime.now().toString()),
    ad: json["ad"] ?? "",
    slug: json["slug"] ?? "",
    translations: json["translations"] == null
        ? []
        : List<Translation>.from(
        json["translations"].map((x) => Translation.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "ad": ad,
    "slug": slug,
    "translations": List<dynamic>.from(translations.map((x) => x.toJson())),
  };
}

class Translation {
  Translation({
    required this.id,
    required this.locale,
    required this.dokumanKategoriId,
    required this.ad,
    required this.slug,
  });

  int id;
  String locale;
  String dokumanKategoriId;
  String ad;
  String slug;

  factory Translation.fromJson(Map<String, dynamic> json) => Translation(
    id: json["id"] ?? 0,
    locale: json["locale"] ?? "",
    dokumanKategoriId: json["dokuman_kategori_id"] ?? "",
    ad: json["ad"] ?? "",
    slug: json["slug"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "locale": locale,
    "dokuman_kategori_id": dokumanKategoriId,
    "ad": ad,
    "slug": slug,
  };
}

