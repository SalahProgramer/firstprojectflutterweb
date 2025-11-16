import 'dart:core';
import 'package:bouncerwidget/bouncerwidget.dart';
import 'package:fawri_app_refactor/salah/utilities/style/colors.dart';
import 'package:fawri_app_refactor/salah/utilities/style/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../localDataBase/models_DB/cart_model.dart';
import '../custom_image.dart';

class WidgetEachCardDelete extends StatelessWidget {
  final CartModel? item;
  final int index;

  const WidgetEachCardDelete({
    super.key,
    this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingWidget(
      offsetYaxis: 0,
      offsetXaxis: -0.006,
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Card(
            elevation: 20,
            shadowColor: CustomColor.primaryColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r)),
            child: Padding(
              padding:
                  EdgeInsets.only(top: 2.h, bottom: 2.h, right: 5.w, left: 3.w),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: CustomImageSponsored(
                        imageUrl: item?.image ?? "",
                        height: 100.h,
                        boxFit: BoxFit.fill,
                        borderCircle: 10.r,
                        borderRadius: BorderRadius.circular(10.r),
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
                                      style: CustomTextStyle()
                                          .heading1L
                                          .copyWith(
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
                                      text(
                                          name: "السعر : ",
                                          color: Colors.black),
                                      text(
                                          name:
                                              "${((item?.newPrice.toString()))}",
                                          color: Colors.green),
                                    ],
                                  ),
                                ),
                                text(
                                    name: "${((item?.totalPrice.toString()))}",
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
          )),
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

  String totalPrice1(String price, int quantity) {
    double total;

    String cleaned = price.replaceAll('₪', '');
    double value = double.parse(cleaned);
    total = value * quantity;
    String f = total.toStringAsFixed(2);
    total = double.parse(f);
    return "$total ₪";
  }
}
