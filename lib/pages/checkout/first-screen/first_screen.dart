import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bouncerwidget/bouncerwidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/pages/checkout/second-screen/second_screen.dart';
import 'package:fawri_app_refactor/salah/controllers/checkout_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/order_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/points_controller.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:fawri_app_refactor/salah/utilities/style/colors.dart';
import 'package:fawri_app_refactor/salah/views/pages/checkout_order/first_screen_checkout/check_points_order.dart';
import 'package:fawri_app_refactor/salah/widgets/lottie_widget.dart';
import 'package:fawri_app_refactor/salah/widgets/widgets_item_view/button_done.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:fawri_app_refactor/server/functions/functions.dart';
import '../../../salah/localDataBase/models_DB/cart_model.dart';
import '../../../salah/utilities/style/text_style.dart';
import '../../../salah/widgets/app_bar_widgets/app_bar_custom.dart';
import '../../../salah/widgets/snackBarWidgets/snack_bar_style.dart';
import '../../../salah/widgets/snackBarWidgets/snackbar_widget.dart';

class CheckoutFirstScreen extends StatefulWidget {
  final List<CartModel> items;
  final dynamic freeShipValue;

  const CheckoutFirstScreen({
    super.key,
    required this.freeShipValue,
    required this.items,
  });

  @override
  State<CheckoutFirstScreen> createState() => _CheckoutFirstScreenState();
}

class _CheckoutFirstScreenState extends State<CheckoutFirstScreen> {
  TextEditingController couponController = TextEditingController();
  bool _hasError = false;
  String couponMessage = "";
  bool coponApplied = false;
  bool wheelApplied = false;
  String discountPercentage = "0.0";
  bool checkCopon = false;
  bool status = false;
  bool coponed = false;
  double discountPrice = 0.0;

