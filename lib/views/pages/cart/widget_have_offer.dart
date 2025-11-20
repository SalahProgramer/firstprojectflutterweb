import 'dart:core';
import 'package:bouncerwidget/bouncerwidget.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import '../../../controllers/cart_controller.dart';
import '../../../core/services/database/models_DB/cart_model.dart';
import '../../../core/utilities/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glowy_borders/glowy_borders.dart';
import 'package:provider/provider.dart';

import '../../../core/utilities/style/text_style.dart';
import '../../../core/widgets/custom_image.dart';
import '../../../core/widgets/lottie_widget.dart';

class WidgetHaveOffer extends StatelessWidget {
  final CartModel? item;
  final int index;

  const WidgetHaveOffer({
    super.key,
    this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    CartController cartController = context.watch<CartController>();
    return (cartController.itemsOffers.contains(item!.id.toString()))
        ? BouncingWidget(
            offsetYaxis: 0,
            offsetXaxis: -0.006,
            child: card1(cartController),
          )
        : card1(cartController);
  }

  Widget card1(CartController cartController) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: Card(
          elevation: 0,
          color: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          child: (cartController.itemsOffers.contains(item!.id.toString()))
              ? AnimatedGradientBorder(
                  gradientColors: [
                    CustomColor.chrismasColor,
                    CustomColor.blueColor
                  ],
                  borderSize: 1.5,
                  glowSize: 2.h,
                  borderRadius: BorderRadius.circular(10.r),
                  child: card(cartController),
                )
              : card(cartController),
        ));
  }

  Widget card(CartController cartController) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          padding: EdgeInsets.only(left: 3.w),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10.r)),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      CustomImageSponsored(
                        imageUrl: item?.image ?? "",
                        height: 100.h,
                        boxFit: BoxFit.fill,
                        borderCircle: 10.r,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      if (cartController.itemsOffers
                          .contains(item!.id.toString()))
                        LottieWidget(
                          name: Assets.lottie.offer,
                          height: 25.w,
                          width: 25.w,
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 5.w,
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  item?.title ?? "",
                                  textDirection: TextDirection.rtl,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                  style: CustomTextStyle().heading1L.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: CustomColor.blueColor,
                                      fontSize: 12.sp),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Row(
                        children: [
                          text(
                            name: "الحجم : ",
                            color: Colors.black,
                          ),
                          text(
                            name: item?.size?.trim().toString() ?? "",
                            color: CustomColor.blueColor,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 4.h,
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  text(name: "السعر : ", color: Colors.black),
                                  text(
                                      name: "${((item?.newPrice.toString()))}",
                                      color: Colors.green),
                                ],
                              ),
                            ),
                            text(
                                name: (item!.newPrice == "0 ₪")
                                    ? "0 ₪"
                                    : "${((item?.totalPrice.toString()))}",
                                color: CustomColor.primaryColor,
                                size: 14.sp)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (cartController.itemsOffers.contains(item!.id.toString()))
          IgnorePointer(
            child: LottieWidget(
              name: Assets.lottie.happy1,
              width: double.maxFinite,
              height: 50.h,
            ),
          ),
      ],
    );
  }

  Widget text({required String name, Color? color, double? size}) {
    return Flexible(
      child: Text(
        name,
        textDirection: TextDirection.rtl,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: CustomTextStyle().heading1L.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? CustomColor.blueColor,
            fontSize: size ?? 12.sp),
      ),
    );
  }
}
