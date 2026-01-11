import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/controllers/rating_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glowy_borders/glowy_borders.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../salah/utilities/global/app_global.dart';
import '../../../salah/utilities/audio_player_extensions.dart';
import '../../../salah/utilities/style/colors.dart';
import '../../../salah/utilities/style/text_style.dart';
import '../../../salah/widgets/custom_button.dart';
import '../../../services/analytics/analytics_service.dart';

Future<void> dialogRatingApp({required RateMyApp rateMyApp}) {
  return showGeneralDialog(
    context: NavigatorApp.navigatorKey.currentState!.context,
    barrierLabel: "ccc",
    barrierDismissible: false,
    pageBuilder: (context, animation, secondaryAnimation) {
      RatingController ratingController = context.watch<RatingController>();
      AnalyticsService analyticsService = AnalyticsService();

      return PopScope(
        canPop: false,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Align(
            alignment: Alignment.center,
            child: Material(
              type: MaterialType.transparency,
              child: AnimatedGradientBorder(
                borderRadius: BorderRadius.circular(10),
                gradientColors: [
                  CustomColor.blueColor,
                  CustomColor.chrismasColor,
                ],
                borderSize: 1.2,
                glowSize: 1,
                child: Container(
                  width: 0.9.sw,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 30,
                        blurStyle: BlurStyle.inner,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 5.h),
                      Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Image(
                          image: AssetImage(Assets.images.image.path),
                          width: 50.w,

                          height: 50.w,

                          // 90% of screen width
                          fit: BoxFit.contain,
                        ),
                      ),
                      Text(
                        "قيّم فوري واربح معنا",
                        style: CustomTextStyle().heading1L.copyWith(
                          color: Colors.black,
                          fontSize: 15.sp,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Text(
                          "كل تقييم منك يجعلنا أفضل، ويمنحك نقاطًا تستحقها! ⭐️🎉",
                          textAlign: TextAlign.center,
                          style: CustomTextStyle().heading1L.copyWith(
                            color: Colors.black87,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                      // SizedBox(
                      //   height: 10.h,
                      // ),
                      // RatingBar.builder(
                      //   initialRating: 0,
                      //   direction: Axis.horizontal,
                      //   allowHalfRating: true,
                      //   minRating: 0.5,
                      //   maxRating: 5,
                      //   itemCount: 5,
                      //   itemSize: 25.h,
                      //   itemPadding: EdgeInsets.symmetric(horizontal: 4.w),
                      //   itemBuilder: (context, index) {
                      //     return Icon(
                      //       FontAwesome.star,
                      //       color: Colors.amber,
                      //     );
                      //   },
                      //   onRatingUpdate: (rating) async {
                      //     await ratingController.changeRateApp(rating);
                      //     printLog("rating: $rating");
                      //   },
                      // ),
                      SizedBox(height: 20.h),
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
                                height: 16.h,
                                hasBackground: false,
                                textStyle: CustomTextStyle().rubik.copyWith(
                                  color:
                                      // (ratingController.rateApp == 0.0)
                                      //     ? Colors.grey
                                      //     :
                                      CustomColor.blueColor,
                                  fontSize: 14.sp,
                                ),
                                onPressed:
                                    // (ratingController.rateApp == 0.0)
                                    //     ? () {}
                                    //     :
                                    () async {
                                      final String androidAppId =
                                          "fawri.app.shop";
                                      final String iosAppId =
                                          "co.fawri.fawri"; // Replace with actual iOS App ID

                                      await analyticsService.logEvent(
                                        parameters: {
                                          "rating_value":
                                              ratingController.rateApp,
                                        },
                                        eventName: "user_rating",
                                      );

                                      // ✅ Check the platform and open the correct store
                                      Uri storeUri;
                                      if (Platform.isAndroid) {
                                        storeUri = Uri.parse(
                                          "https://play.google.com/store/apps/details?id=$androidAppId",
                                        );
                                      } else if (Platform.isIOS) {
                                        storeUri = Uri.parse(
                                          "https://apps.apple.com/app/id$iosAppId",
                                        );
                                      } else {
                                        throw "Unsupported platform";
                                      }

                                      // ✅ Open the Store URL
                                      if (await canLaunchUrl(storeUri)) {
                                        await launchUrl(storeUri);

                                        SharedPreferences prefs =
                                            await SharedPreferences.getInstance();
                                        // String phone =
                                        //     prefs.getString('phone') ?? "";
                                        //
                                        // // await pointsController
                                        // //     .updateUserPointsAndLevel(
                                        // //         phone: phone,
                                        // //         newAmount: '5',
                                        // //   enumNumber: 4
                                        // //        );
                                        await prefs.setBool(
                                          "has_do_rate",
                                          true,
                                        );
                                        await rateMyApp.callEvent(
                                          RateMyAppEventType.rateButtonPressed,
                                        );
                                        NavigatorApp.pop();

                                        await Future.delayed(
                                          Duration(seconds: 15),
                                        );

                                        final player = AudioPlayer();

                                        // Play audio when the dialog opens
                                        player.playAsset(
                                          Assets.audios.iDidItMessageTone,
                                        );
                                        await ratingController.getIsRating();
                                        // Stop the audio after 5 seconds
                                        Future.delayed(
                                          const Duration(seconds: 3),
                                          () async {
                                            await player.stop();
                                          },
                                        );
                                        // await dialogGetPointPopUpShoes(
                                        //     "10 نقاط");
                                      } else {
                                        throw "Could not open App Store / Play Store";
                                      }
                                    },
                              ),
                              CustomButtonWithIconWithoutBackground(
                                text: "ليس الآن",
                                hasBackground: false,
                                textIcon: "",
                                height: 16.h,
                                textStyle: CustomTextStyle().rubik.copyWith(
                                  color: Colors.black,
                                  fontSize: 14.sp,
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await rateMyApp.callEvent(
                                    RateMyAppEventType.laterButtonPressed,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 5.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
