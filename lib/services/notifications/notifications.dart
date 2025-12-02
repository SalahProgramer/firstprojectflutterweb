import 'dart:async';
import 'package:fawri_app_refactor/salah/controllers/sub_main_categories_conrtroller.dart';
import 'package:fawri_app_refactor/salah/views/pages/home/home_screen/home_screen.dart';
import 'package:fawri_app_refactor/server/functions/functions.dart';
import 'package:fawri_app_refactor/salah/utilities/sentry_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../salah/utilities/global/app_global.dart';
import '../../salah/views/pages/notifications/notificationsPage.dart';
import 'local_notification_service.dart';

Future<void> onBackgroundMessage(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();

    // Check if app notifications are enabled
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool appEnabled = prefs.getBool('app_notifications_enabled') ?? true;

    if (!appEnabled) {
      printLog(
        "Background Firebase message blocked - App notifications disabled",
      );
      return;
    }

    if (message.notification != null) {
      await _saveBackgroundNotification(
        message.notification?.title,
        message.notification?.body,
        message.data,
      );
    }

    if (message.data.containsKey('type')) {
      // final type = message.data['type'];
    }

    if (message.notification != null) {
      printLog("Background Firebase message processed");
    }
  } catch (e, stack) {
    await SentryService.captureError(
      exception: e,
      stackTrace: stack,
      functionName: "onBackgroundMessage",
      fileName: "notifications.dart",
      lineNumber: 30,
      extraData: {
        "message_id": message.messageId,
        "message_data": message.data,
      },
    );
  }
}

Future<void> _saveBackgroundNotification(
  String? title,
  String? body,
  Map<String, dynamic> data,
) async {
  // Use unified save function from FCM class
  await FCM.saveNotificationToStorage(title, body, data);
}

class FCM {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final streamCtlr = StreamController<String>.broadcast();
  final titleCtlr = StreamController<String>.broadcast();
  final bodyCtlr = StreamController<String>.broadcast();

  /// Unified function to save notification in all cases (background, foreground, opened, etc.)
  /// Uses the same NotificationsModel format to avoid duplicates and ensure consistency
  static Future<void> saveNotificationToStorage(
    String? title,
    String? body,
    Map<String, dynamic> data,
  ) async {
    try {
      // Use LocalNotificationService.saveNotification to ensure same format
      // This prevents duplicates and format inconsistencies
      await LocalNotificationService.saveNotification(title, body, data);
      printLog("Notification saved to storage successfully");
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: "saveNotificationToStorage",
        fileName: "notifications.dart",
        extraData: {"title": title, "body": body, "data": data},
      );
      printLog("Error saving notification to storage: $e");
    }
  }

  Future<void> sendNotification() async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic('topic_name');

      await FirebaseMessaging.instance.sendMessage(
        data: {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'type': 'sales', // Example type
          'id': '1',
          'status': 'done',
        },
      );
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: "sendNotification",
        fileName: "notifications.dart",
        lineNumber: 60,
      );
    }
  }

  void _navigateBasedOnNotification(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    try {
      if (data["url"] != null) {
        String url = data["url"];
        String notificationTitle = data["title"] ?? "إشعار";

        NavigatorApp.push(
          HomeScreen(
            scrollController:
                context.read<SubMainCategoriesController>().scrollSlidersItems,
            type: "normal",
            title: notificationTitle,
            url: url,
            hasAppBar: true,
          ),
        );
        return;
      }
      NavigatorApp.push(const NotificationsPage());
    } catch (e, stack) {
      SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: "_navigateBasedOnNotification",
        fileName: "notifications.dart",
        lineNumber: 90,
        extraData: {"data": data},
      );
    }
  }

  setNotifications() async {
    try {
      // Add breadcrumb for notification setup

      LocalNotificationService.initialize(NavigatorApp.context);
      FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

      FirebaseMessaging.instance.getInitialMessage().then((message) async {
        if (message != null) {
          // Save notification when app is opened from terminated state
          if (message.notification != null) {
            await saveNotificationToStorage(
              message.notification?.title,
              message.notification?.body,
              message.data,
            );
          }
          _navigateBasedOnNotification(NavigatorApp.context, message.data);
        }
      });

      FirebaseMessaging.onMessage.listen((message) async {
        try {
          if (message.notification != null) {
            // Always save notification first, regardless of display settings
            await saveNotificationToStorage(
              message.notification?.title,
              message.notification?.body,
              message.data,
            );

            // Check if app notifications are enabled before displaying
            bool shouldDisplay =
                await LocalNotificationService.shouldDisplayNotification();
            if (shouldDisplay) {
              LocalNotificationService.display(message);
              printLog("Firebase message received and displayed");
              printLog(message.notification!.body);
              printLog(message.notification!.title);
            } else {
              printLog(
                "Firebase message received but blocked - App notifications disabled",
              );
            }

            // Add breadcrumb for received message
          }
        } catch (e, stack) {
          SentryService.captureError(
            exception: e,
            stackTrace: stack,
            functionName: "onMessage_listener",
            fileName: "notifications.dart",
            lineNumber: 125,
            extraData: {"message_data": message.data},
          );
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) async {
        try {
          // Save notification when app is opened from background
          if (message.notification != null) {
            await saveNotificationToStorage(
              message.notification?.title,
              message.notification?.body,
              message.data,
            );
          }
          _navigateBasedOnNotification(NavigatorApp.context, message.data);

          // Add breadcrumb for app opened from notification
        } catch (e, stack) {
          SentryService.captureError(
            exception: e,
            stackTrace: stack,
            functionName: "onMessageOpenedApp_listener",
            fileName: "notifications.dart",
            lineNumber: 140,
            extraData: {"message_data": message.data},
          );
        }
      });

      final token = await _firebaseMessaging.getToken();
      printLog("token");
      printLog(token);

      if (token != null) {
        // final installationId = await FirebaseAppInstallations.instance.getId();
        // print('Firebase Installation ID: $installationId');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('device_token', token.toString());
      } else {
        await SentryService.captureError(
          exception: "Failed to get FCM token",
          functionName: "setNotifications",
          fileName: "notifications.dart",
          lineNumber: 160,
        );
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: "setNotifications",
        fileName: "notifications.dart",
        lineNumber: 165,
      );
    }
  }

  void dispose() {
    try {
      streamCtlr.close();
      bodyCtlr.close();
      titleCtlr.close();
    } catch (e, stack) {
      SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: "dispose",
        fileName: "notifications.dart",
        lineNumber: 180,
      );
    }
  }
}
