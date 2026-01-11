import 'package:fawri_app_refactor/dialog/dialogs/dialog_waiting/dialog_waiting.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/controllers/order_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/page_main_screen_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/points_controller.dart';
import 'package:fawri_app_refactor/salah/utilities/sentry_service.dart';
import 'package:fawri_app_refactor/salah/utilities/style/colors.dart';
import 'package:fawri_app_refactor/salah/utilities/style/text_style.dart';
import 'package:fawri_app_refactor/salah/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../salah/utilities/global/app_global.dart';
import '../../salah/widgets/lottie_widget.dart';
import '../../salah/widgets/snackBarWidgets/snack_bar_style.dart';
import '../../salah/widgets/snackBarWidgets/snackbar_widget.dart';

Future<void> dialogUpdateProfile({
  required String phone,
  required String name,
}) {
  return showGeneralDialog(
    context: NavigatorApp.navigatorKey.currentState!.context,
    barrierLabel: "ccc",
    barrierDismissible: false,
    pageBuilder: (context, animation, secondaryAnimation) {
      PointsController pointsControllerClass = context
          .watch<PointsController>();
      PageMainScreenController pageMainScreenController = context
          .watch<PageMainScreenController>();
      OrderControllerSalah orderController = context
          .watch<OrderControllerSalah>();

      return PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LottieWidget(name: Assets.lottie.updateLottie),
              SizedBox(height: 10.h),
              Text(
                " تأكيد تحديث بياناتك",
                style: CustomTextStyle().heading1L.copyWith(
                  color: Colors.black,
                  fontSize: 15.sp,
                ),
              ),
              Text(
                "هل أنت متأكد من تحديث الإسم و الرقم؟",
                style: CustomTextStyle().heading1L.copyWith(
                  color: Colors.black54,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomButtonWithoutIcon(
                  backColor: CustomColor.blueColor,
                  text: "تحديث",
                  textWaiting: "",
                  height: 40.h,
                  textStyle: CustomTextStyle().rubik.copyWith(
                    color: Colors.white,
                    fontSize: 12.sp,
                  ),
                  onPressed: () async {
                    try {
                      // Add breadcrumb for update action

                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      await prefs.setString('phone', phone);
                      await prefs.setString('name', name);
                      NavigatorApp.pop();
                      dialogWaiting();
                      final f1 = pageMainScreenController.getUserActivity(
                        phone: phone,
                      );
                      final f2 = pointsControllerClass.getPointsFromAPI(
                        phone: phone,
                      );
                      final f3 = orderController.initialsOrders(phone: phone);
                      await Future.wait([f1, f2, f3]);
                      NavigatorApp.pop();
                      showSnackBar(
                        title: "لقد تم التحديث بنجاح ",
                        type: SnackBarType.success,
                      );
                    } catch (e, stack) {
                      await SentryService.captureError(
                        exception: e,
                        stackTrace: stack,
                        functionName: "dialogUpdateProfile_update",
                        fileName: "dialog_update_profile.dart",
                        lineNumber: 80,
                        extraData: {"phone": phone, "name": name},
                      );
                    }
                  },
                ),
                CustomButtonWithIconWithoutBackground(
                  text: "رجوع",
                  textStyle: CustomTextStyle().rubik.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12.sp,
                  ),
                  onPressed: () {
                    NavigatorApp.pop();
                  },
                  textIcon: '',
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
