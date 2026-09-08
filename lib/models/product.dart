// To parse this JSON data, do
//
//     final product = productFromJson(jsonString);

import 'dart:convert';

List<Product> productFromJson(String str) =>
    List<Product>.from(json.decode(str).map((x) => Product.fromJson(x)));

String productToJson(List<Product> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Product {
  Product({
    required this.id,
    required this.yeni,
    required this.durum,
    required this.createdAt,
    required this.updatedAt,
    required this.ad,
    required this.slug,
    required this.aciklama,
    required this.alinti,
    required this.title,
    this.keywords,
    this.description,
    required this.badge,
    required this.urunFoto,
    required this.malzemeler,
    required this.dokumanlar,
    required this.translations,
  });

  dynamic id;
  dynamic yeni;
  dynamic durum;
  DateTime? createdAt; // Nullable DateTime
  DateTime? updatedAt; // Nullable DateTime
  String ad;
  String slug;
  String aciklama;
  String alinti;
  String title;
  String? keywords; // Nullable String
  String? description; // Nullable String
  String badge;
  List<UrunFoto>? urunFoto; // Nullable List<UrunFoto>
  List<Malzemeler>? malzemeler; // Nullable List<Malzemeler>
  List<Dokumanlar>? dokumanlar; // Nullable List<Dokumanlar>
  List<ProductTranslation>? translations; // Nullable List<ProductTranslation>

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"] ?? 0,
    yeni: json["yeni"] ?? "",
    durum: json["durum"] ?? "",
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    ad: json["ad"] ?? "",
    slug: json["slug"] ?? "",
    aciklama: json["aciklama"] ?? "",
    alinti: json["alinti"] ?? "",
    title: json["title"] ?? "",
    keywords: json["keywords"],
    description: json["description"],
    badge: json["badge"] ?? "",
    urunFoto: json["urun_foto"] == null
        ? null
        : List<UrunFoto>.from(json["urun_foto"].map((x) => UrunFoto.fromJson(x))),
    malzemeler: json["malzemeler"] == null
        ? null
        : List<Malzemeler>.from(json["malzemeler"].map((x) => Malzemeler.fromJson(x))),
    dokumanlar: json["dokumanlar"] == null
        ? null
        : List<Dokumanlar>.from(json["dokumanlar"].map((x) => Dokumanlar.fromJson(x))),
    translations: json["translations"] == null
        ? null
        : List<ProductTranslation>.from(
        json["translations"].map((x) => ProductTranslation.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "yeni": yeni,
    "durum": durum,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "ad": ad,
    "slug": slug,
    "aciklama": aciklama,
    "alinti": alinti,
    "title": title,
    "keywords": keywords,
    "description": description,
    "badge": badge,
    "urun_foto": urunFoto == null ? null : List<dynamic>.from(urunFoto!.map((x) => x.toJson())),
    "malzemeler":
    malzemeler == null ? null : List<dynamic>.from(malzemeler!.map((x) => x.toJson())),
    "dokumanlar":
    dokumanlar == null ? null : List<dynamic>.from(dokumanlar!.map((x) => x.toJson())),
    "translations":
    translations == null ? null : List<dynamic>.from(translations!.map((x) => x.toJson())),
  };
}

class Dokumanlar {
  Dokumanlar({
    required this.id,
    required this.file,
    required this.dokumanKategoriId,
    required this.urunId,
    required this.createdAt,
    required this.updatedAt,
    required this.ad,
    required this.translations,
  });

  dynamic id;
  String file;
  dynamic dokumanKategoriId;
  dynamic urunId;
  DateTime? createdAt; // Nullable DateTime
  DateTime? updatedAt; // Nullable DateTime
  String ad;
  List<DokumanlarTranslation>? translations; // Nullable List<DokumanlarTranslation>

  factory Dokumanlar.fromJson(Map<String, dynamic> json) => Dokumanlar(
    id: json["id"] ?? 0, // Provide a default value or handle null as needed
    file: json["file"] ?? "",
    dokumanKategoriId: json["dokuman_kategori_id"] ?? "",
    urunId: json["urun_id"] ?? "",
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    ad: json["ad"] ?? "",
    translations: json["translations"] == null
        ? null
        : List<DokumanlarTranslation>.from(
        json["translations"].map((x) => DokumanlarTranslation.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "file": file,
    "dokuman_kategori_id": dokumanKategoriId,
    "urun_id": urunId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "ad": ad,
    "translations":
    translations == null ? null : List<dynamic>.from(translations!.map((x) => x.toJson())),
  };
}

class DokumanlarTranslation {
  DokumanlarTranslation({
    required this.id,
    required this.dokumanId,
    required this.ad,
  });

  dynamic id;
  dynamic dokumanId;
  String ad;

  factory DokumanlarTranslation.fromJson(Map<String, dynamic> json) => DokumanlarTranslation(
    id: json["id"],
    dokumanId: json["dokuman_id"],
    ad: json["ad"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "dokuman_id": dokumanId,
    "ad": ad,
  };
}

class Malzemeler {
  Malzemeler({
    required this.id,
    required this.stokKodu,
    required this.paket,
    required this.agirlik,
    required this.hacim,
    required this.image,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.aciklama,
    required this.fiyat,
    required this.pivot,
    required this.translations,
  });

  dynamic id;
  String stokKodu;
  dynamic paket;
  dynamic agirlik;
  dynamic hacim;
  String image;
  dynamic deletedAt;
  DateTime createdAt;
  DateTime updatedAt;
  String aciklama;
  String fiyat;
  Pivot? pivot; // Nullable Pivot
  List<MalzemelerTranslation>? translations; // Nullable List<MalzemelerTranslation>

  factory Malzemeler.fromJson(Map<String, dynamic> json) => Malzemeler(
    id: json["id"] ?? 0, // Provide a default value or handle null as needed
    stokKodu: json["stok_kodu"] ?? "",
    paket: json["paket"] ?? 0,
    agirlik: json["agirlik"] ?? 0.0,
    hacim: json["hacim"] ?? 0.0,
    image: json["image"] ?? "",
    deletedAt: json["deleted_at"],
    createdAt: json["created_at"] == null ? DateTime.now() : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? DateTime.now() : DateTime.parse(json["updated_at"]),
    aciklama: json["aciklama"] ?? "",
    fiyat: json["fiyat"] ?? "",
    pivot: json["pivot"] == null ? null : Pivot.fromJson(json["pivot"]),
    translations: json["translations"] == null
        ? null
        : List<MalzemelerTranslation>.from(
        json["translations"].map((x) => MalzemelerTranslation.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "stok_kodu": stokKodu,
    "paket": paket,
    "agirlik": agirlik,
    "hacim": hacim,
    "image": image,
    "deleted_at": deletedAt,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "aciklama": aciklama,
    "fiyat": fiyat,
    "pivot": pivot?.toJson(),
    "translations": translations == null ? null : List<dynamic>.from(translations!.map((x) => x.toJson())),
  };
}

class Pivot {
  Pivot({
    required this.urunId,
    required this.malzemeId,
  });

  dynamic urunId;
  dynamic malzemeId;

  factory Pivot.fromJson(Map<String, dynamic> json) => Pivot(
    urunId: json["urun_id"] ?? "", // Provide a default value or handle null as needed
    malzemeId: json["malzeme_id"] ?? "", // Provide a default value or handle null as needed
  );

  Map<String, dynamic> toJson() => {
    "urun_id": urunId,
    "malzeme_id": malzemeId,
  };
}

class MalzemelerTranslation {
  MalzemelerTranslation({
    required this.id,
    required this.malzemeId,
    required this.aciklama,
    required this.fiyat,
  });

  dynamic id;
  dynamic malzemeId;
  String aciklama;
  String fiyat;

  factory MalzemelerTranslation.fromJson(Map<String, dynamic> json) => MalzemelerTranslation(
    id: json["id"] ?? 0, // Provide a default value or handle null as needed
    malzemeId: json["malzeme_id"] ?? 0, // Provide a default value or handle null as needed
    aciklama: json["aciklama"] ?? "",
    fiyat: json["fiyat"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "malzeme_id": malzemeId,
    "aciklama": aciklama,
    "fiyat": fiyat,
  };
}

class ProductTranslation {
  ProductTranslation({
    required this.id,
    required this.urunId,
    required this.ad,
    required this.slug,
    required this.aciklama,
    required this.alinti,
    required this.title,
    this.keywords,
    this.description,
    required this.badge,
  });

  dynamic id;
  dynamic urunId;
  String ad;
  String slug;
  String aciklama;
  String alinti;
  String title;
  dynamic keywords;
  dynamic description;
  String badge;

  factory ProductTranslation.fromJson(Map<String, dynamic> json) => ProductTranslation(
    id: json["id"] ?? 0,
    urunId: json["urun_id"] ?? "",
    ad: json["ad"] ?? "",
    slug: json["slug"] ?? "",
    aciklama: json["aciklama"] ?? "",
    alinti: json["alinti"] ?? "",
    title: json["title"] ?? "",
    keywords: json["keywords"],
    description: json["description"],
    badge: json["badge"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "urun_id": urunId,
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

class UrunFoto {
  UrunFoto({
    required this.id,
    required this.foto,
    required this.urunId,
    this.createdAt,
    this.updatedAt,
  });

  dynamic id;
  String foto;
  dynamic urunId;
  dynamic createdAt;
  dynamic updatedAt;

  factory UrunFoto.fromJson(Map<String, dynamic> json) => UrunFoto(
    id: json["id"] ?? 0, // Provide a default value or handle null as needed
    foto: json["foto"] ?? "",
    urunId: json["urun_id"] ?? "", // Provide a default value or handle null as needed
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "foto": foto,
    "urun_id": urunId,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}


class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap; // Use 'late' here

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
