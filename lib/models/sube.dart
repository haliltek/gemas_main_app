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
        id: json["id"] is int ? json["id"] : (int.tryParse(json["id"]?.toString() ?? '0') ?? 0),
        sira: json["sira"]?.toString() ?? '',
        ad: json["ad"]?.toString() ?? '',
        adres: json["adres"]?.toString() ?? '',
        tlf: json["tlf"]?.toString() ?? '',
        tlf2: json["tlf2"]?.toString() ?? '',
        lon: json["lon"]?.toString() ?? '',
        lat: json["lat"]?.toString() ?? '',
        pazartesi: json["pazartesi"]?.toString() ?? '',
        sali: json["sali"]?.toString() ?? '',
        carsamba: json["carsamba"]?.toString() ?? '',
        persembe: json["persembe"]?.toString() ?? '',
        cuma: json["cuma"]?.toString() ?? '',
        cumartesi: json["cumartesi"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "sira": sira,
        "ad": ad,
        "adres": adres,
        "tlf": tlf,
        "tlf2": tlf2,
        "lon": lon,
        "lat": lat,
        "pazartesi": pazartesi,
        "sali": sali,
        "carsamba": carsamba,
        "persembe": persembe,
        "cuma": cuma,
        "cumartesi": cumartesi,
      };
}
