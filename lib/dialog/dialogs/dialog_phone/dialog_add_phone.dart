import 'package:fawri_app_refactor/dialog/dialogs/dialog_waiting/dialog_waiting.dart';
import 'package:fawri_app_refactor/salah/controllers/order_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/page_main_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import '../../../salah/controllers/points_controller.dart';
import '../../../salah/utilities/global/app_global.dart';
import '../../../salah/utilities/style/colors.dart';
import '../../../salah/utilities/style/text_style.dart';
import '../../../salah/utilities/validations/validation.dart';
import '../../../salah/views/pages/spining_wheel/spin_wheel.dart';
import '../../../salah/widgets/custom_button.dart';
import '../../../salah/widgets/snackBarWidgets/snack_bar_style.dart';
import '../../../salah/widgets/snackBarWidgets/snackbar_widget.dart';
import '../../../salah/widgets/widget_text_field/can_custom_text_field.dart';
import '../../../services/analytics/analytics_service.dart';
import '../dialog_blocked/dialog_blocked.dart';

Future<void> showAddPhone({bool isPopUp = false, bool goToSpin = true}) {
  return showGeneralDialog(
    context: NavigatorApp.navigatorKey.currentState!.context,
    barrierLabel: "ccc",
    barrierDismissible: false,
    pageBuilder: (context, animation, secondaryAnimation) => ShowAddPhone(
      goToSpin: goToSpin,
      isPopUp: isPopUp,
    ),
  );
}

class ShowAddPhone extends StatefulWidget {
  final bool isPopUp;
  final bool goToSpin;
  const ShowAddPhone(
      {super.key, required this.isPopUp, required this.goToSpin});

  @override
  State<ShowAddPhone> createState() => _ShowAddPhoneState();
}

class _ShowAddPhoneState extends State<ShowAddPhone> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AnalyticsService analyticsService = AnalyticsService();

  @override
  Widget build(BuildContext context) {
    final PointsController pointsController = context.watch<PointsController>();
    final PageMainScreenController pageMainScreenController =
        context.watch<PageMainScreenController>();
    final OrderControllerSalah orderController =
        context.watch<OrderControllerSalah>();

    return PopScope(
      canPop: false,
      child: AlertDialog(
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () async {
                await analyticsService.logEvent(
                  eventName: "unfocus_add_phone_click",
                  parameters: {
                    "class_name": "AddPhoneDialog",
                    "button_name": "إلغاء التركيز في إضافة الهاتف",
                    "time": DateTime.now().toString(),
                  },
                );
                FocusScope.of(context).unfocus();
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Form(
                key: formKey,
                child: Center(
                  child: Material(
                    type: MaterialType.transparency,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(
                              CustomColor.blueColor, BlendMode.srcIn),
                          child: Lottie.asset(
                            Assets.lottie.addPhone,
                            fit: BoxFit.contain,
                            height: 40,
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "أضف رقمك",
                            style: CustomTextStyle().heading1L.copyWith(
                                color: Colors.black,
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          "سجّل رقمك لتحصل على نقاط وتستبدلها بجوائز",
                          textAlign: TextAlign.center,
                          style: CustomTextStyle().heading1L.copyWith(
                                color: Colors.black.withValues(alpha: 0.6),
                                fontSize: 12.sp,
                              ),
                        ),
                        SizedBox(height: 18.h),

                        /// إدخال رقم الهاتف
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: CanCustomTextFormField(
                                  radius: 25.sp,
                                  autofocus: true,
                                  borderColor: Colors.black,
                                  hintText: "056-123-4567",
                                  inputType: TextInputType.number,
                                  controller: pointsController.phoneController,
                                  hasFocusBorder: true,
                                  maxLength: 10,
                                  hasFill: true,
                                  textAlign: TextAlign.center,
                                  hasSeePassIcon: true,
                                  textStyle: CustomTextStyle()
                                      .heading1L
                                      .copyWith(
                                          color: Colors.black, fontSize: 12.sp),
                                  suffixIcon: Icon(
                                    Icons.phone,
                                    color: CustomColor.blueColor,
                                    size: 20.sp,
                                  ),
                                  controlPage: null,
                                  validate: (p0) =>
                                      Validation.checkPhoneNumber(p0 ?? ""),
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 5.h),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            /// زر "أضف الرقم"
                            CustomButtonWithoutIcon(
                              backColor: CustomColor.blueColor,
                              text: "أضف الرقم",
                              height: 40.h,
                              textStyle: CustomTextStyle().rubik.copyWith(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                  ),
                              onPressed: () async {
                                await analyticsService.logEvent(
                                  eventName: "add_phone_number_click",
                                  parameters: {
                                    "class_name": "AddPhoneDialog",
                                    "button_name": "أضف الرقم",
                                    "time": DateTime.now().toString(),
                                  },
                                );
                                try {
                                  FocusScope.of(context).unfocus();
                                  final phone = pointsController
                                      .phoneController.text
                                      .trim();
                                  if (formKey.currentState?.validate() !=
                                      true) {
                                    return;
                                  }
                                  NavigatorApp.pop();
                                  dialogWaiting();
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString('phone', phone);

                                  await pointsController.changePhone(phone);
                                  final f1 = pageMainScreenController
                                      .getUserActivity(phone: phone);
                                  final f2 = pointsController.getPointsFromAPI(
                                      phone: phone);
                                  final f3 = orderController.initialsOrders(
                                      phone: phone);
                                  await Future.wait([f1, f2, f3]);

                                  if (pageMainScreenController
                                          .userActivity.isActive ==
                                      false) {
                                    NavigatorApp.pop();

                                    await showBlockedDialog();
                                  }

                                  if (!(widget.isPopUp)) {
                                    showSnackBar(
                                      title: "تم إضافة الرقم بنجاح",
                                      type: SnackBarType.success,
                                    );
                                    NavigatorApp.pop();

                                    if (widget.goToSpin) {
                                      if ((pageMainScreenController.userActivity
                                              .getEnumStatus('2')
                                              .canUse ==
                                          true)) {
                                        NavigatorApp.push(SpinWheel());
                                      }
                                    }
                                    pointsController.phoneController.clear();
                                  }
                                } catch (e) {
                                  showSnackBar(
                                    title: "حدث خطأ أثناء العملية",
                                    type: SnackBarType.error,
                                    description: 'يرجى المحاولة مرة أخرى',
                                  );
                                }
                              },
                              textWaiting: '',
                            ),

                            /// زر "رجوع"
                            CustomButtonWithIconWithoutBackground(
                              text: "رجوع",
                              height: 40.h,
                              textStyle: CustomTextStyle().rubik.copyWith(
                                  color: Colors.grey[600], fontSize: 12.sp),
                              onPressed: () async {
                                await analyticsService.logEvent(
                                  eventName: "back_from_add_phone_click",
                                  parameters: {
                                    "class_name": "AddPhoneDialog",
                                    "button_name": "رجوع من إضافة الهاتف",
                                    "time": DateTime.now().toString(),
                                  },
                                );
                                NavigatorApp.pop();
                              },
                              textIcon: '',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
