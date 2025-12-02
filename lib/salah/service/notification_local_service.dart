import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fawri_app_refactor/salah/utilities/sentry_service.dart';
import 'package:fawri_app_refactor/salah/utilities/style/colors.dart';
import 'package:fawri_app_refactor/salah/views/pages/notifications/notificationsPage.dart';
import 'package:fawri_app_refactor/server/functions/functions.dart';
import 'package:flutter/material.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:fawri_app_refactor/salah/views/pages/cart/my_cart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static String channelKey = "high_important_notification_fawri";
  static Future<void> initializeNotification() async {
    // تهيئة مكتبة Awesome Notifications
    await AwesomeNotifications().initialize(
        "resource://mipmap/launcher_icon",
        [
          // تعريف قناة إشعارات جديدة
          NotificationChannel(
              channelName: "Fawri notifications",
              channelKey: channelKey,
              channelDescription: 'to set notification locally from fawri app',
              defaultColor: CustomColor.blueColor,
              ledColor: Colors.white,
              importance: NotificationImportance.Max,
              channelShowBadge: true,
              criticalAlerts: true,
              // تفعيل الإشعارات الحرجة - تتجاوز بعض قيود النظام (في iOS تحتاج إذن خاص من Apple)

              onlyAlertOnce: true,
              // تشغيل التنبيه (الصوت/الاهتزاز) مرة واحدة فقط حتى لو وصل إشعار جديد في نفس القناة

              playSound: true
              // تشغيل صوت الإشعار عند وصوله
              )
        ],
        channelGroups: [
          //جروب تشمل القنوات
          NotificationChannelGroup(
              channelGroupKey: "high_important_notification_fawri",
              channelGroupName: "Group fawri 1")
        ],
        debug: true,
        languageCode: "ar");

    await AwesomeNotifications()
        .isNotificationAllowed()
        .then((isAllowed) async {
      // if (!isAllowed) {
      //   await AwesomeNotifications().requestPermissionToSendNotifications();
      // }
    });

    // ضبط المستمعين (Listeners) لأحداث الإشعارات
    await AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceivedMethod,
        // لما المستخدم يتفاعل مع الإشعار (ضغط أو زر)
        onNotificationCreatedMethod: onNotificationCreatedMethod,
        // لما الإشعار يتم إنشاؤه
        onNotificationDisplayedMethod: onNotificationDisplayedMethod,
        // لما الإشعار يظهر على الشاشة
        onDismissActionReceivedMethod:
            onDismissActionReceivedMethod // لما المستخدم يغلق أو يرفض الإشعار
        );
  }

  /// يتم استدعاء هذا الحدث عند إنشاء الإشعار (قبل عرضه)
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    printLog(
        'onNotificationCreatedMethod (created notification)'); // تسجيل في الـ Console
  }

  /// يتم استدعاء هذا الحدث عند عرض الإشعار على الشاشة
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    printLog(
        'onNotificationDisplayedMethod (displayed)'); // تسجيل في الـ Console
  }

  /// يتم استدعاء هذا الحدث عند إغلاق/رفض الإشعار
  static Future<void> onDismissActionReceivedMethod(
      ReceivedNotification receivedNotification) async {
    printLog(
        'onDismissActionReceivedMethod   (recived/dismiss notification)'); // تسجيل في الـ Console
  }

  /// يتم استدعاء هذا الحدث عند تفاعل المستخدم مع الإشعار (ضغط أو اختيار زر)
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    printLog('onActionReceivedMethod'); // تسجيل في الـ Console

    // قراءة البيانات المرفقة مع الإشعار (Payload)
    final Map<String, String> payload =
        Map<String, String>.from(receivedAction.payload ?? {});
    await _navigateFromPayload(payload);
  }

  // التحقق من إمكانية إرسال الإشعارات
  static Future<bool> canSendNotification() async {
    try {
      // تحقق من إذن النظام
      bool systemAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!systemAllowed) {
        return false;
      }

      // تحقق من الحالة الداخلية للتطبيق
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool appEnabled = prefs.getBool('app_notifications_enabled') ?? true;

      return appEnabled;
    } catch (e) {
      printLog('Error checking notification state: $e');
      return false;
    }
  }

  // شكل الاشعار
