import 'dart:async';
import 'dart:convert';
import 'package:fawri_app_refactor/salah/controllers/notification_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/page_main_screen_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/product_item_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/sub_main_categories_conrtroller.dart';
import 'package:fawri_app_refactor/salah/views/pages/home/home_screen/home_screen.dart';
import 'package:fawri_app_refactor/salah/views/pages/home/main_screen/product_item_view.dart';
import 'package:fawri_app_refactor/server/functions/functions.dart';
import 'package:fawri_app_refactor/salah/utilities/sentry_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../salah/utilities/global/app_global.dart';
import '../../salah/views/pages/notifications/notifications_page.dart';
import 'local_notification_service.dart';

Future<void> onBackgroundMessage(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();

    if (message.notification != null) {
      // Always save notification to storage first (even if disabled)
      // This allows users to see notifications when they re-enable them
      // Include image from android or apple notification
      Map<String, dynamic> dataWithImage = Map.from(message.data);
      if (message.notification?.android?.imageUrl != null) {
        dataWithImage['image'] = message.notification!.android!.imageUrl;
      } else if (message.notification?.apple?.imageUrl != null) {
        dataWithImage['image'] = message.notification!.apple!.imageUrl;
      }

      await _saveBackgroundNotification(
        message.notification?.title,
        message.notification?.body,
        dataWithImage,
      );

      // CRITICAL: Check if app notifications are enabled before displaying
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool appEnabled = prefs.getBool('app_notifications_enabled') ?? true;

      printLog("Background message - app_notifications_enabled: $appEnabled");
      printLog("Background message - Title: ${message.notification?.title}");

      if (appEnabled) {
        // Display notification only if enabled
        await _showBackgroundNotification(
          message.notification?.title,
          message.notification?.body,
          message.data,
        );
        printLog("✅ Background Firebase message processed and displayed");
      } else {
        printLog(
          "🚫 Background Firebase notification BLOCKED - App notifications disabled",
        );
      }
    }

    if (message.data.containsKey('type')) {
      // final type = message.data['type'];
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

Future<void> _showBackgroundNotification(
  String? title,
  String? body,
  Map<String, dynamic> data,
) async {
  try {
    // Encode notification data as JSON for payload
    String payload = jsonEncode(data);

    // Show notification using flutter_local_notifications directly
    await LocalNotificationService.showNotificationDirect(
      title: title ?? 'إشعار جديد',
      body: body ?? '',
      payload: payload,
    );
    printLog("Background notification displayed successfully");
  } catch (e, stack) {
    await SentryService.captureError(
      exception: e,
      stackTrace: stack,
      functionName: "_showBackgroundNotification",
      fileName: "notifications.dart",
      extraData: {"title": title, "body": body, "data": data},
    );
  }
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
      // Priority 1: If notification has SKU, navigate to specific product
      if (data["sku"] != null && data["sku"].toString().isNotEmpty) {
        String sku = data["sku"].toString();

        Future.delayed(const Duration(milliseconds: 100), () async {
          final productItemController = context.read<ProductItemController>();
          final pageMainScreenController = context
              .read<PageMainScreenController>();

          await pageMainScreenController.changePositionScroll(sku, 0);
          await productItemController.clearItemsData();
          await productItemController.getSpecificProduct(sku);

          if (productItemController.isTrue == true &&
              productItemController.specificItemData != null) {
            NavigatorApp.push(
              ProductItemView(
                item: productItemController.specificItemData!,
                sizes: "",
              ),
            );
          }
        });
        return;
      }

      // Priority 2: If notification has URL, navigate to HomeScreen
      if (data["url"] != null) {
        String url = data["url"];
        String notificationTitle = data["title"] ?? "إشعار";

        NavigatorApp.push(
          HomeScreen(
            scrollController: context
                .read<SubMainCategoriesController>()
                .scrollSlidersItems,
            type: "normal",
            title: notificationTitle,
            url: url,
            hasAppBar: true,
          ),
        );
        return;
      }

      // Priority 3: Default to NotificationsPage
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

      // Check Firebase initial message FIRST (for terminated state)
      // This must be awaited to ensure data is captured before app continues
      final RemoteMessage? initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) {
        printLog("🔥 Firebase getInitialMessage found: ${initialMessage.data}");

        // Save notification when app is opened from terminated state
        if (initialMessage.notification != null) {
          // Include image from android or apple notification
          Map<String, dynamic> dataWithImage = Map.from(initialMessage.data);
          if (initialMessage.notification?.android?.imageUrl != null) {
            dataWithImage['image'] =
                initialMessage.notification!.android!.imageUrl;
          } else if (initialMessage.notification?.apple?.imageUrl != null) {
            dataWithImage['image'] =
                initialMessage.notification!.apple!.imageUrl;
          }

          await saveNotificationToStorage(
            initialMessage.notification?.title,
            initialMessage.notification?.body,
            dataWithImage,
          );

          // Store the notification data for navigation handling
          LocalNotificationService.setPendingNotificationData(
            initialMessage.data,
          );
          printLog("✅ Stored Firebase initial message for navigation");
        }

        // Cancel any displayed notifications if settings are disabled
        await LocalNotificationService.cancelAllIfDisabled();
      } else {
        printLog("ℹ️ No Firebase initial message found");

        // Fallback: Check local notifications if no Firebase message
        await LocalNotificationService.checkPendingNotification();
      }

      FirebaseMessaging.onMessage.listen((message) async {
        try {
          if (message.notification != null) {
            // Always save notification first, regardless of display settings
            // Include image from android or apple notification
            Map<String, dynamic> dataWithImage = Map.from(message.data);
            if (message.notification?.android?.imageUrl != null) {
              dataWithImage['image'] = message.notification!.android!.imageUrl;
            } else if (message.notification?.apple?.imageUrl != null) {
              dataWithImage['image'] = message.notification!.apple!.imageUrl;
            }

            await saveNotificationToStorage(
              message.notification?.title,
              message.notification?.body,
              dataWithImage,
            );

            // Check if app notifications are enabled before displaying
            bool shouldDisplay =
                await LocalNotificationService.shouldDisplayNotification();
            if (shouldDisplay) {
              // Always display notification in foreground, even on notifications page
              LocalNotificationService.display(message);
              printLog("Firebase message received and displayed");
              printLog(message.notification!.body);
              printLog(message.notification!.title);
            } else {
              printLog(
                "Firebase message received but blocked - App notifications disabled",
              );
            }

            // Update notification count in real-time using NotificationController
            try {
              final controller = Provider.of<NotificationController>(
                NavigatorApp.context,
                listen: false,
              );
              await controller.loadNotifications();
              printLog("Notification count updated in real-time");
            } catch (e) {
              printLog("Error updating notification count: $e");
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
            // Include image from android or apple notification
            Map<String, dynamic> dataWithImage = Map.from(message.data);
            if (message.notification?.android?.imageUrl != null) {
              dataWithImage['image'] = message.notification!.android!.imageUrl;
            } else if (message.notification?.apple?.imageUrl != null) {
              dataWithImage['image'] = message.notification!.apple!.imageUrl;
            }

            await saveNotificationToStorage(
              message.notification?.title,
              message.notification?.body,
              dataWithImage,
            );
          }

          // Cancel any displayed notifications if settings are disabled
          await LocalNotificationService.cancelAllIfDisabled();

          // Check if notifications are enabled before navigating
          bool shouldDisplay =
              await LocalNotificationService.shouldDisplayNotification();
          if (!shouldDisplay) {
            printLog("Navigation blocked - app notifications disabled");
            return;
          }

          // Add delay to ensure smooth navigation from background
          await Future.delayed(const Duration(milliseconds: 500));

          // Verify context is still valid before navigating
          if (NavigatorApp.navigatorKey.currentContext != null) {
            _navigateBasedOnNotification(NavigatorApp.context, message.data);
          }

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
