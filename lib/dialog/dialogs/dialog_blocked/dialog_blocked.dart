import 'dart:async';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/widgets/snackBarWidgets/snack_bar_style.dart';
import 'package:fawri_app_refactor/salah/widgets/snackBarWidgets/snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../salah/utilities/global/app_global.dart';
import '../../../salah/utilities/style/colors.dart';
import '../../../salah/utilities/style/text_style.dart';
import '../../../salah/widgets/custom_button.dart';
import '../../../salah/widgets/lottie_widget.dart';

Future<void> showBlockedDialog() {
  return showGeneralDialog(
    context: NavigatorApp.navigatorKey.currentState!.context,
    barrierLabel: "blocked",
    barrierDismissible: false,
    pageBuilder: (context, animation, secondaryAnimation) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: Colors.white,
          title: const SizedBox(),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LottieWidget(
                name: Assets.lottie.error,
                height: 55.w,
                width: 55.w,
              ),
              Text(
                "تم حظرك",
                style: CustomTextStyle()
                    .heading1L
                    .copyWith(color: Colors.black, fontSize: 17.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                "تم حظرك من استخدام التطبيق يرجى التواصل مع مركز المساعدة لمزيد من التفاصيل",
                textAlign: TextAlign.center,
                style: CustomTextStyle()
                    .heading1L
                    .copyWith(color: Colors.black54, fontSize: 11.sp),
              ),
            ],
          ),
          actions: [
            CustomButtonWithoutIcon(
              text: "مركز المساعدة",
              height: 40.h,
              backColor: CustomColor.errorAccent,
              textStyle: CustomTextStyle()
                  .rubik
                  .copyWith(color: Colors.white, fontSize: 12.sp),
              onPressed: () async {
                final url2 = Uri.parse(
                    "https://www.facebook.com/FawriCOD?mibextid=LQQJ4d");
                if (!await launchUrl(url2,
                    mode: LaunchMode.externalApplication)) {
                  showSnackBar(
                      type: SnackBarType.error,
                      title:
                          "لم يتم التمكن من الدخول الرابط , الرجاء المحاولة فيما بعد",
                      description: "");
                }
              },
              textWaiting: '',
            ),
          ],
        ),
      );
    },
  );
}
