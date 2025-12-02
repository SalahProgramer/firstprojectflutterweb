import 'dart:async';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/controllers/checks_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/fetch_controller.dart';
import 'package:fawri_app_refactor/salah/utilities/networks/connection_network.dart';
import 'package:fawri_app_refactor/salah/utilities/sentry_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../salah/controllers/page_main_screen_controller.dart';
import '../../../salah/utilities/global/app_global.dart';
import '../../../salah/utilities/style/colors.dart';
import '../../../salah/utilities/style/text_style.dart';

import '../../../salah/widgets/custom_button.dart';
import '../../../salah/widgets/lottie_widget.dart';
import '../dialog_blocked/dialog_blocked.dart';

Future<void> update({required bool checkFirst, required forceUpdate}) {
  return showGeneralDialog(
      context: NavigatorApp.navigatorKey.currentState!.context,
      barrierLabel: "ccc",
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        PageMainScreenController pageMainScreenController =
            context.read<PageMainScreenController>();
        ChecksController checksController = context.read<ChecksController>();
        FetchController fetchController = context.read<FetchController>();
        Timer? timer;

        return PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: Colors.white,
            // insetAnimationCurve: Curves.bounceInOut,
            title: SizedBox(),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LottieWidget(
                  name: Assets.lottie.mobileUpdate,
                  height: 45.w,
                  width: 45.w,
                ),
                Text(" تحديث ",
                    style: CustomTextStyle()
                        .heading1L
                        .copyWith(color: Colors.black, fontSize: 17.sp)),
                SizedBox(
                  height: 5.h,
                ),
                Text(
                    "نحن نعمل دائمًا لتحسين تجربتك، حدث تطبيقك الآن للحصول على أفضل أداء و خصومات وجوائز!",
                    style: CustomTextStyle()
                        .heading1L
                        .copyWith(color: Colors.black54, fontSize: 10.sp)),
              ],
            ),
            actions: [
              CustomButtonWithoutIcon(
                text: "تحديث",
                height: 40.h,
                backColor: CustomColor.blueColor,
                textStyle: CustomTextStyle()
                    .rubik
                    .copyWith(color: Colors.white, fontSize: 12.sp),
                onPressed: () => handleUpdateButton(),
                textWaiting: '',
              ),
              if (!forceUpdate)
                Center(
                  child: CustomButtonWithIconWithoutBackground(
                      text: "ليس الآن",
                      textIcon: "",
                      height: 16.h,
                      textStyle: CustomTextStyle().rubik.copyWith(
                          color: CustomColor.greyColor, fontSize: 11.sp),
                      onPressed: () => handleSkipUpdate(
                            checksController: checksController,
                            pageMainScreenController: pageMainScreenController,
                            fetchController: fetchController,
                            timer: timer,
                            setTimer: (t) => timer = t,
                          )),
                ),
            ],
          ),
        );
      });
}

