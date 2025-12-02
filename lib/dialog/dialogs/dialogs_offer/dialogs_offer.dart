import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/controllers/page_main_screen_controller.dart';
import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:vibration/vibration.dart';

import '../../../../pages/checkout/first-screen/first_screen.dart';
import '../../../../server/domain/domain.dart';
import '../../../../server/functions/functions.dart';
import '../../../../services/remote_config_firebase/remote_config_firebase.dart';
import '../../../salah/controllers/cart_controller.dart';
import '../../../salah/controllers/custom_page_controller.dart';
import '../../../salah/controllers/fetch_controller.dart';
import '../../../salah/controllers/points_controller.dart';
import '../../../salah/controllers/sub_main_categories_conrtroller.dart';
import '../../../salah/utilities/global/app_global.dart';
import '../../../salah/utilities/style/colors.dart';
import '../../../salah/utilities/style/text_style.dart';
import '../../../salah/views/pages/cart/widget_have_offer.dart';
import '../../../salah/widgets/custom_button.dart';
import '../../../salah/widgets/lottie_widget.dart';
import '../../../salah/widgets/widgets_item_view/button_done.dart';
import '../../../salah/widgets/widgets_main_screen/home_screen_widget.dart';
import '../dialog_waiting/dialog_waiting.dart';
import '../dialogs_cart/dialogs_cart_delete_and_check_available.dart';
import '../dialogs_cart/dialogs_no_tawseel_free.dart';

