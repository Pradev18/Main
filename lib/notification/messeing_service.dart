import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gala_travels_app/notification/NotificationDatabaseHelper.dart';
import 'package:provider/provider.dart';

class NotificationServies {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        sound: true,
        provisional: true,
        criticalAlert: true,
        carPlay: false,
        announcement: false,
        badge: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("permission granted");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("permission granted");
    } else {
      print("permission denide");
    }
  }

  Future<String> getToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  Future<void> firebaseinit(BuildContext context) async {
    await initLocalNotification(context);
    FirebaseMessaging.onMessage.listen((message) async {
      if (kDebugMode) {
        showNotificaion(message);
        final dbHelper = DBHelper.instance;

        // Add the notification data directly using DBhelper
        await dbHelper.addData(
          nTitle: message.notification?.title ?? 'No Title',
          nDesc: message.notification?.body ?? 'No Body',
          nTime: DateTime.now().millisecondsSinceEpoch,
        );
        print(
            "-------add Data ------" + message.notification!.title.toString());
        print("-------add Data ------" + message.notification!.body.toString());
        print("-------add Data ------" + message.data.toString());
      }
    });
  }

  Future<void> showNotificaion(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(),
        "High Importance Notification",
        importance: Importance.max);
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            channel.id.toString(), channel.name.toString(),
            channelDescription: channel.description,
            importance: Importance.high,
            priority: Priority.high,
            ticker: "tiker");

    DarwinNotificationDetails darwinNotificationDetails =
        const DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails);
    });
  }

  Future<void> initLocalNotification(BuildContext context,
      [RemoteMessage? message]) async {
    var androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) {});
  }
}
