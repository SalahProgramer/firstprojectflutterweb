import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utilities/print_looger.dart';
import '../sentry/sentry_service.dart';

/// Web-specific notification service using Firebase Cloud Messaging
class WebNotificationService {
  static FirebaseMessaging? _messaging;
  static const String _notificationKey = 'app_notifications_enabled';

  /// Initialize Firebase Cloud Messaging for web
  static Future<void> initialize() async {
    if (!kIsWeb) {
      printLog('WebNotificationService is only for web platform');
      return;
    }

    try {
      _messaging = FirebaseMessaging.instance;

      // Request permission for web notifications
      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        printLog('User granted notification permission');
        
        // Get FCM token for this device
        String? token = await _messaging!.getToken(
          vapidKey: 'YOUR_VAPID_KEY', // You need to get this from Firebase Console
        );
        printLog('FCM Token: $token');
        
        // Save token to use for sending notifications
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('fcm_token', token);
        }
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        printLog('User granted provisional permission');
      } else {
        printLog('User declined or has not accepted notification permission');
      }

      // Listen for foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        printLog('Received foreground message: ${message.notification?.title}');
        
        if (message.notification != null) {
          _showWebNotification(
            title: message.notification!.title ?? 'Notification',
            body: message.notification!.body ?? '',
          );
        }
      });

      // Handle notification clicks
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        printLog('Notification clicked: ${message.notification?.title}');
        _handleNotificationClick(message);
      });

      // Check if app was opened from a notification
      RemoteMessage? initialMessage = await _messaging!.getInitialMessage();
      if (initialMessage != null) {
        printLog('App opened from notification: ${initialMessage.notification?.title}');
        _handleNotificationClick(initialMessage);
      }

    } catch (e, stack) {
      printLog('Error initializing web notifications: $e');
      SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'WebNotificationService.initialize',
      );
    }
  }

  /// Show a local web notification using Web Notifications API
  static Future<void> _showWebNotification({
    required String title,
    required String body,
  }) async {
    try {
      // Use Web Notifications API through JS interop
      printLog('Showing web notification: $title');
      
      // The actual notification will be shown by the browser
      // when Firebase Cloud Messaging receives a message
    } catch (e) {
      printLog('Error showing web notification: $e');
    }
  }

  /// Show a notification manually
  static Future<void> showNotification({
    required String title,
    required String body,
    String? icon,
    Map<String, dynamic>? data,
  }) async {
    if (!kIsWeb) return;

    try {
      if (!await canSendNotification()) {
        printLog('Notifications are disabled');
        return;
      }

      printLog('Showing notification: $title');
      
      // For web, we need to use the service worker to show notifications
      // This is a simplified version - in production, you'd send this through your backend
      // to Firebase Cloud Messaging, which will then deliver it to the browser
      
    } catch (e) {
      printLog('Error showing notification: $e');
    }
  }

  /// Check if notifications are allowed
  static Future<bool> canSendNotification() async {
    try {
      // Check system permission
      if (_messaging == null) return false;
      
      NotificationSettings settings = await _messaging!.getNotificationSettings();
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        return false;
      }

      // Check app-level preference
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool appEnabled = prefs.getBool(_notificationKey) ?? true;

      return appEnabled;
    } catch (e) {
      printLog('Error checking notification permission: $e');
      return false;
    }
  }

  /// Request notification permission
  static Future<bool> requestPermission() async {
    if (!kIsWeb) return false;
    
    try {
      if (_messaging == null) {
        await initialize();
      }

      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      bool granted = settings.authorizationStatus == AuthorizationStatus.authorized;
      
      if (granted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_notificationKey, true);
      }

      return granted;
    } catch (e) {
      printLog('Error requesting notification permission: $e');
      return false;
    }
  }

  /// Disable notifications
  static Future<void> disableNotifications() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationKey, false);
      printLog('Notifications disabled');
    } catch (e) {
      printLog('Error disabling notifications: $e');
    }
  }

  /// Enable notifications
  static Future<bool> enableNotifications() async {
    try {
      bool granted = await requestPermission();
      if (granted) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_notificationKey, true);
        printLog('Notifications enabled');
      }
      return granted;
    } catch (e) {
      printLog('Error enabling notifications: $e');
      return false;
    }
  }

  /// Handle notification click
  static void _handleNotificationClick(RemoteMessage message) {
    // Handle navigation based on notification data
    printLog('Handling notification click with data: ${message.data}');
    
    // You can implement navigation logic here based on message.data
    // For example:
    // if (message.data['destination'] == 'cart') {
    //   NavigatorApp.push(const MyCart());
    // }
  }

  /// Get FCM token
  static Future<String?> getToken() async {
    if (!kIsWeb) return null;
    
    try {
      if (_messaging == null) {
        await initialize();
      }
      return await _messaging?.getToken(
        vapidKey: 'YOUR_VAPID_KEY', // Replace with your VAPID key
      );
    } catch (e) {
      printLog('Error getting FCM token: $e');
      return null;
    }
  }
}

