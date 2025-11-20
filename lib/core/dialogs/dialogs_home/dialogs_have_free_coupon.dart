import 'package:bouncerwidget/bouncerwidget.dart';
import 'package:fawri_app_refactor/core/widgets/custom_pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import '../../utilities/global/app_global.dart';
import '../../utilities/style/colors.dart';
import '../../widgets/snackBarWidgets/snack_bar_style.dart';
import '../../widgets/snackBarWidgets/snackbar_widget.dart';

showDelayedDialogFreeCoupon() {
  return showDialog(
    context: NavigatorApp.context,
    builder: (context) {
      return CustomPopScope(
        widget: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(0),
            child: InkWell(
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();

                Clipboard.setData(ClipboardData(text: "Fawri2025"));
                await prefs.setBool('couponShown', true);
                showSnackBar(
                  title: "تم نسخ الكود😁",
                  type: SnackBarType.success,
                );
                NavigatorApp.pop();
              },
              child: Container(
                color: Colors.black.withValues(alpha: 0.8),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Lottie.asset(Assets.lottie.surprise,
                        height: 250.h,
                        reverse: true,
                        repeat: true,
                        fit: BoxFit.cover),
                    SizedBox(
                      height: 20.h,
                    ),
                    Text(
                      "مفاجأة",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 26.sp,
                          color: Colors.white),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Text(
                        "لقد حصلت على كوبون خصم بقيمة 10% يمكنك استخدامه عند شرائك لأحد منتجاتنا",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    Text(
                      "Fawri2025",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30.sp,
                          color: CustomColor.blueColor),
                    ),
                    SizedBox(
                      height: 50.h,
                    ),
                    BouncingWidget(
                      child: InkWell(
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();

                          Clipboard.setData(ClipboardData(text: "Fawri2025"));
                          await prefs.setBool('couponShown', true);

                          showSnackBar(
                            title: "تم نسخ الكود😁",
                            type: SnackBarType.success,
                          );
                          NavigatorApp.pop();
                        },
                        child: Text(
                          "اضغط للنسخ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.sp,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      );
    },
  );
}
