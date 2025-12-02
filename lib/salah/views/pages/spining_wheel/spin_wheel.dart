import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/controllers/page_main_screen_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/points_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/wheel_controller.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:fawri_app_refactor/salah/utilities/style/text_style.dart';
import 'package:fawri_app_refactor/salah/widgets/app_bar_widgets/app_bar_custom.dart';
import 'package:fawri_app_refactor/salah/widgets/lottie_widget.dart';
import 'package:fawri_app_refactor/server/functions/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glowy_borders/glowy_borders.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../dialog/dialogs/dialogs_spin_and_points/dialogs_points.dart';
import '../../../utilities/audio_player_extensions.dart';
import '../../../utilities/style/colors.dart';
import '../../../widgets/widgets_main_screen/custom_button_spin.dart';

class SpinWheel extends StatefulWidget {
  const SpinWheel({super.key});

  @override
  State<SpinWheel> createState() => _SpinWheelState();
}

class _SpinWheelState extends State<SpinWheel> {
  StreamController<int> controller = StreamController<int>();

  @override
  Widget build(BuildContext context) {
    WheelController wheelController = context.watch<WheelController>();
    PointsController pointsController = context.watch<PointsController>();
    PageMainScreenController pageMainScreenController =
        context.watch<PageMainScreenController>();

    // Get enum status for wheel (enum "2") with fallback handling
    final canUseWheel = pageMainScreenController.userActivity.canUseEnum("2");
    final timeRemaining =
        pageMainScreenController.userActivity.getEnumTimeRemaining("2");
    return Container(
      width: 1.sw,
      height: 1.sh,
      decoration: BoxDecoration(
          image: DecorationImage(
              filterQuality: FilterQuality.high,
              fit: BoxFit.cover,
              image: AssetImage(
                Assets.images.backg.path,
              )),
          color: Colors.white),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
          title: ' لف وأربح معنا',
          textButton: "رجوع",
          onPressed: () {
            NavigatorApp.pop();
          },
          actions: [],
          colorWidgets: Colors.white,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 20.h,
            ),
            Center(
                child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (Rect bounds) {
                return RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.0,
                  colors: <Color>[
                    CustomColor.chrismasColor,
                    CustomColor.blueColor,
                    CustomColor.chrismasColor
                  ],
                  tileMode: TileMode.mirror,
                ).createShader(bounds);
              },
              child: Text(
                "دولاب الفوز",
                style: TextStyle(color: Colors.white, fontSize: 30.sp),
              ),
            )),
            SizedBox(
              height: 0.2.sh,
            ),
            SizedBox(
              width: 1.sw,
              height: 1.sw,
              child: AnimatedGradientBorder(
                gradientColors: [
                  CustomColor.chrismasColor,
                  CustomColor.blueColor
                ],
                borderSize: 3.5,
                glowSize: 2.h,
                borderRadius: BorderRadius.circular(99999999999999.r),
                child: FortuneWheel(
                  selected: controller.stream,
                  // styleStrategy: ,
                  animateFirst: false,

                  hapticImpact: HapticImpact.medium,
                  indicators: [
                    FortuneIndicator(
                        alignment: Alignment.topCenter,
                        child: TriangleIndicator(
                          color: CustomColor.greenColor,
                          width: 35.w,
                          height: 35.w,
                          elevation: 10,
                        )),
                    FortuneIndicator(
                      alignment: Alignment.center,
                      child: AnimatedGradientBorder(
                        gradientColors: [
                          CustomColor.chrismasColor,
                          CustomColor.blueColor
                        ],
                        borderSize: 1.5,
                        glowSize: 1.h,
                        borderRadius: BorderRadius.circular(40.r),
                        child: CircleAvatar(
                          radius: 35.r,
                          backgroundColor:
                              Colors.transparent, // Ensure no obstruction
                          child: ClipOval(
                            child: Image.asset(
                              Assets.images.fawri.path,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  items: [
                    fourtuneSpecificItem(
                        text: "3 نقاط",
                        style: FortuneItemStyle(
                            borderWidth: 0,
                            borderColor: Colors.transparent,
                            color: Colors.blue),
                        nameIcon: Assets.lottie.pointcoins),
                    fourtuneSpecificItem(
                        text: "5 نقاط",
                        style: FortuneItemStyle(
                            borderWidth: 0,
                            borderColor: Colors.transparent,
                            color: CustomColor.blueColor),
                        nameIcon: Assets.lottie.pointcoins),
                    fourtuneSpecificItem(
                        text: "10 نقاط",
                        style: FortuneItemStyle(
                          borderWidth: 0,
                          borderColor: Colors.transparent,
                          color: Colors.blue,
                        ),
                        nameIcon: Assets.lottie.pointcoins),
                    fourtuneSpecificItem(
                        text: "15 نقاط",
                        style: FortuneItemStyle(
                            borderWidth: 0,
                            borderColor: Colors.transparent,
                            color: CustomColor.blueColor),
                        nameIcon: Assets.lottie.pointcoins),
                    fourtuneSpecificItem(
                        text: "25 % \nكوبون خصم ",
                        coupon: true,
                        style: FortuneItemStyle(
                            borderWidth: 0,
                            borderColor: Colors.transparent,
                            color: Colors.blue),
                        nameIcon: Assets.lottie.coupon),
                    fourtuneSpecificItem(
                      text: "جائزة فوري",
                      style: FortuneItemStyle(
                          borderWidth: 0,
                          borderColor: Colors.transparent,
                          color: CustomColor.blueColor),
                      nameIcon: Assets.lottie.offer,
                    ),
                  ],

                  onAnimationEnd: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String phone = prefs.getString('phone') ?? "";
                    if (wheelController.outComeWheel == 0) {
                      final player = AudioPlayer();

                      // Play audio when the dialog opens
                      player.playAsset(Assets.audios.iDidItMessageTone);
                      // Stop the audio after 5 seconds
                      Future.delayed(const Duration(seconds: 3), () async {
                        await player.stop();
                      });
                      dialogGetPoint("3 نقاط");
                      await pointsController.updateUserPointsAndLevel(
                          enumNumber: 2, phone: phone, newAmount: "3");
                      final f1 = pageMainScreenController.getUserActivity(
                          phone: phone);
                      final f2 =
                          pointsController.getPointsFromAPI(phone: phone);

                      await Future.wait([f1, f2]);
                    } else if (wheelController.outComeWheel == 1) {
                      final player = AudioPlayer();

                      // Play audio when the dialog opens
                      player.playAsset(Assets.audios.iDidItMessageTone);
                      // Stop the audio after 5 seconds
                      Future.delayed(const Duration(seconds: 3), () async {
                        await player.stop();
                      });
                      dialogGetPoint("5 نقاط");
                      await pointsController.updateUserPointsAndLevel(
                          enumNumber: 2, phone: phone, newAmount: "5");

                      final f1 = pageMainScreenController.getUserActivity(
                          phone: phone);
                      final f2 =
                          pointsController.getPointsFromAPI(phone: phone);
                      await Future.wait([f1, f2]);
                    } else if (wheelController.outComeWheel == 2) {
                      final player = AudioPlayer();

                      // Play audio when the dialog opens
                      player.playAsset(Assets.audios.iDidItMessageTone);
                      // Stop the audio after 5 seconds
                      Future.delayed(const Duration(seconds: 3), () async {
                        await player.stop();
                      });
                      dialogGetPoint("10 نقاط");
                      await pointsController.updateUserPointsAndLevel(
                          enumNumber: 2, phone: phone, newAmount: "10");
                      final f1 = pageMainScreenController.getUserActivity(
                          phone: phone);
                      final f2 =
                          pointsController.getPointsFromAPI(phone: phone);
                      await Future.wait([f1, f2]);
                    } else if (wheelController.outComeWheel == 3) {
                      final player = AudioPlayer();

                      // Play audio when the dialog opens
                      player.playAsset(Assets.audios.iDidItMessageTone);
                      // Stop the audio after 5 seconds
                      Future.delayed(const Duration(seconds: 3), () async {
                        await player.stop();
                      });

                      dialogGetPoint("15 نقاط");

                      await pointsController.updateUserPointsAndLevel(
                          enumNumber: 2, phone: phone, newAmount: "15");
                      final f1 = pageMainScreenController.getUserActivity(
                          phone: phone);
                      final f2 =
                          pointsController.getPointsFromAPI(phone: phone);
                      await Future.wait([f1, f2]);
                    } else if (wheelController.outComeWheel == 4) {
                      final player = AudioPlayer();

                      // Play audio when the dialog opens
                      player.playAsset(Assets.audios.iDidItMessageTone);
                      // Stop the audio after 5 seconds
                      Future.delayed(const Duration(seconds: 5), () async {
                        await player.stop();
                      });
                      await pointsController.updateUserPointsAndLevel(
                          enumNumber: 2, phone: phone, newAmount: "1");
                      final f1 = pageMainScreenController.getUserActivity(
                          phone: phone);
                      final f2 =
                          pointsController.getPointsFromAPI(phone: phone);
                      await Future.wait([f1, f2]);

                      await dialogGetPoint("", havsCoupon: false);
                    }

                    //                   //execution----------------------------------------------------------
                    // //done------------------------------------------------------------
                    // Update the last execution timestamp
                  },
                ),
              ),
            ),
            SizedBox(
              height: 40.h,
            ),
            CustomButtonSpin(
              width: double.maxFinite,
              flex: 1,
              textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold),
              height: 40.h,
              onTap: canUseWheel ? flingWheel : null,
              canTap: canUseWheel,
              fontSize: 17.sp,
              text: canUseWheel ? 'اضغط هنا واربح معنا' : timeRemaining,
              nameLottie: "",
            )
          ],
        ),
      ),
    );
  }

  void flingWheel() async {
    WheelController wheelController = context.read<WheelController>();
    printLog("msg");
    // تعريف الأوزان لكل نتيجة بناءً على احتمالية الفوز
    // وزن أعلى يعني فرصة أكبر للفوز بتلك النتيجة
    List<int> weights = [
      18,
      12,
      7,
      0,
      0,
      0
    ]; // 3 نقاط، 5 نقاط، 10 نقاط، كوبون خصم، جائزة خاصة

    // حساب مجموع الأوزان لمعرفة نسبة كل نتيجة مقارنة بالمجموع
    int totalWeight = weights.reduce((a, b) => a + b); // مجموع الأوزان = 40

    // قائمة لتخزين النتائج مع النسبة المئوية لكل نتيجة
    List<Map<String, dynamic>> outcomes = [];
    for (int i = 0; i < weights.length; i++) {
      // تحويل الوزن إلى نسبة مئوية
      double percentage = (weights[i] / totalWeight) * 100;
      // إضافة النتيجة والفهرس إلى القائمة
      outcomes.add({'index': i, 'percentage': percentage});
    }

    // جمع النسب المئوية لحساب الاحتمالات الإجمالية
    double totalProbability =
        outcomes.fold(0, (sum, item) => sum + item['percentage']);

    // اختيار قيمة عشوائية بين 0 و100 لاختيار النتيجة
    double randomValue = Random().nextDouble() * totalProbability;
    double cumulative = 0; // تراكم النسب المئوية
    int selectedOutcome = 0; // النتيجة المختارة

    // تحديد النتيجة بناءً على الاحتمال المتراكم
    for (var item in outcomes) {
      cumulative += item['percentage']; // إضافة النسبة المئوية الحالية
      if (randomValue <= cumulative) {
        selectedOutcome = item['index']; // اختيار النتيجة
        break;
      }
    }

    // تعيين النتيجة النهائية في العجلة
    await wheelController.setOutcomeWheel(selectedOutcome);
    // await pointsController.setOutcomeWheel(4);

    // تحديث المؤشر لإظهار النتيجة المختارة
    controller.add(wheelController.outComeWheel);
  }

  FortuneItem fourtuneSpecificItem(
      {required String text,
      bool coupon = false,
      FortuneItemStyle? style,
      required String nameIcon}) {
    return FortuneItem(
        style: style,
        child: RotatedBox(
          quarterTurns: 1,
          child: Padding(
            padding: EdgeInsets.only(bottom: 0.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  text,
                  textDirection:
                      (coupon) ? TextDirection.ltr : TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: CustomTextStyle()
                      .heading1L
                      .copyWith(color: Colors.white, fontSize: 14.sp),
                ),
                Padding(
                  padding: (nameIcon == Assets.lottie.coupon)
                      ? EdgeInsets.only(right: 30.w)
                      : EdgeInsets.zero,
                  child: LottieWidget(
                    width: (nameIcon == Assets.lottie.pointcoins) ? 50.w : 40.w,
                    height:
                        (nameIcon == Assets.lottie.pointcoins) ? 50.w : 40.w,
                    name: nameIcon,
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
