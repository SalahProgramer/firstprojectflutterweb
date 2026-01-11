import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import '../../controllers/page_main_screen_controller.dart';
import '../../controllers/product_item_controller.dart';
import '../../utilities/global/app_global.dart';
import '../../utilities/style/text_style.dart';
import 'home/main_screen/product_item_view.dart';

class SplashLink extends StatefulWidget {
  final String id;

  const SplashLink({super.key, required this.id});

  @override
  State<SplashLink> createState() => _SplashState();
}

class _SplashState extends State<SplashLink> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((callback) async {
      ProductItemController productItemController = NavigatorApp.context
          .read<ProductItemController>();
      PageMainScreenController pageMainScreenController = context
          .read<PageMainScreenController>();

      await pageMainScreenController.changePositionScroll(widget.id, 0);
      await productItemController.clearItemsData();
      await productItemController.getSpecificProduct(widget.id);

      NavigatorApp.pushReplacment(
        ProductItemView(
          item: productItemController.specificItemData!,
          sizes: "",
        ),
      );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage(Assets.images.image.path),

                width: 0.5.sw,
                height: 0.6.sh,

                // 90% of screen width
                fit: BoxFit.contain,
              ),
              Text(
                "⏳✨ الاستعداد لفتح الرابط، لا تقلق✨⏳",
                textAlign: TextAlign.center,
                style: CustomTextStyle().rubik.copyWith(
                  color: Colors.black,
                  fontSize: 16.sp,
                  height: 1.2.h,
                ),
              ),
              SizedBox(height: 20.h),
              const SpinKitCircle(color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}
