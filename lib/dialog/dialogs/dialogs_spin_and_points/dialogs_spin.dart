import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../salah/controllers/page_main_screen_controller.dart';
import '../../../salah/utilities/global/app_global.dart';
import '../../../salah/utilities/style/colors.dart';
import '../../../salah/utilities/style/text_style.dart';
import '../../../salah/views/pages/spining_wheel/spin_wheel.dart';
import '../../../salah/widgets/custom_button.dart';
import '../../../salah/widgets/lottie_widget.dart';
import '../dialog_phone/dialog_add_phone.dart';

AnalyticsService analyticsService = AnalyticsService();
//dialogs-spin---------------------------------------------------------------------------------------------------
Future<void> dialogDoSpin() {
  return showDialog(
    context: NavigatorApp.context,
    builder: (context) {
      return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(0),
          child: GestureDetector(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('skip_spin', true);
              NavigatorApp.pop();
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Stack(
                    children: [
                      LottieWidget(
                        name: Assets.lottie.happy1,
                        height: 1.sh,
                        width: 1.sw,
                      ),
                      Center(
                          child: PopScope(
                        canPop: false,
                        child: CupertinoAlertDialog(
                          insetAnimationCurve: Curves.bounceInOut,
                          title: SizedBox(),
                          content: Column(
                            children: [
                              LottieWidget(
                                name: Assets.lottie.spinWheel1,
                                height: 50.w,
                                width: 50.w,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("لف وأربح معنا",
                                      style: CustomTextStyle()
                                          .heading1L
                                          .copyWith(
                                              color: Colors.black,
                                              fontSize: 16.sp)),
                                ],
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Text(
                                "🎉 لف الدولاب وأربح نقاط و خصومات  حصرية! هل أنت مستعد للتحدي؟ 🎉",
                                style: CustomTextStyle().heading1L.copyWith(
                                    color: Colors.black87, fontSize: 10.sp),
                              ),
                            ],
                          ),
                          actions: [
                            CustomButtonWithIconWithoutBackground(
                              text: "تخطي",
                              textIcon: "",
                              height: 16.h,
                              textStyle: CustomTextStyle().rubik.copyWith(
                                  color: Colors.black, fontSize: 12.sp),
                              onPressed: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setBool('skip_spin', true);

                                NavigatorApp.pop();
                              },
                            ),
                            CustomButtonWithIconWithoutBackground(
                                text: "هيا نربح",
                                textIcon: "",
                                height: 16.h,
                                hasBackground: true,
                                backgroundColor: Colors.transparent,
                                textStyle: CustomTextStyle().rubik.copyWith(
                                    color: CustomColor.blueColor,
                                    fontSize: 12.sp),
                                onPressed: () async {
                                  await analyticsService.logEvent(
                                    eventName: "spin_dialog_lets_win_click",
                                    parameters: {
                                      "class_name": "DialogsSpin",
                                      "button_name": "هيا نربح spin the wheel",
                                      "time": DateTime.now().toString(),
                                    },
                                  );
                                  NavigatorApp.pop();
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  String phone = prefs.getString('phone') ?? "";
                                  await prefs.setBool('skip_spin', true);

                                  if (phone == "") {
                                    await showAddPhone();
                                  } else {
                                    NavigatorApp.push(SpinWheel());
                                  }
                                }),
                          ],
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ));
    },
  );
}

Future<void> dialogCannotDoSpin() {
  return showDialog(
    context: NavigatorApp.context,
    builder: (context) {
      PageMainScreenController pageMainScreenController =
          context.watch<PageMainScreenController>();

      final timeRemaining =
          pageMainScreenController.userActivity.getEnumTimeRemaining("2");

      return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(0),
          child: GestureDetector(
            onTap: () {
              NavigatorApp.pop();
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Center(
                      child: PopScope(
                    canPop: false,
                    child: CupertinoAlertDialog(
                      insetAnimationCurve: Curves.bounceInOut,
                      title: SizedBox(),
                      content: Column(
                        children: [
                          LottieWidget(
                            name: Assets.lottie.spinWheel1,
                            height: 50.w,
                            width: 50.w,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(timeRemaining,
                                  style: CustomTextStyle().rubik.copyWith(
                                      color: Colors.black, fontSize: 16.sp)),
                            ],
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Text(
                            "يمكنك لف الدولاب وربح نقاط و الخصومات الحصرية ! بعد انتهاء هذا الوقت",
                            style: CustomTextStyle().heading1L.copyWith(
                                color: Colors.black87, fontSize: 10.sp),
                          ),
                        ],
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomButtonWithIconWithoutBackground(
                                text: "رجوع",
                                textIcon: "",
                                height: 16.h,
                                hasBackground: true,
                                backgroundColor: Colors.transparent,
                                textStyle: CustomTextStyle().rubik.copyWith(
                                    color: Colors.black, fontSize: 12.sp),
                                onPressed: () async {
                                  NavigatorApp.pop();
                                }),
                          ],
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ));
    },
  );
}
