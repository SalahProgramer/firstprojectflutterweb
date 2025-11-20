import 'package:fawri_app_refactor/views/pages/home/main_screen/products_list.dart';

import '../../../../core/utilities/global/app_global.dart';
import '../../../../core/utilities/style/colors.dart';
import '../../../../core/utilities/style/text_style.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../../core/widgets/widgets_main_screen/show_big_small_categories.dart';
import '../../../../models/products_view_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glowy_borders/glowy_borders.dart';
import 'package:lottie/lottie.dart';
import 'package:neon_circular_timer/neon_circular_timer.dart';
import 'package:provider/provider.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import '../home_screen/home_screen.dart';
import '../../../../controllers/page_main_screen_controller.dart';
import '../../../../controllers/sub_main_categories_conrtroller.dart';
import 'build_timer.dart';

class FlashSalesMain extends StatefulWidget {
  const FlashSalesMain({super.key});

  @override
  State<FlashSalesMain> createState() => _FlashSalesMainState();
}

class _FlashSalesMainState extends State<FlashSalesMain> {
  final CountDownController controllerSeconds = CountDownController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((callback) async {});
  }

  @override
  Widget build(BuildContext context) {
    PageMainScreenController pageMainScreenController =
        context.watch<PageMainScreenController>();
    SubMainCategoriesController subMainCategoriesController =
        context.watch<SubMainCategoriesController>();

    return AnimatedGradientBorder(
      gradientColors: [Colors.yellow, CustomColor.errorColor],
      borderSize: 0,
      glowSize: 0,
      borderRadius: BorderRadius.circular(0.r),
      stretchAxis: Axis.horizontal,
      child: Container(
        color:
            // (pageMainScreenController.flash?.name) == "flash_sales"
            //     ?

            Colors.yellow
        // : CustomColor.errorColor

        ,
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        margin: EdgeInsets.symmetric(vertical: 3.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // if ((pageMainScreenController.flash?.name) == "flash_sales")
                SizedBox(
                  width: 30.w,
                  height: 30.w,
                  child: Lottie.asset(
                    Assets.lottie.animation1729073541927,
                    height: 40.h,
                    reverse: true,
                    repeat: true,
                    fit: BoxFit.cover,
                  ),
                ),
                CustomText(
                  text: (pageMainScreenController.flash?.name) ?? "Flash Sales",
                  textStyle: CustomTextStyle().rubik.copyWith(
                      color: Colors.black,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold),
                ),
                // if ((pageMainScreenController.flash?.name) == "flash_sales")
                SizedBox(
                  width: 30.w,
                  height: 30.w,
                  child: Lottie.asset(
                    Assets.lottie.animation1729073541927,
                    height: 40.h,
                    reverse: true,
                    repeat: true,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    textAlign: TextAlign.center,
                    // text:
                    // widget.flashSalesArray["name"] ??
                    "ينتهي خلال",
                    style: CustomTextStyle().heading1L.copyWith(
                        color: Colors.black,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            BuildTimer(),
            SizedBox(
              height: 5.h,
            ),
            ProductsViewInList(
              configModel: ProductsViewConfigModel(
                hasAnimatedBorder: false,
                bgColor: Colors.transparent,
                colorsGradient: [Colors.yellow, CustomColor.primaryColor],
                height: 0.30.sh,
                numberStyle: 1,
                changeLoadingProduct:
                    pageMainScreenController.changeLoadingProductFlashItems,
                scrollController: pageMainScreenController.scrollFlashItems,
                listItems: pageMainScreenController.flashItems,
                isLoadingProduct: pageMainScreenController.isLoadingFlashItems,
                flag: 0,
              ),
            ),
            ShowBigSmallCategories(
              alignment: MainAxisAlignment.center,
              color:
                  // (pageMainScreenController.flash?.name) == "flash_sales"
                  //     ?

                  Colors.black
              // : Colors.white
              ,
              onTap: () async {
                subMainCategoriesController.clear();
                // await customPageController.changeIndexPage(0);
                // await customPageController.changeIndexCategoryPage(1);

                NavigatorApp.push(HomeScreen(
                  bannerTitle:
                      "ينتهي خلال ${pageMainScreenController.flash?.countdownHours.toString() ?? ""}",
                  endDate: pageMainScreenController.flash!.endDate.toString(),
                  type: "flash_sales",
                  url: pageMainScreenController.flash!.userLimit.toString(),
                  title:
                      "ينتهي خلال ${pageMainScreenController.flash?.countdownHours.toString() ?? ""}",
                  slider: false,
                  hasAppBar: true,
                  productsKinds: true,
                  scrollController:
                      subMainCategoriesController.scrollDynamicItems,
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
