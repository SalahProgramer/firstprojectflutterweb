import 'package:fawri_app_refactor/salah/service/dynamic_link_service.dart';
import 'package:fawri_app_refactor/salah/service/notification_local_service.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:fawri_app_refactor/salah/views/pages/pages.dart';
import 'package:fawri_app_refactor/server/functions/functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../services/notifications/local_notification_service.dart';
import '../../services/remote_config_firebase/remote_config_firebase.dart';
import '../../firebase/user/user_controller.dart';
import '../../firebase/user/user_model.dart';

class ChecksController extends ChangeNotifier {
  bool firstScreen = true;
  String version = "1.0.0";
  bool forceUpdate = false;
  bool timerCancelled = false;
  bool navigationTriggered = false;
  final UserService userService = UserService();

  Future<void> setVersionForceUpdate() async {
    final remoteConfig = FirebaseRemoteConfigClass();

    version = await remoteConfig.fetchLastUpdate();
    forceUpdate = await remoteConfig.fetchForceUpdate();

    notifyListeners();
  }

  Future<bool> checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? seen = prefs.getBool('login');
    firstScreen = seen != true;
    notifyListeners();

    return firstScreen;
  }

  Future<void> changeTimerCancel({required bool cancel}) async {
    timerCancelled = cancel;
    notifyListeners();
  }

  Future<void> changeNavigateTriggered({required bool nav}) async {
    navigationTriggered = nav;
    notifyListeners();
  }

  Future<void> viewPage() async {
    // Auto-add user on first launch
    if (firstScreen) {
      await autoAddUser();
    }

    NavigatorApp.navigateToRemoveUntil(Pages());

    // Add small delay to ensure Pages is fully loaded
    await Future.delayed(const Duration(milliseconds: 200));

    // Handle pending FCM notification (Flutter Local Notifications)
    await LocalNotificationService.handlePendingNotification(
      NavigatorApp.context,
    );

    // Handle Awesome Notifications
    await NotificationService.handleInitialActionIfAny();

    if (DynamicLinkService.initialUri != null) {
      DynamicLinkService.handleInitialUriIfNeeded();
    }
  }

  Future<void> autoAddUser() async {
    try {
      printLog("create user");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('device_token');
      String userId = Uuid().v4();

      UserItem user = UserItem(
        name: "",
        id: userId,
        token: token.toString(),
        email: "$userId@gmail.com",
        password: "",
        address: '',
        birthdate: '',
        gender: '',
        area: '',
        city: '',
        phone: '',
      );

      await userService.addUser(user);
      await prefs.setString('user_id', userId);
      await prefs.setBool('login', true);
    } catch (e) {
      // Continue even if user creation fails
      printLog("Error auto-adding user: $e");
    }
  }
}
