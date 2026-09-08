import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gemas/constants.dart';
import 'package:gemas/models/spare_part.dart';
import 'package:gemas/models/spare_part_category.dart';
import 'package:gemas/pages/spare_part.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:gemas/widgets/gemas_app_bar.dart';

class SparePartByCategoryPage extends StatelessWidget {
  final SparePartCategory category;

  const SparePartByCategoryPage({required this.category}) : super();

  @override
  Widget build(BuildContext context) {
    Future<List<SparePart>> _kategoriUrunleriGetir() async {
      try {
        var response = await http.get(Uri.parse(
            "https://gemas.com.tr/api/v1/${"langCode".tr}/sparePartByCategoryId/${category.id}"));
        if (response.statusCode == 200) {
          return (json.decode(response.body) as List)
              .map((sparePartMap) => SparePart.fromJson(sparePartMap))
              .toList();
        } else {
          throw Exception("Bağlantı hatası: ${response.statusCode}");
        }
      } catch (e) {
        await Future.delayed(Duration(seconds: 15));
        return _kategoriUrunleriGetir();
      }
    }

    return Scaffold(
      appBar: GemasAppBar(title: category.ad),
      body: FutureBuilder(
        future: _kategoriUrunleriGetir(),
        builder: (BuildContext context, AsyncSnapshot<List<SparePart>> snapshot) {
          var data = snapshot.data;
          debugPrint("ABCD [spare_part_by_category.dart] data: $data");
          if (snapshot.hasData) {
            return ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                var malzeme = snapshot.data?[index];
                return Card(
                  elevation: 0,
                  margin: EdgeInsets.all(5),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10),
                    leading: Container(
                      height: 100,
                      width: 100,
                      child: malzeme?.malzeme.image == null
                          ? Image.asset("assets/images/unnamed.png")
                          : CachedNetworkImage(
                              imageUrl: Constants.DOMAIN + malzeme!.malzeme.image,
                              fit: BoxFit.contain),
                    ),
                    title: Text(malzeme!.malzeme.stokKodu,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    subtitle:
                        malzeme.malzeme.aciklama != null ? Text(malzeme.malzeme.aciklama) : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SparePartDetailPage(
                                  id: malzeme.id,
                                  stokKodu: malzeme.malzeme.stokKodu,
                                  aciklama: malzeme.malzeme.aciklama,
                                )),
                      );
                    },
                  ),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
