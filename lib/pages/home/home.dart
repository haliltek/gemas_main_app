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
    setState(() {
      _newProductsFuture = _getNewProducts();
      _categoryListFuture = _getCategoryList();
      _newsListFuture = _getNewsList();
    });
  }

  Future<List<Product>> _getNewProducts({int retryCount = 0}) async {
    try {
      var url = Uri.parse("https://gemas.com.tr/api/v1/${"langCode".tr}/productsByCategoryV2/1");
      var response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List).map((newProductMap) => Product.fromJson(newProductMap)).toList();
      } else {
        handleError(response.statusCode);
      }
    } catch (e) {
      if (retryCount >= 2) {
        handleError(-1);
      }
    }

    if (retryCount < 2) {
      await Future.delayed(const Duration(seconds: 3));
      return _getNewProducts(retryCount: retryCount + 1);
    }
    return [];
  }

  Future<List<Category>> _getCategoryList({int retryCount = 0}) async {
    try {
      var response = await http
          .get(Uri.parse("https://gemas.com.tr/api/v1/${"langCode".tr}/categoriesV2"))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List).map((categoryMap) => Category.fromJson(categoryMap)).toList();
      } else {
        handleError(response.statusCode);
      }
    } catch (e) {
      if (retryCount >= 2) {
        handleError(-1);
      }
    }

    if (retryCount < 2) {
      await Future.delayed(const Duration(seconds: 3));
      return _getCategoryList(retryCount: retryCount + 1);
    }
    return [];
  }

  Future<List<Duyuru>> _getNewsList({int retryCount = 0}) async {
    try {
      var langCode = Get.locale?.languageCode ?? "tr";
      var response = await http
          .get(Uri.parse("https://gemas.com.tr/api/v1/$langCode/duyurularV2"))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List).map((newsMap) => Duyuru.fromJson(newsMap)).toList();
      } else {
        handleError(response.statusCode);
      }
    } catch (e) {
      if (retryCount >= 2) {
        handleError(-1);
      }
    }

    if (retryCount < 2) {
      await Future.delayed(const Duration(seconds: 3));
      return _getNewsList(retryCount: retryCount + 1);
    }
    return [];
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void handleError(int statusCode) {
    if (!mounted) return;
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
                    const SizedBox(width: 5),
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
                    const SizedBox(width: 5),
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
                    const SizedBox(width: 5),
                    Text(
                      "Français",
                      style: TextStyle(fontSize: responsive.dp(1.5)),
                    ),
                  ],
                ),
                value: "fr",
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/images/flags/ru.svg",
                      width: responsive.wp(5),
                    ),
                    const SizedBox(width: 5),
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
                      "assets/images/flags/es.svg",
                      width: responsive.wp(5),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Español",
                      style: TextStyle(fontSize: responsive.dp(1.5)),
                    ),
                  ],
                ),
                value: "es",
              ),
            ],
            onSelected: (String menu) {
              if (menu == "tr") {
                Get.updateLocale(const Locale('tr', 'TR'));
              } else if (menu == "en") {
                Get.updateLocale(const Locale('en', 'US'));
              } else if (menu == "fr") {
                Get.updateLocale(const Locale('fr', 'FR'));
              } else if (menu == "ru") {
                Get.updateLocale(const Locale('ru', 'RU'));
              } else if (menu == "es") {
                Get.updateLocale(const Locale('es', 'ES'));
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
