import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../services/analytics/analytics_service.dart';
import '../../controllers/cart_controller.dart';
import '../../views/pages/cart/my_cart.dart';
import '../custom_button.dart';

class IconCart extends StatefulWidget {
  final Color? color;

  const IconCart({super.key, this.color});

  @override
  State<IconCart> createState() => _IconCartState();
}

class _IconCartState extends State<IconCart> {
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
            await analyticsService.logEvent(
              eventName: "open_cart_page",
              parameters: {
                "class_name": "IconCart",
                "button_name": "cart_icon pressed ",
                "time": DateTime.now().toString(),
              },
            );
            await cartController.getCartItems();

            NavigatorApp.push(ShowCaseWidget(builder: (context) => MyCart()));
          },
          colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
        ),
      ),
    );
  }
}
