import 'dart:convert';
import 'package:fawri_app_refactor/salah/models/notifications/notificationsModel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../server/functions/functions.dart';
import '../../salah/utilities/sentry_service.dart';
import '../../salah/utilities/global/app_global.dart';
import '../../salah/views/pages/notifications/notificationsPage.dart';
import 'package:provider/provider.dart';
import '../../salah/controllers/notification_controller.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Check if notifications should be displayed based on app settings
  static Future<bool> shouldDisplayNotification() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool appEnabled = prefs.getBool('app_notifications_enabled') ?? true;
      printLog("Firebase notification check - App enabled: $appEnabled");
      return appEnabled;
    } catch (e) {
      printLog('Error checking notification state: $e');
      return true; // Default to true if error
    }
  }

  static void initialize(BuildContext context) {
    try {
      // Add breadcrumb for local notification initialization

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings();

      final InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {
              try {
                NavigatorApp.push(const NotificationsPage());
              } catch (e, stack) {
                SentryService.captureError(
                  exception: e,
                  stackTrace: stack,
                  functionName: "onDidReceiveNotificationResponse",
                  fileName: "local_notification_service.dart",
                  lineNumber: 45,
                  extraData: {
                    "payload": notificationResponse.payload,
                    "action_id": notificationResponse.actionId,
                  },
                );
              }
            },
      );

      // final InitializationSettings initializationSettings =
      //     InitializationSettings(
      //         android: AndroidInitializationSettings("@mipmap/launcher_icon"),
      //         iOS: IOSInitializationSettings());
      // _notificationsPlugin.initialize(initializationSettings,
      //     onSelectNotification: (String? route) async {
      //   // if(route != null){
      //   //   Navigator.of(context).pushNamed(route);
      //   // }
      // });
      // Print FCM token
      FirebaseMessaging.instance.getToken().then((token) {
        printLog('Fawri: FCM Token: $token');
        print('FCM Token: $token');
      });
    } catch (e, stack) {
      SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: "initialize",
        fileName: "local_notification_service.dart",
        lineNumber: 55,
      );
    }
  }

  static void display(RemoteMessage message) async {
    try {
      // Check if notifications should be displayed based on app settings
      bool shouldDisplay = await shouldDisplayNotification();
      if (!shouldDisplay) {
        printLog("Firebase notification blocked - App notifications disabled");
        return;
      }

      final controller = Provider.of<NotificationController>(
        NavigatorApp.context,
        listen: false,
      );
      await controller.loadNotifications();

      // Add breadcrumb for local notification display
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "app_notification",
          "app_notification channel",
          playSound: true,
          icon: "@mipmap/launcher_icon",
          importance: Importance.max,
          ongoing: true,
          priority: Priority.high,
          enableLights: true,
        ),
      );

      await _notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: message.data["route"],
      );

      printLog("Firebase notification displayed successfully");
    } on Exception catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: "display",
        fileName: "local_notification_service.dart",
        lineNumber: 100,
        extraData: {
          "title": message.notification?.title,
          "body": message.notification?.body,
          "data": message.data,
        },
      );
      printLog(e.toString());
    }
  }

  static Future<void> saveNotification(
    String? title,
    String? body,
    Map<String, dynamic> data,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> notificationsJson =
          prefs.getStringList('fawri_notifications') ?? [];

      final notification = NotificationsModel(
        title: title ?? 'إشعار جديد',
        body: body ?? '',
        timestamp: DateTime.now(),
        isRead: false,
        name: data["name"],
        url: data["url"],
      );

      notificationsJson.insert(0, jsonEncode(notification.toJson()));

      await prefs.setStringList('fawri_notifications', notificationsJson);
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: "_saveNotification",
        fileName: "local_notification_service.dart",
        extraData: {"title": title, "body": body, "data": data},
      );
    }
  }

  static Future<List<NotificationsModel>> getSavedNotifications() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> notificationsJson =
          prefs.getStringList('fawri_notifications') ?? [];

      return notificationsJson
          .map((json) => NotificationsModel.fromJson(jsonDecode(json)))
          .toList();
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: "getSavedNotifications",
        fileName: "local_notification_service.dart",
      );
      return [];
    }
  }

  static Future<void> saveAllNotifications(
    List<NotificationsModel> notifications,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> notificationsList = notifications
          .map((notification) => jsonEncode(notification.toJson()))
          .toList();
      await prefs.setStringList('fawri_notifications', notificationsList);
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: "saveAllNotifications",
        fileName: "local_notification_service.dart",
      );
    }
  }
}
