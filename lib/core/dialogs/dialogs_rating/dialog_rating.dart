import 'package:fawri_app_refactor/core/dialogs/dialogs_rating/widget_rating.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glowy_borders/glowy_borders.dart';
import 'package:provider/provider.dart';
import '../../services/sentry/sentry_service.dart';
import '../../../controllers/page_main_screen_controller.dart';
import '../../utilities/global/app_global.dart';
import '../../utilities/style/colors.dart';
import '../../utilities/style/text_style.dart';
import '../../widgets/lottie_widget.dart';

Future<void> dialogRatingSet() {
  // Add breadcrumb for rating dialog

  return showGeneralDialog(
    context: NavigatorApp.navigatorKey.currentState!.context,
    barrierLabel: "ccc",
    barrierDismissible: false,
    pageBuilder: (context, animation, secondaryAnimation) {
      PageMainScreenController pageMainScreenController =
          context.watch<PageMainScreenController>();

      return PopScope(
        canPop: false,
        child: GestureDetector(
          onTap: () {
            try {
              FocusScope.of(context).unfocus();
            } catch (e, stack) {
              SentryService.captureError(
                exception: e,
                stackTrace: stack,
                functionName: "dialogRatingSet_unfocus",
                fileName: "dialog_rating.dart",
                lineNumber: 35,
              );
            }
          },
          child: ValueListenableBuilder<bool>(
              valueListenable: pageMainScreenController.isFocusedNotifier,
              // Listen to focus changes

              builder: (context, isFocused, child) {
                return Align(
                  alignment: isFocused ? Alignment.topCenter : Alignment.center,
                  child: Material(
                    type: MaterialType.transparency,
                    child: AnimatedGradientBorder(
                      borderRadius: BorderRadius.circular(10),
                      gradientColors: [
                        CustomColor.blueColor,
                        CustomColor.chrismasColor
                      ],
                      borderSize: 1.2,
                      glowSize: 1,
                      child: Container(
                          width: 0.9.sw,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.r),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 30,
                                    blurStyle: BlurStyle.inner)
                              ]),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LottieWidget(
                                height: 60.w,
                                width: 60.w,
                                name: Assets.lottie.rating,
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Text("قيّم واربح",
                                  style: CustomTextStyle().heading1L.copyWith(
                                      color: Colors.black, fontSize: 15.sp)),
                              SizedBox(
                                height: 5.h,
                              ),
                              Padding(
                                padding: EdgeInsets.all(4.w),
                                child: Text(
                                    "كل تقييم منك يساعدنا على التحسن، ويمنحك نقاطًا تستحقها! 🎉",
                                    textAlign: TextAlign.center,
                                    style: CustomTextStyle().heading1L.copyWith(
                                        color: Colors.black87,
                                        fontSize: 11.sp)),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              DialogRating(),
                            ],
                          )),
                    ),
                  ),
                );
              }),
        ),
      );
    },
  );
}
