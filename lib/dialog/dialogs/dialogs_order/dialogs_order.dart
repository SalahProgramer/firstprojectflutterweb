import 'package:fawri_app_refactor/salah/controllers/points_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import '../../../../salah/utilities/sentry_service.dart';
import '../../../../pages/chooses_birthdate/chooses_birthdate.dart';
import '../../../../server/functions/functions.dart';
import '../../../salah/controllers/custom_page_controller.dart';
import '../../../salah/controllers/order_controller.dart';
import '../../../salah/utilities/global/app_global.dart';
import '../../../salah/utilities/style/colors.dart';
import '../../../salah/utilities/style/text_style.dart';
import '../../../salah/utilities/validations/validation.dart';
import '../../../salah/views/pages/orders/new_orders.dart';
import '../../../salah/views/pages/pages.dart';
import '../../../salah/widgets/custom_button.dart';
import '../../../salah/widgets/custom_pop_scope.dart';
import '../../../salah/widgets/lottie_widget.dart';
import '../../../salah/widgets/widget_text_field/can_custom_text_field.dart';
import '../../../salah/widgets/widgets_item_view/button_done.dart';
import '../dialog_waiting/dialog_waiting.dart';

Future<void> dialogErrorOrder() {
  return showDialog(
    context: NavigatorApp.context,
    builder: (BuildContext context) {
      CustomPageController customPageController = context
          .watch<CustomPageController>();
      return CustomPopScope(
        widget: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(0),
          child: Container(
            color: Colors.black.withValues(alpha: 0.8),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: InkWell(
              onTap: () async {
                NavigatorApp.pop();
                NavigatorApp.pop();
                NavigatorApp.pop();
                NavigatorApp.pop();
                await customPageController.changeIndexPage(0);
                await customPageController.changeIndexCategoryPage(1);
                NavigatorApp.navigateToRemoveUntil(Pages());
              },
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      Assets.lottie.animation1726476947033,
                      height: 250.h,
                      reverse: true,
                      repeat: true,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "حدث خطأ ما , الرجاء التواصل معنا على فريق الدعم الفني",
                        textAlign: TextAlign.center,
                        style: CustomTextStyle().heading1L.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    ButtonDone(
                      text: "التواصل معنا",
                      iconName: Assets.icons.phone,
                      onPressed: () async {
                        final url = Uri.parse(
                          "https://www.facebook.com/FawriCOD?mibextid=LQQJ4d",
                        );
                        if (!await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        )) {
                          await SentryService.captureError(
                            exception: "Failed to launch support URL",
                            functionName: "dialogErrorOrder_contact",
                            fileName: "dialogs_order.dart",
                            lineNumber: 85,
                            extraData: {"url": url.toString()},
                          );

                          // messageError(
                          //     "لم يتم التمكن من الدخول الرابط , الرجاء المحاولة فيما بعد");

                          NavigatorApp.pop();
                          NavigatorApp.pop();
                          NavigatorApp.pop();
                          await customPageController.changeIndexPage(0);

                          await customPageController.changeIndexCategoryPage(1);
                        } else {}
                      },
                    ),
                    SizedBox(height: 15.h),
                    ButtonDone(
                      text: "الصفحة الرئيسية",
                      iconName: Assets.icons.home,
                      onPressed: () async {
                        NavigatorApp.pop();
                        NavigatorApp.pop();
                        NavigatorApp.pop();
                        NavigatorApp.pop();
                        await customPageController.changeIndexPage(0);

                        await customPageController.changeIndexCategoryPage(1);
                        NavigatorApp.navigateToRemoveUntil(Pages());
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<void> showCancelOrderDialog({
  required int orderId,
  required String userId,
  required String phone,
  required int totalDiscountAfterDelete,
}) {
  return showGeneralDialog(
    context: NavigatorApp.navigatorKey.currentState!.context,
    barrierLabel: "ccc",
    barrierDismissible: false,
    pageBuilder: (context, animation, secondaryAnimation) {
      OrderControllerSalah orderController = context
          .watch<OrderControllerSalah>();
      PointsController pointsController = context.watch<PointsController>();

      GlobalKey<FormState> formKey = GlobalKey<FormState>();

      return Form(
        key: formKey,
        child: PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: CupertinoAlertDialog(
              insetAnimationCurve: Curves.bounceInOut,
              title: SizedBox(),
              content: Column(
                children: [
                  LottieWidget(
                    name: Assets.lottie.cancelShopping,
                    height: 40.w,
                    width: 40.w,
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    "إلغاء الطلب",
                    style: CustomTextStyle().rubik.copyWith(
                      color: Colors.black,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    "ارجو منك كتابة سبب إلغاء الطلب ",
                    style: CustomTextStyle().rubik.copyWith(
                      color: Colors.black54,
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CanCustomTextFormField(
                    controller: orderController.reason,
                    hintText: 'ادخل السبب',
                    textStyle: CustomTextStyle().heading1L.copyWith(
                      color: Colors.black,
                      fontSize: 10.sp,
                    ),
                    hintStyle: CustomTextStyle().heading1L.copyWith(
                      color: Colors.black45,
                      fontSize: 10.sp,
                    ),
                    maxLines: null,
                    inputType: TextInputType.text,
                    controlPage: null,
                    validate: (p0) {
                      return Validation.checkText(p0.toString(), "السبب");
                    },
                  ),
                ],
              ),
              actions: [
                CustomButtonWithIconWithoutBackground(
                  text: "إلغاء الطلب",
                  textIcon: "",
                  height: 16.h,
                  textStyle: CustomTextStyle().rubik.copyWith(
                    color: CustomColor.chrismasColor,
                    fontSize: 12.sp,
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      String? phone = prefs.getString("phone");

                      NavigatorApp.pop();
                      await Future.delayed(Duration(milliseconds: 100));
                      dialogWaiting();

                      bool check = await cancelOrder(
                        orderId,
                        orderController.reason.text,
                        context,
                        phone ?? "",
                        totalDiscountAfterDelete,
                      );
                      if (check == true) {
                        final f1 = orderController.initialsOrders(
                          phone: phone ?? "",
                        );
                        final f2 = pointsController.getPointsFromAPI(
                          phone: phone ?? "",
                        );
                        await Future.wait([f1, f2]);
                      }
                      orderController.reason.clear();
                    } else {}
                  },
                ),
                CustomButtonWithIconWithoutBackground(
                  text: "رجوع",
                  textIcon: "",
                  height: 16.h,
                  textStyle: CustomTextStyle().rubik.copyWith(
                    color: Colors.black,
                    fontSize: 12.sp,
                  ),
                  onPressed: () async {
                    NavigatorApp.pop();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> dialogSuccessOrder({
  required String userID,
  required String token,
  required TextEditingController phoneController,
  required TextEditingController nameController,
  required String selectedArea,
}) {
  return showDialog(
    context: NavigatorApp.context,
    builder: (BuildContext context) {
      CustomPageController customPageController = context
          .watch<CustomPageController>();
      OrderControllerSalah orderControllerSalah = context
          .watch<OrderControllerSalah>();

      return CustomPopScope(
        widget: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(0),
          child: Container(
            color: Colors.black.withValues(alpha: 0.8),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: InkWell(
              onTap: () async {
                NavigatorApp.pop();
                NavigatorApp.pop();

                SharedPreferences prefs = await SharedPreferences.getInstance();
                bool? show = prefs.getBool('show_birthday') ?? true;

                if (show) {
                  NavigatorApp.push(
                    ChooseBirthdate(
                      name: nameController.text,
                      phoneController: phoneController.text,
                      token: token.toString(),
                      userID: userID.toString(),
                      selectedArea: selectedArea.toString(),
                      select: 2,
                    ),
                  );
                } else {
                  await customPageController.changeIndexPage(0);
                  await customPageController.changeIndexCategoryPage(1);
                  NavigatorApp.pushReplacment(Pages());
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset(
                    Assets.lottie.animation1701597212878,
                    height: 250.h,
                    reverse: true,
                    repeat: true,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Text(
                      "شكرا لشرائك من فوري ستحتاج الطلبية من ٣-٤ ايام ، يمكنك متابعة الطلب من قسم طلباتي الحالية",
                      textAlign: TextAlign.center,
                      style: CustomTextStyle().heading1L.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  ButtonDone(
                    iconName: Assets.icons.home,
                    onPressed: () async {
                      NavigatorApp.pop();
                      NavigatorApp.pop();

                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      bool? show = prefs.getBool('show_birthday') ?? true;

                      if (show) {
                        NavigatorApp.push(
                          ChooseBirthdate(
                            name: nameController.text,
                            phoneController: phoneController.text,
                            token: token.toString(),
                            userID: userID.toString(),
                            selectedArea: selectedArea.toString(),
                            select: 0,
                          ),
                        );
                      } else {
                        await customPageController.changeIndexPage(0);
                        await customPageController.changeIndexCategoryPage(1);
                        NavigatorApp.pushReplacment(Pages());
                      }
                    },
                    text: "الصفحة الرئيسية",
                  ),
                  SizedBox(height: 15.h),
                  ButtonDone(
                    iconName: Assets.icons.order,
                    onPressed: () async {
                      await orderControllerSalah.changePageOrder(0);
                      NavigatorApp.pop();

                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      bool? show = prefs.getBool('show_birthday') ?? true;

                      if (show) {
                        NavigatorApp.push(
                          ChooseBirthdate(
                            name: nameController.text,
                            phoneController: phoneController.text,
                            token: token.toString(),
                            userID: userID.toString(),
                            selectedArea: selectedArea.toString(),
                            select: 1,
                          ),
                        );
                      } else {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        String? phone = prefs.getString("phone");

                        NavigatorApp.pushReplacment(
                          OrdersPages(
                            userId: userID.toString(),
                            phone: phone ?? "",
                          ),
                        );
                      }
                    },
                    text: "تتبع طلبياتي",
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
