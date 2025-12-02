import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/controllers/custom_page_controller.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:fawri_app_refactor/salah/utilities/style/text_style.dart';
import 'package:fawri_app_refactor/salah/widgets/custom_button.dart';
import 'package:fawri_app_refactor/salah/widgets/widgets_item_view/button_done.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../views/pages/pages.dart';
import 'lottie_widget.dart';

class EmptyWidget extends StatelessWidget {
  final String text;
  final String iconName;
  final double? height;
  final double? width;
  final double? heightIcon;
  final bool? hasButton;

  const EmptyWidget(
      {super.key,
      required this.text,
      required this.iconName,
      this.height,
      this.width,
      this.heightIcon,
      this.hasButton});

  @override
  Widget build(BuildContext context) {
    CustomPageController customPageController =
        context.watch<CustomPageController>();
    return SizedBox(
      width: 0.65.sw,
      child: IntrinsicWidth(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                text,
                style: CustomTextStyle().heading1L.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 14.sp),
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
            (iconName == Assets.lottie.cartempty ||
                    (iconName == Assets.lottie.nowifi) ||
                    (iconName == Assets.lottie.emptyItems))
                ? LottieWidget(
                    name: (iconName == Assets.lottie.cartempty)
                        ? Assets.lottie.cartempty
                        : (iconName == Assets.lottie.emptyItems)
                            ? Assets.lottie.emptyItems
                            : Assets.lottie.nowifi,
                    width: width ?? 50.w,
                    height: height ?? 50.w,
                  )
                : IconSvg(
                    nameIcon: iconName,
                    onPressed: null,
                    height: height ?? 40.w,
                    width: width ?? 40.w,
                    heightIcon: heightIcon ?? 30.h,
                    backColor: Colors.transparent,
                  ),
            SizedBox(
              height: 5.h,
            ),
            if (hasButton == true)
              ButtonDone(
                isLoading: false,
                text: "تسوق الآن",
                iconName: Assets.icons.cart,
                height: 39.w,
                widthIconInStartEnd: 30.w,
                heightIconInStartEnd: 30.w,
                padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                onPressed: () async {
                  await customPageController.changeIndexPage(0);
                  await customPageController.changeIndexCategoryPage(1);
                  NavigatorApp.navigateToRemoveUntil(Pages());
                },
              )
          ],
        ),
      ),
    );
  }
}
