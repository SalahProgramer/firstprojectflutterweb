import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'core/services/analytics/analytics_service.dart';
import 'core/services/dynamic_link/dynamic_link_service.dart';
import 'core/services/locator.dart';
import 'core/services/notifications/notification_service.dart';
import 'core/services/sentry/sentry_service.dart';
import 'core/utilities/providers.dart';
import 'fawri_main/fawri_main.dart';
import 'games/audio_helper.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

    await NotificationService.initializeNotification();
    await Firebase.initializeApp();
    FirebaseInAppMessaging.instance.setAutomaticDataCollectionEnabled(true);
    await setupServiceLocator();
    await AnalyticsService.logAppLaunch();
    await DynamicLinkService().initDynamicLink();
    // await LocalStorage().initHive();
    




   if(!kReleaseMode){
     errorHandle();
   }
  } catch (e, stack) {
    await SentryService.captureError(exception: e, stackTrace: stack);
  }
  await getIt.get<AudioHelper>().initialize();

  SentryService.init(
      appRunner: () => runApp(
            SentryWidget(
              child: MultiProvider(
                providers: providers,
                child: Fawri(),
              ),
            ),
          ));
}


Future<void> errorHandle()async{

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        "Error\n${details.exception}",
      ),
    );
  };
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

}


