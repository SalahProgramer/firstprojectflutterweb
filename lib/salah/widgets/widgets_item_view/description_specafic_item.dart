import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/controllers/page_main_screen_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/product_item_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/favourite_controller.dart';
import 'package:fawri_app_refactor/salah/widgets/widgets_item_view/widget_description_text.dart';
import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../../../dialog/dialogs/dialog_waiting/dialog_waiting.dart';
import '../../models/items/item_model.dart';
import '../../service/dynamic_link_service.dart';
import '../../utilities/style/colors.dart';
import '../../utilities/style/text_style.dart';
import '../custom_button.dart';
import '../custom_text.dart';
import '../snackBarWidgets/snack_bar_style.dart';
import '../snackBarWidgets/snackbar_widget.dart';

class DescriptionSpecaficItem extends StatefulWidget {
  final Item item;
  final bool isFeature;
  final bool favourite;
  final int indexVariants;

  const DescriptionSpecaficItem({
    super.key,
    required this.item,
    required this.isFeature,
    required this.favourite,
    required this.indexVariants,
  });

  @override
  State<DescriptionSpecaficItem> createState() =>
      _DescriptionSpecaficItemState();
}

class _DescriptionSpecaficItemState extends State<DescriptionSpecaficItem> {
  @override
  Widget build(BuildContext context) {
    AnalyticsService analyticsService = AnalyticsService();

    ProductItemController productItemController =
        context.watch<ProductItemController>();

    PageMainScreenController pageMainScreenController =
        context.watch<PageMainScreenController>();
    FavouriteController favouriteController =
        context.watch<FavouriteController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 2.w, vertical: 0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                  fontSize: 9.sp,
                                  alignmentGeometry: Alignment.topRight,
                                  fontWeight: FontWeight.normal,
                                  text: widget.item.oldPrice.toString()),
                            ],
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CustomText(
                                fontSize: 12.sp,
                                color: Colors.red,
                                alignmentGeometry: Alignment.topRight,
                                textDecoration: TextDecoration.none,
                                text: widget.item.newPrice.toString(),
                              )
                              // CustomText(
                              //     fontSize: 12.sp,
                              //     color: Colors.red,
                              //     fontWeight: FontWeight.normal,
                              //     textDecoration: TextDecoration.none,
                              //     text:
                              //         "  % ${calculateDiscountSimple(widget.item.id)}"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: widget.isFeature,
                child: Padding(
                  padding: EdgeInsets.only(left: 5.w),
                  child: Opacity(
                    opacity: 1,
                    child: Container(
                      height: 27.h,
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: Colors.white),
                      child: Center(
                        child: Text(
                          "👑  منتج مميز  👑",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                              color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Spacer(),
              CustomIconButton(
                opacity: (productItemController.allItems.isEmpty)
                    ? 0
                    : (widget.item.sku == null)
                        ? 0
                        : 1,
                widgetIcon: Tooltip(
                    onTriggered: () {
                      Clipboard.setData(
                          ClipboardData(text: widget.item.sku.toString()));

                      showSnackBar(
                          title: 'تم النسخ بنجاح!', type: SnackBarType.success);
                    },
                    triggerMode: TooltipTriggerMode.tap,
                    message: widget.item.sku.toString(),
                    child: IconSvgPicture(
                      nameIcon: Assets.icons.copy,
                      heightIcon: 18.h,
                      colorFilter:
                          ColorFilter.mode(Colors.black, BlendMode.srcIn),
                    )),
              ),
              CustomIconButton(
                  widgetIcon: InkWell(
                onTap: () async {
                  await analyticsService.logEvent(
                    eventName: "share_product_click",
                    parameters: {
                      "class_name": "DescriptionSpecaficItem",
                      "button_name": "share icon pressed ",
                      "product_id": widget.item.id?.toString() ?? "",
                      "product_title": widget.item.title ?? "",
                      "time": DateTime.now().toString(),
                    },
                  );
                  dialogWaiting();
                  await Future.delayed(Duration(milliseconds: 900));

                  await DynamicLinkService().buildDynamicLink(
                      widget.item.title.toString(),
                      widget.item.vendorImagesLinks?[0].toString() ?? "",
                      widget.item.id.toString());
                },
                overlayColor: WidgetStatePropertyAll(Colors.transparent),
                child: Image.asset(
                  Assets.images.share.path,
                  width: 22.w,
                  height: 22.w,
                  fit: BoxFit.cover,
                ),
              )),
              CustomIconButton(
                widgetIcon: InkWell(
                  overlayColor: WidgetStatePropertyAll(Colors.transparent),
                  onTap: () async {
                    if (await favouriteController.checkFavouriteItem(
                            productId: widget.item.id) ==
                        false) {
                      productItemController.flareControls.play("like");
                      await pageMainScreenController.changeIsFavourite(
                          widget.item.id.toString(), true);
                      List<String> tags = (widget.item.tags ?? []);

                      await favouriteController.insertData(
                        id: "${widget.item.id}000",
                        variantId: widget.item.variants?[0].id,
                        productId: widget.item.id,
                        image: widget.item.vendorImagesLinks![0],
                        title: widget.item.title,
                        oldPrice: widget.item.oldPrice.toString(),
                        newPrice: widget.item.newPrice,
                        tags: '$tags',
                      );
                      Vibration.vibrate(duration: 100);

                      // await pageMainScreenController.changeIsFavourite(
                      //     widget.item.id.toString(),
                      //     !(pageMainScreenController
                      //         .isFavourite[widget.item.id.toString()])!);
                      await analyticsService.logAddToWishlist(
                        productId: widget.item.id?.toString() ?? "",
                        productTitle: widget.item.title ?? "",
                        price: double.tryParse(
                                widget.item.newPrice?.replaceAll("₪", "") ??
                                    "0") ??
                            0.0,
                        parameters: {
                          "class_name": "DescriptionSpecaficItem",
                          "button_name": "favourite_heart_icon",
                          "product_id": widget.item.id?.toString() ?? "",
                          "product_title": widget.item.title ?? "",
                          "price": (double.tryParse(widget.item.newPrice
                                          ?.replaceAll("₪", "") ??
                                      "0") ??
                                  0.0)
                              .toString(),
                          "time": DateTime.now().toString(),
                        },
                      );
                    } else {
                      await favouriteController.deleteItem(
                          productId: widget.item.id);
                    }
                  },
                  child: Icon(FontAwesome.heart,
                      color: (widget.favourite == true)
                          ? CustomColor.primaryColor
                          : Colors.grey),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 2.h,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  widget.item.title.toString(),
                  textDirection: TextDirection.rtl,

                  textAlign: TextAlign.right,
                  style: CustomTextStyle()
                      .heading1L
                      .copyWith(fontSize: 14.sp, color: Colors.black),
                  // textDecoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
        WidgetDescriptionText(
          item: widget.item,
        )
      ],
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
