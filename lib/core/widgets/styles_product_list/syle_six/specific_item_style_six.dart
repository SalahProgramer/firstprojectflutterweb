import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glowy_borders/glowy_borders.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../../controllers/APIS/api_product_item.dart';
import '../../../../controllers/fetch_controller.dart';
import '../../../../controllers/page_main_screen_controller.dart';
import '../../../../controllers/product_item_controller.dart';
import '../../../../models/items/item_model.dart';
import '../../../utilities/global/app_global.dart';
import '../../../utilities/style/colors.dart';
import '../../../utilities/style/text_style.dart';
import '../../../../views/pages/home/main_screen/product_item_view.dart';
import '../../custom_image.dart';
import '../../custom_shimmer.dart';
import '../../custom_text.dart';
import '../../lottie_widget.dart';

class CustomImagesStyleSix extends StatelessWidget {
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
  const CustomImagesStyleSix(
      {super.key,
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
      this.isFavourite = false});

  @override
  Widget build(BuildContext context) {
    ProductItemController productItemController =
        context.watch<ProductItemController>();
    PageMainScreenController pageMainScreenController =
        context.watch<PageMainScreenController>();
    FetchController fetchController = context.watch<FetchController>();

    ApiProductItemController apiProductItemController =
        context.watch<ApiProductItemController>();

    return Container(
      padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 8.h),
      child: InkWell(
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
        onTap: () async {
          await pageMainScreenController.changePositionScroll(
              item.id.toString(), 0);
          await productItemController.clearItemsData();
          await apiProductItemController.cancelRequests();

          NavigatorApp.push(ProductItemView(
            item: item,
            isFeature: isFeature,
            sizes: '',
            isFlashOrBest: (isLoadingProduct ==
                    pageMainScreenController.isLoadingFlashItems)
                ? true
                : false,
          ));
        },
        child: Stack(
          alignment: Alignment.topRight,
          clipBehavior: Clip.none,
          children: [
            Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: Colors.white),
                width: width ?? 120.w,
                child: Column(
                  children: [
                    Flexible(
                        flex: 3,
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            (hasAnimatedBorder)
                                ? AnimatedGradientBorder(
                                    glowSize: 1,
                                    borderSize: 1.4,
                                    gradientColors: colorsGradient ??
                                        ((fetchController.showEven == 1 &&
                                                flag == 1)
                                            ? [
                                                CustomColor.primaryColor,
                                                CustomColor.primaryColor
                                                    .withValues(alpha: 0.2),
                                              ]
                                            : [
                                                Colors.red,
                                                CustomColor.primaryColor
                                                    .withValues(alpha: 0.2),
                                              ]),
                                    borderRadius: BorderRadius.circular(20.r),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        ShimmerImagePost(),
                                        CustomImageSponsored(
                                          imageUrl: image.isEmpty
                                              ? "https://www.fawri.co/assets/about_us/fawri_logo.jpg"
                                              : image,
                                          boxFit: BoxFit.fill,
                                          borderCircle: (changeLoadingProduct ==
                                                  pageMainScreenController
                                                      .changeLoadingProductFlashItems)
                                              ? 0
                                              : 20,
                                          borderRadius: (changeLoadingProduct ==
                                                  pageMainScreenController
                                                      .changeLoadingProductFlashItems)
                                              ? BorderRadius.circular(0.r)
                                              : BorderRadius.circular(20.r),
                                        ),
                                      ],
                                    ))
                                : Stack(
                                    children: [
                                      CustomImageSponsored(
                                        imageUrl: image.isEmpty
                                            ? "https://www.fawri.co/assets/about_us/fawri_logo.jpg"
                                            : image,
                                        boxFit: BoxFit.cover,
                                        borderCircle: (changeLoadingProduct ==
                                                pageMainScreenController
                                                    .changeLoadingProductFlashItems)
                                            ? 0
                                            : 10,
                                        borderRadius: (changeLoadingProduct ==
                                                pageMainScreenController
                                                    .changeLoadingProductFlashItems)
                                            ? BorderRadius.circular(0.r)
                                            : BorderRadius.only(
                                                topLeft: Radius.circular(10.r),
                                                topRight:
                                                    Radius.circular(10.r)),
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
                                                  bottomRight:
                                                      Radius.circular(5.r),
                                                  bottomLeft:
                                                      Radius.circular(5.r),
                                                  topLeft: Radius.circular(5.r),
                                                  topRight:
                                                      Radius.circular(0.r))),
                                          child: Lottie.asset(
                                            Assets
                                                .lottie.animation1729073541927,
                                            height: 40.h,
                                            reverse: true,
                                            repeat: true,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                    ],
                                  ),
                          ],
                        )),
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            item.title ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            strutStyle: StrutStyle(
                              fontSize: 10.sp,
                              fontFamily: 'CrimsonText',
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            style: CustomTextStyle().crimson.copyWith(
                                  fontSize: 10.sp,
                                  color: (changeLoadingProduct ==
                                          pageMainScreenController
                                              .changeLoadingProductFlashItems)
                                      ? Colors.black
                                      : (fetchController.showEven == 1 &&
                                              flag == 1)
                                          ? Colors.white
                                          : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: Row(
                        children: [
                          CustomText(
                            fontWeight: FontWeight.bold,
                            fontSize: 10.sp,
                            text: item.newPrice ?? "0",
                            color: (changeLoadingProduct ==
                                    pageMainScreenController
                                        .changeLoadingProductFlashItems)
                                ? ((pageMainScreenController.flash?.name) ==
                                        "flash_sales")
                                    ? Colors.red
                                    : Colors.red
                                // Colors.white
                                : (fetchController.showEven == 1 && flag == 1)
                                    ? CustomColor.greenColor
                                    : Colors.red,
                            textDecoration: TextDecoration.none,
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
            (fetchController.showEven == 1 && (hasBellChristmas == true))
                ? Positioned(
                    top: -12.h,
                    right: -9.h,
                    child: LottieWidget(
                      name: Assets.lottie.christmasBell,
                    ))
                : (fetchController.showEven == 1 && (hasAnimatedBorder == true))
                    ? Positioned(
                        top: -12.h,
                        right: -9.h,
                        child: LottieWidget(
                          name: Assets.lottie.christmasHat,
                        ))
                    : SizedBox(),
          ],
        ),
      ),
    );
  }
}
