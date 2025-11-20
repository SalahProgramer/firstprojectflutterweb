import 'package:fawri_app_refactor/core/dialogs/dialog_waiting/dialog_waiting.dart';
import 'package:fawri_app_refactor/controllers/page_main_screen_controller.dart';
import 'package:fawri_app_refactor/controllers/points_controller.dart';
import 'package:fawri_app_refactor/controllers/rating_controller.dart';
import 'package:fawri_app_refactor/core/utilities/global/app_global.dart';
import 'package:fawri_app_refactor/core/utilities/style/text_style.dart';
import 'package:fawri_app_refactor/core/utilities/print_looger.dart';
import 'package:fawri_app_refactor/core/widgets/widget_text_field/can_custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:rating_and_feedback_collector/rating_and_feedback_collector.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utilities/style/colors.dart';
import '../../widgets/custom_button.dart';
import '../dialogs_spin_and_points/dialogs_points.dart';

class DialogRating extends StatefulWidget {
  const DialogRating({super.key});

  @override
  State<DialogRating> createState() => _DialogRatingState();
}

class _DialogRatingState extends State<DialogRating> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PageMainScreenController pageMainScreenController =
          context.read<PageMainScreenController>();

      pageMainScreenController.focusNodeDescription.addListener(() {
        pageMainScreenController.isFocusedNotifier.value =
            pageMainScreenController.focusNodeDescription.hasFocus;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    RatingController ratingController = context.watch<RatingController>();
    PageMainScreenController pageMainScreenController =
        context.watch<PageMainScreenController>();
    PointsController pointsController = context.watch<PointsController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        shader(text: "سرعة التوصيل ؟"),
        SizedBox(
          height: 5.h,
        ),
        RatingBar(
          iconSize: 25.h,
          // Size of the rating icons
          allowHalfRating: true,
          // Allows selection of half ratings
          showDescriptionInput: true,

          filledIcon: Icons.star,
          // Icon to display for a filled rating unit
          halfFilledIcon: Icons.star_half,
          // Icon to display for a half-filled rating unit
          emptyIcon: Icons.star_border,

          // Icon to display for an empty rating units
          filledColor: Colors.amber,
          // Color of filled rating units
          emptyColor: Colors.black,
          // Color of empty rating units
          currentRating: ratingController.rateSpeedDelivery,
          // Set initial rating value
          onRatingChanged: (rating) async {
            await ratingController.changeRatingSpeedDelivery(rating);
          },
          // showFeedbackForRatingsLessThan: 4,
          // feedbackUIType: FeedbackUIType.alertBox,
          // fee
          // onSubmitTap: (selectedFeedback,description){
          //
          //   //use selectedFeedback!.key to get selected reason index
          //   //use selectedFeedback!.value to get selected reason text
          //   //use description to get selected reason text
          //
          // },
        ),
        SizedBox(
          height: 10.h,
        ),
        shader(text: "جودة البضائع ؟"),
        SizedBox(
          height: 5.h,
        ),
        RatingBarEmoji(
          imageSize: 25.h,

          // Size of image in the rating bar.
          currentRating: ratingController.rateQuality,
          // Set initial rating value
          onRatingChanged: (rating) async {
            await ratingController.changeRateQuality(rating);
          },

          // showFeedbackForRatingsLessThan: 4,
          // feedbackUIType: FeedbackUIType.bottomSheet,
        ),
        SizedBox(
          height: 10.h,
        ),
        shader(text: "تناسب المقاسات ؟"),
        SizedBox(
          height: 5.h,
        ),
        RatingBarCustomImage(
          imageSize: 25.h,
          // Size of image in the rating bar.
          currentRating: ratingController.rateSizes,
          // Set initial rating value
          activeImages: [
            AssetImage(Assets.images.rating.icAngry.path),
            AssetImage(Assets.images.rating.icSad.path),
            AssetImage(Assets.images.rating.icNeutral.path),
            AssetImage(Assets.images.rating.icHappy.path),
            AssetImage(Assets.images.rating.icExcellent.path),
          ],

          deActiveImages: [
            AssetImage(Assets.images.rating.icAngryDisable.path),
            AssetImage(Assets.images.rating.icSadDisable.path),
            AssetImage(Assets.images.rating.icNeutralDisable.path),
            AssetImage(Assets.images.rating.icHappyDisable.path),
            AssetImage(Assets.images.rating.icExcellentDisable.path),
          ],
          onRatingChanged: (rating) async {
            await ratingController.changeRateSizes(rating);
          },
        ),
        SizedBox(
          height: 10.h,
        ),
        shader(text: "ملاحظات عن التطبيق ؟"),
        SizedBox(
          height: 5.h,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: CanCustomTextFormField(
              hintText: "ما هي ملاحظاتك عن التطبيق ؟",
              focusNode: pageMainScreenController.focusNodeDescription,
              textStyle: CustomTextStyle().heading1L.copyWith(
                  color: Colors.black,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold),
              hintStyle: CustomTextStyle().heading1L.copyWith(
                  color: Colors.black54,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.bold),
              hasFocusBorder: true,
              inputType: TextInputType.text,
              controller: ratingController.descriptionText,
              controlPage: ratingController,
              onChanged: (p0) async {
                printLog(p0);
                ratingController.changeText(p0);
              },
              maxLines: 2,
              maxLength: 300),
        ),
        SizedBox(
          height: 20.h,
        ),
        SizedBox(
          width: double.maxFinite,
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButtonWithIconWithoutBackground(
                  text: "تقييم",
                  textIcon: "",
                  hasBackground: false,
                  height: 16.h,
                  textStyle: CustomTextStyle().rubik.copyWith(
                      color: (ratingController.rateSizes != 0.0 &&
                              ratingController.rateQuality != 0.0 &&
                              ratingController.rateSpeedDelivery != 0.0)
                          ? CustomColor.blueColor
                          : Colors.grey,
                      fontSize: 14.sp),
                  onPressed: (ratingController.rateSizes != 0.0 &&
                          ratingController.rateQuality != 0.0 &&
                          ratingController.rateSpeedDelivery != 0.0)
                      ? () async {
                          await analyticsService.logEvent(
                            parameters: {
                              "rating_value": ratingController.rateApp
                            },
                            eventName: "user_rating",
                          );
                          NavigatorApp.pop();
                          dialogWaiting();
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          bool check =
                              await ratingController.addFeedBckInServer(
                                  orderId: pageMainScreenController.userActivity
                                          .checkOrderStatus?.orderId ??
                                      1,
                                  description:
                                      ratingController.text.toString().trim(),
                                  deliverySpeed: ratingController
                                      .rateSpeedDelivery
                                      .toInt(),
                                  itemsQuality:
                                      ratingController.rateQuality.toInt(),
                                  sizesFit: ratingController.rateSizes.toInt());

                          String phone = prefs.getString('phone') ?? "";

                          await pointsController.updateUserPointsAndLevel(
                              phone: phone, newAmount: '3', enumNumber: 4);

                          final f1 = pageMainScreenController.getUserActivity(
                              phone: phone);
                          final f2 =
                              pointsController.getPointsFromAPI(phone: phone);

                          await Future.wait([f1, f2]);
                          await ratingController.changeLoading(false);
                          if (check) {
                            NavigatorApp.pop();

                            dialogGetPoint("3 نقاط");
                          } else {
                            NavigatorApp.pop();
                          }
                        }
                      : () {},
                ),
                CustomButtonWithIconWithoutBackground(
                  text: "ليس الآن",
                  hasBackground: false,
                  textIcon: "",
                  height: 16.h,
                  textStyle: CustomTextStyle()
                      .rubik
                      .copyWith(color: Colors.black, fontSize: 14.sp),
                  onPressed: () async {
                    await analyticsService.logEvent(
                      parameters: {"rating_value": ratingController.rateApp},
                      eventName: "user_rating",
                    );
                    NavigatorApp.pop();
                  },
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
      ],
    );
  }

  Widget shader({required String text}) {
    return ShaderMask(
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
          text,
          style: CustomTextStyle().heading1L.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 12.sp),
        ));
  }
}
