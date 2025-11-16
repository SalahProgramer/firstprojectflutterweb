import 'dart:async';
import 'package:fawri_app_refactor/server/functions/functions.dart';
import 'package:fawri_app_refactor/salah/utilities/sentry_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../salah/utilities/global/app_global.dart';
import 'local_notification_service.dart';

Future<void> onBackgroundMessage(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();

    // Check if app notifications are enabled
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool appEnabled = prefs.getBool('app_notifications_enabled') ?? true;

    if (!appEnabled) {
      printLog(
          "Background Firebase message blocked - App notifications disabled");
      return;
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

class FCM {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final streamCtlr = StreamController<String>.broadcast();
  final titleCtlr = StreamController<String>.broadcast();
  final bodyCtlr = StreamController<String>.broadcast();

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
      BuildContext context, Map<String, dynamic> data) {
    try {
      final type = data['type'];

      // Add breadcrumb for navigation

      switch (type) {
        case 'sales':
          Navigator.pushNamed(context, '/sales');
          break;
        case 'order_status':
          Navigator.pushNamed(context, '/order_status');
          break;
        case 'product':
          Navigator.pushNamed(context, '/product_details',
              arguments: {'productId': data['productId']});
          break;
        default:
          break;
      }
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

      FirebaseMessaging.instance.getInitialMessage().then((message) {
        if (message != null) {
          _navigateBasedOnNotification(NavigatorApp.context, message.data);
        }
      });

      FirebaseMessaging.onMessage.listen((message) async {
        try {
          if (message.notification != null) {
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
                  "Firebase message received but blocked - App notifications disabled");
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

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        try {
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
