import 'package:fawri_app_refactor/core/dialogs/dialog_waiting/dialog_waiting.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/controllers/custom_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../utilities/vibration_helper.dart';
import '../../services/firebase/remote_config_firebase/remote_config_firebase.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/page_main_screen_controller.dart';
import '../../../controllers/points_controller.dart';
import '../../utilities/global/app_global.dart';
import '../../utilities/routes.dart';
import '../../utilities/print_looger.dart';
import '../../utilities/style/colors.dart';
import '../../utilities/style/text_style.dart';
import '../../widgets/lottie_widget.dart';
import '../../widgets/widgets_item_view/button_done.dart';
import 'dialogs_cart_delete_and_check_available.dart';

Future<void> dialogGetNoTawseel(
    double remainder, ItemScrollController scrollController) {
  return showGeneralDialog(
    context: NavigatorApp.navigatorKey.currentState!.context,
    barrierLabel: "ShowGetNoTawseel",
    pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) =>
        ShowGetNoTawseel(
      remainder: remainder,
      scrollController: scrollController,
    ),
    barrierDismissible: true,
  );
}

class ShowGetNoTawseel extends StatefulWidget {
  final double remainder;
  final ItemScrollController scrollController;

  const ShowGetNoTawseel(
      {super.key, required this.remainder, required this.scrollController});

  @override
  State<ShowGetNoTawseel> createState() => _ShowGetNoTawseelState();
}

class _ShowGetNoTawseelState extends State<ShowGetNoTawseel> {
  bool hasReachedIndex = false;
  final ScrollController scrollController2 = ScrollController();
  bool isLoading = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController2.addListener(() async {
        PageMainScreenController pageMainScreenController =
            context.read<PageMainScreenController>();
        final itemWidth = 0.16.sw;

        final index25Offset =
            (((pageMainScreenController.offerTawseelItems.length ~/ 28)) * 25) *
                itemWidth;

        if (scrollController2.offset >= index25Offset && !hasReachedIndex) {
          hasReachedIndex = true;
          await pageMainScreenController.getOfferTawseelItems();
          hasReachedIndex = false;
        }
      });
    });

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    CartController cartController = context.watch<CartController>();
    CustomPageController customPageController =
        context.watch<CustomPageController>();
    PointsController pointsController = context.watch<PointsController>();

    return PopScope(
        canPop: false,
        // Prevents system back navigation
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            await cartController.deleteItemAddedToCart();
            await cartController.getCartItems();
            await cartController.changeButton(true);

            NavigatorApp.pop();
          }
        },
        child: AlertDialog(
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          insetPadding: EdgeInsets.all(13.w),
          clipBehavior: Clip.hardEdge,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 20.h,
          ),
          constraints: BoxConstraints(
            minWidth: 1.sw,
            maxWidth: 1.sw,
          ),
          content: SizedBox(
            width: 1.sw,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LottieWidget(
                      height: 60.w,
                      width: 60.w,
                      name: Assets.lottie.freeShipping,
                    ),
                  ],
                ),
                Text(
                  "اشترِ بقيمة 250 شيكل للحصول على توصيل مجاني!",
                  textAlign: TextAlign.center,
                  style: CustomTextStyle().cairo.copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.black),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  spacing: 2.w,
                  children: [
                    // First row content (مجموع القطع)
                    Flexible(
                      flex: 3,
                      child: Text(
                        "مجموع المتبقي للخصم : ",
                        textDirection: TextDirection.rtl,
                        maxLines: 1,
                        style: CustomTextStyle().cairo.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        "${widget.remainder.toInt()} ₪",
                        textDirection: TextDirection.rtl,
                        overflow: TextOverflow.ellipsis,
                        style: CustomTextStyle().heading1L.copyWith(
                              color: CustomColor.primaryColor,
                              fontSize: 15.sp,
                            ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: Column(
                    spacing: 5.h,
                    children: [
                      ButtonDone(
                          text: "اذهب للتسوق لإضافة منتجات",
                          haveBouncingWidget: false,
                          // iconName: Assets.icons.cart,
                          fontSize: 12.sp,
                          backColor: Colors.black,
                          borderRadius: 30.r,
                          shadowColor: Colors.grey.withValues(alpha: 0.30),
                          onPressed: () async {
                            NavigatorApp.pop();
                            await customPageController.changeIndexPage(0);
                            await customPageController
                                .changeIndexCategoryPage(1);
                            NavigatorApp.navigateToRemoveUntil(AppRoutes.pages);
                          }),
                      ButtonDone(
                        text: "استمر في إتمام الطلب",

                        textColor: Colors.grey[700],
                        haveBouncingWidget: false,
                        fontSize: 12.sp,
                        backColor: Colors.white60,
                        borderColor: Colors.grey[400],
                        borderRadius: 30.r,
                        shadowColor: Colors.grey.withValues(alpha: 0.30),
                        // iconName: Assets.icons.order,
                        onPressed: cartController.isLoading
                            ? null
                            : () async {
                                await cartController.changeLoading(true);
                                dialogWaiting();
                                await cartController.deleteItemAddedToCart();
                                await cartController.getCartItems();

                                await VibrationHelper.vibrate(duration: 100);

                                await cartController.changeLoading(false);
                                await cartController.changeButton(true);

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
                                  parameters: {
                                    "class_name": "checkout continue",
                                    "button_name": "تابع الشراء تجاهل العرض",
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

                                NavigatorApp.pop();

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
                                    NavigatorApp.pushName(
                                      AppRoutes.checkoutFirstScreen,
                                      arguments: {
                                        'freeShipValue': freeShipValue,
                                        'items': cartController.cartItems,
                                      },
                                    );
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
                                      NavigatorApp.pushName(
                                        AppRoutes.checkoutFirstScreen,
                                        arguments: {
                                          'freeShipValue': freeShipValue,
                                          'items': cartController.cartItems,
                                        },
                                      );
                                    } else {
                                      await cartController.changeLoading(false);
                                      await pointsController.changeTotal(
                                          double.parse(cartController
                                              .totalItemsPrice
                                              .toString()));

                                      await pointsController.changeTotalItems(
                                          double.parse(cartController
                                              .totalItemsPrice
                                              .toString()));
                                      NavigatorApp.pushName(
                                        AppRoutes.checkoutFirstScreen,
                                        arguments: {
                                          'freeShipValue': freeShipValue,
                                          'items': cartController.cartItems,
                                        },
                                      );
                                    }
                                  }
                                } else if (cartController
                                    .notAvailabilityItems.isNotEmpty) {
                                  await cartController.changeLoading(false);

                                  await dialogCheckItemsAvailable();
                                } else {
                                  await cartController.changeLoading(false);

                                  await widget.scrollController.scrollTo(
                                    index: cartController
                                        .availabilityWithFalseItems
                                        .indexOf(cartController
                                            .availabilityWithFalseItems.first),
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
