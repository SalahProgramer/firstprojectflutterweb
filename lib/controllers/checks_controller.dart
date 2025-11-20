import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/dynamic_link/dynamic_link_service.dart';
import '../core/services/firebase/remote_config_firebase/remote_config_firebase.dart';
import '../core/services/notifications/notification_service.dart';
import '../core/utilities/global/app_global.dart';
import '../views/login/login_screen.dart';
import '../views/pages/pages.dart';

class ChecksController extends ChangeNotifier {
  bool firstScreen = true;
  String version = "1.0.0";
  bool forceUpdate = false;
  bool timerCancelled = false;
  bool navigationTriggered = false;

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
    if (firstScreen) {
      NavigatorApp.navigateToRemoveUntil(LoginScreen());
    } else {
      NavigatorApp.navigateToRemoveUntil(Pages());

      await NotificationService.handleInitialActionIfAny();

      if (DynamicLinkService.initialUri != null) {
        DynamicLinkService.handleInitialUriIfNeeded();
      }
    }
  }
}
