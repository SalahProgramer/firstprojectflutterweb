import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glowy_borders/glowy_borders.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../controllers/APIS/api_product_item.dart';
import '../../../controllers/fetch_controller.dart';
import '../../../controllers/page_main_screen_controller.dart';
import '../../../controllers/product_item_controller.dart';
import '../../../models/items/item_model.dart';
import '../../../utilities/global/app_global.dart';
import '../../../utilities/style/colors.dart';
import '../../../utilities/style/text_style.dart';
import '../../../views/pages/home/main_screen/product_item_view.dart';
import '../../custom_image.dart';
import '../../custom_text.dart';
import '../../lottie_widget.dart';

class CustomImagesStyleFour extends StatelessWidget {
  final int i;
  final int flag;
  final bool hasAnimatedBorder;
  final bool hasBellChristmas;
  final Item item;
  final String image;
  final dynamic changeLoadingProduct;
  final Map<String, bool> isLoadingProduct;
  final double? width;
  final List<Color>? colorsGradient;
  final bool isFeature;
  final bool isFavourite;
  const CustomImagesStyleFour({
    super.key,
    this.hasAnimatedBorder = false,
    required this.i,
    required this.item,
    required this.image,
    required this.changeLoadingProduct,
    required this.isLoadingProduct,
    this.width,
    this.colorsGradient,
    required this.isFeature,
    this.hasBellChristmas = false,
    required this.flag,
    this.isFavourite = false,
  });

  @override
  Widget build(BuildContext context) {
    ProductItemController productItemController = context
        .watch<ProductItemController>();
    PageMainScreenController pageMainScreenController = context
        .watch<PageMainScreenController>();
    FetchController fetchController = context.watch<FetchController>();

    ApiProductItemController apiProductItemController = context
        .watch<ApiProductItemController>();

    return InkWell(
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      overlayColor: WidgetStatePropertyAll(Colors.transparent),
      onTap: () async {
        // (changeLoadingProduct ==
        //     pageMainScreenController.changeLoadingSectionsItems)
        //     ? await changeLoadingProduct(i, item.id.toString(), true)
        //     : await changeLoadingProduct(item.id.toString(), true);

        await pageMainScreenController.changePositionScroll(
          item.id.toString(),
          0,
        );
        await productItemController.clearItemsData();
        await apiProductItemController.cancelRequests();

        NavigatorApp.push(
          ProductItemView(item: item, isFeature: isFeature, sizes: ''),
        );
        // (changeLoadingProduct ==
        //     pageMainScreenController.changeLoadingSectionsItems)
        //     ? await changeLoadingProduct(i, item.id.toString(), false)
        //     : await changeLoadingProduct(item.id.toString(), false);
      },
      child: AnimatedGradientBorder(
        gradientColors: [CustomColor.greenColor, CustomColor.chrismasColor],
        borderSize: 1.4,
        glowSize: 0,
        borderRadius: BorderRadius.circular(10.r),
        child: Stack(
          alignment: Alignment.topRight,
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: (i % 2 == 0)
                    ? Colors.black87
                    : CustomColor.chrismasColor.withValues(alpha: 0.87),
              ),
              width: width ?? 120.w,
              // height: 420.h,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Stack(
                          children: [
                            CustomImageSponsored(
                              imageUrl: image.isEmpty
                                  ? "https://www.fawri.co/assets/about_us/fawri_logo.jpg"
                                  : image,
                              boxFit: BoxFit.fill,
                              borderCircle:
                                  (changeLoadingProduct ==
                                      pageMainScreenController
                                          .changeLoadingProductFlashItems)
                                  ? 0
                                  : 10,
                              borderRadius:
                                  (changeLoadingProduct ==
                                      pageMainScreenController
                                          .changeLoadingProductFlashItems)
                                  ? BorderRadius.circular(0.r)
                                  : BorderRadius.only(
                                      bottomRight: Radius.circular(10.r),
                                      topRight: Radius.circular(10.r),
                                    ),
                            ),
                            if (changeLoadingProduct ==
                                pageMainScreenController
                                    .changeLoadingProductFlashItems)
                              Container(
                                width: 30.w,
                                height: 30.w,
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(5.r),
                                    bottomLeft: Radius.circular(5.r),
                                    topLeft: Radius.circular(5.r),
                                    topRight: Radius.circular(0.r),
                                  ),
                                ),
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

                        // (isLoadingProduct[item.id.toString()] == true)
                        //     ? SpinKitSpinningLines(
                        //   color: Colors.red,
                        //   size: 30.h,
                        // )
                        //     : SizedBox()
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(height: 3.h),
                          Text(
                            item.title ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            strutStyle: StrutStyle(
                              fontSize: 12.sp,
                              fontFamily: 'CrimsonText',
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            style: CustomTextStyle().crimson.copyWith(
                              fontSize: 12.sp,
                              color:
                                  (changeLoadingProduct ==
                                      pageMainScreenController
                                          .changeLoadingProductFlashItems)
                                  ? Colors.black
                                  : (fetchController.showEven == 1 && flag == 1)
                                  ? Colors.white
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          SizedBox(
                            width: width ?? 120.w,
                            height: 20.h,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CustomText(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.sp,
                                  text: item.newPrice ?? "0",
                                  color:
                                      (changeLoadingProduct ==
                                          pageMainScreenController
                                              .changeLoadingProductFlashItems)
                                      ? ((pageMainScreenController
                                                    .flash
                                                    ?.name) ==
                                                "flash_sales")
                                            ? Colors.red
                                            : CustomColor.greenColor
                                      // Colors.white
                                      : (fetchController.showEven == 1 &&
                                            flag == 1)
                                      ? CustomColor.greenColor
                                      : CustomColor.greenColor,
                                  textDecoration: TextDecoration.none,
                                ),
                                CustomText(
                                  fontSize: 10.sp,
                                  color:
                                      (fetchController.showEven == 1 &&
                                          flag == 1)
                                      ? Colors.white
                                      : Colors.black,
                                  text: item.oldPrice,
                                  textStyle: CustomTextStyle().rubik.copyWith(
                                    color:
                                        (changeLoadingProduct ==
                                            pageMainScreenController
                                                .changeLoadingProductFlashItems)
                                        ? Colors.white
                                        : (fetchController.showEven == 1 &&
                                              flag == 1)
                                        ? Colors.white
                                        : Colors.white,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 10.sp,
                                    decoration: TextDecoration.lineThrough,

                                    // decorationThickness: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            (fetchController.showEven == 1 && (hasBellChristmas == true))
                ? Positioned(
                    top: -12.h,
                    right: -9.h,
                    child: LottieWidget(name: Assets.lottie.christmasBell),
                  )
                : (fetchController.showEven == 1 && (hasAnimatedBorder == true))
                ? Positioned(
                    top: -12.h,
                    right: -9.h,
                    child: LottieWidget(name: Assets.lottie.christmasHat),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
