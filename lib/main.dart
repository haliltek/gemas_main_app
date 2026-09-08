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

const AndroidNotificationChannel _highImportanceChannel = AndroidNotificationChannel(
  'gemas_high_importance_channel',
  'Gemaş Bildirimleri',
  description: 'Gemaş mobil uygulama duyuru ve ürün bildirim kanalı',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeFirebase() async {
  try {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize local notifications plugin and channel for Android/iOS
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final Map<String, dynamic> data = json.decode(response.payload!);
            _handleMessage(RemoteMessage(data: data));
          } catch (e) {
            debugPrint('[main.dart] Local notification click error: $e');
          }
        }
      },
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_highImportanceChannel);

    final messaging = FirebaseMessaging.instance;

    // Request notification permissions
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Check if app was opened via notification while terminated
    try {
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessage(initialMessage);
      }
    } catch (e) {
      debugPrint('[main.dart] getInitialMessage error: $e');
    }

    // Listen to notification clicks when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    // Foreground message handler with high priority channel
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[main.dart] Foreground message received: ${message.messageId}');
      final notification = message.notification;
      if (notification != null) {
        final androidDetails = AndroidNotificationDetails(
          _highImportanceChannel.id,
          _highImportanceChannel.name,
          channelDescription: _highImportanceChannel.description,
          priority: Priority.high,
          importance: Importance.max,
          icon: '@mipmap/ic_launcher',
        );
        const iOSDetails = DarwinNotificationDetails();
        final details = NotificationDetails(android: androidDetails, iOS: iOSDetails);

        _localNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          details,
          payload: json.encode(message.data),
        );
      }
    });

    // Run topic subscriptions in background (non-blocking)
    _setupTopicSubscriptions();
  } catch (error) {
    debugPrint('[main.dart] Firebase initialization error: $error');
  }
}

Future<void> _setupTopicSubscriptions() async {
  try {
    final messaging = FirebaseMessaging.instance;
    final locale = Get.deviceLocale;
    final language = locale?.languageCode ?? 'tr';

    // Broadcast topic for all users (Admin panel general notifications)
    final generalTopics = [
      messaging.subscribeToTopic("allUsers"),
      messaging.subscribeToTopic("NewsFromGemas"),
    ];

    List<Future<void>> languageTopics;
    if (language == "tr") {
      languageTopics = [
        messaging.subscribeToTopic("newProductsTR"),
        messaging.subscribeToTopic("newNewsTR"),
        messaging.subscribeToTopic("updateSparePartsTR"),
        messaging.subscribeToTopic("updateProductPriceTR"),
        messaging.subscribeToTopic("updateDocumentationTR"),
        messaging.unsubscribeFromTopic("newProductsEN"),
        messaging.unsubscribeFromTopic("newNewsEN"),
        messaging.unsubscribeFromTopic("updateSparePartsEN"),
        messaging.unsubscribeFromTopic("updateProductPriceEN"),
        messaging.unsubscribeFromTopic("updateDocumentationEN"),
      ];
    } else {
      languageTopics = [
        messaging.subscribeToTopic("newProductsEN"),
        messaging.subscribeToTopic("newNewsEN"),
        messaging.subscribeToTopic("updateSparePartsEN"),
        messaging.subscribeToTopic("updateProductPriceEN"),
        messaging.subscribeToTopic("updateDocumentationEN"),
        messaging.unsubscribeFromTopic("newProductsTR"),
        messaging.unsubscribeFromTopic("newNewsTR"),
        messaging.unsubscribeFromTopic("updateSparePartsTR"),
        messaging.unsubscribeFromTopic("updateProductPriceTR"),
        messaging.unsubscribeFromTopic("updateDocumentationTR"),
      ];
    }

    await Future.wait([...generalTopics, ...languageTopics]);
    debugPrint('[main.dart] FCM topic subscriptions completed');
  } catch (e) {
    debugPrint('[main.dart] Topic subscription error: $e');
  }
}

void _handleMessage(RemoteMessage initialMessage) async {
  debugPrint('[main.dart] Handling a notification open: ${initialMessage.messageId}');

  Get.dialog(
    const Center(child: CircularProgressIndicator()),
    barrierDismissible: false,
  );

  try {
    final stockCode = initialMessage.data["stockCode"];
    await createProduct(stockCode, initialMessage);
    if (Get.isDialogOpen ?? false) Get.back();

    if (product != null) {
      Get.to(() => ProductPage(product: product!));
    } else {
      Get.to(() => HomePage());
    }
  } catch (e) {
    debugPrint("[main.dart] Error handling message: $e");
    if (Get.isDialogOpen ?? false) Get.back();
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("[main.dart] Background message received: ${message.messageId}");
}

Future<void> createProduct(dynamic stockCode, RemoteMessage message) async {
  if (stockCode == null || stockCode.toString().isEmpty) {
    product = null;
    return;
  }
  try {
    product = await _getCategoryProductUsingStockCode(stockCode.toString());
  } catch (e) {
    debugPrint("[main.dart] createProduct error: $e");
    product = null;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint("[main.dart] Firebase.initializeApp error: $e");
  }

  runApp(MyApp());

  // Initialize notification channels, handlers and topics without blocking runApp
  initializeFirebase();
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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      color: Colors.white,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      translations: Messages(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      home: UpgradeAlert(
        upgrader: Upgrader(
          messages: _getMessages(),
        ),
        child: HomePage(),
      ),
    );
  }
}