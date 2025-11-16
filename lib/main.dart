import 'package:fawri_app_refactor/LocalDB/Database/local_storage.dart';
import 'package:fawri_app_refactor/salah/games/audio_helper.dart';
import 'package:fawri_app_refactor/salah/games/service_locator.dart';
import 'package:fawri_app_refactor/salah/service/dynamic_link_service.dart';
import 'package:fawri_app_refactor/salah/service/notification_local_service.dart';
import 'package:fawri_app_refactor/salah/utilities/sentry_service.dart';
import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'salah/utilities/providers.dart';
import 'salah/main/fawri_main.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';

Box? boxSizes;

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    // Ensure service locator is always ready before any other awaits
    await setupServiceLocator();

    if (!kIsWeb) {
      await NotificationService.initializeNotification();
    }
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

    await AnalyticsService.logAppLaunch();
    await DynamicLinkService().initDynamicLink();
    FirebaseInAppMessaging.instance.setAutomaticDataCollectionEnabled(true);
    await LocalStorage().initHive();
    


    // await FlutterNotificationChannel().registerNotificationChannel(
    //   description: 'For Showing Message Notifiation',
    //   id: 'fawri_app',
    //
    //   importance: NotificationImportance.IMPORTANCE_HIGH,
    //   name: 'fawri_app',
    //   visibility: NotificationVisibility.VISIBILITY_PUBLIC,
    //   allowBubbles: true,
    //   enableVibration: true,
    //   enableSound: true,
    //   showBadge: true,
    //
    // );
    //
    // ErrorWidget.builder = (FlutterErrorDetails details) {
    //   return Container(
    //     alignment: Alignment.center,
    //     child: Text(
    //       "Error\n${details.exception}",
    //     ),
    //   );
    // };
    // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
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
