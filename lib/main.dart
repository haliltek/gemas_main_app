import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gemas/pages/home/home.dart';
import 'package:gemas/pages/product.dart';
import 'package:gemas/theme/app_theme.dart';
import 'package:get/get.dart';
import 'package:http/retry.dart';
import 'package:upgrader/upgrader.dart';

import 'firebase_options.dart';
import 'language/translations.dart';
import 'models/product.dart';

import 'package:http/http.dart' as http;

Product? product;
List<Product> products = [];
final StreamController<String?> selectNotificationStream = StreamController<String?>.broadcast();
String? selectedNotificationPayload;

Future<Product> _getCategoryProductUsingStockCode(String stockCode) async {
  var client = new RetryClient(http.Client(), retries: 2);
  var response = await client.get(Uri.parse("https://gemas.com.tr/api/v1/${"langCode".tr}/productByStockCode/$stockCode"));

  client.close();

  if (response.statusCode == 200) {
    print("[main.dart] response.body: ${response.body}");

    var decodedBody = json.decode(response.body);
    if (decodedBody is List) {
      if (decodedBody.isNotEmpty) {
        return Product.fromJson(decodedBody.first);
      } else {
        throw Exception("API returned an empty list");
      }
    } else if (decodedBody is Map<String, dynamic>) {
      return Product.fromJson(decodedBody);
    } else {
      throw Exception("Unexpected API response format");
    }
  } else {
    print("[main.dart] response.statusCode: ${response.statusCode}");
    throw Exception("Bağlantı hatası: ${response.statusCode}");
  }
}

Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await Future.delayed(Duration(seconds: 1));

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    print("[main.dart] Firebase initialized!");

    RemoteMessage? initialMessage;
    try {
      await Future.delayed(Duration(seconds: 1));
      initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    } catch (error) {
      debugPrint('[main.dart] FirebaseMessaging.instance.getInitialMessage() error: $error');
    }

    print("[main.dart] initialMessage: $initialMessage");

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      _handleMessage(message);
    });

    final locale = Get.deviceLocale;
    final language = locale?.languageCode;

    if (language == "tr") {
      await FirebaseMessaging.instance.subscribeToTopic("newProductsTR");
      await FirebaseMessaging.instance.subscribeToTopic("newNewsTR");
      await FirebaseMessaging.instance.subscribeToTopic("updateSparePartsTR");
      await FirebaseMessaging.instance.subscribeToTopic("updateProductPriceTR");
      await FirebaseMessaging.instance.subscribeToTopic("updateDocumentationTR");

      await FirebaseMessaging.instance.unsubscribeFromTopic("newProductsEN");
      await FirebaseMessaging.instance.unsubscribeFromTopic("newNewsEN");
      await FirebaseMessaging.instance.unsubscribeFromTopic("updateSparePartsEN");
      await FirebaseMessaging.instance.unsubscribeFromTopic("updateProductPriceEN");
      await FirebaseMessaging.instance.unsubscribeFromTopic("updateDocumentationEN");
    } else {
      await FirebaseMessaging.instance.subscribeToTopic("newProductsEN");
      await FirebaseMessaging.instance.subscribeToTopic("newNewsEN");
      await FirebaseMessaging.instance.subscribeToTopic("updateSparePartsEN");
      await FirebaseMessaging.instance.subscribeToTopic("updateProductPriceEN");
      await FirebaseMessaging.instance.subscribeToTopic("updateDocumentationEN");

      await FirebaseMessaging.instance.unsubscribeFromTopic("newProductsTR");
      await FirebaseMessaging.instance.unsubscribeFromTopic("newNewsTR");
      await FirebaseMessaging.instance.unsubscribeFromTopic("updateSparePartsTR");
      await FirebaseMessaging.instance.unsubscribeFromTopic("updateProductPriceTR");
      await FirebaseMessaging.instance.unsubscribeFromTopic("updateDocumentationTR");
    }

    // old
    await FirebaseMessaging.instance.subscribeToTopic("NewsFromGemas");

    // Test
    // await FirebaseMessaging.instance.subscribeToTopic("a0b12"); // at 0.4.10 version 32
    // await FirebaseMessaging.instance.subscribeToTopic("a0b13"); // at 0.4.10 version 32

    await FirebaseMessaging.instance.subscribeToTopic("a0b15");
    await FirebaseMessaging.instance.subscribeToTopic("a0b16");

    final fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint('FCM Token: $fcmToken');

    FirebaseMessaging.instance.onTokenRefresh.listen((event) {
      debugPrint('[main.dart] FCM Token Refreshed: $event');
    }).onError((error) {
      debugPrint('[main.dart] FCM Token Refreshed Error: $error');
    });

    final messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('[main.dart] User granted permission: ${settings.authorizationStatus}');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('[main.dart] Got a message whilst in the foreground!');
      print('[main.dart] Message data: ${message.data}');

      if (message.notification != null)
        print('Message also contained a notification: ${message.notification!.body}');

      final notification = message.notification;
      final android = AndroidNotificationDetails('channel id', 'channel name',
          priority: Priority.high, importance: Importance.max, icon: '@mipmap/ic_launcher');

      final iOS = DarwinNotificationDetails();
      final platform = NotificationDetails(android: android, iOS: iOS);

      FlutterLocalNotificationsPlugin().show(
        notification!.hashCode,
        notification.title,
        notification.body,
        platform,
      );
    });
  } catch (error) {
    debugPrint('[main.dart] Firebase initialization error: $error');
  }
}

