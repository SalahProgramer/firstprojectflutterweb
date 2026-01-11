import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../services/analytics/analytics_service.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/reels_controller.dart';
import '../../controllers/custom_page_controller.dart';
import '../../views/pages/cart/my_cart.dart';
import '../custom_button.dart';

class IconCart extends StatelessWidget {
  final Color? color;
  final Color? colorIcon;

  const IconCart({super.key, this.color, this.colorIcon});

  @override
  Widget build(BuildContext context) {
    CartController cartController = context.watch<CartController>();
    AnalyticsService analyticsService = AnalyticsService();

    return Padding(
      padding: EdgeInsets.only(top: 8.h, right: 2.w, left: 2.w),
      child: Badge(
        label: Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: Text(
            cartController.cartItems.length.toString(),
            textAlign: TextAlign.center,
          ),
        ),
        alignment: Alignment.topRight,
        child: IconSvg(
          nameIcon: Assets.icons.cart,
          backColor: Colors.transparent,
          height: 40.w,
          width: 40.w,
          // heightIcon: 40.h,
          onPressed: () async {
            // Check if we're on reels page and pause all videos
            bool wasOnReelsPage = false;
            try {
              final customPageController = context.read<CustomPageController>();
              wasOnReelsPage = customPageController.selectPage == 1;
              
              if (wasOnReelsPage) {
                final reelsController = context.read<ReelsController>();
                // CRITICAL: Pause ALL videos before navigating to cart
                reelsController.pauseAllVideos();
                debugPrint('🛒 Opening cart - paused all reel videos');
              }
            } catch (e) {
              debugPrint('Error pausing reels: $e');
            }

            await analyticsService.logEvent(
              eventName: "open_cart_page",
              parameters: {
                "class_name": "IconCart",
                "button_name": "cart_icon pressed ",
                "time": DateTime.now().toString(),
              },
            );
            await cartController.getCartItems();

            // Navigate to cart
            await NavigatorApp.push(
              ShowCaseWidget(builder: (context) => MyCart()),
            );

            // When returning: DON'T do anything
            // Keep all videos paused - user must manually play
            if (wasOnReelsPage) {
              try {
                final reelsController = context.read<ReelsController>();
                reelsController.pauseAllVideos();
                debugPrint('🔇 Returned from cart - all videos paused');
              } catch (e) {
                debugPrint('Error after cart return: $e');
              }
            }
          },
          colorFilter: ColorFilter.mode(
            colorIcon ?? Colors.black,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
