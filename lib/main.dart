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
import 'core/services/firebase/firebase_options.dart';
import 'core/services/locator.dart';
import 'core/services/notifications/notification_service.dart';
import 'core/services/sentry/sentry_service.dart';
import 'core/utilities/functions.dart';
import 'core/utilities/providers.dart';
import 'fawri_main/fawri_main.dart';
import 'games/audio_helper.dart';

void main() async {
  try {
    // ============================================
    // PHASE 1: Core System Setup (Sequential)
    // ============================================
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

    // ============================================
    // PHASE 2: Independent Services (Parallel)
    // ============================================
    // These services don't depend on each other and can run concurrently
    await Future.wait([
      NotificationService.initializeNotification(),
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    ]);

    // ============================================
    // PHASE 3: Firebase-Dependent Services (Sequential)
    // ============================================
    // Must run after Firebase initialization
    FirebaseInAppMessaging.instance.setAutomaticDataCollectionEnabled(true);
    
    // Setup service locator (required for AudioHelper and other services)
    await setupServiceLocator();

    // ============================================
    // PHASE 4: Service Locator-Dependent Services (Parallel)
    // ============================================
    // These services depend on setupServiceLocator but not on each other
    await Future.wait([
      AnalyticsService.logAppLaunch(),
      DynamicLinkService().initDynamicLink(),
      _initializeAudioHelper(),
      // Uncomment when ready:
      // LocalStorage().initHive(),
    ]);

    // ============================================
    // PHASE 5: Error Handling Setup
    // ============================================
    if (!kReleaseMode) {
      errorHandle();
    }
  } catch (e, stack) {
    await SentryService.captureError(exception: e, stackTrace: stack);
  }

  // ============================================
  // PHASE 6: App Launch
  // ============================================
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

/// Helper function to initialize AudioHelper with error handling
Future<void> _initializeAudioHelper() async {
  try {
    await getIt.get<AudioHelper>().initialize();
  } catch (e, stack) {
    await SentryService.captureError(exception: e, stackTrace: stack);
    printLog('AudioHelper initialization failed: $e');
  }
}

Future<void> errorHandle() async {
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
