import 'dart:async';

import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/controllers/fetch_controller.dart';
import 'package:fawri_app_refactor/salah/service/notification_local_service.dart';
import 'package:fawri_app_refactor/salah/utilities/style/colors.dart';
import 'package:fawri_app_refactor/salah/widgets/widgets_item_view/quantity_view.dart';
import 'package:fawri_app_refactor/salah/widgets/widgets_item_view/slider_images_view.dart';
import 'package:fawri_app_refactor/server/functions/functions.dart';
import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:vibration/vibration.dart';
import '../../../dialog/dialogs/dialogs_cart/dialogs_cart_delete_and_check_available.dart';
import '../../controllers/APIS/api_product_item.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/page_main_screen_controller.dart';
import '../../controllers/product_item_controller.dart';
import '../../controllers/favourite_controller.dart';
import '../../models/items/item_model.dart';
import '../../utilities/global/app_global.dart';
import '../../views/pages/cart/my_cart.dart';
import '../app_bar_widgets/app_bar_custom.dart';
import '../custom_button.dart';
import '../lottie_widget.dart';
import '../snackBarWidgets/snack_bar_style.dart';
import '../snackBarWidgets/snackbar_widget.dart';
import 'animation_tags.dart';
import 'button_done.dart';
import 'description_specafic_item.dart';
import 'favourite.dart';

class SpecificProductView extends StatefulWidget {
  final Item item;
  final int indexVariants;
  final bool isFeature;

  const SpecificProductView({
    super.key,
    required this.item,
    required this.isFeature,
    required this.indexVariants,
  });

  @override
  State<SpecificProductView> createState() => _SpecificProductViewState();
}

class _SpecificProductViewState extends State<SpecificProductView> {
  GlobalKey widgetKey = GlobalKey();

  GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;

  Timer? timer; // Declare a Timer variable

