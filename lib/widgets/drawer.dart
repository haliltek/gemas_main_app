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
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  static List<Corporate>? _cachedCorporate;
  static List<Sube>? _cachedOffices;
  static String? _cachedLang;

  late Future<List<Corporate>> _corporateFuture;
  late Future<List<Sube>> _officeFuture;

  @override
  void initState() {
    super.initState();
    final lang = "langCode".tr;
    if (_cachedCorporate != null && _cachedLang == lang) {
      _corporateFuture = Future.value(_cachedCorporate!);
    } else {
      _corporateFuture = _getCorporateList();
    }

    if (_cachedOffices != null && _cachedLang == lang) {
      _officeFuture = Future.value(_cachedOffices!);
    } else {
      _officeFuture = _getOfficeList();
    }
  }

  Future<List<Corporate>> _getCorporateList() async {
    final lang = "langCode".tr;
    try {
      final response = await http
          .get(Uri.parse("${Constants.BASE_API_URL}$lang/corporate"))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final list = (json.decode(response.body) as List)
            .map((corporateMap) => Corporate.fromJson(corporateMap))
            .toList();
        _cachedCorporate = list;
        _cachedLang = lang;
        return list;
      } else {
        throw Exception("Bağlantı hatası: ${response.statusCode}");
      }
    } catch (_) {
      return _cachedCorporate ?? [];
    }
  }

  Future<List<Sube>> _getOfficeList() async {
    final lang = "langCode".tr;
    try {
      final response = await http
          .get(Uri.parse("${Constants.BASE_API_URL}$lang/subeler"))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final list = (json.decode(response.body) as List)
            .map((officeMap) => Sube.fromJson(officeMap))
            .toList();
        _cachedOffices = list;
        return list;
      } else {
        throw Exception("Bağlantı hatası: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("DrawerMenu _getOfficeList error: $e");
      return _cachedOffices ?? [];
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);

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
                    colorFilter: const ColorFilter.mode(
                      Constants.gemasPrimaryTextColor,
                      BlendMode.srcIn,
                    ),
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
                    leading: const Icon(Icons.apartment_outlined),
                    title: Text('corporate'.tr),
                    trailing: const Icon(Icons.keyboard_arrow_down_rounded),
                    children: <Widget>[
                      FutureBuilder<List<Corporate>>(
                        future: _corporateFuture,
                        builder: (BuildContext context, AsyncSnapshot<List<Corporate>> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            );
                          }
                          final list = snapshot.data ?? [];
                          if (list.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return ListView.builder(
                            physics: const ClampingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              var kurumsal = list[index];
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
                                leading: const Icon(Icons.business_outlined),
                                title: Text(kurumsal.ad),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  ExpansionTile(
                    leading: const Icon(Icons.contact_page_outlined),
                    title: Text('contact'.tr),
                    trailing: const Icon(Icons.keyboard_arrow_down_rounded),
                    children: <Widget>[
                      FutureBuilder<List<Sube>>(
                        future: _officeFuture,
                        builder: (BuildContext context, AsyncSnapshot<List<Sube>> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            );
                          }
                          final list = snapshot.data ?? [];
                          if (list.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return ListView.builder(
                            physics: const ClampingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              var sube = list[index];
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
                                leading: const Icon(Icons.location_on_outlined),
                                title: Text(sube.ad),
                              );
                            },
                          );
                        },
                      ),
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
