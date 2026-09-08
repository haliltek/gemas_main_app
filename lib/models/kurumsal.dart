// To parse this JSON data, do
//
//     final corporate = corporateFromJson(jsonString);

import 'dart:convert';

List<Corporate> corporateFromJson(String str) =>
    List<Corporate>.from(json.decode(str).map((x) => Corporate.fromJson(x)));

String corporateToJson(List<Corporate> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Corporate {
  Corporate({
    required this.id,
    required this.image,
    required this.ad,
    required this.icerik,
  });

  int id;
  String image;
  String ad;
  String icerik;

  factory Corporate.fromJson(Map<String, dynamic> json) => Corporate(
        id: json["id"] is int ? json["id"] : (int.tryParse(json["id"]?.toString() ?? '0') ?? 0),
        image: json["image"]?.toString() ?? '',
        ad: json["ad"]?.toString() ?? '',
        icerik: json["icerik"]?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
        "ad": ad,
        "icerik": icerik,
      };
}