/// Handle update button press with comprehensive error handling
Future<void> handleUpdateButton() async {
  try {
    const playStoreUrl = 'https://www.fawri.co/Fawriapp';
    if (await canLaunchUrl(Uri.parse(playStoreUrl))) {
      await launchUrl(
        Uri.parse(playStoreUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  } catch (e, stack) {
    await SentryService.captureError(
      exception: e,
      stackTrace: stack,
      functionName: '_handleUpdateButton',
      fileName: 'dialog_update.dart',
      lineNumber: 95,
    );
  }
}

/// Handle skip update button with parallel execution and comprehensive error handling
Future<void> handleSkipUpdate({
  required ChecksController checksController,
  required PageMainScreenController pageMainScreenController,
  required FetchController fetchController,
  Timer? timer,
  required Function(Timer?) setTimer,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final String phone = prefs.getString('phone') ?? "";

    // Close dialog and reset navigation states
    NavigatorApp.pop();
    await resetNavigationStates(checksController);

    // Check connection and proceed
    if (await isConnectedWifi()) {
      await initializeAfterSkipUpdate(
        phone: phone,
        pageMainScreenController: pageMainScreenController,
        fetchController: fetchController,
        checksController: checksController,
        setTimer: setTimer,
      );
    }
  } catch (e, stack) {
    await SentryService.captureError(
      exception: e,
      stackTrace: stack,
      functionName: '_handleSkipUpdate',
      fileName: 'dialog_update.dart',
      lineNumber: 116,
    );
  }
}

/// Reset navigation states
Future<void> resetNavigationStates(ChecksController checksController) async {
  try {
    await Future.wait<void>([
      checksController.changeNavigateTriggered(nav: false).catchError((e, stack) {
        SentryService.captureError(
          exception: e,
          stackTrace: stack,
          functionName: '_resetNavigationStates (NavigateTriggered)',
          fileName: 'dialog_update.dart',
          lineNumber: 154,
        );
        throw e;
      }),
      checksController.changeTimerCancel(cancel: false).catchError((e, stack) {
        SentryService.captureError(
          exception: e,
          stackTrace: stack,
          functionName: '_resetNavigationStates (TimerCancel)',
          fileName: 'dialog_update.dart',
          lineNumber: 164,
        );
        throw e;
      }),
    ]);
  } catch (e, stack) {
    await SentryService.captureError(
      exception: e,
      stackTrace: stack,
      functionName: '_resetNavigationStates',
      fileName: 'dialog_update.dart',
      lineNumber: 146,
    );
  }
}

/// Initialize app after skipping update
Future<void> initializeAfterSkipUpdate({
  required String phone,
  required PageMainScreenController pageMainScreenController,
  required FetchController fetchController,
  required ChecksController checksController,
  required Function(Timer?) setTimer,
}) async {
  try {
    // Check user activity status
    await pageMainScreenController.getUserActivity(phone: phone);

    if (pageMainScreenController.userActivity.isActive == false) {
      await showBlockedDialog();
      return; // Stop here if user is blocked
    }

    // Start timer for navigation
    setTimer(startTimer(checkController: checksController));

    // Set controllers first
    await fetchController.setControllers();

    // Parallel execution of data fetching operations
    await fetchAppDataAfterSkipUpdate(pageMainScreenController);

    // Handle refresh state
    await handleRefreshStateAfterSkipUpdate(
      pageMainScreenController: pageMainScreenController,
      checksController: checksController,
    );
  } catch (e, stack) {
    await SentryService.captureError(
      exception: e,
      stackTrace: stack,
      functionName: '_initializeAfterSkipUpdate',
      fileName: 'dialog_update.dart',
      lineNumber: 187,
    );
  }
}

/// Fetch app data in parallel after skipping update
Future<void> fetchAppDataAfterSkipUpdate(
  PageMainScreenController pageMainScreenController,
) async {
  try {
    await Future.wait<void>([
      pageMainScreenController.getCachedProducts().catchError((e, stack) {
        SentryService.captureError(
          exception: e,
          stackTrace: stack,
          functionName: '_fetchAppDataAfterSkipUpdate (CachedProducts)',
          fileName: 'dialog_update.dart',
          lineNumber: 229,
        );
        throw e;
      }),
      pageMainScreenController.getAllSliders().catchError((e, stack) {
        SentryService.captureError(
          exception: e,
          stackTrace: stack,
          functionName: '_fetchAppDataAfterSkipUpdate (Sliders)',
          fileName: 'dialog_update.dart',
          lineNumber: 239,
        );
        throw e;
      }),
      // Fire and forget operations (non-critical)
      Future(() => pageMainScreenController.getItemsViewed()).catchError((e, stack) {
        SentryService.captureError(
          exception: e,
          stackTrace: stack,
          functionName: '_fetchAppDataAfterSkipUpdate (ItemsViewed)',
          fileName: 'dialog_update.dart',
          lineNumber: 249,
        );
      }),
      Future(() => pageMainScreenController.fetchRecommendedItems()).catchError((e, stack) {
        SentryService.captureError(
          exception: e,
          stackTrace: stack,
          functionName: '_fetchAppDataAfterSkipUpdate (RecommendedItems)',
          fileName: 'dialog_update.dart',
          lineNumber: 258,
        );
      }),
      Future(() => pageMainScreenController.getAppSections()).catchError((e, stack) {
        SentryService.captureError(
          exception: e,
          stackTrace: stack,
          functionName: '_fetchAppDataAfterSkipUpdate (AppSections)',
          fileName: 'dialog_update.dart',
          lineNumber: 267,
        );
      }),
    ]);
  } catch (e, stack) {
    await SentryService.captureError(
      exception: e,
      stackTrace: stack,
      functionName: '_fetchAppDataAfterSkipUpdate',
      fileName: 'dialog_update.dart',
      lineNumber: 221,
    );
    // Don't rethrow - allow app to continue with partial data
  }
}

/// Handle refresh state and navigation after skipping update
Future<void> handleRefreshStateAfterSkipUpdate({
  required PageMainScreenController pageMainScreenController,
  required ChecksController checksController,
}) async {
  try {
    // Check if refresh is needed
    if (pageMainScreenController.sections.isEmpty &&
        !pageMainScreenController.fetchAppSection) {
      await pageMainScreenController.changeDoRefresh(true);
    }

    // Handle navigation
    if (!checksController.navigationTriggered) {
      await checksController.changeNavigateTriggered(nav: true);
      await checksController.changeTimerCancel(cancel: true);
      await checksController.viewPage();
    }
  } catch (e, stack) {
    await SentryService.captureError(
      exception: e,
      stackTrace: stack,
      functionName: '_handleRefreshStateAfterSkipUpdate',
      fileName: 'dialog_update.dart',
      lineNumber: 288,
    );
  }
}

/// Start timer with comprehensive error handling
Timer startTimer({required ChecksController checkController}) {
  return Timer(const Duration(seconds: 4), () async {
    try {
      if (!checkController.timerCancelled &&
          !checkController.navigationTriggered) {
        await checkController.changeNavigateTriggered(nav: true);
        await checkController.viewPage();
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'startTimer',
        fileName: 'dialog_update.dart',
        lineNumber: 321,
      );
    }
  });
}
