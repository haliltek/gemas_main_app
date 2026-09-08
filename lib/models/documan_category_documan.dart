// To parse this JSON data, do
//
//     final documanCategoryDocuman = documanCategoryDocumanFromJson(jsonString);

import 'dart:convert';

List<DocumanCategoryDocuman> documanCategoryDocumanFromJson(String str) => List<DocumanCategoryDocuman>.from(json.decode(str).map((x) => DocumanCategoryDocuman.fromJson(x)));

String documanCategoryDocumanToJson(List<DocumanCategoryDocuman> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DocumanCategoryDocuman {
  DocumanCategoryDocuman({
    required this.name,
    required this.file,
    required this.urun,
  });

  String name;
  String file;
  Urun urun;

  factory DocumanCategoryDocuman.fromJson(Map<String, dynamic> json) => DocumanCategoryDocuman(
    name: json["name"] == null ? null : json["name"],
    file: json["file"] == null ? null : json["file"],
    urun: json["urun"] = Urun.fromJson(json["urun"]),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "file": file,
    "urun": urun.toJson(),
  };
}

class Urun {
  Urun({
    required this.id,
    required this.yeni,
    required this.durum,
    required this.ad,
    required this.slug,
    required this.aciklama,
    required this.alinti,
    this.createdAt,
    this.updatedAt,
    this.title,
    this.keywords,
    this.description,
    this.badge,
    required this.translations,
  });

  int id;
  String yeni;
  String durum;
  String ad;
  String slug;
  String aciklama;
  String alinti;
  dynamic createdAt;
  dynamic updatedAt;
  dynamic title;
  dynamic keywords;
  dynamic description;
  dynamic badge;
  List<Translation> translations;

  factory Urun.fromJson(Map<String, dynamic> json) => Urun(
    id: json["id"] == null ? null : json["id"],
    yeni: json["yeni"] == null ? '' : json["yeni"],
    durum: json["durum"] == null ? '' : json["durum"],
    createdAt: json["created_at"] == null ? DateTime.now() : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? DateTime.now() : DateTime.parse(json["updated_at"]),
    ad: json["ad"] == null ? '' : json["ad"],
    slug: json["slug"] == null ? '' : json["slug"],
    aciklama: json["aciklama"] == null ? '' : json["aciklama"],
    alinti: json["alinti"] == null ? '' : json["alinti"],
    title: json["title"] == null ? '' : json["title"],
    keywords: json["keywords"] == null ? '' : json["keywords"],
    description: json["description"] == null ? '' : json["description"],
    badge: json["badge"] == null ? '' : json["badge"],
    translations: json["translations"] = List<Translation>.from(json["translations"].map((x) => Translation.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "yeni": yeni,
    "durum": durum,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "ad": ad,
    "slug": slug,
    "aciklama": aciklama,
    "alinti": alinti,
    "title": title,
    "keywords": keywords,
    "description": description,
    "badge": badge,
    "translations": translations.map((x) => x.toJson()).toList(),
  };
}

class Translation {
  Translation({
    required this.id,
    required this.urunId,
    required this.locale,
    required this.ad,
    required this.slug,
    required this.aciklama,
    required this.alinti,
    this.title,
    this.keywords,
    this.description,
    this.badge,
  });

  int id;
  String urunId;
  Locale locale;
  String ad;
  String slug;
  String aciklama;
  String alinti;
  dynamic title;
  dynamic keywords;
  dynamic description;
  dynamic badge;

  factory Translation.fromJson(Map<String, dynamic> json) => Translation(
    id: json["id"] == null ? null : json["id"],
    urunId: json["urun_id"] == null ? null : json["urun_id"],
    locale: json["locale"] == null ? Locale.TR : localeValues.map[json["locale"]] ?? Locale.TR,
    ad: json["ad"] == null ? '' : json["ad"],
    slug: json["slug"] == null ? '' : json["slug"],
    aciklama: json["aciklama"] == null ? '' : json["aciklama"],
    alinti: json["alinti"] == null ? '' : json["alinti"],
    title: json["title"] == null ? '' : json["title"],
    keywords: json["keywords"] == '' ? null : json["keywords"],
    description: json["description"] == '' ? null : json["description"],
    badge: json["badge"] == null ? '' : json["badge"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "urun_id": urunId,
    "locale": localeValues.reverse[locale],
    "ad": ad,
    "slug": slug,
    "aciklama": aciklama,
    "alinti": alinti,
    "title": title,
    "keywords": keywords,
    "description": description,
    "badge": badge,
  };
}

enum Locale { EN, FR, TR, ES }

final localeValues = EnumValues({
  "en": Locale.EN,
  "es": Locale.ES,
  "fr": Locale.FR,
  "tr": Locale.TR
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap = {};

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap.isEmpty) {
      reverseMap = map.map((k, v) => MapEntry(v, k));
    }
    return reverseMap;
  }
}

