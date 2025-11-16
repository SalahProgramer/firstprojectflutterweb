import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:fawri_app_refactor/server/functions/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../service/notification_local_service.dart';
import '../widgets/snackBarWidgets/snack_bar_style.dart';
import '../widgets/snackBarWidgets/snackbar_widget.dart';

class NotificationController extends ChangeNotifier {
  bool notificationsEnabled = false; // هل التطبيق يسمح بالإشعارات من داخله
  static String channelKey = "high_important_notification_fawri";
  static const String _notificationKey = 'app_notifications_enabled';
  final AnalyticsService analyticsService = AnalyticsService();

  // حفظ الحالة في SharedPreferences
  Future<void> _saveNotificationState() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationKey, notificationsEnabled);
      printLog("Saved notification state: $notificationsEnabled");
    } catch (e) {
      printLog('Error saving notification state: $e');
    }
  }

  // استرجاع الحالة من SharedPreferences
  Future<void> _loadNotificationState() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      notificationsEnabled =
          prefs.getBool(_notificationKey) ?? true; // افتراضياً مفعل
      printLog("Loaded notification state: $notificationsEnabled");
    } catch (e) {
      printLog('Error loading notification state: $e');
      notificationsEnabled = true; // افتراضياً مفعل في حالة الخطأ
    }
  }

  // Initialize notification permission status
  Future<void> initializeNotificationStatus() async {
    try {
      // استرجاع الحالة المحفوظة من SharedPreferences
      await _loadNotificationState();

      // تحقق من إذن النظام
      bool systemAllowed = await AwesomeNotifications().isNotificationAllowed();

      // إذا النظام لا يسمح، تأكد أن التطبيق معطل
      if (!systemAllowed) {
        notificationsEnabled = false;
        await _saveNotificationState(); // حفظ الحالة الجديدة
      }
      // إذا النظام يسمح، استخدم الحالة المحفوظة من التطبيق

      await analyticsService.logEvent(
        eventName: "notification_permission_status_checked",
        parameters: {
          "class_name": "NotificationController",
          "status": (systemAllowed && notificationsEnabled)
              ? "allowed"
              : "not_allowed",
          "time": DateTime.now().toString(),
        },
      );

      notifyListeners();
      printLog(
          "System allowed: $systemAllowed, App enabled: $notificationsEnabled");
    } catch (e) {
      printLog('Error checking notification permission: $e');
      notificationsEnabled = false;
      notifyListeners();
    }
  }

  // Handle notification toggle
  Future<void> handleNotificationToggle(
      bool value, BuildContext context) async {
    if (value) {
      await enableNotifications(context);
    } else {
      await disableNotifications(context);
    }
  }

  // Enable notifications
  Future<void> enableNotifications(BuildContext context) async {
    try {
      // طلب إذن النظام إذا لم يكن مفعل
      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        isAllowed =
            await AwesomeNotifications().requestPermissionToSendNotifications();
      }

      if (isAllowed) {
        notificationsEnabled = true;
        await _saveNotificationState(); // حفظ الحالة

        // إرسال إشعار تجريبي
        await NotificationService.showNotification(
            title: 'إشعارات فوري',
            body: "تم تفعيل الإشعارات بنجاح!",
            id: 999999);
      } else {
        notificationsEnabled = false;
        await _saveNotificationState(); // حفظ الحالة
        showSnackBar(
          title: "تم رفض إذن الإشعارات من النظام",
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      printLog('Error enabling notifications: $e');
    } finally {
      notifyListeners();
    }
  }

  // Disable notifications (stop from app side)
  Future<void> disableNotifications(BuildContext context) async {
    try {
      // إلغاء كل الإشعارات المجدولة والحالية (Awesome Notifications)
      await AwesomeNotifications().cancelAllSchedules();
      await AwesomeNotifications().cancelAll();

      // تحديث الحالة الداخلية للتطبيق فقط (لا يؤثر على إذن النظام)
      notificationsEnabled = false;
      await _saveNotificationState(); // حفظ الحالة

      showSnackBar(title: "تم إيقاف الإشعارات", type: SnackBarType.success);

      notifyListeners();
    } catch (e) {
      printLog('Error disabling notifications: $e');
    }
  }

  // Get current notification state (for external services)
  bool get isNotificationEnabled => notificationsEnabled;

  // Test Firebase notification integration
  Future<void> testFirebaseNotification(BuildContext context) async {
    try {
      // Check current notification state
      bool currentState = notificationsEnabled;
      printLog("Current notification state: $currentState");

      if (currentState) {
        // Send a test local notification to simulate Firebase
        await NotificationService.showNotification(
          title: 'اختبار Firebase',
          body: "هذا إشعار تجريبي لاختبار تكامل Firebase مع إعدادات التطبيق",
          id: 888888,
        );

        showSnackBar(
            title: "تم إرسال إشعار تجريبي - الإشعارات مفعلة",
            type: SnackBarType.success);
      } else {
        showSnackBar(
            title: "الإشعارات معطلة - لن يتم إرسال إشعار تجريبي",
            type: SnackBarType.error);
      }
    } catch (e) {
      printLog('Error testing Firebase notification: $e');
      showSnackBar(title: "خطأ في اختبار الإشعارات", type: SnackBarType.error);
    }
  }
}
