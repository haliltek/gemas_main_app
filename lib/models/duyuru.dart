// To parse this JSON data, do
//
//     final duyuru = duyuruFromJson(jsonString);

import 'dart:convert';

List<Duyuru> duyuruFromJson(String str) => List<Duyuru>.from(json.decode(str).map((x) => Duyuru.fromJson(x)));

String duyuruToJson(List<Duyuru> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Duyuru {
  Duyuru({
    required this.id,
    required this.image,
    this.aciklama,
  });

  int id;
  String image;
  String? aciklama;

  factory Duyuru.fromJson(Map<String, dynamic> json) => Duyuru(
        id: json["id"] == null ? null : json["id"],
        image: json["image"] == null ? null : json["image"],
        aciklama: json["aciklama"] == null ? null : json["aciklama"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "image": image == null ? null : image,
        "aciklama": aciklama == null ? null : aciklama,
      };
}