  Timer? _couponMessageTimer;
  PageController pageController = PageController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      CheckoutController checkoutController = context
          .read<CheckoutController>();
      PointsController pointsController = context.read<PointsController>();
      await checkoutController.changeDeliveryPrice(
        widget.freeShipValue,
        pointsController,
        doClear: true,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    OrderControllerSalah orderControllerSalah = context
        .watch<OrderControllerSalah>();

    PointsController pointsController = context.watch<PointsController>();

    CheckoutController checkoutController = context.watch<CheckoutController>();

    return PopScope(
      canPop: true,

      onPopInvokedWithResult: (didPop, result) async =>
          await pointsController.clearAllDataPointPage(),
      child: Scaffold(
        bottomNavigationBar: BouncingWidget(
          child: ButtonDone(
            text: "متابعة عملية الشراء",
            iconName: Assets.icons.yes,
            isLoading: orderControllerSalah.isLoading1,
            onPressed: () async {
              await orderControllerSalah.changeLoading1(true);

              if (checkoutController.dropdownValue == "اختر منطقتك") {
                await orderControllerSalah.changeLoading1(false);
                showSnackBar(
                  title: "قم باختيار منطقتك",
                  type: SnackBarType.warning,
                );
                setState(() {
                  _hasError = true;
                  Vibration.vibrate(duration: 100);
                  Future.delayed(Duration(milliseconds: 1000), () {
                    setState(() {
                      _hasError = false;
                    });
                  });
                });
              } else if (pointsController.total <
                  int.parse(widget.freeShipValue.toString())) {
                await orderControllerSalah.changeLoading1(false);
                printLog(pointsController.shekelText.trim().toString());

                NavigatorApp.push(
                  CheckoutSecondScreen(
                    totalWithoutDelivery: pointsController.total.round(),
                    pointControllerText: (pointsController.pointApplied)
                        ? pointsController.pointsController.text
                              .trim()
                              .toString()
                        : "0",
                    usedWheelCoupon: wheelApplied,
                    initialCity: checkoutController.dropdownValue.toString(),
                    couponControllerText:
                        (couponMessage ==
                                "الكوبون المدخل مستخدم من قبل , الرجاء المحاولة فيما بعد" ||
                            couponMessage == "" ||
                            couponMessage == "تم استخدام الكوبون من قبل")
                        ? ""
                        : couponController.text,
                    total:
                        ((checkoutController.deliveryPrice) +
                                pointsController.total)
                            .round()
                            .toStringAsFixed(2),
                    delivery: (checkoutController.deliveryPrice)
                        .round()
                        .toStringAsFixed(2),
                  ),
                );
              } else {
                await orderControllerSalah.changeLoading1(false);

                printLog(pointsController.shekelText.trim().toString());

                NavigatorApp.push(
                  CheckoutSecondScreen(
                    totalWithoutDelivery: pointsController.total.round(),
                    usedWheelCoupon: wheelApplied,
                    delivery: ((checkoutController.deliveryPrice)
                        .round()
                        .toStringAsFixed(2)),
                    pointControllerText: (pointsController.pointApplied)
                        ? pointsController.pointsController.text
                              .trim()
                              .toString()
                        : "0",
                    initialCity: checkoutController.dropdownValue.toString(),
                    couponControllerText:
                        (couponMessage ==
                                "الكوبون المدخل مستخدم من قبل , الرجاء المحاولة فيما بعد" ||
                            couponMessage == "" ||
                            couponMessage == "تم استخدام الكوبون من قبل")
                        ? ""
                        : couponController.text,
                    total:
                        (checkoutController.deliveryPrice +
                                pointsController.total)
                            .round()
                            .toStringAsFixed(2),
                  ),
                );
              }
            },
          ),
        ),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: CustomAppBar(
            title: "فوري",
            textButton: "رجوع",
            onPressed: () async {
              await pointsController.clearAllDataPointPage();
              NavigatorApp.pop();
            },
            actions: [],
            colorWidgets: Colors.white,
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 25, right: 25),
            child: Column(
              key: Key("2"),
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 1000),
                    curve: Curves.easeInOut,
                    transform: _hasError
                        ? Matrix4.translationValues(5, 0, 0)
                        : Matrix4.identity(),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _hasError
                            ? Colors.red
                            : Colors.grey.withValues(alpha: 0.6),
                        width: 1.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.3),
                          blurRadius: 12.r,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          borderRadius: BorderRadius.circular(14.r),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.black87,
                            size: 24,
                          ),
                          value: checkoutController.dropdownValue,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          dropdownColor: Colors.white,
                          items:
                              <String>[
                                "اختر منطقتك",
                                'القدس',
                                'الداخل',
                                'الضفه الغربيه',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 6.w,
                                    ),
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        fontSize: 13.5.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                          onChanged: (String? newValue) async {
                            await checkoutController.changeDropdownValue(
                              newValue!,
                            );
                            await checkoutController.changeDeliveryPrice(
                              widget.freeShipValue,
                              pointsController,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: int.parse(widget.freeShipValue.toString()) > 0,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.sp),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 10.h,
                            horizontal: 12.w,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(
                                  255,
                                  71,
                                  1,
                                  236,
                                ).withValues(alpha: 0.1),
                                Color.fromARGB(
                                  255,
                                  71,
                                  1,
                                  236,
                                ).withValues(alpha: 0.1),
                                Color.fromARGB(
                                  255,
                                  162,
                                  122,
                                  255,
                                ).withValues(alpha: 0.1),
                                Color.fromARGB(
                                  255,
                                  91,
                                  178,
                                  250,
                                ).withValues(alpha: 0.1),
                                // CustomColor.deepNavy,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: CustomColor.deepPurple.withValues(
                                alpha: 0.8,
                              ),
                              width: 1.3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: CustomColor.deepPurple.withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LottieWidget(name: Assets.lottie.freeShipping),
                              // Icon(
                              //   (double.parse(widget.freeShipValue
                              //               .toString()) <=
                              //           pointsController.totalItems)
                              //       ? Icons.local_shipping_rounded
                              //       : Icons.card_giftcard_rounded,
                              //   color: const Color(0xFFD32F2F),
                              //   size: 28,
                              // ),
                              const SizedBox(height: 8),
                              Text(
                                (double.parse(
                                          widget.freeShipValue.toString(),
                                        ) <=
                                        pointsController.totalItems)
                                    ? "مبروك! حصلت على خصم توصيل بقيمة 20 شيكل"
                                    : "تسوّق بـ₪${int.parse(widget.freeShipValue.toString())} أو أكثر لتحصل على توصيل مجاني للضفة، 10 شيكل للقدس، و40 شيكل لباقي المناطق.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Visibility(
                  visible: ((int.tryParse(pointsController.points) ?? 0) > 300)
                      ? true
                      : false,
                  child: AnimatedOpacity(
                    opacity:
                        ((int.tryParse(pointsController.points) ?? 0) > 300)
                        ? 1
                        : 0,
                    duration: Duration(seconds: 1),
                    child: Center(
                      child: InkWell(
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        overlayColor: WidgetStateColor.transparent,
                        focusColor: Colors.transparent,
                        onTap: () {
                          NavigatorApp.pushAnimation(CheckPointsOrder());
                        },
                        child: Column(
                          children: [
                            Text(
                              "لديك ${pointsController.points} من النقاط ",
                              textAlign: TextAlign.center,
                              style: CustomTextStyle().heading1L.copyWith(
                                fontSize: 20.sp,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            BouncingWidget(
                              child: Text(
                                "أنقر لاستخدام خصم النقاط",
                                textAlign: TextAlign.center,
                                style: CustomTextStyle().heading1L.copyWith(
                                  fontSize: 11.sp,
                                  color: CustomColor.deepPurple,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                copounField(context),
                SizedBox(height: 30),
                Container(
                  // height: 400,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.2),
                        spreadRadius: 5,
                        blurRadius: 7,
                        // offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10.sp),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 8.w,
                            children: [
                              Icon(
                                Icons.info_outlined,
                                color: Colors.black87,
                                size: 20.sp,
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 2.h),
                                child: Text(
                                  "معلومات الطلب ",
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 5.h,
                            horizontal: 4.w,
                          ),
                          child: Divider(
                            color: Colors.grey.shade900,
                            thickness: 1.5.h,
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "مجموع القطع : ",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "₪${pointsController.totalItems}",
                                  style: TextStyle(
                                    color: Color(0xff8F5C4B),
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Visibility(
                              visible: couponMessage == "" ? false : true,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 5.h,
                                    ),
                                    child: Divider(color: Colors.grey.shade300),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "نسبة الخصم : ",
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "%${discountPercentage.toString().substring(0, 2)}",
                                        style: TextStyle(
                                          color: Color(0xffC01C1C),
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: (pointsController.pointsMessage == "")
                                  ? true
                                  : false,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 5.h,
                                    ),
                                    child: Divider(color: Colors.grey.shade300),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "خصم من النقاط : ",
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "(${pointsController.shekelText} ₪) ${pointsController.pointsController.text.trim().trim().toString()} pts",
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(
                                          color: Color(0xffC01C1C),
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible:
                                  (couponMessage != "" ||
                                      pointsController.pointsMessage == "")
                                  ? true
                                  : false,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 5.h,
                                    ),
                                    child: Divider(color: Colors.grey.shade300),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "مبلغ التوفير : ",
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "₪${pointsController.discount.toStringAsFixed(2)}",
                                        style: TextStyle(
                                          color: Color(0xffA8AA57),
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.h),
                              child: Divider(color: Colors.grey.shade300),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "المبلغ النهائي بعد الخصم",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "₪${pointsController.total.round()}",
                                  style: TextStyle(
                                    color: Color(0xff905D4C),
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.h),
                              child: Divider(color: Colors.grey.shade300),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "التوصيل : ",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Visibility(
                                      visible:
                                          int.parse(
                                                widget.freeShipValue.toString(),
                                              ) ==
                                              0
                                          ? false
                                          : pointsController.total >=
                                                int.parse(
                                                  widget.freeShipValue
                                                      .toString(),
                                                ),
                                      child: Text(
                                        "لقد حصلت على خصم ₪20 على التوصيل",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "₪${checkoutController.deliveryPrice}",
                                  style: TextStyle(
                                    color: Color(0xffA8AA57),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.h),
                              child: Divider(color: Colors.grey.shade400),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "المبلغ للدفع : ",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "₪${((checkoutController.deliveryPrice) + pointsController.total).round()}",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column copounField(BuildContext context) {
    PointsController pointsController = context.watch<PointsController>();
    CheckoutController checkoutController = context.watch<CheckoutController>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "اظهار كود الخصم",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              FlutterSwitch(
                activeColor: CustomColor.deepPurple,
                width: 60.0,
                height: 30.0,
                valueFontSize: 25.0,
                toggleSize: 27.0,
                value: status,
                borderRadius: 30.0,
                padding: 3.0,
                // showOnOff: true,
                onToggle: (val) {
                  setState(() {
                    status = !status;
                    if (status == false) {
                      couponMessage = "";
                      coponed = false;
                      pointsController.clearAllDataCouponPage();
                    }
                  });
                },
              ),
            ],
          ),
        ),
        Visibility(
          visible: status ? true : false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: TextField(
                        controller: couponController,
                        obscureText: false,
                        onChanged: (val) {
                          if (val != "") {
                            setState(() {
                              checkCopon = true;
                            });
                          } else {
                            setState(() {
                              checkCopon = false;
                            });
                          }
                        },
                        decoration: InputDecoration(hintText: "كود الخصم"),
                      ),
                    ),
                    Visibility(
                      visible: checkCopon,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () async {
                            if (!coponApplied) {
                              if (couponController.text == "noTawseel") {
                                var res = await getCoupunDeleteCose();
                                if (res["active"] == true) {
                                  if (double.parse(
                                        pointsController.total.toString(),
                                      ) >
                                      double.parse(res["above"].toString())) {
                                    setState(() async {
                                      discountPrice = double.parse(
                                        res["remove"].toString(),
                                      );

                                      await checkoutController
                                          .changeValueDeliveryPrice(
                                            checkoutController.deliveryPrice -
                                                double.parse(
                                                  res["remove"].toString(),
                                                ),
                                          );
                                      coponApplied = true;
                                    });

                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.success,
                                      animType: AnimType.rightSlide,
                                      btnOkText: "حسنا",
                                      btnCancelText: "اغلاق",
                                      title: 'تم الخصم بنجاح!',
                                      desc:
                                          'تم خصم سعر التوصيل بقيمة ${res["remove"].toString()} شيكل',
                                      btnCancelOnPress: () {},
                                      btnOkOnPress: () {},
                                    ).show();
                                  } else {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.error,
                                      animType: AnimType.rightSlide,
                                      btnOkText: "حسنا",
                                      btnCancelText: "اغلاق",
                                      title:
                                          'قيمة الطلبية يجب أن تكون اعلى من ${res["above"].toString()}',
                                      btnCancelOnPress: () {},
                                      btnOkOnPress: () {},
                                    ).show();
                                  }
                                } else {
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.error,
                                    animType: AnimType.rightSlide,
                                    btnOkText: "حسنا",
                                    btnCancelText: "اغلاق",
                                    title: 'الكود غير مفعل',
                                    desc: 'لم يعد هذا الكود مفعل',
                                    btnCancelOnPress: () {},
                                    btnOkOnPress: () {},
                                  ).show();
                                }
                              } else {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String userID =
                                    prefs.getString('user_id') ?? "";

                                bool wheelCoupon = false;
                                // prefs.getBool('wheel_coupon') ?? false;

                                bool couponExists = await checkCouponInFirebase(
                                  couponController.text.trim(),
                                  userID.toString(),
                                );

                                if (couponController.text.trim().toString() ==
                                        "FawriWheel" &&
                                    wheelCoupon == false) {
                                  couponMessage =
                                      "لا يمكنك استخدام الكوبون المدخل , الرجاء المحاولة فيما بعد";
                                  setState(() {});
                                  wheelApplied = false;

                                  _couponMessageTimer?.cancel();

                                  // Set a new timer to clear the message after 15 seconds
                                  _couponMessageTimer = Timer(
                                    Duration(seconds: 5),
                                    () {
                                      setState(() {
                                        couponMessage = "";
                                      });
                                    },
                                  );
                                } else {
                                  if (couponExists) {
                                    couponMessage =
                                        "الكوبون المدخل مستخدم من قبل , الرجاء المحاولة فيما بعد";
                                    setState(() {});
                                    _couponMessageTimer?.cancel();

                                    // Set a new timer to clear the message after 15 seconds
                                    _couponMessageTimer = Timer(
                                      Duration(seconds: 5),
                                      () {
                                        setState(() {
                                          couponMessage = "";
                                        });
                                      },
                                    );
                                  } else {
                                    var res = await getCoupun(
                                      couponController.text,
                                    );
                                    if (res.toString() == "null" ||
                                        res.toString() == "false") {
                                      couponMessage =
                                          "الكوبون المدخل خاطئ , الرجاء المحاولة فيما بعد";
                                      setState(() {});
                                      _couponMessageTimer?.cancel();

                                      // Set a new timer to clear the message after 15 seconds
                                      _couponMessageTimer = Timer(
                                        Duration(seconds: 5),
                                        () {
                                          setState(() {
                                            couponMessage = "";
                                          });
                                        },
                                      );
                                    } else {
                                      couponMessage =
                                          "تم خصم قيمة الكوبون من مجموع الطلبية";

                                      setState(() async {
                                        await pointsController.clearTotal();
                                        for (var i in widget.items) {
                                          int d = (i.shopId != "null")
                                              ? int.tryParse(
                                                      i.shopId.toString(),
                                                    ) ??
                                                    1 // Safely parse integer
                                              : 1;

                                          if (d < 2) {
                                            await pointsController.changeTotal(
                                              pointsController.total +
                                                  (double.parse(
                                                        i.totalPrice!
                                                            .replaceAll("₪", "")
                                                            .toString(),
                                                      ).toDouble() *
                                                      (1 - res)),
                                            );
                                          } else {
                                            printLog(
                                              "$d ffffffffffffffffffffffffffffffffffffffffffffffffffff",
                                            );
                                            await pointsController.changeTotal(
                                              pointsController.total +
                                                  (double.parse(
                                                        i.totalPrice!
                                                            .replaceAll("₪", "")
                                                            .toString(),
                                                      ).toDouble() *
                                                      1),
                                            );
                                          }
                                        }

                                        // widget.total = widget.total * (1 - res);

                                        double discountPercentage1 =
                                            100 * double.parse(res.toString());

                                        discountPercentage = discountPercentage1
                                            .toStringAsFixed(2);

                                        await pointsController
                                            .changeDiscountCoupon(
                                              double.parse(
                                                _calculateTotalDifference(
                                                  pointsController.totalItems,
                                                  pointsController.total,
                                                ),
                                              ),
                                            );
                                        await pointsController.changeTotal(
                                          pointsController.total -
                                              pointsController.discountpoint,
                                        );
                                        if (pointsController.total < 0) {
                                          await pointsController.clearTotal();
                                        }
                                        await pointsController
                                            .changeAllDiscount(
                                              pointsController.discountpoint +
                                                  pointsController
                                                      .discountCoupoun,
                                            );
                                      });
                                    }
                                  }
                                }
                              }
                            } else {
                              setState(() {
                                couponMessage = "تم استخدام الكوبون من قبل";
                              });
                              // Optionally, you can use a timer to clear the message after a few seconds
                              Timer(Duration(seconds: 5), () {
                                setState(() {
                                  couponMessage = "";
                                });
                              });
                            }
                          },
                          child: Container(
                            width: 70,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: mainColor,
                            ),
                            child: Center(
                              child: Text(
                                "تطبيق",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: couponMessage == "" ? false : true,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Row(
                    children: [
                      Text(couponMessage, style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool> checkCouponInFirebase(String coupon, String userId) async {
    try {
      // Query Firestore to check if the coupon and user_id match any record
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('used_copons')
          .where('copon', isEqualTo: coupon)
          .where('user_id', isEqualTo: userId)
          .get();

      // If there are any matching records, return true
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      // Handle any errors here
      printLog("Error checking coupon in Firebase: $e");
      return false;
    }
  }

  // Inside your State class
  @override
  void dispose() {
    // Dispose the timer when the widget is disposed to prevent memory leaks
    _couponMessageTimer?.cancel();
    super.dispose();
  }

  // int _safeRound(dynamic value) {
  //   if (value == null) {
  //     return 0; // Default value if `oldTotal` is null
  //   }
  //   try {
  //     return double.parse(value.toString()).round();
  //   } catch (e) {
  //     return 0; // Default value in case of a parsing error
  //   }
  // }

  String _calculateTotalDifference(dynamic oldTotal, dynamic newTotal) {
    // Handle null values by providing a default value of 0.0
    double oldTotalValue = oldTotal != null
        ? double.parse(
            double.parse(oldTotal.toString()).toStringAsFixed(2).toString(),
          )
        : 0.0;

    double newTotalValue = 0.0;

    if (newTotal != null) {
      String newTotalStr = newTotal.toString();
      if (newTotalStr.length > 5) {
        newTotalStr = newTotalStr.substring(0, 5);
      }
      newTotalValue = double.parse(
        double.parse(newTotalStr.toString()).toStringAsFixed(2).toString(),
      );
    }

    double difference = oldTotalValue - newTotalValue;
    return difference.toStringAsFixed(2);
  }
}
