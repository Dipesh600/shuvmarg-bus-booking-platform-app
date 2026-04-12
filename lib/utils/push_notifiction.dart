import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebasePushnotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  setUpFirebaseNotification() async {
    await initialize();
    // await requestNotificationPermissions();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;

      if (notification != null) {
        createanddisplaynotification(message);
      }
    });

    //Print fcm token
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        log("FCM Token: $token");
      } else {
        log("FCM Token is null - Firebase service may be unavailable");
      }
    } catch (e) {
      log("Error getting FCM token: $e");
      // Don't throw the error, just log it to prevent app crash
    }

    FirebaseMessaging.onMessageOpenedApp
        .listen((RemoteMessage message) {
      createanddisplaynotification(message);
    });

    FirebaseMessaging.onBackgroundMessage((message) async {
      createanddisplaynotification(message);
    });

    // FirebaseMessaging.instance.getInitialMessage().then((message) {
    //   if (message != null) {
    //     createanddisplaynotification(message);
    //     Navigator.pushNamed(
    //       navigatorKey.currentContext!,
    //       AppRouter.demoTest,
    //     );
    //   }
    // });

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  initialize() async {
    // initializationSettings  for Android
    requestNotificationPermissions();

    const AndroidInitializationSettings
        initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // IoS settings

    final DarwinInitializationSettings initializationSettingsDarwom =
        DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
            requestCriticalPermission: true,
            onDidReceiveLocalNotification:
                onDidReceiveLocalNotification);

    InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwom,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onSelectNotification,
    );
  }

  Future onSelectNotification(
    NotificationResponse notification,
  ) async {
    if (notification.payload != null) {}
  }

  void onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {}

  static void createanddisplaynotification(
      RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const NotificationDetails notificationDetails =
          NotificationDetails(
        android: AndroidNotificationDetails(
          "insvella",
          "pushnotificationappchannel",
          // sound

          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: jsonEncode(message.data),
      );
    } on Exception catch (e) {}
  }

  static void requestNotificationPermissions() async {
    NotificationSettings setting =
        await FirebaseMessaging.instance.requestPermission(
      sound: true,
      announcement: true,
      badge: true,
      alert: true,
      carPlay: true,
      provisional: true,
      criticalAlert: true,
    );
    if (setting.authorizationStatus ==
        AuthorizationStatus.authorized) {
    } else if (setting.authorizationStatus ==
        AuthorizationStatus.provisional) {
    } else {}
  }

  static void requestIOSPermissions() {
    _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // It is assumed that all messages contain a data field with the key 'type'
  static setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  static _handleMessage(RemoteMessage message) {}
}
