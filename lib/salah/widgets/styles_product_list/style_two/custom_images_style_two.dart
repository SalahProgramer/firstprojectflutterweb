import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:glowy_borders/glowy_borders.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../../../controllers/APIS/api_product_item.dart';
import '../../../controllers/fetch_controller.dart';
import '../../../controllers/page_main_screen_controller.dart';
import '../../../controllers/product_item_controller.dart';
import '../../../controllers/favourite_controller.dart';
import '../../../models/items/item_model.dart';
import '../../../utilities/global/app_global.dart';
import '../../../utilities/style/colors.dart';
import '../../../utilities/style/text_style.dart';
import '../../../views/pages/home/main_screen/product_item_view.dart';
import '../../custom_image.dart';
import '../../custom_shimmer.dart';
import '../../custom_text.dart';
import '../../lottie_widget.dart';

class CustomImagesStyleTwo extends StatelessWidget {
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

  const CustomImagesStyleTwo({
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
    AnalyticsService analyticsService = AnalyticsService();

    ApiProductItemController apiProductItemController = context
        .watch<ApiProductItemController>();
    FavouriteController favouriteController = context
        .watch<FavouriteController>();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 8.h),
      child: InkWell(
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
        onTap: () async {
          await pageMainScreenController.changePositionScroll(
            item.id.toString(),
            0,
          );
          await productItemController.clearItemsData();
          await apiProductItemController.cancelRequests();

          NavigatorApp.push(
            ProductItemView(
              item: item,
              isFeature: isFeature,
              sizes: '',
              isFlashOrBest:
                  (isLoadingProduct ==
                      pageMainScreenController.isLoadingItemViewedProducts)
                  ? true
                  : false,
            ),
          );
        },
        child: Stack(
          alignment: Alignment.topRight,
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
              ),
              width: width ?? 120.w,
              // height: 420.h,
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        AnimatedGradientBorder(
                          glowSize: 0,
                          borderSize: 1.4,
                          gradientColors:
                              colorsGradient ??
                              ((fetchController.showEven == 1 && flag == 1)
                                  ? [
                                      CustomColor.primaryColor,
                                      CustomColor.primaryColor.withValues(
                                        alpha: 0.2,
                                      ),
                                    ]
                                  : [
                                      Colors.red,
                                      CustomColor.primaryColor.withValues(
                                        alpha: 0.2,
                                      ),
                                    ]),
                          borderRadius: BorderRadius.circular(10.r),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ShimmerImagePost(),
                                      Stack(
                                        alignment: Alignment.bottomRight,
                                        children: [
                                          Stack(
                                            children: [
                                              CustomImageSponsored(
                                                imageUrl: image.isEmpty
                                                    ? "https://www.fawri.co/assets/about_us/fawri_logo.jpg"
                                                    : image,
                                                boxFit: BoxFit.fill,
                                                borderCircle: 0,
                                                borderRadius:
                                                    BorderRadius.circular(10.r),
                                              ),
                                            ],
                                          ),
                                          Stack(
                                            alignment: Alignment.topRight,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        10.r,
                                                      ),
                                                  gradient: LinearGradient(
                                                    begin:
                                                        Alignment.bottomCenter,
                                                    end: Alignment.topCenter,
                                                    colors: [
                                                      Colors.black87,
                                                      Colors.black12,
                                                    ],
                                                  ),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      item.title ?? "",
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      strutStyle: StrutStyle(
                                                        fontSize: 12.sp,
                                                        height: 1.5.h,
                                                        fontFamily:
                                                            'CrimsonText',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: CustomTextStyle()
                                                          .crimson
                                                          .copyWith(
                                                            fontSize: 12.sp,
                                                            height: 1.5.h,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                    SizedBox(
                                                      width: width ?? 120.w,
                                                      height: 20.h,
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          CustomText(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 9.sp,
                                                            text:
                                                                item.newPrice ??
                                                                "0",
                                                            color: CustomColor
                                                                .greenColor,

                                                            // Colors.white
                                                            textDecoration:
                                                                TextDecoration
                                                                    .none,
                                                          ),
                                                          CustomText(
                                                            fontSize: 8.sp,
                                                            color:
                                                                (fetchController
                                                                            .showEven ==
                                                                        1 &&
                                                                    flag == 1)
                                                                ? Colors.white
                                                                : Colors.black,
                                                            text: item.oldPrice,
                                                            textStyle: CustomTextStyle().rubik.copyWith(
                                                              color:
                                                                  Colors.white,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              fontSize: 8.sp,
                                                              decoration:
                                                                  TextDecoration
                                                                      .lineThrough,

                                                              // decorationThickness: 1.5,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              AnimatedGradientBorder(
                                                glowSize: 0.5,
                                                borderSize: 0.5,
                                                borderRadius: BorderRadius.only(
                                                  bottomRight: Radius.circular(
                                                    0.r,
                                                  ),
                                                  bottomLeft: Radius.circular(
                                                    5.r,
                                                  ),
                                                  topLeft: Radius.circular(5.r),
                                                  topRight: Radius.circular(
                                                    10.r,
                                                  ),
                                                ),
                                                gradientColors:
                                                    colorsGradient ??
                                                    ((fetchController
                                                                    .showEven ==
                                                                1 &&
                                                            flag == 1)
                                                        ? [
                                                            CustomColor
                                                                .primaryColor,
                                                            CustomColor
                                                                .primaryColor
                                                                .withValues(
                                                                  alpha: 0.2,
                                                                ),
                                                          ]
                                                        : [
                                                            Colors.red,
                                                            CustomColor
                                                                .primaryColor
                                                                .withValues(
                                                                  alpha: 0.2,
                                                                ),
                                                          ]),
                                                child: Container(
                                                  width: 30.w,
                                                  height: 30.w,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                          bottomRight:
                                                              Radius.circular(
                                                                0.r,
                                                              ),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                5.r,
                                                              ),
                                                          topLeft:
                                                              Radius.circular(
                                                                5.r,
                                                              ),
                                                          topRight:
                                                              Radius.circular(
                                                                10.r,
                                                              ),
                                                        ),
                                                  ),
                                                  child: InkWell(
                                                    overlayColor:
                                                        WidgetStatePropertyAll(
                                                          Colors.transparent,
                                                        ),
                                                    onTap: () async {
                                                      if (await favouriteController
                                                              .checkFavouriteItem(
                                                                productId:
                                                                    item.id,
                                                              ) ==
                                                          false) {
                                                        productItemController
                                                            .flareControls
                                                            .play("like");
                                                        await pageMainScreenController
                                                            .changeIsFavourite(
                                                              item.id
                                                                  .toString(),
                                                              true,
                                                            );
                                                        List<String> tags =
                                                            (item.tags ?? []);

                                                        await favouriteController
                                                            .insertData(
                                                              id: "${item.id}000",
                                                              variantId: item
                                                                  .variants![0]
                                                                  .id,
                                                              productId:
                                                                  item.id,
                                                              image: item
                                                                  .vendorImagesLinks![0],
                                                              title: item.title,
                                                              oldPrice: item
                                                                  .oldPrice
                                                                  .toString(),
                                                              newPrice:
                                                                  item.newPrice,
                                                              tags: '$tags',
                                                            );
                                                        Vibration.vibrate(
                                                          duration: 100,
                                                        );

                                                        // await pageMainScreenController.changeIsFavourite(
                                                        //     widget.item.id.toString(),
                                                        //     !(pageMainScreenController
                                                        //         .isFavourite[widget.item.id.toString()])!);
                                                        await analyticsService.logAddToWishlist(
                                                          productId:
                                                              item.id
                                                                  ?.toString() ??
                                                              "",
                                                          productTitle:
                                                              item.title ?? "",
                                                          price:
                                                              double.tryParse(
                                                                item.newPrice
                                                                        ?.replaceAll(
                                                                          "₪",
                                                                          "",
                                                                        ) ??
                                                                    "0",
                                                              ) ??
                                                              0.0,
                                                          parameters: {
                                                            "class_name":
                                                                "CustomImagesStyleTwo",
                                                            "button_name":
                                                                "wishlist_heart_icon",
                                                            "product_id":
                                                                item.id
                                                                    ?.toString() ??
                                                                "",
                                                            "product_title":
                                                                item.title ??
                                                                "",
                                                            "price":
                                                                (double.tryParse(
                                                                          item.newPrice?.replaceAll(
                                                                                "₪",
                                                                                "",
                                                                              ) ??
                                                                              "0",
                                                                        ) ??
                                                                        0.0)
                                                                    .toString(),
                                                            "time":
                                                                DateTime.now()
                                                                    .toString(),
                                                          },
                                                        );
                                                      } else {
                                                        await favouriteController
                                                            .deleteItem(
                                                              productId:
                                                                  item.id,
                                                            );
                                                      }
                                                    },
                                                    child: Icon(
                                                      FontAwesome.heart,
                                                      color:
                                                          (isFavourite == false)
                                                          ? Colors.grey
                                                          : CustomColor
                                                                .primaryColor,
                                                      size: 15.h,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
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
