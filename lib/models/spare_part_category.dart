// To parse this JSON data, do
//
//     final sparePartCategory = sparePartCategoryFromJson(jsonString);

import 'dart:convert';

List<SparePartCategory> sparePartCategoryFromJson(String str) =>
    List<SparePartCategory>.from(json.decode(str).map((x) => SparePartCategory.fromJson(x)));

String sparePartCategoryToJson(List<SparePartCategory> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SparePartCategory {
  SparePartCategory({
    required this.id,
    required this.image,
    this.ustId,
    required this.durum,
    required this.createdAt,
    required this.updatedAt,
    required this.yedekParcaCount,
    required this.ad,
    required this.slug,
    this.title,
    this.keywords,
    this.description,
    required this.translations,
  });

  dynamic id;
  String image;
  dynamic ustId;
  dynamic durum;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic yedekParcaCount;
  String ad;
  String slug;
  dynamic title;
  dynamic keywords;
  dynamic description;
  List<Translation>? translations; // Change to List<Translation>?

  factory SparePartCategory.fromJson(Map<String, dynamic> json) => SparePartCategory(
    id: json["id"],
    image: json["image"],
    ustId: json["ust_id"] == null ? '' : json["ust_id"],
    durum: json["durum"],
    createdAt: json["created_at"] = DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] = DateTime.parse(json["updated_at"]),
    yedekParcaCount: json["yedek_parca_count"],
    ad: json["ad"],
    slug: json["slug"],
    title: json["title"],
    keywords: json["keywords"],
    description: json["description"],
    translations: json["translations"] == null ? [] : List<Translation>.from(json["translations"].map((x) => Translation.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id = id,
    "image": image = image,
    "ust_id": ustId,
    "durum": durum = durum,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "yedek_parca_count": yedekParcaCount = yedekParcaCount,
    "ad": ad = ad,
    "slug": slug = slug,
    "title": title,
    "keywords": keywords,
    "description": description,
    "translations": translations == null ? null : List<dynamic>.from(translations!.map((x) => x.toJson())),
  };
}

class Translation {
  Translation({
    required this.id,
    required this.kategoriId,
    required this.locale,
    required this.ad,
    required this.slug,
    this.title,
    this.keywords,
    this.description,
  });

  dynamic id;
  dynamic kategoriId;
  Locale locale;
  String ad;
  String slug;
  dynamic title;
  dynamic keywords;
  dynamic description;

  factory Translation.fromJson(Map<String, dynamic> json) => Translation(
    id: json["id"] = json["id"],
    kategoriId: json["kategori_id"] == null ? null : json["kategori_id"],
    locale: json["locale"] = localeValues.map[json["locale"]]!,
    ad: json["ad"] == null ? '' : json["ad"],
    slug: json["slug"] == null ? '' : json["slug"],
    title: json["title"] == null ? '' : json["title"],
    keywords: json["keywords"] == null ? '' : json["keywords"],
    description: json["description"] == null ? '' : json["description"],
  );

  Map<String, dynamic> toJson() => {
    "id": id = id,
    "kategori_id": kategoriId = kategoriId,
    "locale": localeValues.reverse[locale],
    "ad": ad = ad,
    "slug": slug = slug,
    "title": title == null ? '' : title,
    "keywords": keywords == null ? '' : keywords,
    "description": description == null ? '' : description,
  };
}

enum Locale { TR, EN, FR }

final localeValues = EnumValues({
  "en": Locale.EN,
  "fr": Locale.FR,
  "tr": Locale.TR
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    return reverseMap;
  }
}
