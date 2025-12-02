
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import '../../../../controllers/custom_page_controller.dart';
import '../../../../controllers/points_controller.dart';
import '../../../../core/utilities/global/app_global.dart';
import '../../../../core/utilities/routes.dart';
import '../../../../core/utilities/style/colors.dart';
import '../../../../core/utilities/style/text_style.dart';
import '../../../../core/utilities/validations/validation.dart';
import '../../../../core/widgets/app_bar_widgets/app_bar_custom.dart';
import '../../../../core/widgets/lottie_widget.dart';
import '../../../../core/widgets/snackBarWidgets/snack_bar_style.dart';
import '../../../../core/widgets/snackBarWidgets/snackbar_widget.dart';
import '../../../../core/widgets/widget_text_field/can_custom_text_field.dart';
import '../../../../core/widgets/widgets_item_view/button_done.dart';

class CheckPointsOrder extends StatefulWidget {
  const CheckPointsOrder({super.key});

  @override
  State<CheckPointsOrder> createState() => _CheckPointsOrderState();
}

class _CheckPointsOrderState extends State<CheckPointsOrder> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    CustomPageController customPageController =
        context.watch<CustomPageController>();
    PointsController pointsControllerClass = context.watch<PointsController>();
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: ButtonDone(
        text: "تأكيد عملية الخصم",
        iconName: Assets.icons.yes,
        isLoading: false,
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            await pointsControllerClass.changePointsApplied(true);

            double nis = pointsControllerClass.calculateValueInNIS(double.parse(
                pointsControllerClass.pointsController.text.trim().toString()));
            pointsControllerClass.shekelText = nis.toStringAsFixed(2);

            double pointDouble = (pointsControllerClass.totalItems) - (nis);
            await pointsControllerClass.changeTotal(
                pointDouble - pointsControllerClass.discountCoupoun);

            await pointsControllerClass.changeDiscountPoints(nis);
            await pointsControllerClass
                .changeAllDiscount(nis + pointsControllerClass.discountCoupoun);

            showSnackBar(
                title: "تم خصم${nis.toStringAsFixed(1)} شيكل",
                type: SnackBarType.success);
            NavigatorApp.pop();
          } else {
            double nis = 0;
            pointsControllerClass.shekelText = nis.toStringAsFixed(2);
            await pointsControllerClass.changePointsApplied(false);
            double pointDouble = (pointsControllerClass.totalItems) - 0;
            await pointsControllerClass.changeTotal(
                pointDouble - pointsControllerClass.discountCoupoun);
            await pointsControllerClass.changeDiscountPoints(0);

            await pointsControllerClass
                .changeAllDiscount(0 + pointsControllerClass.discountCoupoun);
          }
        },
      ),
      appBar: CustomAppBar(
        title: "نقاطي",
        textButton: "رجوع",
        onPressed: () async {
          if (Navigator.of(context).canPop() == true) {
            NavigatorApp.pop();
          } else {
            NavigatorApp.pushReplacment(AppRoutes.pages);

            await customPageController.changeIndexPage(0);
            await customPageController.changeIndexCategoryPage(1);
          }
        },
        actions: [],
        colorWidgets: Colors.black,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.maxFinite,
                  // height: 0.3.sh,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(25.r),
                          bottomRight: Radius.circular(25.r)),
                      boxShadow: [
                        BoxShadow(
                            blurStyle: BlurStyle.outer,
                            color: Colors.black,
                            spreadRadius: 2,
                            blurRadius: 10.r)
                      ],
                      image: DecorationImage(
                        filterQuality: FilterQuality.high,
                        image: AssetImage(Assets.images.backg.path),
                      )),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 30.h,
                      ),
                      Container(
                        height: 0.30.sh,
                        padding: EdgeInsets.zero,
                        child: Image(
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.high,
                          image: AssetImage(Assets.images.cardCoin.path),
                        ),
                      ),
                      Center(
                          child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (Rect bounds) {
                          return RadialGradient(
                            center: Alignment.topLeft,
                            radius: 1.0,
                            colors: <Color>[
                              Colors.black,
                              Colors.black,
                              Colors.black,
                              Colors.black,
                            ],
                            tileMode: TileMode.mirror,
                          ).createShader(bounds);
                        },
                        child: Text(
                          "رصيد النقاط المتوفرة",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          numAndText(
                              text: "  نقطة  ",
                              num: "${pointsControllerClass.points} "),
                          SizedBox(
                            width: 15.h,
                          ),
                          Container(
                            width: 3.w,
                            height: 30.h,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10.r),
                                bottom: Radius.circular(10.r),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 15.h,
                          ),
                          numAndText(
                              text: "  شيكل  ",
                              num: "${pointsControllerClass.shekel} "),
                        ],
                      ),
                      SizedBox(
                        height: 10.h,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      "   القيمة النقدية :",
                      style: CustomTextStyle()
                          .heading1L
                          .copyWith(color: Colors.black, fontSize: 13.sp),
                    )),
                Padding(
                  padding: EdgeInsets.all(4.w),
                  child: CanCustomTextFormField(
                    controller: pointsControllerClass.pointsController,
                    hasSeePassIcon: true,
                    suffixIcon: SizedBox(
                      width: 120.w,
                      child: ButtonDone(
                          haveBouncingWidget: false,
                          padding: EdgeInsets.only(left: 6.w),
                          height: 20.h,
                          heightIcon: 0.h,
                          fontSize: 13.sp,
                          widthIconInStartEnd: 20.w,
                          heightIconInStartEnd: 20.w,
                          text: "تطبيق",
                          iconName: Assets.icons.yes,
                          onPressed: (pointsControllerClass.textPointDo
                                      .trim() ==
                                  "")
                              ? null
                              : () async {
                                  FocusScope.of(context).unfocus();

                                  if (formKey.currentState!.validate()) {
                                    // await pointsControllerClass
                                    //     .changePointsApplied(true);

                                    double nis = pointsControllerClass
                                        .calculateValueInNIS(double.parse(
                                            pointsControllerClass
                                                .pointsController.text
                                                .trim()
                                                .toString()));
                                    pointsControllerClass.shekelText =
                                        nis.toStringAsFixed(2);

                                    // double pointDouble =
                                    //     (pointsControllerClass.totalItems) -
                                    //         (nis);
                                    // await pointsControllerClass.changeTotal(
                                    //     pointDouble -
                                    //         pointsControllerClass
                                    //             .discountCoupoun);
                                    //
                                    // await pointsControllerClass
                                    //     .changeDiscountPoints(nis);
                                    // await pointsControllerClass
                                    //     .changeAllDiscount(nis +
                                    //         pointsControllerClass
                                    //             .discountCoupoun);
                                    // NavigatorApp.pop();
                                    // messageSnackBar(
                                    //     text:
                                    //         "تم خصم${nis.toStringAsFixed(1)} شيكل",
                                    //     nameIcon: "yes);
                                  } else {
                                    double nis = 0;
                                    pointsControllerClass.shekelText =
                                        nis.toStringAsFixed(2);
                                    await pointsControllerClass
                                        .changePointsApplied(false);
                                    double pointDouble =
                                        (pointsControllerClass.totalItems) - 0;
                                    await pointsControllerClass.changeTotal(
                                        pointDouble -
                                            pointsControllerClass
                                                .discountCoupoun);
                                    await pointsControllerClass
                                        .changeDiscountPoints(0);

                                    await pointsControllerClass
                                        .changeAllDiscount(0 +
                                            pointsControllerClass
                                                .discountCoupoun);
                                  }
                                }),
                    ),
                    hasFocusBorder: true,
                    hasTap: false,
                    onChanged: (value) async {
                      await pointsControllerClass.setChangeText(value);
                    },
                    textStyle: CustomTextStyle().heading1L.copyWith(
                        fontSize: 12.sp, color: CustomColor.blueColor),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 7.h),
                      child: LottieWidget(
                        name: Assets.lottie.pointcoins,
                        animate: true,
                        width: 50.w,
                        height: 50.w,
                      ),
                    ),
                    hintText: "ادخل النقاط التي تحتاجها",
                    validate: (value) {
                      if (Validation.checkTextPoints(
                              text: value.toString(),
                              points: pointsControllerClass.points) ==
                          null) {
                        pointsControllerClass.changeMessegePoint("");
                      } else {
                        pointsControllerClass.changeMessegePoint(
                            Validation.checkTextPoints(
                                text: value.toString(),
                                points: pointsControllerClass.points));
                      }

                      return Validation.checkTextPoints(
                          text: value.toString(),
                          points: pointsControllerClass.points);
                    },
                    inputType: TextInputType.number,
                    controlPage: pointsControllerClass,
                    maxLines: null,
                  ),
                ),
                SizedBox(
                  height: 50.h,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 0.2.sw),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black,
                            blurRadius: 2,
                            spreadRadius: 10.r,
                            blurStyle: BlurStyle.outer)
                      ]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "القيمة الإستبدالية للخصم",
                        style: CustomTextStyle()
                            .heading1L
                            .copyWith(color: Colors.black, fontSize: 13.sp),
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      numAndText(
                          text: "  شيكل  ",
                          num: pointsControllerClass.shekelText
                              .toString()
                              .trim())
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget numAndText({required String num, required String text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            num.toString().trim(),
            textDirection: TextDirection.rtl,
            style: CustomTextStyle().heading1L.copyWith(
                color: CustomColor.chrismasColor,
                fontSize: 23.sp,
                fontWeight: FontWeight.bold),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Text(
            text.trim(),
            textDirection: TextDirection.ltr,
            style: TextStyle(
                color: Colors.black,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
