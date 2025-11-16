import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../server/functions/functions.dart';

Future<void> iosPush() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    printLog('User granted permission');
  } else {
    printLog('User declined or has not accepted permission');
  }
}