// دالة لعرض الإشعارات
  static Future<void> showNotification(
      {required final String title, // عنوان الإشعار
      required final String body,
      required final int id, // نص الإشعار
      final String? summary, // ملخص إضافي يظهر أسفل الإشعار (اختياري)
      final Map<String, String>?
          payload, // بيانات إضافية (key-value) يتم تمريرها مع الإشعار
      final ActionType actionType =
          ActionType.Default, // نوع الإجراء عند الضغط على الإشعار
      final NotificationLayout notificationLayout =
          NotificationLayout.Default, // تصميم الإشعار
      final NotificationCategory?
          category, // تصنيف الإشعار (مكالمات، رسائل، ... إلخ)
      final String? bigPicture, // صورة كبيرة تظهر داخل الإشعار (اختياري)
      final List<NotificationActionButton>?
          actionButtons, // أزرار تفاعلية في الإشعار
      final bool scheduled = false, // إذا كان true يعني إشعار مجدول
      final int? interval, // الفاصل الزمني (بالثواني) إذا كان مجدول
      final String? imageProfile // صورة شخصية أو أيقونة كبيرة للإشعار
      }) async {
    try {
      // التحقق من إمكانية إرسال الإشعارات
      if (!await canSendNotification()) {
        printLog("الإشعارات معطلة، لن يتم الإرسال");
        return;
      }
      // شرط للتأكد: إذا الإشعار مجدول، لازم يكون فيه قيمة interval
      assert(!scheduled || (scheduled && interval != null));

      // إنشاء الإشعار
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          // رقم تعريف الإشعار (مهم لو تريد تحديثه أو حذفه لاحقًا)
          channelKey: channelKey,
          // القناة التي سيظهر فيها الإشعار
          title: title,
          // عنوان الإشعار
          body: body,
          // نص الإشعار
          showWhen: true,
          icon: "resource://mipmap/launcher_icon",
          // أيقونة صغيرة صحيحة للإشعار
          autoDismissible: true,
          // يغلق تلقائيًا عند الضغط عليه
          roundedBigPicture: true,
          // جعل الصورة الكبيرة بزوايا دائرية
          actionType: actionType,
          // نوع الفعل عند الضغط
          notificationLayout: notificationLayout,
          // شكل الإشعار
          displayOnBackground: true,
          // عرض الإشعار إذا التطبيق بالخلفية
          displayOnForeground: true,
          // عرض الإشعار إذا التطبيق مفتوح
          summary: summary,
          // ملخص إضافي
          color: CustomColor.blueColor,
          // لون الإشعار
          largeIcon: imageProfile,
          // أيقونة أو صورة كبيرة للإشعار
          roundedLargeIcon: true,
          // جعل الأيقونة الكبيرة بزوايا دائرية
          hideLargeIconOnExpand: false,
          // إظهار الأيقونة الكبيرة حتى عند توسيع الإشعار
          criticalAlert: true,
          // إشعار حرج (يتجاوز بعض القيود)
          category: category,
          // تصنيف الإشعار
          payload: payload,
          // بيانات إضافية مع الإشعار
          bigPicture: bigPicture, // صورة كبيرة في الإشعار
        ),
        actionButtons: actionButtons, // الأزرار التفاعلية إن وجدت

        // إذا الإشعار مجدول، نحدد الإعدادات هنا
        schedule: scheduled
            ? NotificationInterval(
                interval: Duration(
                    minutes: interval ?? 1), // الفاصل الزمني بين التكرار
                timeZone: await AwesomeNotifications()
                    .getLocalTimeZoneIdentifier(), // المنطقة الزمنية
                preciseAlarm: true, // دقة عالية للتنبيه
              )
            : null, // إذا الإشعار فوري، ما نحتاج جدول
      );
    } catch (e) {
      SentryService.captureError(exception: e);
    }
  }

  static const int cartReminderNotificationId = 12345;

  static Future<void> scheduleCartReminderIfNeeded({
    required int cartItemCount,
    Duration interval = const Duration(minutes: 2),
  }) async {
    try {
      // التحقق من إمكانية إرسال الإشعارات
      if (!await canSendNotification()) {
        printLog("الإشعارات معطلة، لن يتم جدولة تذكير السلة");
        return;
      }
      if (cartItemCount <= 0) {
        await AwesomeNotifications().cancelSchedule(cartReminderNotificationId);
        return;
      }

      // 3️⃣ تحقق إذا فيه إشعار مجدول بنفس ID
      List<NotificationModel> scheduled =
          await AwesomeNotifications().listScheduledNotifications();

      bool alreadyScheduled = scheduled.any(
        (n) => n.content?.id == cartReminderNotificationId,
      );

      if (alreadyScheduled) {
        printLog("تذكير السلة موجود بالفعل، لن يتم إعادة الجدولة");
        return;
      }

      // ننشئ إشعار متكرر كل interval (دقيقتين)
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: cartReminderNotificationId,
          channelKey: channelKey,
          title: "السلة مليئة بالكنوز! 🛒✨",
          body:
              "هناك منتجات رائعة تنتظرك في السلة! لا تنسَ إتمام عملية الدفع لتستمتع بتجربتك المميزة",
          icon: 'resource://mipmap/launcher_icon',
          displayOnBackground: true,
          displayOnForeground: true,
          showWhen: true,
          autoDismissible: true,
          roundedBigPicture: true,
          color: CustomColor.blueColor,
          roundedLargeIcon: true,
          hideLargeIconOnExpand: false,
          criticalAlert: true,
          notificationLayout: NotificationLayout.Default,
          payload: const {
            'navigate': 'true',
            'destination': 'cart',
          },
        ),
        schedule: NotificationInterval(
          interval: const Duration(hours: 72),
          timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
          preciseAlarm: true,
          repeats: true,
          allowWhileIdle: true,
        ),
      );
    } catch (e) {
      SentryService.captureError(exception: e);
      printLog('Error scheduling notification: $e');
    }
  }

  // fixed unique ID

  static Future<void> cancelCartReminder() async {
    await AwesomeNotifications()
        .cancelSchedule(DateTime.now().millisecondsSinceEpoch);
  }

  // Cold start handler: call this once app is up (e.g., in Fawri init) to process initial notification tap
  static Future<void> handleInitialActionIfAny() async {
    try {
      final ReceivedAction? initialAction =
          await AwesomeNotifications().getInitialNotificationAction(
        removeFromActionEvents: true,
      );
      if (initialAction != null) {
        await _navigateFromPayload(
          initialAction.payload == null
              ? null
              : Map<String, String>.from(initialAction.payload!),
        );
      }
    } catch (_) {}
  }

  static Future<void> _navigateFromPayload(Map<String, String>? payload) async {
    if (payload == null) return;
    if (payload['navigate'] == 'true') {
      final destination = payload['destination'];
      if (destination == 'cart') {
        Future.microtask(() {
          try {
            NavigatorApp.push(const MyCart());
          } catch (_) {}
        });
      } else if (destination == 'notifications') {
        Future.microtask(() {
          try {
            NavigatorApp.push(const NotificationsPage());
          } catch (_) {}
        });
      }
    }
  }
}