Future<void> dialogOffer(
    {required bool useHappy,
    required String text,
    required ItemScrollController scrollController}) {
  return showDialog(
    context: NavigatorApp.context,
    builder: (context) {
      CustomPageController customPageController =
          context.watch<CustomPageController>();
      CartController cartController = context.watch<CartController>();

      SubMainCategoriesController subMainCategoriesController =
          context.watch<SubMainCategoriesController>();
      FetchController fetchController = context.watch<FetchController>();
      PointsController pointsController = context.watch<PointsController>();
      PageMainScreenController pageMainScreenController =
          context.watch<PageMainScreenController>();
      AnalyticsService analyticsService = AnalyticsService();
      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) async {
          await cartController.getCartItems();
        },
        child: GestureDetector(
          onTap: () async {
            await cartController.getCartItems();
            NavigatorApp.pop();
          },
          child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    if (useHappy)
                      Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [],
                        ),
                      ),
                    Stack(
                      children: [
                        if (useHappy)
                          LottieWidget(
                            name: Assets.lottie.happy1,
                            height: 1.sh,
                            width: 1.sw,
                          ),
                        Center(
                            child: PopScope(
                          canPop: false,
                          child: CupertinoAlertDialog(
                            insetAnimationCurve: Curves.bounceInOut,
                            title: SizedBox(),
                            content: Column(
                              children: [
                                LottieWidget(
                                  name: Assets.lottie.shoesSale,
                                  height: 50.w,
                                  width: 50.w,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    LottieWidget(
                                      name: Assets.lottie.offerCircle,
                                      height: 25.w,
                                      width: 25.w,
                                    ),
                                    Text("عرض   ",
                                        style: CustomTextStyle()
                                            .heading1L
                                            .copyWith(
                                                color: Colors.black,
                                                fontSize: 16.sp)),
                                    LottieWidget(
                                      name: Assets.lottie.offerCircle,
                                      height: 25.w,
                                      width: 25.w,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5.h,
                                ),
                                Text(
                                  text,
                                  style: CustomTextStyle().heading1L.copyWith(
                                      color: Colors.black87, fontSize: 10.sp),
                                ),
                              ],
                            ),
                            actions: [
                              CustomButtonWithIconWithoutBackground(
                                  text: "تسوق الآن",
                                  textIcon: "",
                                  height: 16.h,
                                  textStyle: CustomTextStyle().rubik.copyWith(
                                      color: CustomColor.blueColor,
                                      fontSize: 12.sp),
                                  onPressed: () async {
                                    await analyticsService.logEvent(
                                      eventName: "offer_shop_now_click",
                                      parameters: {
                                        "class_name": "DialogsOffer",
                                        "button_name": "تسوق الآن عرض التوصيل",
                                        "time": DateTime.now().toString(),
                                      },
                                    );
                                    NavigatorApp.pop();
                                    await customPageController
                                        .changeIndexPage(0);
                                    await customPageController
                                        .changeIndexCategoryPage(1);
                                    await subMainCategoriesController.clear();
                                    String tagName = fetchController.offer;
                                    NavigatorApp.push(homeScreenWidget(
                                      bannerTitle: tagName.toString(),
                                      type: tagName.toString(),
                                      url: urlFLASHSALES,
                                      scroll: subMainCategoriesController
                                          .scrollDynamicItems,
                                    ));
                                  }),
                              CustomButtonWithIconWithoutBackground(
                                  text: "متابعة الشراء",
                                  textIcon: "",
                                  height: 16.h,
                                  textStyle: CustomTextStyle().rubik.copyWith(
                                      color: mainColor, fontSize: 12.sp),
                                  onPressed: () async {
                                    await cartController.getCartItems();
                                    printLog(
                                        cartController.cartItems[0].toString());

                                    Vibration.vibrate(duration: 100);

                                    await cartController.changeLoading(false);

                                    List<Map<String, dynamic>> jsonList =
                                        cartController.cartItems
                                            .map((cart) => cart.toJsonCart())
                                            .toList();

                                    await cartController
                                        .checkProductAvailability(jsonList);

                                    if (cartController
                                            .notAvailabilityItems.isEmpty &&
                                        cartController
                                                .availabilityItems.length ==
                                            cartController.cartItems.length) {
                                      var freeShipValue =
                                          await FirebaseRemoteConfigClass()
                                              .fetchFreeShip();
                                      printLog(freeShipValue);
                                      printLog(cartController.totalItemsPrice
                                          .toString());
                                      if (int.parse(freeShipValue.toString()) ==
                                          0) {
                                        await pointsController.changeTotal(
                                            double.parse(cartController
                                                .totalItemsPrice
                                                .toString()));

                                        await pointsController.changeTotalItems(
                                            double.parse(cartController
                                                .totalItemsPrice
                                                .toString()));
                                        NavigatorApp.push(CheckoutFirstScreen(
                                          freeShipValue: freeShipValue,
                                          items: cartController.cartItems,
                                        ));
                                      } else {
                                        if (double.parse(cartController
                                                .totalItemsPrice
                                                .toString()) >
                                            double.parse(
                                                freeShipValue.toString())) {
                                          await cartController
                                              .changeLoading(false);
                                          await pointsController.changeTotal(
                                              double.parse(cartController
                                                  .totalItemsPrice
                                                  .toString()));

                                          await pointsController
                                              .changeTotalItems(double.parse(
                                                  cartController.totalItemsPrice
                                                      .toString()));
                                          NavigatorApp.push(CheckoutFirstScreen(
                                            freeShipValue: freeShipValue,
                                            items: cartController.cartItems,
                                          ));
                                        } else {
                                          NavigatorApp.pop();
                                          double remainder = ((double.parse(
                                                  freeShipValue.toString())) -
                                              (double.parse(cartController
                                                  .totalItemsPrice
                                                  .toString())));
                                          if (remainder < 0) {
                                            remainder = 0;
                                          }

                                          dialogWaiting();

                                          pageMainScreenController
                                              .getOfferTawseelClear();
                                          await pageMainScreenController
                                              .getOfferTawseelItems();

                                          NavigatorApp.pop();

                                          cartController
                                              .initCalculateItemOfferTawseel(
                                                  remainder.toInt());
                                          await cartController
                                              .changeLoading(false);
                                          await cartController
                                              .changeButton(false);

                                          dialogGetNoTawseel(
                                              remainder, scrollController);

                                          await cartController
                                              .changeLoading(false);

                                          await pointsController.changeTotal(
                                              double.parse(cartController
                                                  .totalItemsPrice
                                                  .toString()));

                                          // await pointsController
                                          //     .changeTotalItems(double.parse(
                                          //         cartController.totalItemsPrice
                                          //             .toString()));
                                          //
                                          // NavigatorApp.push(CheckoutFirstScreen(
                                          //     freeShipValue: freeShipValue,
                                          //     items: cartController.cartItems));
                                        }
                                      }
                                    } else if (cartController
                                        .notAvailabilityItems.isNotEmpty) {
                                      await cartController.changeLoading(false);

                                      await dialogCheckItemsAvailable();
                                    } else {
                                      await cartController.changeLoading(false);

                                      await scrollController.scrollTo(
                                        index: cartController
                                            .availabilityWithFalseItems
                                            .indexOf(cartController
                                                .availabilityWithFalseItems
                                                .first),
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  }),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ],
                ),
              )),
        ),
      );
    },
  );
}

Future<void> dialogHaveHappyOffer(
    {required String text,
    required String freeShipValue,
    required ItemScrollController scrollController,
    required ItemScrollController scrollController1,
    bool havButtonCart = false}) {
  return showDialog(
    context: NavigatorApp.context,
    builder: (context) {
      CartController cartController = context.watch<CartController>();
      SubMainCategoriesController subMainCategoriesController =
          context.watch<SubMainCategoriesController>();
      FetchController fetchController = context.watch<FetchController>();
      PointsController pointsController = context.watch<PointsController>();
      PageMainScreenController pageMainScreenController =
          context.watch<PageMainScreenController>();
      CustomPageController customPageController =
          context.watch<CustomPageController>();
      printLog("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk");
      // Scroll to the offer item after a delay
      Future.delayed(const Duration(milliseconds: 600), () {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (cartController.cartItemsOffers.isNotEmpty) {
            final offerIndex = cartController.cartItems
                .indexOf(cartController.cartItemsOffers.first);
            if (offerIndex >= 0) {
              final reversedIndex =
                  cartController.cartItems.length - 1 - offerIndex;
              await scrollController1.scrollTo(
                index: reversedIndex,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }
        });
      });

      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) async {
          await cartController.getCartItems();
        },
        child: GestureDetector(
          onTap: () async {
            // await cartController.getCartItems();
          },
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: EdgeInsets.zero,
            child: Container(
              width: 0.98.sw,
              margin: EdgeInsets.only(bottom: 5.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
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
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: 4.w, right: 4.w, bottom: 4.w, top: 20.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            LottieWidget(
                              name: Assets.lottie.confettiPopper,
                              height: 50.w,
                              width: 50.w,
                            ),
                            LottieWidget(
                              name: Assets.lottie.confettiPopper,
                              height: 50.w,
                              width: 50.w,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 10.w),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: InkWell(
                                  onTap: () async {
                                    await cartController.getCartItems();
                                    NavigatorApp.pop();
                                  },
                                  child: Text(
                                    "رجوع",
                                    textAlign: TextAlign.right,
                                    style: CustomTextStyle().heading1L.copyWith(
                                        color: CustomColor.blueColor,
                                        fontSize: 15.sp),
                                  )),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              LottieWidget(
                                name: Assets.lottie.offer,
                                height: 50.w,
                                width: 50.w,
                              ),
                            ],
                          ),
                          SizedBox(height: 15.h),
                          Text(
                            text,
                            textAlign: TextAlign.center,
                            style: CustomTextStyle()
                                .rubik
                                .copyWith(fontSize: 18.sp, color: Colors.black),
                          ),
                          SizedBox(height: 5.h),
                          if (havButtonCart)
                            ButtonDone(
                              isLoading: false,
                              text: "تسوق الآن",
                              iconName: Assets.icons.cart,
                              height: 39.w,
                              widthIconInStartEnd: 30.w,
                              heightIconInStartEnd: 30.w,
                              padding: EdgeInsets.symmetric(
                                  vertical: 2.h, horizontal: 4.w),
                              onPressed: () async {
                                await analyticsService.logEvent(
                                  eventName: "happy_offer_shop_now_click",
                                  parameters: {
                                    "class_name": "DialogsOffer",
                                    "button_name": " تسوق الآن عرض التوصيل",
                                    "time": DateTime.now().toString(),
                                  },
                                );
                                NavigatorApp.pop();
                                await customPageController.changeIndexPage(0);
                                await customPageController
                                    .changeIndexCategoryPage(1);
                                await subMainCategoriesController.clear();
                                String tagName = fetchController.offer;
                                NavigatorApp.push(homeScreenWidget(
                                  bannerTitle: tagName.toString(),
                                  type: tagName.toString(),
                                  url: urlFLASHSALES,
                                  scroll: subMainCategoriesController
                                      .scrollDynamicItems,
                                ));
                              },
                            ),
                          SizedBox(height: 5.h),
                          Expanded(
                            child: ScrollablePositionedList.builder(
                              physics: ClampingScrollPhysics(),
                              itemScrollController: scrollController1,
                              itemCount: cartController.cartItems.length,
                              itemBuilder: (context, i) {
                                final reversedIndex =
                                    cartController.cartItems.length - 1 - i;
                                return WidgetHaveOffer(
                                  index: reversedIndex,
                                  item: cartController.cartItems[reversedIndex],
                                );
                              },
                            ),
                          ),
                          ButtonDone(
                              text: "تأكيد عمليه الشراء",
                              heightIcon: 28.h,
                              iconName: Assets.icons.yes,
                              isLoading: cartController.isLoading,
                              onPressed: () async {
                                await cartController.getCartItemsAfterOffer();
                                printLog(
                                    cartController.cartItems[0].toString());

                                Vibration.vibrate(duration: 100);

                                await cartController.changeLoading(true);

                                List<Map<String, dynamic>> jsonList =
                                    cartController.cartItems
                                        .map((cart) => cart.toJsonCart())
                                        .toList();

                                await cartController
                                    .checkProductAvailability(jsonList);

                                await analyticsService.logInitiatedCheckout(
                                  checkoutId: DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  productIds: cartController.cartItems
                                      .map((e) => e.id.toString())
                                      .toList(),
                                  totalPrice: double.tryParse(cartController
                                          .totalItemsPrice
                                          .toString()) ??
                                      0.0,
                                  currency: "NIS",
                                  parameters: {
                                    "class_name": "DialogsOffer",
                                    "button_name": "تأكيد عمليه الشراء",
                                    "cart_items_count": cartController
                                        .cartItems.length
                                        .toString(),
                                    "price": double.tryParse(cartController
                                            .totalItemsPrice
                                            .toString()) ??
                                        0.0,
                                    "time": DateTime.now().toString(),
                                  },
                                );

                                if (cartController
                                        .notAvailabilityItems.isEmpty &&
                                    cartController.availabilityItems.length ==
                                        cartController.cartItems.length) {
                                  var freeShipValue =
                                      await FirebaseRemoteConfigClass()
                                          .fetchFreeShip();
                                  printLog(freeShipValue);
                                  printLog(cartController.totalItemsPrice
                                      .toString());
                                  if (int.parse(freeShipValue.toString()) ==
                                      0) {
                                    await pointsController.changeTotal(
                                        double.parse(cartController
                                            .totalItemsPrice
                                            .toString()));

                                    await pointsController.changeTotalItems(
                                        double.parse(cartController
                                            .totalItemsPrice
                                            .toString()));

                                    NavigatorApp.push(CheckoutFirstScreen(
                                      freeShipValue: freeShipValue,
                                      items: cartController.cartItems,
                                    ));
                                  } else {
                                    if (double.parse(cartController
                                            .totalItemsPrice
                                            .toString()) >
                                        double.parse(
                                            freeShipValue.toString())) {
                                      await cartController.changeLoading(false);
                                      await pointsController.changeTotal(
                                          double.parse(cartController
                                              .totalItemsPrice
                                              .toString()));

                                      await pointsController.changeTotalItems(
                                          double.parse(cartController
                                              .totalItemsPrice
                                              .toString()));
                                      NavigatorApp.push(CheckoutFirstScreen(
                                        freeShipValue: freeShipValue,
                                        items: cartController.cartItems,
                                      ));
                                    } else {
                                      NavigatorApp.pop();
                                      double remainder = ((double.parse(
                                              freeShipValue.toString())) -
                                          (double.parse(cartController
                                              .totalItemsPrice
                                              .toString())));
                                      if (remainder < 0) {
                                        remainder = 0;
                                      }

                                      dialogWaiting();

                                      pageMainScreenController
                                          .getOfferTawseelClear();
                                      await pageMainScreenController
                                          .getOfferTawseelItems();

                                      NavigatorApp.pop();

                                      cartController
                                          .initCalculateItemOfferTawseel(
                                              remainder.toInt());
                                      await cartController.changeLoading(false);
                                      await cartController.changeButton(false);

                                      dialogGetNoTawseel(
                                          remainder, scrollController);

                                      await cartController.changeLoading(false);

                                      await pointsController.changeTotal(
                                          double.parse(cartController
                                              .totalItemsPrice
                                              .toString()));

                                      // await pointsController.changeTotalItems(
                                      //     double.parse(cartController
                                      //         .totalItemsPrice
                                      //         .toString()));
                                      //
                                      // NavigatorApp.push(CheckoutFirstScreen(
                                      //     freeShipValue: freeShipValue,
                                      //     items: cartController.cartItems));
                                    }
                                  }
                                } else if (cartController
                                    .notAvailabilityItems.isNotEmpty) {
                                  await cartController.changeLoading(false);

                                  await dialogCheckItemsAvailable();
                                } else {
                                  await cartController.changeLoading(false);

                                  await scrollController.scrollTo(
                                    index: cartController
                                        .availabilityWithFalseItems
                                        .indexOf(cartController
                                            .availabilityWithFalseItems.first),
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