void _handleMessage(RemoteMessage initialMessage) async {
  debugPrint('[main.dart] A new onMessageOpenedApp event was published!');
  debugPrint('[main.dart] Message data: ${initialMessage.data}');
  print("[main.dart] Handling a background message: (1) ${initialMessage.messageId}");

  Get.dialog(
    Center(child: CircularProgressIndicator()),
    barrierDismissible: false,
  );

  try {
    print("[main.dart] Message.data stockCode: ${initialMessage.data["stockCode"]}");
    await createProduct(initialMessage.data["stockCode"], initialMessage);
    Get.back();

    if (product != null) {
      Get.to(() => ProductPage(product: product!));
    } else {
      Get.to(() => HomePage());
    }
  } catch (e) {
    print("[main.dart] Error handling message: $e");
    Get.back();
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("[main.dart] Handling a background message: (2) ${message.messageId}");
}

Future<void> createProduct(stockCode, RemoteMessage message) async {
  print("stockCode: $stockCode");

  if (stockCode == null || stockCode == "") {
    product = null;
    return;
  }

  print("[main.dart] Message data: ${message.data}");
  print("[main.dart] Message.data stockCode: ${message.data["stockCode"]}");
  print("[main.dart] Message value: $message");

  product = await _getCategoryProductUsingStockCode(stockCode);
  print("[main.dart] product: $product");
}

void main() async {
  runApp(MyApp());
  print("[main.dart] main() started");
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
}

class MyEnglishMessages extends UpgraderMessages {

    @override
    String get buttonTitleIgnore => 'Ignore';

    @override
    String get buttonTitleLater => 'Later';

    @override
    String get body => 'A new version of the app is available. Please update it now.';

    @override
    String get buttonTitleUpdate => 'Update Now';

    @override
    String get prompt => 'Would you like to update now?';

    @override
    String get releaseNotes => 'Release Notes';

    @override
    String get title => 'Update App?';
}

class MyTurkishMessages extends UpgraderMessages {

  @override
  String get buttonTitleIgnore => 'Yoksay';

  @override
  String get body => 'Uygulamanın yeni bir sürümü mevcut. Lütfen uygulamayı güncelleyin.';

  @override
  String get buttonTitleLater => 'Daha Sonra';

  @override
  String get buttonTitleUpdate => 'Şimdi Güncelle';

  @override
  String get prompt => 'Güncelleme yapmak ister misiniz?';

  @override
  String get releaseNotes => 'Sürüm Notları';

  @override
  String get title => 'Uygulamayı Güncelle?';
}

UpgraderMessages _getMessages() {
  String? currentLocale = Get.deviceLocale?.languageCode;

  if (currentLocale != null && currentLocale == 'tr') {
    return MyTurkishMessages();
  } else {
    return MyEnglishMessages();
  }
}

// If the minAppVersion in the news section is less than 0.4.100, it does not update.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      color: Colors.white,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      translations: Messages(),
      locale: Get.deviceLocale,
      fallbackLocale: Locale('en', 'US'),
      home: UpgradeAlert(
        upgrader: Upgrader(
          minAppVersion: "0.4.130",
          messages: _getMessages(),
        ),
        child: HomePage(),
      ),
    );
  }
}