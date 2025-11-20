import 'dart:core';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/controllers/fetch_controller.dart';
import 'package:fawri_app_refactor/controllers/product_item_controller.dart';
import 'package:fawri_app_refactor/models/items/item_model.dart';
import 'package:fawri_app_refactor/core/utilities/global/app_global.dart';
import 'package:fawri_app_refactor/core/utilities/style/colors.dart';
import 'package:fawri_app_refactor/core/utilities/style/text_style.dart';
import 'package:fawri_app_refactor/core/widgets/custom_button.dart';
import 'package:fawri_app_refactor/core/widgets/lottie_widget.dart';
import 'package:fawri_app_refactor/core/widgets/widgets_carts/slidable_cart_widget.dart';
import 'package:fawri_app_refactor/core/services/analytics/analytics_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glowy_borders/glowy_borders.dart';
import 'package:provider/provider.dart';
import 'package:fawri_app_refactor/views/pages/home/main_screen/product_item_view.dart';
import 'package:fawri_app_refactor/controllers/APIS/api_product_item.dart';
import 'package:fawri_app_refactor/controllers/cart_controller.dart';
import 'package:fawri_app_refactor/controllers/page_main_screen_controller.dart';
import 'package:fawri_app_refactor/models/items/variants_model.dart';
import '../../dialogs/dialogs_cart/dialogs_cart_delete_and_check_available.dart';
import '../../services/database/models_DB/cart_model.dart';
import '../custom_image.dart';

class WidgetEachCard extends StatelessWidget {
  final CartModel? cartItem;
  final int index;
  final String avaliable;

  WidgetEachCard({
    super.key,
    this.cartItem,
    required this.index,
    required this.avaliable,
  });
  final AnalyticsService analyticsService = AnalyticsService();

