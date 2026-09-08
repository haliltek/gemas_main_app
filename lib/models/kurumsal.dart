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
        id: json["id"],
        image: json["image"],
        ad: json["ad"],
        icerik: json["icerik"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
        "ad": ad,
        "icerik": icerik,
      };
}
