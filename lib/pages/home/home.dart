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
import 'package:gemas/services/search_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static List<Product>? _cachedNewProducts;
  static List<Category>? _cachedCategories;
  static List<Duyuru>? _cachedNews;
  static String? _cachedLocale;

  late Future<List<Product>> _newProductsFuture;
  late Future<List<Category>> _categoryListFuture;
  late Future<List<Duyuru>> _newsListFuture;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData({bool forceRefresh = false}) async {
    final currentLang = "langCode".tr;

    // Fast path: Render instantly in 0ms from cache
    if (!forceRefresh &&
        _cachedLocale == currentLang &&
        _cachedNewProducts != null &&
        _cachedCategories != null &&
        _cachedNews != null) {
      setState(() {
        _newProductsFuture = Future.value(_cachedNewProducts!);
        _categoryListFuture = Future.value(_cachedCategories!);
        _newsListFuture = Future.value(_cachedNews!);
      });
      // Revalidate in background without showing blocking spinner
      _refreshInBackground();
      return;
    }

    setState(() {
      _newProductsFuture = _getNewProducts();
      _categoryListFuture = _getCategoryList();
      _newsListFuture = _getNewsList();
      _cachedLocale = currentLang;
    });
  }

  Future<void> _refreshInBackground() async {
    try {
      final newProd = await _getNewProducts(silent: true);
      final newCat = await _getCategoryList(silent: true);
      final newNews = await _getNewsList(silent: true);

      if (mounted && (newProd.isNotEmpty || newCat.isNotEmpty || newNews.isNotEmpty)) {
        setState(() {
          if (newProd.isNotEmpty) _newProductsFuture = Future.value(_cachedNewProducts = newProd);
          if (newCat.isNotEmpty) _categoryListFuture = Future.value(_cachedCategories = newCat);
          if (newNews.isNotEmpty) _newsListFuture = Future.value(_cachedNews = newNews);
        });
      }
    } catch (_) {}
  }

  Future<List<Product>> _getNewProducts({int retryCount = 0, bool silent = false}) async {
    try {
      var url = Uri.parse("https://gemas.com.tr/api/v1/${"langCode".tr}/productsByCategoryV2/1");
      var response = await http.get(url).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final list = (json.decode(response.body) as List).map((newProductMap) => Product.fromJson(newProductMap)).toList();
        _cachedNewProducts = list;
        return list;
      } else if (!silent) {
        handleError(response.statusCode);
      }
    } catch (e) {
      if (retryCount >= 2 && !silent) {
        handleError(-1);
      }
    }

    if (retryCount < 2) {
      await Future.delayed(const Duration(seconds: 2));
      return _getNewProducts(retryCount: retryCount + 1, silent: silent);
    }
    return _cachedNewProducts ?? [];
  }

  Future<List<Category>> _getCategoryList({int retryCount = 0, bool silent = false}) async {
    try {
      var response = await http
          .get(Uri.parse("https://gemas.com.tr/api/v1/${"langCode".tr}/categoriesV2"))
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final list = (json.decode(response.body) as List).map((categoryMap) => Category.fromJson(categoryMap)).toList();
        _cachedCategories = list;
        return list;
      } else if (!silent) {
        handleError(response.statusCode);
      }
    } catch (e) {
      if (retryCount >= 2 && !silent) {
        handleError(-1);
      }
    }

    if (retryCount < 2) {
      await Future.delayed(const Duration(seconds: 2));
      return _getCategoryList(retryCount: retryCount + 1, silent: silent);
    }
    return _cachedCategories ?? [];
  }

  Future<List<Duyuru>> _getNewsList({int retryCount = 0, bool silent = false}) async {
    try {
      var langCode = Get.locale?.languageCode ?? "tr";
      var response = await http
          .get(Uri.parse("https://gemas.com.tr/api/v1/$langCode/duyurularV2"))
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final list = (json.decode(response.body) as List).map((newsMap) => Duyuru.fromJson(newsMap)).toList();
        _cachedNews = list;
        return list;
      } else if (!silent) {
        handleError(response.statusCode);
      }
    } catch (e) {
      if (retryCount >= 2 && !silent) {
        handleError(-1);
      }
    }

    if (retryCount < 2) {
      await Future.delayed(const Duration(seconds: 2));
      return _getNewsList(retryCount: retryCount + 1, silent: silent);
    }
    return _cachedNews ?? [];
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
              SearchService.clearCache();
              fetchData(forceRefresh: true);
            },
          ),
        ],
      ),
      drawer: DrawerMenu(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => fetchData(forceRefresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
            child: Column(
              children: [
                buildTopNavbar(context),
                FutureBuilder<List<Product>>(
                  future: _newProductsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * .30,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (snapshot.hasError) {
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
                      return SizedBox(
                        height: responsive.hp(5),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return buildCategories(context, snapshot.data ?? []);
                    }
                  },
                ),
                const SizedBox(height: 5),
                buildCatalogueBanner(context),
                buildSparePartsBanner(context),
                buildDocumentBanner(context),
                FutureBuilder<List<Duyuru>>(
                  future: _newsListFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: responsive.hp(50.0),
                        child: const Center(
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
