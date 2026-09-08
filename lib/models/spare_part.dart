// To parse this JSON data, do
//
//     final sparePart = sparePartFromJson(jsonString);

import 'dart:convert';

List<SparePart> sparePartFromJson(String str) => List<SparePart>.from(json.decode(str).map((x) => SparePart.fromJson(x)));

String sparePartToJson(List<SparePart> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SparePart {
  SparePart({
    required this.id,
    required this.kategoriId,
    required this.malzemeId,
    required this.image,
    required this.durum,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    required this.malzeme,
  });

  dynamic id;
  dynamic kategoriId;
  dynamic malzemeId;
  String image;
  dynamic durum;
  dynamic deletedAt;
  dynamic createdAt;
  dynamic updatedAt;
  Malzeme malzeme;

  factory SparePart.fromJson(Map<String, dynamic> json) => SparePart(
        id: json["id"] == null ? null : json["id"],
        kategoriId: json["kategori_id"] == null ? null : json["kategori_id"],
        malzemeId: json["malzeme_id"] == null ? null : json["malzeme_id"],
        image: json["image"] == null ? null : json["image"],
        durum: json["durum"] == null ? null : json["durum"],
        deletedAt: json["deleted_at"] == null ? null : DateTime.parse(json["deleted_at"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        malzeme: json["malzeme"] = Malzeme.fromJson(json["malzeme"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id = id,
        "kategori_id": kategoriId = kategoriId,
        "malzeme_id": malzemeId = malzemeId,
        "image": image = image,
        "durum": durum = durum,
        "deleted_at": deletedAt == null ? null : deletedAt,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "malzeme": malzeme.toJson(),
      };
}

class Malzeme {
  Malzeme({
    required this.id,
    required this.stokKodu,
    this.paket,
    this.agirlik,
    this.hacim,
    required this.image,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.aciklama,
    this.fiyat,
    required this.translations,
  });

  dynamic id;
  dynamic stokKodu;
  dynamic paket;
  dynamic agirlik;
  dynamic hacim;
  String image;
  dynamic deletedAt;
  dynamic createdAt;
  dynamic updatedAt;
  dynamic aciklama;
  dynamic fiyat;
  List<Translation> translations;

  factory Malzeme.fromJson(Map<String, dynamic> json) => Malzeme(
        id: json["id"] == null ? null : json["id"],
        stokKodu: json["stok_kodu"] == null ? '' : json["stok_kodu"],
        paket: json["paket"] == null ? 0 : json["paket"],
        agirlik: json["agirlik"] == null ? 0.0 : json["agirlik"],
        hacim: json["hacim"] == null ? 0.0  : json["hacim"],
        image: json["image"] == null ? '' : json["image"],
        deletedAt: json["deleted_at"] == null ? '' : json["deleted_at"],
        createdAt: json["created_at"] == null ? '' : json["created_at"],
        updatedAt: json["updated_at"] == null ? '' : json["updated_at"],
        aciklama: json["aciklama"] == null ? '' : json["aciklama"],
        fiyat: json["fiyat"] == null ? 0 : json["fiyat"],
        translations: json["translations"] = List<Translation>.from(json["translations"].map((x) => Translation.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id = id,
        "stok_kodu": stokKodu == null ? null : stokKodu,
        "paket": paket == null ? null : paket,
        "agirlik": agirlik == null ? null : agirlik,
        "hacim": hacim == null ? null : hacim,
        "image": image == null ? null : image,
        "deleted_at": deletedAt,
        "created_at": createdAt == null ? null : createdAt.toIso8601String(),
        "updated_at": updatedAt == null ? null : updatedAt.toIso8601String(),
        "aciklama": aciklama == null ? null : aciklama,
        "fiyat": fiyat == null ? null : fiyat,
        "translations": List<dynamic>.from(translations.map((x) => x.toJson())),
      };
}

class Translation {
  Translation({
    required this.id,
    required this.malzemeId,
    required this.locale,
    this.aciklama,
    this.fiyat,
  });

  int id;
  dynamic malzemeId;
  Locale? locale;
  dynamic aciklama;
  dynamic fiyat;

  factory Translation.fromJson(Map<String, dynamic> json) => Translation(
        id: json["id"],
        malzemeId: json["malzeme_id"] == null ? '' : json["malzeme_id"],
        locale: json["locale"] == null ? Locale.TR : localeValues.map[json["locale"]],
        aciklama: json["aciklama"] == null ? '' : json["aciklama"],
        fiyat: json["fiyat"] == null ? '' : json["fiyat"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "malzeme_id": malzemeId == null ? null : malzemeId,
        "locale": locale == null ? null : localeValues.reverse[locale],
        "aciklama": aciklama == null ? null : aciklama,
        "fiyat": fiyat == null ? null : fiyat,
      };
}

enum Locale { EN, TR }

final localeValues = EnumValues({"en": Locale.EN, "tr": Locale.TR});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    return reverseMap;
  }
}
