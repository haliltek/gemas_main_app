import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gemas/constants.dart';
import 'package:gemas/models/kurumsal.dart';
import 'package:gemas/models/sube.dart';
import 'package:gemas/pages/corporate.dart';
import 'package:gemas/pages/sube.dart';
import 'package:gemas/utils/responsive.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class DrawerMenu extends StatefulWidget {
  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    Future<List<Corporate>> _getCorporateList() async {
      var response =
          await http.get(Uri.parse("${Constants.BASE_API_URL}${"langCode".tr}/corporate"));
      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((corporateMap) => Corporate.fromJson(corporateMap))
            .toList();
      } else {
        throw Exception("Bağlantı hatası: ${response.statusCode}");
      }
    }

    Future<List<Sube>> _getOfficeList() async {
      var response =
          await http.get(Uri.parse("${Constants.BASE_API_URL}tr/subeler"));
      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((officeMap) => Sube.fromJson(officeMap))
            .toList();
      } else {
        throw Exception("Bağlantı hatası: ${response.statusCode}");
      }
    }

    return SafeArea(
      child: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Constants.gemasPrimaryBgColor,
                    Constants.gemasPrimaryBgColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/logo.svg',
                    width: responsive.dp(6),
                    color: Constants.gemasPrimaryTextColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Gemaş Genel Mühendislik Mek. San ve Tic. A.Ş.',
                      style: TextStyle(
                        color: Constants.gemasPrimaryTextColor,
                        fontSize: responsive.dp(1.6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ExpansionTile(
                leading: Icon(Icons.apartment_outlined),
                title: Text('corporate'.tr),
                trailing: Icon(Icons.keyboard_arrow_down_rounded),
                children: <Widget>[
                  //KURUMSAL
                  FutureBuilder(
                      future: _getCorporateList(),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Corporate>> snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                              physics: ClampingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: snapshot.data?.length,
                              itemBuilder: (context, index) {
                                var kurumsal = snapshot.data![index];
                                return ListTile(
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CorporatePage(
                                          corporate: kurumsal,
                                        ),
                                      ),
                                    );
                                  },
                                  leading: Icon(Icons.business_outlined),
                                  title: Text(kurumsal.ad),
                                );
                              });
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      }),
                  //KURUMSAL SONU
                ],
              ),
                  ExpansionTile(
                leading: Icon(Icons.contact_page_outlined),
                title: Text('contact'.tr),
                trailing: Icon(Icons.keyboard_arrow_down_rounded),
                children: <Widget>[
                  //KURUMSAL
                  FutureBuilder(
                      future: _getOfficeList(),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Sube>> snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                              physics: ClampingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: snapshot.data?.length,
                              itemBuilder: (context, index) {
                                var sube = snapshot.data![index];
                                return ListTile(
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SubePage(
                                          sube: sube,
                                        ),
                                      ),
                                    );
                                  },
                                  leading: Icon(Icons.location_on_outlined),
                                  title: Text(sube.ad),
                                );
                              });
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      }),
                  //KURUMSAL SONU
                ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