  @override
  void initState() {
    super.initState();

    // استخدام Future.microtask بدلاً من addPostFrameCallback لتقليل خطر استخدام context غير صالح
    Future.microtask(() async {
      if (!mounted) return;

      final pageMainScreenController = context.read<PageMainScreenController>();
      final cartController = context.read<CartController>();

      // إعداد التايمر
      timer = Timer(Duration(seconds: 5), () async {
        if (!mounted) return;

        bool check = await pageMainScreenController.checkItemViewedById(
          productId: widget.item.id ?? 0,
        );

        bool check1 = await cartController.checkCartItemByIdToViewed(
          productId: widget.item.id ?? 0,
        );

        if (!check && !check1) {
          DateTime createdAt = DateTime.now();
          String formattedDate = DateFormat(
            'yyyy-MM-dd HH:mm:ss',
          ).format(createdAt);

          if (!mounted) return;

          if (pageMainScreenController.itemsViewed.length < 30) {
            await pageMainScreenController.insertData(
              id: widget.item.id ?? 0,
              createdAt: formattedDate,
            );
          } else {
            await pageMainScreenController.deleteLastItem(
              id: widget.item.id ?? 0,
              createdAt: formattedDate,
            );
            timer?.cancel();
          }
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    runAddToCartAnimation = (_) {}; // Reset function
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ProductItemController productItemController = context
        .watch<ProductItemController>();
    FavouriteController favouriteController = context
        .watch<FavouriteController>();
    PageMainScreenController pageMainScreenController = context
        .watch<PageMainScreenController>();
    CartController cartController = context.watch<CartController>();
    ApiProductItemController apiProductItemController = context
        .watch<ApiProductItemController>();
    AnalyticsService analyticsService = AnalyticsService();

    FetchController fetchController = context.watch<FetchController>();
    bool favourite = favouriteController.checkFavouriteItemProductId(
      productId: (widget.item.id!.toInt()),
    );

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          printLog("Canceling requests and disposing resources");
          await apiProductItemController
              .cancelRequests(); // Directly cancel requests
          await productItemController.clearItemsData();
        } else {
          return;
        }
      },
      child: Scaffold(
        extendBody:
            ((widget.item.variants?[0].size == "") ||
                widget.item.subCategoris == "")
            ? true
            : false,
        bottomNavigationBar: ButtonDone(
          text: (widget.item.variants?[0].size == "")
              ? "لم يعد متوفر"
              : (productItemController.inCart[widget.item.id.toString()] ==
                    true)
              ? "إزالة من السلة"
              : ((productItemController.inCart[widget.item.id.toString()] ==
                        false) &&
                    (productItemController.update == true))
              ? "تحديث إلى السلة"
              : "أضف إلى السلة",
          backColor: (fetchController.showEven == 1)
              ? CustomColor.chrismasColor
              : (fetchController.showEven == 4)
              ? CustomColor.eidColor
              : Colors.black,
          iconName: Assets.icons.cart,
          isLoading: productItemController.isLoadingButtonCart,
          onPressed: (widget.item.variants?[0].size == "")
              ? null
              : (productItemController.inCart[widget.item.id.toString()] ==
                    true)
              ? () async {
                  await analyticsService.logEvent(
                    eventName: "remove_from_cart",
                    parameters: {
                      "class_name": "SpecificProductView",
                      "button_name": "remove_from_cart button",
                      "product_id": widget.item.id?.toString() ?? "",
                      "product_title": widget.item.title ?? "",
                      "time": DateTime.now().toString(),
                    },
                  );
                  Vibration.vibrate(duration: 100);
                  await onPopDeleteCartItem(
                    id: "${widget.item.id}00${productItemController.indexItems[widget.item.id.toString()].toString()}",
                  );

                  await productItemController.changeSizesItem(
                    widget.item.id.toString(),
                    widget
                        .item
                        .variants![productItemController.indexItems[widget
                            .item
                            .id
                            .toString()]!]
                        .size
                        .toString(),
                    widget.item,
                    productItemController.indexItems[widget.item.id
                        .toString()]!,
                  );
                }
              : ((productItemController.inCart[widget.item.id.toString()]) ==
                        false &&
                    productItemController.update == true)
              ? () async {
                  Vibration.vibrate(duration: 100);

                  await productItemController.changeLoadingButtonCart(true);
                  await productItemController.changeNoChoiceSize(false);

                  await cartController.updateData(
                    id: "${widget.item.id}00${productItemController.indexItems[widget.item.id.toString()]}",
                    quantity: productItemController
                        .valueQuantityItems[widget.item.id.toString()],
                    totalPrice: totalPrice1(
                      widget.item.newPrice.toString(),
                      int.parse(
                        productItemController
                            .valueQuantityItems[widget.item.id
                                .toString()
                                .trim()]
                            .toString(),
                      ),
                    ),
                  );

                  await productItemController.changeLoadingButtonCart(false);
                  await cartController.getCartItems();

                  NavigatorApp.pop();

                  if (context.mounted) {
                    await showSnackBar(
                      title: "تم تحديث المنتج في السلة",
                      type: SnackBarType.success,
                      context: context,
                    );
                  }
                }
              : (productItemController.allItems.isEmpty)
              ? null
              : () async {
                  Vibration.vibrate(duration: 100);

                  await productItemController.changeLoadingButtonCart(true);

                  if ((productItemController
                          .sizesItems[widget.item.id.toString()]
                          .toString()) ==
                      "") {
                    await productItemController.changeLoadingButtonCart(false);
                    await productItemController.changeNoChoiceSize(true);

                    if (context.mounted) {
                      showSnackBar(
                        title: "لم يتم اختيار حجم المنتج!! ",
                        type: SnackBarType.warning,
                        context: context,
                      );
                    }
                  } else {
                    if (await cartController.checkCartItem(
                      id: "${widget.item.id}00${(productItemController.indexItems[widget.item.id.toString()].toString())}",
                    )) {
                      await productItemController.changeLoadingButtonCart(
                        false,
                      );
                      await productItemController.changeNoChoiceSize(false);
                      if (context.mounted) {
                        showSnackBar(
                          title: "تم إضافة المنتج من هذا الحجم مسبقا",
                          type: SnackBarType.warning,
                          context: context,
                        );
                      }
                    } else {
                      bool isFavourite = await favouriteController
                          .checkFavouriteItem(productId: widget.item.id);
                      printLog("msg${widget.item.shopId}");

                      String hasOffer1 = "false";

                      String offer = await fetchController.getOffer();

                      for (var i in widget.item.tags ?? []) {
                        if (i.toString().trim().toString() ==
                            offer.toString().trim().toString()) {
                          hasOffer1 = "true";
                        }
                      }
                      List<String> tags = (widget.item.tags ?? []);

                      await cartController.insertData(
                        id: "${widget.item.id}00${(productItemController.indexItems[widget.item.id.toString()].toString())}",
                        productId: widget.item.id,
                        variantId: widget
                            .item
                            .variants?[productItemController
                                    .indexItems[widget.item.id.toString()]
                                    ?.toInt() ??
                                0]
                            .id,
                        shopId: widget.item.shopId.toString(),
                        employee:
                            widget
                                .item
                                .variants?[productItemController
                                        .indexItems[widget.item.id.toString()]
                                        ?.toInt() ??
                                    0]
                                .employee
                                .toString() ??
                            "",
                        nickname:
                            widget
                                .item
                                .variants?[productItemController
                                        .indexItems[widget.item.id.toString()]
                                        ?.toInt() ??
                                    0]
                                .nickname
                                .toString() ??
                            "",
                        placeInHouse: widget
                            .item
                            .variants?[productItemController
                                    .indexItems[widget.item.id.toString()]
                                    ?.toInt() ??
                                0]
                            .placeInWarehouse
                            .toString(),
                        sku: widget.item.sku.toString(),
                        vendorSku: widget.item.vendorSku.toString(),
                        image: widget.item.vendorImagesLinks?.isNotEmpty == true
                            ? widget.item.vendorImagesLinks![0]
                            : "",
                        title: widget.item.title,
                        oldPrice: widget.item.oldPrice.toString(),
                        size: (productItemController
                            .sizesItems[widget.item.id.toString()]
                            .toString()),
                        quantity: int.parse(
                          productItemController
                              .valueQuantityItems[widget.item.id
                                  .toString()
                                  .trim()]
                              .toString(),
                        ),
                        basicQuantity: int.parse(
                          productItemController
                              .basicQuantityItems[widget.item.id
                                  .toString()
                                  .trim()]
                              .toString(),
                        ),
                        totalPrice: totalPrice1(
                          widget.item.newPrice.toString(),
                          int.parse(
                            productItemController
                                .valueQuantityItems[widget.item.id
                                    .toString()
                                    .trim()]
                                .toString(),
                          ),
                        ),
                        indexVariants: productItemController
                            .indexItems[widget.item.id.toString()],
                        newPrice: widget.item.newPrice,
                        favourite: isFavourite.toString(),
                        hasOffer: hasOffer1,
                        tags: '$tags',
                      );

                      await runAddToCartAnimation(widgetKey);

                      await productItemController.changeNoChoiceSize(false);
                      await productItemController.changeLoadingButtonCart(
                        false,
                      );
                      if (context.mounted) {
                        await NotificationService.showNotification(
                          title: "تم أضافة منتج في سلتك",
                          id: widget.item.id ?? 0,
                          body:
                              " تم أضافة المنتج  ${widget.item.title} في السلة ",
                        );

                        await NotificationService.scheduleCartReminderIfNeeded(
                          cartItemCount: cartController.cartItems.length,
                        );

                        NavigatorApp.pop();

                        showSnackBar(
                          title: "تم أضافة المنتج في السلة",
                          type: SnackBarType.success,
                        );
                      }
                    }
                  }
                },
        ),
        appBar: CustomAppBar(
          title: "فوري",
          textButton: "رجوع",
          onPressed: () async {
            printLog("Canceling requests and disposing resources");
            await apiProductItemController
                .cancelRequests(); // Directly cancel requests
            await productItemController.clearItemsData();
            NavigatorApp.pop();
          },
          actions: [
            Container(
              key: cartKey,
              child: Padding(
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
                        eventName: "cart_icon_pressed",
                        parameters: {
                          "class_name": "SpecificProductView",
                          "button_name": "cart_icon pressed",
                          "product_id": widget.item.id?.toString() ?? "",
                          "product_title": widget.item.title ?? "",
                          "time": DateTime.now().toString(),
                        },
                      );
                      await cartController.getCartItems();

                      NavigatorApp.push(
                        ShowCaseWidget(builder: (context) => MyCart()),
                      );
                    },
                    colorFilter: ColorFilter.mode(
                      Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ],
          colorWidgets: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              AddToCartAnimation(
                cartKey: cartKey,
                dragAnimation: const DragToCartAnimationOptions(rotation: true),
                createAddToCartAnimation: (runAddToCart) {
                  if (mounted) {
                    runAddToCartAnimation = runAddToCart;
                  }
                },
                height: 40.w,
                width: 20.h,
                opacity: 0.99,
                jumpAnimation: const JumpAnimationOptions(
                  duration: Duration(microseconds: 200),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          color: Colors.transparent,
                          height: 0.55.sh,
                          width: double.maxFinite,
                          key: widgetKey,
                          child: Stack(
                            alignment: Alignment.bottomLeft,
                            children: [
                              InkWell(
                                onDoubleTap: () async {
                                  // Trigger vibration
                                  Vibration.vibrate(duration: 100);

                                  if (await favouriteController
                                          .checkFavouriteItem(
                                            productId: widget.item.id,
                                          ) ==
                                      true) {
                                    productItemController.flareControls.play(
                                      "like",
                                    );
                                  } else {
                                    productItemController.flareControls.play(
                                      "like",
                                    );
                                    List<String> tags =
                                        (widget.item.tags ?? []);

                                    await favouriteController.insertData(
                                      id: "${widget.item.id}000",
                                      productId: widget.item.id,
                                      variantId: widget.item.variants?[0].id,
                                      image: widget.item.vendorImagesLinks![0],
                                      title: widget.item.title,
                                      oldPrice: widget.item.oldPrice.toString(),
                                      newPrice: widget.item.newPrice,
                                      tags: '$tags',
                                    );
                                  }
                                },
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
                                            SliderImagesView(
                                              id: widget.item.id.toString(),
                                              videoUrl: widget.item.videoUrl,
                                              images:
                                                  widget
                                                      .item
                                                      .vendorImagesLinks ??
                                                  [],
                                              onPageChange:
                                                  (index, reason) async {
                                                    await pageMainScreenController
                                                        .changePositionScroll(
                                                          widget.item.id
                                                              .toString(),
                                                          index.toDouble(),
                                                        );
                                                  },
                                            ),
                                            FavouriteIconDouble(),
                                            SizedBox(
                                              height: double.maxFinite,
                                              width: double.maxFinite,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Visibility(
                                                        visible:
                                                            widget
                                                                    .item
                                                                    .vendorImagesLinks
                                                                    ?.length ==
                                                                1
                                                            ? false
                                                            : true,
                                                        child: DotsIndicator(
                                                          onTap:
                                                              (
                                                                position,
                                                              ) async {},
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          position:
                                                              pageMainScreenController
                                                                  .positionScroll[widget
                                                                  .item
                                                                  .id
                                                                  .toString()] ??
                                                              0,
                                                          dotsCount:
                                                              widget
                                                                  .item
                                                                  .vendorImagesLinks!
                                                                  .isEmpty
                                                              ? (widget.item.videoUrl !=
                                                                            null &&
                                                                        widget
                                                                            .item
                                                                            .videoUrl!
                                                                            .isNotEmpty)
                                                                    ? 1
                                                                    : 0
                                                              : (widget.item.videoUrl !=
                                                                        null &&
                                                                    widget
                                                                        .item
                                                                        .videoUrl!
                                                                        .isNotEmpty)
                                                              ? (widget
                                                                        .item
                                                                        .vendorImagesLinks!
                                                                        .length +
                                                                    1)
                                                              : (widget
                                                                    .item
                                                                    .vendorImagesLinks!
                                                                    .length),
                                                          axis: Axis.vertical,
                                                          decorator: DotsDecorator(
                                                            size: Size.square(
                                                              7.r,
                                                            ),
                                                            activeSize: Size(
                                                              12.w,
                                                              12.w,
                                                            ),
                                                            activeShape:
                                                                RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        5.r,
                                                                      ),
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (widget.item.tags != null)
                                          AnimationTags(item: widget.item),
                                      ],
                                    ),
                                    if (fetchController.showEven != 0)
                                      Positioned(
                                        top: 0,
                                        left: -20.h,
                                        bottom: -330.h,

                                        child: IgnorePointer(
                                          ignoring: true,
                                          child:
                                              (fetchController.showEven == 11)
                                              ? Image.asset(
                                                  Assets.images.button11.path,
                                                  height: 120.w,
                                                  width: 120.w,
                                                )
                                              : (fetchController.showEven == 30)
                                              ? Image.asset(
                                                  Assets
                                                      .images
                                                      .blackFridayLogo
                                                      .path,
                                                  height: 120.w,
                                                  width: 120.w,
                                                )
                                              : LottieWidget(
                                                  // name: "Ramadan Kareem",
                                                  name: Assets.lottie.adhaEid,
                                                  width: 70.w,
                                                  height: 70.w,
                                                ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5.h),
                        DescriptionSpecaficItem(
                          item: widget.item,
                          isFeature: widget.isFeature,
                          favourite: favourite,
                          indexVariants: widget.indexVariants,
                        ),
                        SizedBox(height: 10.h),
                        QuantityView(item: widget.item),
                        SizedBox(height: 10.h),
                      ],
                    ),
                  ],
                ),
              ),
              if ((widget.item.variants?[0].size == ""))
                Container(
                  color: Colors.black.withValues(alpha: 0.7),
                  height: 1.sh,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        Assets.lottie.animation1726740976006,
                        height: 120.h,
                        reverse: true,
                        repeat: true,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'عذرا لم يعد متوفر كمية من هذا المنتج يمكنك التمرير لمشاهدة المنتجات الشبيهة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String totalPrice1(String price, int quantity) {
    double total;

    String cleaned = price.replaceAll('₪', '');
    double value = double.parse(cleaned);
    total = value * quantity;
    String f = total.toStringAsFixed(2);
    total = double.parse(f);
    return "$total ₪";
  }
}
