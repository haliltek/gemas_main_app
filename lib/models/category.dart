import 'dart:convert';

List<Category> categoryFromJson(String str) => List<Category>.from(json.decode(str).map((x) => Category.fromJson(x)));

String categoryToJson(List<Category> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Category {
  Category({
    required this.id,
    required this.image,
    required this.ustId,
    required this.durum,
    required this.createdAt,
    required this.updatedAt,
    required this.urunlerCount,
    required this.ad,
    required this.slug,
    required this.title,
    this.keywords,
    this.description,
    required this.altKategoriler,
    required this.translations,
  });

  dynamic id;
  String image;
  dynamic ustId;
  dynamic durum;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic urunlerCount;
  String ad;
  String slug;
  String title;
  dynamic keywords;
  dynamic description;
  List<Category> altKategoriler;
  List<Translation> translations;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"] == null ? 0 : json["id"],
    image: json["image"] == null ? "" : json["image"],
    ustId: json["ust_id"] == null ? 0 : json["ust_id"],
    durum: json["durum"] == null ? 1 : json["durum"],
    createdAt: DateTime.parse(json["created_at"] ?? ""),
    updatedAt: DateTime.parse(json["updated_at"] ?? ""),
    urunlerCount: json["urunler_count"] == null ? "" : json["urunler_count"],
    ad: json["ad"] == null ? "" : json["ad"],
    slug: json["slug"] == null ? "" : json["slug"],
    title: json["title"] == null ? "" : json["title"],
    keywords: json["keywords"],
    description: json["description"],
    altKategoriler: json["alt_kategoriler"] == null ? [] : List<Category>.from(json["alt_kategoriler"].map((x) => Category.fromJson(x))),
    translations: json["translations"] == null ? [] : List<Translation>.from(json["translations"].map((x) => Translation.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image": image,
    "ust_id": ustId,
    "durum": durum,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "urunler_count": urunlerCount,
    "ad": ad,
    "slug": slug,
    "title": title,
    "keywords": keywords,
    "description": description,
    "alt_kategoriler": List<dynamic>.from(altKategoriler.map((x) => x.toJson())),
    "translations": List<dynamic>.from(translations.map((x) => x.toJson())),
  };
}

class Translation {
  Translation({
    required this.id,
    required this.kategoriId,
    required this.ad,
    required this.slug,
    required this.title,
    this.keywords,
    this.description,
  });

  dynamic id;
  dynamic kategoriId;
  String ad;
  String slug;
  String title;
  dynamic keywords;
  dynamic description;

  factory Translation.fromJson(Map<String, dynamic> json) => Translation(
    id: json["id"] == null ? 0 : json["id"],
    kategoriId: json["kategori_id"] == null ? "" : json["kategori_id"],
    ad: json["ad"] == null ? "" : json["ad"],
    slug: json["slug"] == null ? "" : json["slug"],
    title: json["title"] == null ? "" : json["title"],
    keywords: json["keywords"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "kategori_id": kategoriId,
    "ad": ad,
    "slug": slug,
    "title": title,
    "keywords": keywords,
    "description": description,
  };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
