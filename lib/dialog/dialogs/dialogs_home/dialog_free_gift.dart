import 'package:carousel_slider/carousel_slider.dart';
import 'package:fawri_app_refactor/salah/controllers/fetch_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/free_gift_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/product_item_controller.dart';
import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glowy_borders/glowy_borders.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import '../../../salah/controllers/cart_controller.dart';
import '../../../salah/utilities/global/app_global.dart';
import '../../../salah/utilities/style/colors.dart';
import '../../../salah/utilities/style/text_style.dart';
import '../../../salah/widgets/custom_image.dart';
import '../../../salah/widgets/lottie_widget.dart';
import '../../../salah/widgets/snackBarWidgets/snack_bar_style.dart';
import '../../../salah/widgets/snackBarWidgets/snackbar_widget.dart';
import '../../../salah/widgets/widgets_item_view/button_done.dart';

Future<void> dialogFreeGift() {
  return showDialog(
    context: NavigatorApp.context,
    builder: (context) {
      CartController cartController = context.watch<CartController>();
      AnalyticsService analyticsService = AnalyticsService();

      ProductItemController productItemController = context
          .watch<ProductItemController>();
      FreeGiftController freeGiftController = context
          .watch<FreeGiftController>();
      FetchController fetchController = context.watch<FetchController>();
      return PopScope(
        canPop: false, // Prevents system back navigation
        child: GestureDetector(
          onTap: () async {},
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedGradientBorder(
                  borderRadius: BorderRadius.circular(10),
                  gradientColors: [
                    CustomColor.blueColor,
                    CustomColor.chrismasColor,
                  ],
                  borderSize: 1.2,
                  glowSize: 1,
                  child: Container(
                    width: 0.95.sw,
                    height: 0.62.sh,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 30,
                          blurStyle: BlurStyle.inner,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                LottieWidget(
                                  height: 60.w,
                                  width: 60.w,
                                  name: Assets.lottie.offer,
                                ),
                              ],
                            ),
                            SizedBox(height: 5.h),
                            ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (Rect bounds) {
                                return RadialGradient(
                                  center: Alignment.topLeft,
                                  radius: 1.0,
                                  colors: <Color>[
                                    CustomColor.chrismasColor,
                                    CustomColor.blueColor,
                                    CustomColor.chrismasColor,
                                  ],
                                  tileMode: TileMode.mirror,
                                ).createShader(bounds);
                              },
                              child: Text(
                                "هدية مفاجئة",
                                style: CustomTextStyle().heading1L.copyWith(
                                  color: Colors.black,
                                  fontSize: 18.sp,
                                ),
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Padding(
                              padding: EdgeInsets.all(4.w),
                              child: Text(
                                "🎁 مفاجأة رائعة! لقد استمتعت بوقتك في تطبيقنا، وها نحن نقدم لك هدية مجانية تقديرًا لك! 🎉",
                                textAlign: TextAlign.center,
                                style: CustomTextStyle().heading1L.copyWith(
                                  color: Colors.black54,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                color: Colors.transparent,
                                height: 0.35.sh,
                                width: double.maxFinite,
                                child: Stack(
                                  alignment: Alignment.bottomLeft,
                                  children: [
                                    Stack(
                                      alignment: Alignment.topLeft,
                                      children: [
                                        Stack(
                                          alignment: Alignment.center,
                                          clipBehavior: Clip.none,
                                          children: [
                                            SizedBox(
                                              height: 0.35.sh,
                                              width: double.maxFinite,
                                              child: CarouselSlider.builder(
                                                itemBuilder: (context, index, realIndex) {
                                                  return Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                          vertical: 15.h,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20.r,
                                                          ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: CustomColor
                                                              .blueColor,
                                                          blurStyle:
                                                              BlurStyle.outer,
                                                          blurRadius: 8,
                                                        ),
                                                      ],
                                                    ),
                                                    child: CustomImageSponsored(
                                                      boxFit: BoxFit.cover,
                                                      imageUrl:
                                                          freeGiftController
                                                              .theItemFree
                                                              .vendorImagesLinks?[index]
                                                              .toString() ??
                                                          "",
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20.r,
                                                          ),
                                                      width: double.maxFinite,
                                                      height: 0.35.sh,
                                                      padding: EdgeInsets.zero,
                                                      borderCircle: 20.r,
                                                    ),
                                                  );
                                                },
                                                options: CarouselOptions(
                                                  initialPage: 0,

                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  height: 0.35.sh,
                                                  enlargeCenterPage: true,

                                                  enlargeStrategy:
                                                      CenterPageEnlargeStrategy
                                                          .scale,

                                                  // pageViewKey: PageStorageKey(
                                                  //     widget.item.vendorImagesLinks[0].toString()),
                                                  viewportFraction: 0.7,
                                                  aspectRatio: 7,

                                                  // autoPlayCurve: Curves.fastEaseInToSlowEaseOut,
                                                  autoPlayAnimationDuration:
                                                      Duration(
                                                        milliseconds: 3000,
                                                      ),

                                                  // autoPlayInterval: Duration(milliseconds: 5900),
                                                  scrollPhysics:
                                                      ClampingScrollPhysics(),
                                                  autoPlay: true,
                                                ),
                                                itemCount: freeGiftController
                                                    .theItemFree
                                                    .vendorImagesLinks
                                                    ?.length,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ButtonDone(
                              text:
                                  (freeGiftController
                                          .theItemFree
                                          .variants?[0]
                                          .size ==
                                      "")
                                  ? "لم يعد متوفر"
                                  : (productItemController
                                            .inCart[freeGiftController
                                            .theItemFree
                                            .id
                                            .toString()] ==
                                        true)
                                  ? "إزالة من السلة"
                                  : ((productItemController
                                                .inCart[freeGiftController
                                                .theItemFree
                                                .id
                                                .toString()] ==
                                            false) &&
                                        (productItemController.update == true))
                                  ? "تحديث إلى السلة"
                                  : "أضف إلى السلة",
                              backColor: (fetchController.showEven == 1)
                                  ? CustomColor.chrismasColor
                                  : Colors.black,
                              iconName: Assets.icons.cart,
                              isLoading:
                                  productItemController.isLoadingButtonCart,
                              onPressed: () async {
                                await productItemController
                                    .changeLoadingButtonCart(true);
                                String hasOffer1 = "false";

                                String offer = await fetchController.getOffer();

                                for (var i
                                    in freeGiftController.theItemFree.tags ??
                                        []) {
                                  if (i.toString().trim().toString() ==
                                      offer.toString().trim().toString()) {
                                    hasOffer1 = "true";
                                  }
                                }
                                List<String> tags =
                                    (freeGiftController.theItemFree.tags ?? []);

                                await cartController.insertData(
                                  id: "${freeGiftController.theItemFree.id}000",
                                  variantId: freeGiftController
                                      .theItemFree
                                      .variants?[0]
                                      .id,
                                  productId: freeGiftController.theItemFree.id,
                                  shopId: freeGiftController.theItemFree.shopId
                                      .toString(),
                                  employee: freeGiftController
                                      .theItemFree
                                      .variants?[0]
                                      .employee
                                      .toString(),
                                  nickname: freeGiftController
                                      .theItemFree
                                      .variants?[0]
                                      .nickname
                                      .toString(),
                                  placeInHouse: freeGiftController
                                      .theItemFree
                                      .variants?[0]
                                      .placeInWarehouse
                                      .toString(),
                                  sku: freeGiftController.theItemFree.sku
                                      .toString(),
                                  vendorSku: freeGiftController
                                      .theItemFree
                                      .vendorSku
                                      .toString(),
                                  image: freeGiftController
                                      .theItemFree
                                      .vendorImagesLinks![0],
                                  title: freeGiftController.theItemFree.title,
                                  oldPrice: "0 ₪",
                                  size: freeGiftController
                                      .theItemFree
                                      .variants?[0]
                                      .size
                                      .toString(),
                                  quantity: 1,
                                  basicQuantity: 1,
                                  totalPrice: "0 ₪",
                                  indexVariants: 0,
                                  newPrice: "0 ₪",
                                  favourite: "true",
                                  hasOffer: hasOffer1,
                                  tags: '$tags',
                                );

                                await analyticsService.logAddToCart(
                                  productId:
                                      freeGiftController.theItemFree.id
                                          ?.toString() ??
                                      "",
                                  productTitle:
                                      freeGiftController.theItemFree.title ??
                                      "",
                                  parameters: {
                                    "class_name": "DialogFreeGift",
                                    "button_name": "أضف إلى السلة",
                                    "productId":
                                        freeGiftController.theItemFree.id
                                            ?.toString() ??
                                        "",
                                    "productTitle":
                                        freeGiftController.theItemFree.title ??
                                        "",
                                    "time": DateTime.now().toString(),
                                  },
                                );

                                await productItemController
                                    .changeLoadingButtonCart(false);
                                await freeGiftController.markGiftAsGiven();
                                await freeGiftController.changeRepeatLottie(
                                  true,
                                );

                                showSnackBar(
                                  title: "تم إضافة المنتج إلى السلة",
                                  type: SnackBarType.success,
                                );
                                NavigatorApp.pop();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                IgnorePointer(
                  child: (freeGiftController.repeat)
                      ? Lottie.asset(
                          Assets.lottie.happy1,
                          height: 1.sh,
                          width: 1.sw,
                          fit: BoxFit.cover,
                          repeat: true,
                          animate: true,
                          onLoaded: (composition) {
                            Future.delayed(Duration(seconds: 5), () async {
                              await freeGiftController.changeRepeatLottie(
                                false,
                              );
                            });
                          },
                        )
                      : SizedBox(),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
