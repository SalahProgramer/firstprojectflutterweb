import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fawri_app_refactor/salah/controllers/page_main_screen_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/product_item_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/sub_main_categories_conrtroller.dart';
import 'package:fawri_app_refactor/salah/models/notifications/notifications_model.dart';
import 'package:fawri_app_refactor/salah/views/pages/home/home_screen/home_screen.dart';
import 'package:fawri_app_refactor/salah/views/pages/home/main_screen/product_item_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../salah/controllers/APIS/api_product_item.dart';
import '../../server/functions/functions.dart';
import '../../salah/utilities/sentry_service.dart';
import '../../salah/utilities/global/app_global.dart';
import '../../salah/views/pages/notifications/notifications_page.dart';
import 'package:provider/provider.dart';
import '../../salah/controllers/notification_controller.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Flag to prevent double navigation from terminated state
  static bool _hasHandledTerminatedNavigation = false;

  // Store pending notification data to handle after app initialization
  static Map<String, dynamic>? _pendingNotificationData;

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

  // Cancel all displayed notifications if settings are disabled
  static Future<void> cancelAllIfDisabled() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool appEnabled = prefs.getBool('app_notifications_enabled') ?? true;

      printLog("cancelAllIfDisabled - Current state: $appEnabled");

      if (!appEnabled) {
        // Cancel all local notifications
        await _notificationsPlugin.cancelAll();
        printLog(
          "✅ All Flutter Local Notifications cancelled - app notifications disabled",
        );

        // Also cancel Awesome Notifications to be thorough
        try {
          await AwesomeNotifications().cancelAll();
          await AwesomeNotifications().cancelAllSchedules();
          printLog("✅ All Awesome Notifications cancelled");
        } catch (e) {
          printLog(
            "Note: Could not cancel Awesome Notifications (might not be initialized): $e",
          );
        }
      }
    } catch (e) {
      printLog('Error cancelling notifications: $e');
    }
  }

  // Set pending notification data (called from Firebase getInitialMessage)
  static void setPendingNotificationData(Map<String, dynamic> data) {
    _pendingNotificationData = data;
    printLog("📝 Pending notification data set:");
    printLog("   SKU: ${data['sku']}");
    printLog("   URL: ${data['url']}");
    printLog("   Title: ${data['title']}");
  }

  // Check if app was launched from a notification and store the data
  static Future<void> checkPendingNotification() async {
    try {
      printLog(
        "🔍 Checking for pending notification from local notifications...",
      );
      final NotificationAppLaunchDetails? details = await _notificationsPlugin
          .getNotificationAppLaunchDetails();

      printLog(
        "NotificationAppLaunchDetails: didLaunchApp=${details?.didNotificationLaunchApp}, hasResponse=${details?.notificationResponse != null}",
      );

      if (details != null &&
          details.didNotificationLaunchApp &&
          details.notificationResponse != null) {
        String? payload = details.notificationResponse!.payload;
        printLog("Notification payload: $payload");

        if (payload != null && payload.isNotEmpty) {
          try {
            _pendingNotificationData = jsonDecode(payload);
            printLog("✅ Pending notification found from local notifications!");
            printLog("   SKU: ${_pendingNotificationData?['sku']}");
            printLog("   URL: ${_pendingNotificationData?['url']}");
            printLog("   Title: ${_pendingNotificationData?['title']}");
          } catch (e) {
            printLog("❌ Error parsing pending notification: $e");
          }
        } else {
          printLog("⚠️ Payload is null or empty");
        }
      } else {
        printLog("ℹ️ No pending notification found from local notifications");
      }
    } catch (e) {
      printLog("❌ Error checking pending notification: $e");
    }
  }

  // Handle pending notification after app is fully initialized
  static Future<void> handlePendingNotification(BuildContext context) async {
    ApiProductItemController apiProductItemController = context
        .read<ApiProductItemController>();
    printLog("📱 handlePendingNotification called");

    if (_pendingNotificationData == null) {
      printLog("ℹ️ No pending notification data to handle");
      return;
    }

    try {
      Map<String, dynamic> data = _pendingNotificationData!;
      _pendingNotificationData = null; // Clear it

      printLog("🔄 Processing pending notification data: $data");

      // Add delay to ensure app is fully initialized
      await Future.delayed(const Duration(milliseconds: 500));

      // Priority 1: If notification has SKU, navigate to specific product
      if (data["sku"] != null && data["sku"].toString().isNotEmpty) {
        String sku = data["sku"].toString();
        printLog("🚀 Navigating to product with SKU: $sku");

        final productItemController = context.read<ProductItemController>();
        final pageMainScreenController = context
            .read<PageMainScreenController>();
        await pageMainScreenController.changePositionScroll(sku, 0);
        await productItemController.clearItemsData();
        await apiProductItemController.cancelRequests();
        await productItemController.getSpecificProduct(sku);

        if (productItemController.isTrue == true &&
            productItemController.specificItemData != null) {
          NavigatorApp.push(
            ProductItemView(
              item: productItemController.specificItemData!,
              sizes: "",
            ),
          );
        } else {
          // If product not found, go to notifications page
          printLog("⚠️ Product not found, navigating to notifications page");
          NavigatorApp.push(const NotificationsPage());
        }
      }
      // Priority 2: If notification has URL, navigate to HomeScreen
      else if (data["url"] != null && data["url"].toString().isNotEmpty) {
        String url = data["url"].toString();
        String notificationTitle = data["title"]?.toString() ?? "إشعار";

        printLog("🚀 Navigating to HomeScreen with URL: $url");

        final subMainCategoriesController = context
            .read<SubMainCategoriesController>();
        await subMainCategoriesController.clear();

        NavigatorApp.push(
          HomeScreen(
            scrollController: subMainCategoriesController.scrollSlidersItems,
            type: "normal",
            title: notificationTitle,
            url: url,
            hasAppBar: true,
          ),
        );
      }
      // Priority 3: Default to NotificationsPage if no SKU or URL
      else {
        printLog(
          "⚠️ No SKU or URL found in notification data - navigating to NotificationsPage",
        );
        NavigatorApp.push(const NotificationsPage());
      }
    } catch (e, stack) {
      printLog("❌ Error handling pending notification: $e");
      SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: "handlePendingNotification",
        fileName: "local_notification_service.dart",
      );
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
                printLog("📬 onDidReceiveNotificationResponse triggered");
                printLog("   actionId: ${notificationResponse.actionId}");
                printLog("   payload: ${notificationResponse.payload}");

                // If there's pending notification data, it means we're handling it via handlePendingNotification
                // Skip this handler to avoid duplicate navigation
                if (_pendingNotificationData != null) {
                  printLog(
                    "⏭️ Skipping - will be handled by handlePendingNotification",
                  );
                  return;
                }

                // Check if we already handled navigation from terminated state
                if (_hasHandledTerminatedNavigation) {
                  printLog(
                    "⏭️ Skipping duplicate navigation from local notification",
                  );
                  _hasHandledTerminatedNavigation =
                      false; // Reset for next time
                  return;
                }

                // Mark that we're handling navigation
                _hasHandledTerminatedNavigation = true;

                // Add delay to ensure app is fully initialized
                await Future.delayed(const Duration(milliseconds: 300));

                // Check if we can navigate safely
                if (NavigatorApp.navigatorKey.currentContext != null) {
                  // Parse notification data from payload
                  Map<String, dynamic> data = {};
                  if (notificationResponse.payload != null &&
                      notificationResponse.payload!.isNotEmpty) {
                    try {
                      data = jsonDecode(notificationResponse.payload!);
                    } catch (e) {
                      printLog("Error parsing notification payload: $e");
                    }
                  }

                  // Navigate based on notification data
                  final context = NavigatorApp.navigatorKey.currentContext!;

                  // Priority 1: If notification has SKU, navigate to specific product
                  if (data["sku"] != null &&
                      data["sku"].toString().isNotEmpty) {
                    String sku = data["sku"].toString();

                    final productItemController = context
                        .read<ProductItemController>();
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
                    } else {
                      // If product not found, go to notifications page
                      NavigatorApp.push(const NotificationsPage());
                    }
                  }
                  // Priority 2: If notification has URL, navigate to HomeScreen
                  else if (data["url"] != null &&
                      data["url"].toString().isNotEmpty) {
                    String url = data["url"].toString();
                    String notificationTitle =
                        data["title"]?.toString() ?? "إشعار";

                    final subMainCategoriesController = context
                        .read<SubMainCategoriesController>();
                    await subMainCategoriesController.clear();

                    NavigatorApp.push(
                      HomeScreen(
                        scrollController:
                            subMainCategoriesController.scrollSlidersItems,
                        type: "normal",
                        title: notificationTitle,
                        url: url,
                        hasAppBar: true,
                      ),
                    );
                  }
                  // Priority 3: Default to NotificationsPage
                  else {
                    NavigatorApp.push(const NotificationsPage());
                  }
                }

                // Reset flag after successful navigation
                await Future.delayed(const Duration(milliseconds: 500));
                _hasHandledTerminatedNavigation = false;
              } catch (e, stack) {
                _hasHandledTerminatedNavigation = false; // Reset on error
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
      // CRITICAL: Double-check if notifications should be displayed based on app settings
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool appEnabled = prefs.getBool('app_notifications_enabled') ?? true;

      if (!appEnabled) {
        printLog(
          "Firebase notification BLOCKED (display check 1) - App notifications disabled",
        );
        return;
      }

      bool shouldDisplay = await shouldDisplayNotification();
      if (!shouldDisplay) {
        printLog(
          "Firebase notification BLOCKED (display check 2) - App notifications disabled",
        );
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
          ongoing: false, // Changed to false to allow dismissing
          priority: Priority.high,
          enableLights: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      // Encode notification data as JSON for payload
      String payload = jsonEncode(message.data);

      await _notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: payload,
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

  // Direct notification display for background/terminated state
  static Future<void> showNotificationDirect({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      // CRITICAL: Double-check notification settings before displaying
      // First check - using SharedPreferences directly for reliability
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool appEnabled = prefs.getBool('app_notifications_enabled') ?? true;

      if (!appEnabled) {
        printLog(
          "Direct notification BLOCKED (check 1) - App notifications disabled: $title",
        );
        return;
      }

      // Second check - using helper method
      bool shouldDisplay = await shouldDisplayNotification();
      if (!shouldDisplay) {
        printLog(
          "Direct notification BLOCKED (check 2) - App notifications disabled: $title",
        );
        return;
      }

      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "app_notification",
          "app_notification channel",
          playSound: true,
          icon: "@mipmap/launcher_icon",
          importance: Importance.max,
          ongoing: false,
          priority: Priority.high,
          enableLights: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      printLog("Direct notification displayed successfully: $title");
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: "showNotificationDirect",
        fileName: "local_notification_service.dart",
        extraData: {"title": title, "body": body, "payload": payload},
      );
      printLog("Error showing direct notification: $e");
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
        image: data["image"],
        sku: data["sku"],
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
