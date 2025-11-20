import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utilities/global/app_global.dart';
import '../../utilities/style/text_style.dart';
import '../../widgets/lottie_widget.dart';

class NoConnection {
  static Future<void> show({BuildContext? context}) {
    final BuildContext dialogContext =
        context ?? NavigatorApp.navigatorKey.currentState!.overlay!.context;

    return showGeneralDialog(
        context: dialogContext,
        useRootNavigator: true,
        barrierDismissible: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LottieWidget(
                    name: Assets.lottie.noWifiLottie,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "لا يوجد انترنت",
                    style: CustomTextStyle().heading1L.copyWith(
                        color: Colors.black54.withValues(alpha: 0.8),
                        fontSize: 17.sp),
                  ),
                  Text(
                    "لا يوجد اتصال، قم بالتحقق من الشبكة",
                    style: CustomTextStyle()
                        .heading1L
                        .copyWith(color: Colors.black54, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
