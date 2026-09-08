import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gemas/models/category.dart';
import 'package:gemas/models/duyuru.dart';
import 'package:gemas/models/product.dart';
import 'package:gemas/pages/home/catalogueBanner.dart';
import 'package:gemas/pages/home/categories.dart';
import 'package:gemas/pages/home/documentBanner.dart';
import 'package:gemas/pages/home/newProducts.dart';
import 'package:gemas/pages/home/news.dart';
import 'package:gemas/pages/home/sparePartsBanner.dart';
import 'package:gemas/pages/home/topBar.dart';
import 'package:gemas/pages/product_search_delegate.dart';
import 'package:gemas/utils/responsive.dart';
import 'package:gemas/widgets/drawer.dart';
import 'package:gemas/widgets/gemas_app_bar.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late Future<List<Product>> _newProductsFuture;
  late Future<List<Category>> _categoryListFuture;
  late Future<List<Duyuru>> _newsListFuture;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      _newProductsFuture = _getNewProducts();
      _categoryListFuture = _getCategoryList();
      _newsListFuture = _getNewsList();
    } catch (e) {
      _showErrorSnackbar('Veriler alınamadı. Lütfen tekrar deneyin.');
    }
    setState(() {});
  }

  Future<List<Product>> _getNewProducts() async {
    var url = Uri.parse("https://gemas.com.tr/api/v1/${"langCode".tr}/productsByCategoryV2/1");
    var response = await http.get(url);
    try {
      print("[home.dart] _getNewProducts() response.statusCode: ${response.statusCode}");

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List).map((newProductMap) => Product.fromJson(newProductMap)).toList();
      } else {
        print("[home.dart] _getNewProducts() response.statusCode: ${response.statusCode}");
        print("[home.dart] _getNewProducts() response.body: ${response.body}");
        handleError(response.statusCode);
      }
    } catch (e) {
      print("[home.dart] _getNewProducts() catch response.statusCode: ${response.statusCode}");
      print("[home.dart] _getNewProducts() catchresponse.body: ${response.body}");
      handleError(-1);
    }

    await Future.delayed(Duration(seconds: 8));
    return _getNewProducts();
  }

  Future<List<Category>> _getCategoryList() async {
    try {
      var response = await http.get(Uri.parse("https://gemas.com.tr/api/v1/${"langCode".tr}/categoriesV2"));
      print("[home.dart] _getCategoryList() response.statusCode: ${response.statusCode}");

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List).map((categoryMap) => Category.fromJson(categoryMap)).toList();
      } else {
        handleError(response.statusCode);
      }
    } catch (e) {
      handleError(-1);
    }

    await Future.delayed(Duration(seconds: 8));
    return _getCategoryList();
  }

  Future<List<Duyuru>> _getNewsList() async {
    try {
      var response = await http.get(Uri.parse("https://gemas.com.tr/api/v1/${Get.locale!.languageCode}/duyurularV2"));
      print("[home.dart] _getNewsList() response.statusCode: ${response.statusCode}");

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List).map((newsMap) => Duyuru.fromJson(newsMap)).toList();
      } else {
        handleError(response.statusCode);
      }
    } catch (e) {
      handleError(-1);
    }

    await Future.delayed(Duration(seconds: 8));
    return _getNewsList();
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void handleError(int statusCode) {
    String errorMessageKey;

    switch (statusCode) {
      case 429:
        errorMessageKey = 'textError429';
        break;
      case 503:
        errorMessageKey = 'textError503';
        break;
      case 200:
        errorMessageKey = 'textError200';
        break;
      default:
        print("[home.dart] handleError() statusCode: $statusCode");
        errorMessageKey = 'textErrorOther';
    }

    String errorMessage = errorMessageKey.tr;
    _showErrorSnackbar(errorMessage);
  }


  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GemasAppBar(
        title: "home".tr.toUpperCase(),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.onPrimary,
              size: responsive.dp(2.5),
            ),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(),
              );
            },
          ),
          PopupMenuButton(
            icon: Icon(
              Icons.language,
              color: Theme.of(context).colorScheme.onPrimary,
              size: responsive.dp(2.5),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/images/flags/tr.svg",
                      width: responsive.wp(5),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "Türkçe",
                      style: TextStyle(fontSize: responsive.dp(1.5)),
                    ),
                  ],
                ),
                value: "tr",
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/images/flags/en.svg",
                      width: responsive.wp(5),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "English",
                      style: TextStyle(fontSize: responsive.dp(1.5)),
                    ),
                  ],
                ),
                value: "en",
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/images/flags/fr.svg",
                      width: responsive.wp(5),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "Français",
                      style: TextStyle(fontSize: responsive.dp(1.5)),
                    ),
                  ],
                ),
                value: "en",
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/images/flags/ru.svg",
                      width: responsive.wp(5),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "Russian",
                      style: TextStyle(fontSize: responsive.dp(1.5)),
                    ),
                  ],
                ),
                value: "ru",
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/images/flags/en.svg",
                      width: responsive.wp(5),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "Espanol",
                      style: TextStyle(fontSize: responsive.dp(1.5)),
                    ),
                  ],
                ),
                value: "es",
              ),
            ],
            onSelected: (String menu) {
              if (menu == "tr") {
                Get.updateLocale(Locale('tr', 'TR'));
              } else if (menu == "en") {
                Get.updateLocale(Locale('en', 'US'));
              } else if (menu == "fr") {
                Get.updateLocale(Locale('fr', 'FR'));
              } else if (menu == "ru") {
                Get.updateLocale(Locale('ru', 'RU'));
              } else if (menu == "es") {
                Get.updateLocale(Locale('es', 'ES'));
              }
              fetchData();
            },
          ),
        ],
      ),
      drawer: DrawerMenu(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
          children: [
            buildTopNavbar(context),
            FutureBuilder<List<Product>>(
              future: _newProductsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: MediaQuery.of(context).size.height * .30,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  // Error state
                  return Text('Error: ${snapshot.error}');
                } else {
                  return buildNewProducts(context, snapshot.data ?? []);
                }
              },
            ),
            // Use FutureBuilder for categories
            FutureBuilder<List<Category>>(
              future: _categoryListFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: responsive.hp(5),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  // Error state
                  return Text('Error: ${snapshot.error}');
                } else {
                  // Data loaded successfully
                  return buildCategories(context, snapshot.data ?? []);
                }
              },
            ),
            SizedBox(height: 5),
            buildCatalogueBanner(context),
            buildSparePartsBanner(context),
            buildDocumentBanner(context),
            FutureBuilder<List<Duyuru>>(
              future: _newsListFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: responsive.hp(50.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return buildNews(context, snapshot.data ?? []);
                }
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
        ));
  }
}
