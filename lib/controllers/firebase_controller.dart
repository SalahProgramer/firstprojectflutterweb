import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/firebase/user/user_model.dart';
import '../core/services/sentry/sentry_service.dart';
import '../core/utilities/print_looger.dart';


class FirebaseController {
  static DateTime fourDaysAgo = DateTime.now().subtract(Duration(days: 3));

  static String formattedDate = DateTime.now()
      .subtract(Duration(days: 4))
      .toIso8601String()
      .substring(0, 10);

  static String formattedDateOlder =
      fourDaysAgo.toIso8601String().substring(0, 10);

  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<void> sendNotification(UserItem user, String msg) async {
    try {
      // printLog(user.token);
      final body = {
        "to": user.token,
        "notification": {"title": user.name, "body": msg, "sound": "default"},
        "data": {
          "some_data": "User ID: ${user.id}",
        },
      };
      // var response =
      await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAACwl5eY0:APA91bHHuJ0hAZrN5X9Pxmygq8He3SwM0_2wXsUMC0JaPT3R12FWQnc3A0E9LaDEDieuwHa4lRCeYSObgT5nroTscoUjUA9CX3a6cYG9fa0L0sB-YPvVEqdk5ekMOyb24b8COE_rsuCz'
          },
          body: jsonEncode(body));
      // printLog('Response status: ${response.statusCode}');
      // printLog('Response body: ${response.body}');
    } catch (e) {
      await SentryService.captureError(
        exception: e,
        stackTrace: StackTrace.current,
        functionName: 'sendNotification',
        fileName: 'firebase_controller.dart',
        lineNumber: 42,
      );
      printLog("notification: $e");
    }
  }
}
