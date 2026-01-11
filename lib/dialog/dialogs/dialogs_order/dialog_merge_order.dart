import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/controllers/order_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../salah/utilities/global/app_global.dart';
import '../../../salah/utilities/style/colors.dart';
import '../../../salah/utilities/style/text_style.dart';
import '../../../salah/widgets/custom_button.dart';
import '../../../salah/widgets/lottie_widget.dart';

Future<void> dialogMergeOrder() {
  return showGeneralDialog(
    context: NavigatorApp.navigatorKey.currentState!.context,
    barrierLabel: "ccc",
    barrierDismissible: false,
    pageBuilder: (context, animation, secondaryAnimation) {
      OrderControllerSalah orderControllerSalah = context
          .watch<OrderControllerSalah>();

      return PopScope(
        canPop: false,
        child: CupertinoAlertDialog(
          insetAnimationCurve: Curves.bounceInOut,
          title: SizedBox(),
          content: Column(
            children: [
              LottieWidget(
                name: Assets.lottie.merge,
                height: 45.w,
                width: 45.w,
              ),
              Text(
                "🔄 دمج طلبك 🔄",
                style: CustomTextStyle().heading1L.copyWith(
                  color: Colors.black,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                "📦✨ هل تريد دمج هذا الطلب مع طلبك قيد الانتظار في طلب واحد للحصول على خدمة أسرع وتجربة أكثر كفاءة!",
                style: CustomTextStyle().heading1L.copyWith(
                  color: Colors.black54,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
          actions: [
            CustomButtonWithIconWithoutBackground(
              text: "أريد",
              textIcon: "",
              height: 16.h,
              textStyle: CustomTextStyle().rubik.copyWith(
                color: CustomColor.blueColor,
                fontSize: 12.sp,
              ),
              onPressed: () async {
                await orderControllerSalah.changeDoMergeOrder(true);
                NavigatorApp.pop();
              },
            ),
            CustomButtonWithIconWithoutBackground(
              text: "لا أريد",
              textIcon: "",
              height: 16.h,
              textStyle: CustomTextStyle().rubik.copyWith(
                color: CustomColor.primaryColor,
                fontSize: 12.sp,
              ),
              onPressed: () async {
                await orderControllerSalah.changeDoMergeOrder(false);
                NavigatorApp.pop();
              },
            ),
          ],
        ),
      );
    },
  );
}
