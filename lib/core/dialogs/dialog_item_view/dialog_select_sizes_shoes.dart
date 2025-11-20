import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../controllers/search_controller.dart';

import '../../services/analytics/analytics_service.dart';
import '../../utilities/global/app_global.dart';
import '../../utilities/style/colors.dart';
import '../../utilities/style/text_style.dart';
import '../../widgets/lottie_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/widgets_item_view/pop_up_shoes.dart';
import '../dialog_waiting/dialog_waiting.dart';

AnalyticsService analyticsService = AnalyticsService();

Future<void> showPopUpShoesDialog() {
  return showGeneralDialog(
    context: NavigatorApp.navigatorKey.currentState!.context,
    barrierLabel: "ccc",
    barrierDismissible: false,
    barrierColor: Colors.black54,
    pageBuilder: (context, animation, secondaryAnimation) {
      SearchItemController searchItemController =
          context.watch<SearchItemController>();
      return PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('show_pop_up_shoes', false);
                  NavigatorApp.pop();
                },
                child: Icon(MaterialCommunityIcons.window_close,
                    color: Colors.grey[700], size: 22.sp),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LottieWidget(
                  name: Assets.lottie.shoesSale, height: 45.w, width: 45.w),
              Text(
                "مقاسك يهمنا! ",
                style: CustomTextStyle()
                    .heading1L
                    .copyWith(color: Colors.black, fontSize: 18.sp),
              ),
              SizedBox(height: 5.h),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "ساعدنا في تخصيص تجربة التسوق لك! اختر مقاس حذائك",
                  style: CustomTextStyle()
                      .heading1L
                      .copyWith(color: Colors.black87, fontSize: 11.5.sp),
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: EdgeInsets.all(4.h),
              child: CustomButtonWithoutIcon(
                text: "مقاس رجالي",
                height: 42.h,
                backColor: CustomColor.blueButtonColor,
                textStyle: CustomTextStyle()
                    .rubik
                    .copyWith(color: Colors.white, fontSize: 12.sp),
                onPressed: () async {
                  await analyticsService.logEvent(
                    eventName: "popup_shoes_male_size_click",
                    parameters: {
                      "class_name": "DialogSelectSizesShoes",
                      "button_name": "مقاس رجالي",
                      "time": DateTime.now().toString(),
                    },
                  );

                  NavigatorApp.pop();
                  dialogWaiting();
                  await searchItemController.setSizesPopUpShoes(isMale: true);
                  await searchItemController.getShoesPopUp(isMale: true);
                  NavigatorApp.pop();
                  NavigatorApp.push(PopUpShoes(isMale: true));
                },
                textWaiting: '',
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.h),
              child: CustomButtonWithoutIcon(
                text: "مقاس نسائي",
                height: 40.h,
                backColor: CustomColor.pinkButtonColor,
                textStyle: CustomTextStyle()
                    .rubik
                    .copyWith(color: Colors.white, fontSize: 12.sp),
                onPressed: () async {
                  await analyticsService.logEvent(
                    eventName: "popup_shoes_female_size_click",
                    parameters: {
                      "class_name": "DialogSelectSizesShoes",
                      "button_name": "مقاس نسائي",
                      "time": DateTime.now().toString(),
                    },
                  );

                  NavigatorApp.pop();
                  dialogWaiting();
                  await searchItemController.setSizesPopUpShoes(isMale: false);
                  await searchItemController.getShoesPopUp(isMale: false);
                  NavigatorApp.pop();
                  NavigatorApp.push(PopUpShoes(isMale: false));
                },
                textWaiting: '',
              ),
            ),
          ],
        ),
      );
    },
  );
}
