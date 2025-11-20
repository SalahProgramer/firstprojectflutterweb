import 'package:fawri_app_refactor/core/widgets/snackBarWidgets/snack_bar_style.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../animation/zoom_in.dart';
import '../../utilities/global/app_global.dart';
import '../../utilities/print_looger.dart';
import '../../utilities/style/text_style.dart';
import '../lottie_widget.dart';
import 'circle_logo.dart';
import 'snack_bar_card.dart';

Future<void> showSnackBar({
  required String title,
  String description = "",
  required SnackBarType type,
  BuildContext? context,
}) async {
  final currentContext = context ?? NavigatorApp.context;

  // Additional safety check for disposed widgets
  try {
    // Test if we can still access the ScaffoldMessenger
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(currentContext);
    if (scaffoldMessenger == null) {
      printLog(
          'Warning: Cannot show snackbar - ScaffoldMessenger not available');
      return;
    }
  } catch (e) {
    printLog('Warning: Cannot show snackbar - context is disposed: $e');
    return;
  }

  try {
    final style = stylesSnackBar[type]!;
    ScaffoldMessenger.of(currentContext).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        clipBehavior: Clip.none,
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        duration: Duration(milliseconds: 2200),
        content: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topLeft,
          children: [
            SnackBarCard(
              radius: 20.r,
              fillGradient: style.fill,
              borderGradient: style.border,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 14.w, 12.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ZoomIn(
                      base: 30.w,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          style.lottieColor ??
                              Color.fromARGB(255, 246, 198, 255),
                          BlendMode.srcIn,
                        ),
                        child: LottieWidget(
                          name: style.lottieName,
                          width: double.infinity,
                          height: double.infinity,
                          animate: true,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 10.w),
                            child: Text(
                              title,
                              style: CustomTextStyle().pacifico.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13.sp,
                                    height:
                                        (description != "") ? 0.85.h : 1.2.h,
                                  ),
                            ),
                          ),
                          if (description != "") SizedBox(height: 10.h),
                          if (description != "")
                            Text(
                              description,
                              style: CustomTextStyle().pacifico.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11.sp,
                                    height: 0.85.h,
                                  ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -10.h,
              left: -7.w,
              child: CircleLogo(
                size: 45.w,
                color: style.badge,
              ),
            ),
          ],
        ),
      ),
    );
  } catch (e) {
    printLog('Error showing snackbar: $e');
  }
}
