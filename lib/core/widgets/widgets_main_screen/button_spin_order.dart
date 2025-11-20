import 'package:audioplayers/audioplayers.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../controllers/order_controller.dart';
import '../../../controllers/page_main_screen_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../../controllers/wheel_controller.dart';
import '../../../views/pages/home/main_screen/newest_order_in_home.dart';
import '../../../views/pages/spining_wheel/spin_wheel.dart';
import '../../dialogs/dialog_phone/dialog_add_phone.dart';
import '../../dialogs/dialogs_spin_and_points/dialogs_spin.dart';
import '../../utilities/audio_player_extensions.dart';
import '../../utilities/global/app_global.dart';
import 'custom_button_spin.dart';

class ButtonSpinOrder extends StatefulWidget {
  const ButtonSpinOrder({super.key});

  @override
  State<ButtonSpinOrder> createState() => _ButtonSpinOrderState();
}

class _ButtonSpinOrderState extends State<ButtonSpinOrder> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      WheelController wheelController = context.read<WheelController>();
      PageMainScreenController pageMainScreenController =
          context.read<PageMainScreenController>();

      SharedPreferences prefs = await SharedPreferences.getInstance();

      final skipSpin = prefs.getBool('skip_spin') ?? false;
      final phone = prefs.getString('phone') ?? "";
      if (skipSpin == false &&
          (pageMainScreenController.userActivity.getEnumStatus('2').canUse ==
              true) &&
          (phone != "")) {
        await wheelController.changeWasShowWheelCoupon(true);
        final player = AudioPlayer();

        // Play audio when the dialog opens
        player.playAsset(Assets.audios.iDidItMessageTone);
        // Stop the audio after 5 seconds
        Future.delayed(const Duration(seconds: 3), () async {
          await player.stop();
        });
        dialogDoSpin();
      }
    });
  }

  // Initial time is set to 24 hours
  @override
  Widget build(BuildContext context) {
    OrderControllerSalah orderControllerSalah =
        context.watch<OrderControllerSalah>();
    UserController userController = context.watch<UserController>();
    PageMainScreenController pageMainScreenController =
        context.watch<PageMainScreenController>();

    final canUseWheel = pageMainScreenController.userActivity.canUseEnum("2");
    final timeRemaining =
        pageMainScreenController.userActivity.getEnumTimeRemaining("2");

    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.all(1.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      height: (orderControllerSalah.newestOrderData.isNotEmpty)
          ? 0.186.sh
          : 0.16.sh,
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (orderControllerSalah.newestOrderData.isNotEmpty)
              NewestOrderInHome(
                  userId: userController.userId,
                  newOrders: orderControllerSalah.newestOrderData),
            if (orderControllerSalah.newestOrderData.isNotEmpty)
              SizedBox(
                width: 25.w,
              ),
            CustomButtonSpin(
              text: (canUseWheel) ? 'لف وأربح معنا' : timeRemaining,
              nameLottie: Assets.lottie.spinWheel1,
              canTap: (canUseWheel) ? true : false,
              onTap: (canUseWheel)
                  ? () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      String phone = prefs.getString('phone') ?? "";

                      if (phone == "") {
                        await showAddPhone();
                      } else {
                        NavigatorApp.push(SpinWheel());
                      }
                    }
                  : () {
                      dialogCannotDoSpin();
                    },
            ),
          ],
        ),
      ),
    );
  }
}