  @override
  Widget build(BuildContext context) {
    CartController cartController = context.watch<CartController>();
    String number = (avaliable.contains("false,"))
        ? avaliable.split(":").last.trim()
        : "0";

    int availableQuantity = int.parse(number);

    // Find the availability data for this cart item
    String? messageToShow;
    bool hasAvailabilityMessage = false;

    if (cartController.availability.isNotEmpty &&
        index < cartController.availability.length) {
      var availabilityData = cartController.availability[index];
      if (availabilityData.availability == "true" &&
          availabilityData.message != null &&
          availabilityData.message!.isNotEmpty) {
        messageToShow = availabilityData.message;
        hasAvailabilityMessage = true;
      }
    }

    return SlidableCartWidget(
      index: index,
      onPressed: () async {
        await analyticsService.logEvent(
          eventName: "delete_cart_item",
          parameters: {
            "class_name": "WidgetEachCard",
            "button_name": "delete_cart_item",
            "cart_item_id": cartItem?.id ?? "",
            "product_id": cartItem?.productId ?? "",
            "product_title": cartItem?.title ?? "",
            "time": DateTime.now().toString(),
          },
        );
        await onPopDeleteCartItem(id: cartItem?.id ?? "");
      },
      card: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          (avaliable.contains("false,"))
              ? AnimatedGradientBorder(
                  glowSize: 1,
                  borderSize: 0,
                  gradientColors: [
                    CustomColor.primaryColor,
                    CustomColor.primaryColor.withValues(alpha: 0.2),
                  ],
                  borderRadius: BorderRadius.circular(10.r),
                  child: card(context),
                )
              : card(context),
          if (avaliable.contains("false,"))
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "عذراً، الكمية المتوفرة من هذا المنتج هي : ",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyle().rubik.copyWith(
                        color: CustomColor.primaryColor,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "$availableQuantity",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyle().rubik.copyWith(
                        color: CustomColor.blueColor,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          // Show message for items with availability true but have messages
          if (hasAvailabilityMessage && messageToShow != null)
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      translateMessageToArabic(messageToShow),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyle().rubik.copyWith(
                        color: CustomColor.blueColor,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget card(BuildContext context) {
    CartController cartController = context.watch<CartController>();
    ProductItemController productItemController = context
        .watch<ProductItemController>();
    PageMainScreenController pageMainScreenController = context
        .watch<PageMainScreenController>();
    FetchController fetchController = context.watch<FetchController>();
    ApiProductItemController apiProductItemController = context
        .watch<ApiProductItemController>();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: InkWell(
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  overlayColor: WidgetStateColor.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    String rawTags = cartItem?.tags ?? "";
                    List<String> tags;

                    if (rawTags.startsWith("[") && rawTags.endsWith("]")) {
                      // Remove brackets and split by comma, trimming spaces
                      tags = rawTags
                          .substring(1, rawTags.length - 1)
                          .split(",")
                          .map((e) => e.trim())
                          .toList();
                    } else {
                      // If it's not an array, assume it's a single tag
                      tags = [rawTags.trim()];
                    }
                    Item item = Item(
                      id: cartItem!.productId,
                      tags: tags,
                      variants: [
                        Variants(
                          employee: "",
                          oldPrice: "",
                          newPrice: "",
                          size: "${cartItem!.productId}",
                          id: cartItem?.variantId,
                          placeInWarehouse: "",
                          quantity: "",
                          nickname: "",
                          season: "",
                        ),
                      ],
                      newPrice: cartItem?.newPrice.toString(),
                      oldPrice: cartItem?.oldPrice.toString(),
                      sku: cartItem?.sku.toString(),
                      title: cartItem!.title,
                      vendorImagesLinks: [cartItem!.image.toString()],
                    );

                    await analyticsService.logEvent(
                      eventName: "open_product_from_cart",
                      parameters: {
                        "class_name": "WidgetEachCard",
                        "button_name": "open_product_from_cart",
                        "cart_item_id": cartItem?.id ?? "",
                        "product_id": cartItem?.productId ?? "",
                        "product_title": cartItem?.title ?? "",
                        "time": DateTime.now().toString(),
                      },
                    );

                    await pageMainScreenController.changePositionScroll(
                      item.id.toString(),
                      0,
                    );
                    await productItemController.clearItemsData();
                    await apiProductItemController.cancelRequests();
                    NavigatorApp.push(
                      ProductItemView(
                        item: item,
                        indexVariants: cartItem!.indexVariants,
                        sizes: "",
                      ),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      CustomImageSponsored(
                        imageUrl: cartItem?.image ?? "",
                        height: 100.h,
                        boxFit: BoxFit.fill,
                        borderCircle: 10.r,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      if (fetchController.showEven != 0)
                        LottieWidget(
                          name: (fetchController.showEven == 4)
                              ?
                                // "Ramadan Lantern"
                                Assets.lottie.eid
                              : (fetchController.showEven == 30)
                              ? Assets.lottie.blackFriday
                              : Assets.lottie.eleven,
                          width: (fetchController.showEven == 4) ? 31.w : 40.w,
                          height: (fetchController.showEven == 4) ? 31.w : 40.w,
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 5.w),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                cartItem?.title ?? "",
                                textDirection: TextDirection.rtl,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                                style: CustomTextStyle().heading1L.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: CustomColor.blueColor,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          InkWell(
                            highlightColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            overlayColor: WidgetStateColor.transparent,
                            onTap: () async {
                              await analyticsService.logEvent(
                                eventName: "delete_cart_item_icon",
                                parameters: {
                                  "class_name": "WidgetEachCard",
                                  "button_name": "delete_cart_item_icon",
                                  "cart_item_id": cartItem?.id ?? "",
                                  "product_id": cartItem?.productId ?? "",
                                  "product_title": cartItem?.title ?? "",
                                  "time": DateTime.now().toString(),
                                },
                              );
                              await onPopDeleteCartItem(id: cartItem?.id ?? "");
                            },
                            child: Icon(
                              CupertinoIcons.delete,
                              color: CustomColor.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        text(name: "الحجم : ", color: Colors.black),
                        text(
                          name: cartItem?.size?.trim().toString() ?? "",
                          color: CustomColor.blueColor,
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Visibility(
                      visible: (cartItem!.basicQuantity! > 1) ? true : false,
                      child: Row(
                        children: [
                          text(name: "الكمية : ", color: Colors.black),
                          IconSvg(
                            nameIcon: Assets.icons.add,
                            onPressed: () async {
                              await analyticsService.logEvent(
                                eventName: "delete_cart_item_icon",
                                parameters: {
                                  "class_name": "WidgetEachCard",
                                  "button_name": "delete_cart_item_icon",
                                  "cart_item_id": cartItem?.id ?? "",
                                  "product_id": cartItem?.productId ?? "",
                                  "product_title": cartItem?.title ?? "",
                                  "time": DateTime.now().toString(),
                                },
                              );
                              // valueQuantityItems[id]! >= int.parse(basicQuantityItems[id]!)
                              await cartController.doOperation(
                                id: cartItem?.id,
                                quantity: cartItem?.quantity,
                                basicQuantity: cartItem?.basicQuantity,
                                price: cartItem?.newPrice,
                                operation: '+',
                              );
                            },
                            backColor: Colors.transparent,
                            height: 27.h,
                            colorFilter: ColorFilter.mode(
                              CustomColor.blueColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          text(
                            name: "${cartItem?.quantity}",
                            color: CustomColor.blueColor,
                          ),
                          IconSvg(
                            nameIcon: Assets.icons.remove,
                            onPressed: () async {
                              await analyticsService.logEvent(
                                eventName: "decrease_cart_quantity",
                                parameters: {
                                  "class_name": "WidgetEachCard",
                                  "button_name": "decrease_cart_quantity",
                                  "cart_item_id": cartItem?.id ?? "",
                                  "product_id": cartItem?.productId ?? "",
                                  "product_title": cartItem?.title ?? "",
                                  "time": DateTime.now().toString(),
                                },
                              );
                              await cartController.doOperation(
                                id: cartItem?.id,
                                quantity: cartItem?.quantity,
                                basicQuantity: cartItem?.basicQuantity,
                                price: cartItem?.newPrice,
                                operation: '-',
                              );
                            },
                            backColor: Colors.transparent,
                            height: 27.h,
                            colorFilter: ColorFilter.mode(
                              CustomColor.blueColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (cartItem!.quantity! < 1) Spacer(),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                text(name: "السعر : ", color: Colors.black),
                                text(
                                  name: "${((cartItem?.newPrice.toString()))}",
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          ),
                          text(
                            name: "${((cartItem?.totalPrice.toString()))}",
                            color: CustomColor.primaryColor,
                            size: 14.sp,
                          ),
                        ],
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

  Widget text({required String name, Color? color, double? size}) {
    return Flexible(
      child: Text(
        name,
        textDirection: TextDirection.rtl,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: CustomTextStyle().heading1L.copyWith(
          fontWeight: FontWeight.bold,
          color: color ?? CustomColor.blueColor,
          fontSize: size ?? 12.sp,
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

  // Method to translate common English messages to Arabic
  String translateMessageToArabic(String message) {
    // Convert to lowercase for easier matching
    String lowerMessage = message.toLowerCase();

    // Common translations
    if (lowerMessage.contains('offer ended') &&
        lowerMessage.contains('price updated')) {
      // Extract price from message if present
      RegExp priceRegex = RegExp(r'(\d+\.?\d*)');
      Match? match = priceRegex.firstMatch(message);
      String price = match?.group(0) ?? '';

      if (price.isNotEmpty) {
        return 'للأسف!! انتهى العرض، تم تحديث السعر إلى $price ₪';
      } else {
        return 'للأسف!! انتهى العرض، تم تحديث السعر';
      }
    }

    // Other common translations
    if (lowerMessage.contains('product not found')) {
      return 'للأسف!! المنتج غير موجود';
    }

    if (lowerMessage.contains('out of stock')) {
      return 'للأسف!! نفد من المخزون';
    }

    if (lowerMessage.contains('invalid quantity')) {
      return 'للأسف!! كمية غير صالحة';
    }

    if (lowerMessage.contains('price updated')) {
      RegExp priceRegex = RegExp(r'(\d+\.?\d*)');
      Match? match = priceRegex.firstMatch(message);
      String price = match?.group(0) ?? '';

      if (price.isNotEmpty) {
        return 'للأسف!! تم تحديث السعر إلى $price ₪';
      } else {
        return 'للأسف!! تم تحديث السعر';
      }
    }

    // If no translation found, return original message with "للأسف!!"
    return message;
  }
}
