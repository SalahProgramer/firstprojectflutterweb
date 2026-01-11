import 'dart:async';
import 'dart:math' as math;

import 'package:fawri_app_refactor/salah/controllers/fetch_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/page_main_screen_controller.dart';
import 'package:fawri_app_refactor/salah/utilities/networks/connection_network.dart';
import 'package:fawri_app_refactor/salah/utilities/style/colors.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:fawri_app_refactor/salah/views/pages/home/main_screen/first_project_webview_page.dart';
import 'package:fawri_app_refactor/server/functions/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import '../../dialog/dialogs/dialog_blocked/dialog_blocked.dart';
import '../../dialog/dialogs/dialog_update/dialog_update.dart';
import '../controllers/checks_controller.dart';
import '../utilities/style/text_style.dart';
import '../utilities/sentry_service.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  Timer? timer;
  // DateTime? _splashStartTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((callback) async {
      // _splashStartTime = DateTime.now();
      await initializeSplash();
    });
  }

  /// Initialize splash screen with parallel execution and comprehensive error handling
  Future<void> initializeSplash() async {
    try {
      // Get all required controllers
      final ChecksController checksController = context
          .read<ChecksController>();
      final FetchController fetchController = context.read<FetchController>();
      final PageMainScreenController pageMainScreenController = context
          .read<PageMainScreenController>();
      // Phase 1: Check version and update if needed
      final bool shouldUpdate = await checkVersionAndUpdate(checksController);

      if (shouldUpdate) {
        return; // Stop here if update is required
      }

      await checksController.changeTimerCancel(cancel: false);
      timer = startTimer(
        checkController: checksController,
        pageMainScreenController: pageMainScreenController,
      );

      // Phase 2: Check network and proceed with initialization
      await initializeAppData(
        checksController: checksController,
        fetchController: fetchController,
        pageMainScreenController: pageMainScreenController,
      );
    } catch (e) {
      printLog(e.toString());
    }
  }

  /// Check app version and show update dialog if needed
  Future<bool> checkVersionAndUpdate(ChecksController checksController) async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String versionCode = packageInfo.version;

      await checksController.setVersionForceUpdate();

      final bool checkVersion = await isVersionGreater(
        versionCode.toString(),
        checksController.version.toString(),
      );

      printLog(checkVersion);
      printLog(versionCode);
      printLog(checksController.version);

      if (checkVersion) {
        await update(
          checkFirst: checksController.firstScreen,
          forceUpdate: checksController.forceUpdate,
        );
        return true; // Update required
      }

      return false; // No update needed
    } catch (e) {
      printLog(e.toString());

      return false; // Continue even if version check fails
    }
  }

  /// Initialize app data if network is available
  Future<void> initializeAppData({
    required ChecksController checksController,
    required FetchController fetchController,
    required PageMainScreenController pageMainScreenController,
  }) async {
    try {
      if (await isConnectedWifi()) {
        final prefs = await SharedPreferences.getInstance();
        final String phone = prefs.getString('phone') ?? "";

        // Check user activity status
        await pageMainScreenController.getUserActivity(phone: phone);

        if (pageMainScreenController.userActivity.isActive == false) {
          await showBlockedDialog();
          return; // Stop here if user is blocked
        }

        // Set controllers first
        await fetchController.setControllers();

        // Parallel execution of independent data fetching operations
        fetchAppDataInParallel(pageMainScreenController);

        // Handle refresh state
        await handleRefreshState(
          checksController: checksController,
          pageMainScreenController: pageMainScreenController,
        );
      }
    } catch (e) {
      printLog(e.toString());
    }
  }

  /// Fetch app data in parallel for better performance
  void fetchAppDataInParallel(
    PageMainScreenController pageMainScreenController,
  ) {
    // كل futures رح تشتغل بنفس الوقت بدون await

    pageMainScreenController.getCachedProducts().catchError((e, stack) {
      SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: '_fetchAppDataInParallel (CachedProducts)',
        fileName: 'splash.dart',
        lineNumber: 133,
      );
    });

    pageMainScreenController.getAllSliders().catchError((e, stack) {
      SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: '_fetchAppDataInParallel (Sliders)',
        fileName: 'splash.dart',
        lineNumber: 143,
      );
    });

    pageMainScreenController.getItemsViewed().catchError((e, stack) {
      SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: '_fetchAppDataInParallel (ItemsViewed)',
        fileName: 'splash.dart',
        lineNumber: 153,
      );
    });

    pageMainScreenController.fetchRecommendedItems().catchError((e, stack) {
      SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: '_fetchAppDataInParallel (RecommendedItems)',
        fileName: 'splash.dart',
        lineNumber: 162,
      );
    });

    pageMainScreenController.getAppSections().catchError((e, stack) {
      printLog(e.toString());
    });
  }

  /// Handle refresh state and navigation
  Future<void> handleRefreshState({
    required ChecksController checksController,
    required PageMainScreenController pageMainScreenController,
  }) async {
    try {
      // Check if refresh is needed
      if (pageMainScreenController.sections.isEmpty &&
          !pageMainScreenController.fetchAppSection) {
        await pageMainScreenController.changeDoRefresh(true);
      }

      // Handle navigation - ensure minimum 5 seconds splash display
      if (!checksController.navigationTriggered) {
        await checksController.changeNavigateTriggered(nav: true);
        await checksController.changeTimerCancel(cancel: true);
        timer?.cancel();

        // Auto-add user on first launch
        if (checksController.firstScreen) {
          await checksController.autoAddUser();
        }

        await Future.delayed(Duration(milliseconds: 500));

        // Navigate to WebView page
        NavigatorApp.navigateToRemoveUntil(const FirstProjectWebViewPage());
      }
    } catch (e) {
      printLog(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: basicSplash());
  }

  Future<bool> isVersionGreater(String thisVersion, String lastVersion) async {
    try {
      // Compare versions properly
      // thisVersion: current app version (e.g., "2.0.0")
      // lastVersion: server version (e.g., "1.52.0")

      printLog('Comparing versions: $thisVersion vs $lastVersion');

      final v1Parts = thisVersion.split('.').map(int.parse).toList();
      final v2Parts = lastVersion.split('.').map(int.parse).toList();

      printLog('v1Parts: $v1Parts');
      printLog('v2Parts: $v2Parts');

      final length = math.max(v1Parts.length, v2Parts.length);

      for (int i = 0; i < length; i++) {
        final v1 = i < v1Parts.length ? v1Parts[i] : 0;
        final v2 = i < v2Parts.length ? v2Parts[i] : 0;

        printLog('Comparing: $v1 vs $v2 at position $i');

        if (v1 > v2) {
          printLog(
            '$v1 > $v2, returning false (app is up to date, no update needed)',
          );
          return false; // thisVersion أكبر - app is up to date, no update needed
        }
        if (v1 < v2) {
          printLog('$v1 < $v2, returning true (app needs update)');
          return true; // lastVersion أكبر - app needs update
        }
      }

      printLog('Versions are equal, returning false');
      return false; // متساويين
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'isVersionGreater',
        fileName: 'splash.dart',
        lineNumber: 110,
      );
      return false;
    }
  }

  Timer startTimer({
    required ChecksController checkController,
    required PageMainScreenController pageMainScreenController,
  }) {
    return Timer(Duration(seconds: 5), () async {
      try {
        if (!(checkController.timerCancelled) &&
            !(checkController.navigationTriggered)) {
          await checkController.changeNavigateTriggered(nav: true);
          await pageMainScreenController.changeDoRefresh(true);
          
          // Auto-add user on first launch
          if (checkController.firstScreen) {
            await checkController.autoAddUser();
          }

          // Navigate to WebView page
          NavigatorApp.navigateToRemoveUntil(const FirstProjectWebViewPage());
        }
      } catch (e, stack) {
        await SentryService.captureError(
          exception: e,
          stackTrace: stack,
          functionName: 'startTimer',
          fileName: 'splash.dart',
          lineNumber: 125,
        );
      }
    });
  }

  Widget show11() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.images.blackFridaySplash.path),

          filterQuality: FilterQuality.high,
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Widget basicSplash() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image(
              image: AssetImage(Assets.images.image.path),
              width: 0.5.sw,
              height: 0.50.sh,
              fit: BoxFit.contain,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 3.w,
                  children: [
                    Text(
                      "انتظر لحظة",
                      style: CustomTextStyle().heading1L.copyWith(
                        color: Colors.black,
                        fontSize: 16.sp,
                      ),
                    ),
                    SpinKitThreeBounce(color: Colors.black, size: 10.w),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  " لأجلك نصنع الأفضل دائمًا\n✨🛍️💫".trim(),
                  textAlign: TextAlign.center,
                  style: CustomTextStyle().heading1L.copyWith(
                    color: Colors.black,
                    fontSize: 16.sp,
                    height: 1.5.h,
                  ),
                ),
              ],
            ),
            Spacer(),
            SpinKitSpinningLines(color: CustomColor.blueColor, size: 30.w),
          ],
        ),
      ),
    );
  }
}
