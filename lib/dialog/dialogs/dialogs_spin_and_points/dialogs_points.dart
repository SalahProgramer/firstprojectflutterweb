import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../server/functions/functions.dart';
import '../../../salah/utilities/global/app_global.dart';
import '../../../salah/utilities/style/colors.dart';
import '../../../salah/utilities/style/text_style.dart';
import '../../../salah/widgets/lottie_widget.dart';
import '../../../salah/widgets/snackBarWidgets/snack_bar_style.dart';
import '../../../salah/widgets/snackBarWidgets/snackbar_widget.dart';

AnalyticsService analyticsService = AnalyticsService();
// Fixed version of points dialog with improved button handling
Future<void> dialogGetPoint(String points, {bool havsCoupon = false}) {
  // Add breadcrumb for points dialog opening

  return showDialog(
    context: NavigatorApp.context,
    barrierDismissible: false,
    builder: (context) {
      int randomNumber = 0;
      if (havsCoupon) {
        randomNumber = 25;
        printLog('Random number between 20 and 30: $randomNumber');
      }

      return PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(0),
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  CustomColor.primaryColor.withValues(alpha: 0.1),
                  Colors.yellow.withValues(alpha: 0.1),
                  CustomColor.chrismasColor.withValues(alpha: 0.1),
                ],
              ),
            ),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                // Background animations
                Positioned(
                  top: 4.w,
                  left: 4.w,
                  child: LottieWidget(
                    name: Assets.lottie.confettiPopper,
                    height: 50.w,
                    width: 50.w,
                  ),
                ),
                Positioned(
                  top: 4.w,
                  right: 4.w,
                  child: LottieWidget(
                    name: Assets.lottie.confettiPopper,
                    height: 50.w,
                    width: 50.w,
                  ),
                ),
                Positioned(
                  bottom: 4.w,
                  left: 4.w,
                  child: LottieWidget(
                    name: Assets.lottie.confettiPopper,
                    height: 50.w,
                    width: 50.w,
                  ),
                ),
                Positioned(
                  bottom: 4.w,
                  right: 4.w,
                  child: LottieWidget(
                    name: Assets.lottie.confettiPopper,
                    height: 50.w,
                    width: 50.w,
                  ),
                ),

                // Main content
                Center(
                  child: LottieWidget(
                    name: Assets.lottie.happy1,
                    height: 1.sh,
                    width: 1.sw,
                  ),
                ),

                // Dialog content
                Center(
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header with confetti
                          Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LottieWidget(
                                  name: Assets.lottie.confettiPopper,
                                  height: 25.w,
                                  width: 25.w,
                                ),
                                Text(
                                  "مبروك",
                                  style: CustomTextStyle().heading1L.copyWith(
                                        color: Colors.black,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                LottieWidget(
                                  name: Assets.lottie.confettiPopper,
                                  height: 25.w,
                                  width: 25.w,
                                ),
                              ],
                            ),
                          ),

                          // Main icon
                          LottieWidget(
                            name: (points != "")
                                ? Assets.lottie.pointcoins
                                : Assets.lottie.coupon,
                            height: 80.w,
                            width: 80.w,
                          ),

                          SizedBox(height: 16.h),

                          // Message
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Text(
                              (havsCoupon)
                                  ? "مذهل! لقد حصلت على خصم ${randomNumber.toString()} %"
                                  : "مذهل! لقد أضفت ${points.toString()} إلى مجموع نقاطك !",
                              textAlign: TextAlign.center,
                              style: CustomTextStyle().heading1L.copyWith(
                                    color: Colors.black87,
                                    fontSize: 14.sp,
                                  ),
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // Coupon section (if applicable)
                          if (havsCoupon) ...[
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20.w),
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: CustomColor.blueColor
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: CustomColor.blueColor
                                      .withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "FawriWheel",
                                    style: CustomTextStyle().heading1L.copyWith(
                                          color: CustomColor.blueColor,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      Clipboard.setData(
                                          ClipboardData(text: "FawriWheel"));
                                      showSnackBar(
                                        title: 'تم نسخ الكود بنجاح!',
                                        type: SnackBarType.success,
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(8.w),
                                      decoration: BoxDecoration(
                                        color: CustomColor.blueColor,
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      child: Icon(
                                        Icons.copy,
                                        color: Colors.white,
                                        size: 16.w,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),
                          ],

                          // Button
                          Padding(
                            padding: EdgeInsets.all(20.w),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await analyticsService.logEvent(
                                    eventName: "app_rating_confirm",
                                    parameters: {
                                      "class_name": "DialogAppRating",
                                      "button_name": "تقييم التطبيق (حسناً)",
                                      "time": DateTime.now().toString(),
                                    },
                                  );
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();

                                  if (havsCoupon) {
                                    await prefs.setBool("wheel_coupon", true);
                                    showSnackBar(
                                      title: 'تم نسخ الكود بنجاح!',
                                      type: SnackBarType.success,
                                    );
                                  }

                                  NavigatorApp.pop();
                                  NavigatorApp.pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CustomColor.blueColor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  elevation: 3,
                                ),
                                child: Text(
                                  "حسناً",
                                  style: CustomTextStyle().rubik.copyWith(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// Fixed version of shoes points dialog
Future<void> dialogGetPointPopUpShoes(String points) {
  return showDialog(
    context: NavigatorApp.context,
    barrierDismissible: false,
    builder: (context) {
      return PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(0),
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  CustomColor.primaryColor.withValues(alpha: 0.1),
                  Colors.yellow.withValues(alpha: 0.1),
                  CustomColor.chrismasColor.withValues(alpha: 0.1),
                ],
              ),
            ),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                // Background animations
                Positioned(
                  top: 4.w,
                  left: 4.w,
                  child: LottieWidget(
                    name: Assets.lottie.confettiPopper,
                    height: 50.w,
                    width: 50.w,
                  ),
                ),
                Positioned(
                  top: 4.w,
                  right: 4.w,
                  child: LottieWidget(
                    name: Assets.lottie.confettiPopper,
                    height: 50.w,
                    width: 50.w,
                  ),
                ),
                Positioned(
                  bottom: 4.w,
                  left: 4.w,
                  child: LottieWidget(
                    name: Assets.lottie.confettiPopper,
                    height: 50.w,
                    width: 50.w,
                  ),
                ),
                Positioned(
                  bottom: 4.w,
                  right: 4.w,
                  child: LottieWidget(
                    name: Assets.lottie.confettiPopper,
                    height: 50.w,
                    width: 50.w,
                  ),
                ),

                // Main content
                Center(
                  child: LottieWidget(
                    name: Assets.lottie.happy1,
                    height: 1.sh,
                    width: 1.sw,
                  ),
                ),

                // Dialog content
                Center(
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header with confetti
                          Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LottieWidget(
                                  name: Assets.lottie.confettiPopper,
                                  height: 25.w,
                                  width: 25.w,
                                ),
                                Text(
                                  "مبروك",
                                  style: CustomTextStyle().heading1L.copyWith(
                                        color: Colors.black,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                LottieWidget(
                                  name: Assets.lottie.confettiPopper,
                                  height: 25.w,
                                  width: 25.w,
                                ),
                              ],
                            ),
                          ),

                          // Main icon
                          LottieWidget(
                            name: Assets.lottie.pointcoins,
                            height: 80.w,
                            width: 80.w,
                          ),

                          SizedBox(height: 16.h),

                          // Message
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Text(
                              "مذهل! لقد أضفت ${points.toString()} إلى مجموع نقاطك !",
                              textAlign: TextAlign.center,
                              style: CustomTextStyle().heading1L.copyWith(
                                    color: Colors.black87,
                                    fontSize: 14.sp,
                                  ),
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // Button
                          Padding(
                            padding: EdgeInsets.all(20.w),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await analyticsService.logEvent(
                                    eventName: "app_rating_later",
                                    parameters: {
                                      "class_name": "DialogAppRating",
                                      "button_name":
                                          "CustomButtonWithIconWithoutBackground (ليس الآن)",
                                      "time": DateTime.now().toString(),
                                    },
                                  );
                                  NavigatorApp.pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CustomColor.blueColor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  elevation: 3,
                                ),
                                child: Text(
                                  "حسناً",
                                  style: CustomTextStyle().rubik.copyWith(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
