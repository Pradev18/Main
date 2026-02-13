import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:gala_travels_app/menu_pages/constants/constants.dart';
import 'package:gala_travels_app/select_school.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gala_travels_app/firebase_options.dart';
import 'package:gala_travels_app/menu_pages/menubar.dart';

import 'menu_pages/homescreen/provider.dart';
import 'notification/NotificationDatabaseHelper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Constants.initSharedPreferences();
    // await Firebase.initializeApp(
    //     options: DefaultFirebaseOptions.currentPlatform);
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackground);
  } catch (e) {
    print('Error initializing Firebase or SharedPreferences: $e');
  }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  HttpOverrides.global = MyHttpOverrides();
  bool setLoggedIn = await checkLoginStatus();

  // testHttpClientRequest();

  // String? fcmToken = await FirebaseMessaging.instance.getToken();
  // print('FCM Token: $fcmToken');
  // Constants.fcmToken = fcmToken;

  runApp(ChangeNotifierProvider(
      create: (context) => HomeProvider(),
      child: setLoggedIn ? Menubar() : const MyApp()));
}

void testHttpClientRequest() async {
  final client = HttpClient();
  final request = await client.getUrl(Uri.parse('http://192.168.1.109:8081'));
  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();
  print('Response from proxy test: $responseBody');
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackground(RemoteMessage message) async {
  // Ensure Flutter bindings are available if any plugin needs them.
  WidgetsFlutterBinding.ensureInitialized(); // Often helpful

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print('--- BACKGROUND MESSAGE RECEIVED (App Potentially Terminated) ---');
  print('Message data: ${message.data}');
  print('Message notification: ${message.notification}');

  final dbHelper = DBHelper.instance;

  String title =
      message.data['title'] ?? message.notification?.title ?? 'No Title';
  String body = message.data['body'] ?? message.notification?.body ?? 'No Body';

  print('[BACKGROUND] Parsed Title: $title');
  print('[BACKGROUND] Parsed Body: $body');

  try {
    print('[BACKGROUND] Attempting to save to DB...');
    await dbHelper.addData(
      nTitle: title,
      nDesc: body,
      nTime: DateTime.now().millisecondsSinceEpoch,
    );
    print('✅ [BACKGROUND] Saved in background: Title: $title');
  } catch (e, s) {
    print('❌ [BACKGROUND] Error saving notification to DB: $e');
    print('❌ [BACKGROUND] Stacktrace: $s');
    // For production, consider logging this to a remote service
    // as print statements from terminated app isolates can be hard to catch.W
  }
}

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackground(RemoteMessage message) async {
//   await Firebase.initializeApp();
//
//   final dbHelper = DBhelper.instance;
//
//   await dbHelper.addData(
//     nTitle: message.data['title'] ?? 'No Title',
//     nDesc: message.data['body'] ?? 'No Body',
//     nTime: DateTime.now().toString(),
//   );
//
//   print('✅ Saved in background: ${message.data}');
// }

Future<bool> checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('setLoggedIn') ?? false;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My School Bus - Lakshya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: select_school(),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    var client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  }
}
