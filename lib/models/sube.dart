// To parse this JSON data, do
//
//     final sube = subeFromJson(jsonString);

import 'dart:convert';

Sube subeFromJson(String str) => Sube.fromJson(json.decode(str));

String subeToJson(Sube data) => json.encode(data.toJson());

class Sube {
  Sube({
    required this.id,
    required this.sira,
    required this.ad,
    required this.adres,
    required this.tlf,
    required this.tlf2,
    required this.lon,
    required this.lat,
    required this.pazartesi,
    required this.sali,
    required this.carsamba,
    required this.persembe,
    required this.cuma,
    this.cumartesi,
  });

  int id;
  String sira;
  String ad;
  String adres;
  String tlf;
  String tlf2;
  String lon;
  String lat;
  String pazartesi;
  String sali;
  String carsamba;
  String persembe;
  String cuma;
  String? cumartesi;

  factory Sube.fromJson(Map<String, dynamic> json) => Sube(
        id: json["id"] == null ? null : json["id"],
        sira: json["sira"] == null ? null : json["sira"],
        ad: json["ad"] == null ? null : json["ad"],
        adres: json["adres"] == null ? null : json["adres"],
        tlf: json["tlf"] == null ? null : json["tlf"],
        tlf2: json["tlf2"] == null ? null : json["tlf2"],
        lon: json["lon"] == null ? null : json["lon"],
        lat: json["lat"] == null ? null : json["lat"],
        pazartesi: json["pazartesi"] == null ? null : json["pazartesi"],
        sali: json["sali"] == null ? null : json["sali"],
        carsamba: json["carsamba"] == null ? null : json["carsamba"],
        persembe: json["persembe"] == null ? null : json["persembe"],
        cuma: json["cuma"] == null ? null : json["cuma"],
        cumartesi: json["cumartesi"] == null ? null : json["cumartesi"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "sira": sira == null ? null : sira,
        "ad": ad == null ? null : ad,
        "adres": adres == null ? null : adres,
        "tlf": tlf == null ? null : tlf,
        "tlf2": tlf2 == null ? null : tlf2,
        "lon": lon == null ? null : lon,
        "lat": lat == null ? null : lat,
        "pazartesi": pazartesi == null ? null : pazartesi,
        "sali": sali == null ? null : sali,
        "carsamba": carsamba == null ? null : carsamba,
        "persembe": persembe == null ? null : persembe,
        "cuma": cuma == null ? null : cuma,
        "cumartesi": cumartesi == null ? null : cumartesi,
      };
}
