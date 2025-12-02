import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/controllers/cart_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/fetch_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/favourite_controller.dart';
import 'package:fawri_app_refactor/salah/localDataBase/models_DB/favourite_model.dart';
import 'package:fawri_app_refactor/salah/widgets/custom_button.dart';
import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../dialog/dialogs/dialog_waiting/dialog_waiting.dart';
import '../../../dialog/dialogs/dialogs_favourite/dialogs_favourite.dart';
import '../../controllers/APIS/api_product_item.dart';
import '../../controllers/page_main_screen_controller.dart';
import '../../controllers/product_item_controller.dart';
import '../../models/items/item_model.dart';
import '../../models/items/variants_model.dart';
import '../../utilities/global/app_global.dart';
import '../../utilities/style/colors.dart';
import '../../utilities/style/text_style.dart';
import '../../views/pages/home/main_screen/product_item_view.dart';
import '../custom_image.dart';
import '../lottie_widget.dart';
import '../snackBarWidgets/snack_bar_style.dart';
import '../snackBarWidgets/snackbar_widget.dart';
import '../widgets_carts/slidable_cart_widget.dart';

class WidgetFavouriteCard extends StatefulWidget {
  final int index;

  final FavouriteModel favouriteItem;
  final bool checkInCart;

  const WidgetFavouriteCard(
      {super.key,
      required this.index,
      required this.favouriteItem,
      required this.checkInCart});

  @override
  State<WidgetFavouriteCard> createState() => _WidgetFavouriteCardState();
}

AnalyticsService analyticsService = AnalyticsService();

class _WidgetFavouriteCardState extends State<WidgetFavouriteCard> {
  @override
  Widget build(BuildContext context) {
    ProductItemController productItemController =
        context.watch<ProductItemController>();
    PageMainScreenController pageMainScreenController =
        context.watch<PageMainScreenController>();

    ApiProductItemController apiProductItemController =
        context.watch<ApiProductItemController>();
    String rawTags = widget.favouriteItem.tags ?? "";
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
      id: widget.favouriteItem.productId,
      title: widget.favouriteItem.title,
      tags: tags,
      variants: [
        Variants(
            employee: "",
            oldPrice: "",
            newPrice: "",
            id: widget.favouriteItem.variantId,

            size: "${widget.favouriteItem.productId}",
            placeInWarehouse: "",
            quantity: "",
            nickname: "",
            season: "")
      ],
      vendorImagesLinks: [widget.favouriteItem.image ?? ""],
      newPrice: widget.favouriteItem.newPrice,
      oldPrice: widget.favouriteItem.oldPrice,
    );

    return InkWell(
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      overlayColor: WidgetStateColor.transparent,
      onTap: () async {
        await pageMainScreenController.changePositionScroll(
            widget.favouriteItem.productId.toString(), 0);
        await productItemController.clearItemsData();
        await apiProductItemController.resetRequests();
        NavigatorApp.push(ProductItemView(
          item: item,
          sizes: '',
        ));
      },
      child: SlidableCartWidget(
        index: widget.index,
        card: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.w),
            child: card(context, item)),
        onPressed: () async {
          await onPopDeleteFavouriteItem(
              productId: widget.favouriteItem.productId);
        },
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
            fontSize: size ?? 14.sp),
      ),
    );
  }

  Widget card(BuildContext context, Item item) {
    FavouriteController favouriteController =
        context.read<FavouriteController>();
    CartController cartController = context.watch<CartController>();
    FetchController fetchController = context.watch<FetchController>();
    ApiProductItemController apiProductItemController =
        context.watch<ApiProductItemController>();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
          // side: BorderSide(color: Colors.black,width: 0.0),

          borderRadius: BorderRadius.circular(10.r)),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Stack(
                      children: [
                        CustomImageSponsored(
                          imageUrl: widget.favouriteItem.image ?? "",
                          height: 100.h,
                          boxFit: BoxFit.fill,
                          borderCircle: 10.r,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        Visibility(
                          visible: widget.checkInCart,
                          child: Container(
                            width: double.maxFinite,
                            height: 100.h,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(169, 0, 0, 0),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "تم إضافته للسلة",
                                  style: CustomTextStyle().heading1L.copyWith(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Image.asset(
                                    Assets.images.inCart.path,
                                    height: 25.w,
                                    width: 25.w,
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    if (fetchController.showEven != 0)
                      LottieWidget(
                        name: (fetchController.showEven == 4)
                            ?
                            // "Ramadan Lantern"

                            Assets.lottie.eid
                            : Assets.lottie.blackFriday,
                        width: (fetchController.showEven == 4) ? 31.w : 40.w,
                        height: (fetchController.showEven == 4) ? 31.w : 40.w,
                      )
                  ],
                ),
              ),
              SizedBox(
                width: 5.w,
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          widget.favouriteItem.title ?? "",
                          textDirection: TextDirection.rtl,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: CustomTextStyle().heading1L.copyWith(
                              fontWeight: FontWeight.bold,
                              color: CustomColor.blueColor,
                              fontSize: 12.sp),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        text(
                            name: " ${widget.favouriteItem.newPrice}",
                            color: CustomColor.primaryColor),
                        Row(
                          children: [
                            Visibility(
                              visible: !widget.checkInCart,
                              child: IconSvg(
                                nameIcon: Assets.icons.cart,
                                backColor: Colors.transparent,
                                onPressed: () async {
                                  double priceValue = 0.0;
                                  try {
                                    priceValue = double.tryParse(widget
                                                .favouriteItem.newPrice
                                                ?.replaceAll("₪", "") ??
                                            "0") ??
                                        0.0;
                                  } catch (_) {}

                                  await analyticsService.logAddToCart(
                                    productId: widget.favouriteItem.productId
                                        .toString(),
                                    productTitle:
                                        widget.favouriteItem.title ?? "",
                                    price: priceValue,
                                    parameters: {
                                      "class_name": "WidgetFavouriteCard",
                                      "button_name": "cart_icon",
                                      "product_id": widget
                                          .favouriteItem.productId
                                          .toString(),
                                      "product_title":
                                          widget.favouriteItem.title ?? "",
                                      "time": DateTime.now().toString(),
                                    },
                                  );
                                  // printLog(widget.favouriteItem.productId);
                                  await apiProductItemController
                                      .resetRequests();
                                  dialogWaiting();

                                  await favouriteController.getItemData(item);

                                  if (favouriteController
                                          .item?.variants?[0].size ==
                                      "") {
                                    NavigatorApp.pop();

                                    await showSnackBar(
                                      title: "للأسف!، هذه المنتج لم تعد متوفرة",
                                      type: SnackBarType.warning,
                                    );
                                  } else {
                                    bool check =
                                        await cartController.checkCartItemById(
                                            productId:
                                                favouriteController.item!.id ??
                                                    0);

                                    if (check == true) {
                                      await showSnackBar(
                                        title:
                                            "تم إضافة المنتج من هذا الحجم مسبقا",
                                        type: SnackBarType.warning,
                                      );
                                      NavigatorApp.pop();
                                    } else {
                                      // printLog(favouriteController
                                      //     .item?.variants?[0].size);

                                      String hasOffer1 = "false";

                                      String offer =
                                          await fetchController.getOffer();

                                      for (var i
                                          in favouriteController.item?.tags ??
                                              []) {
                                        if (i.toString().trim().toString() ==
                                            offer
                                                .toString()
                                                .trim()
                                                .toString()) {
                                          hasOffer1 = "true";
                                        }
                                      }
                                      List<String> tags = (item.tags ?? []);

                                      await cartController.insertData(
                                          id:
                                              "${favouriteController.item?.id}000",
                                          variantId: favouriteController
                                              .item?.variants?[0].id,
                                          tags: '$tags',
                                          productId:
                                              favouriteController.item?.id,
                                          shopId: favouriteController
                                              .item?.shopId
                                              .toString(),
                                          employee: favouriteController
                                              .item?.variants?[0].employee
                                              .toString(),
                                          nickname: favouriteController
                                              .item?.variants?[0].nickname
                                              .toString(),
                                          placeInHouse: favouriteController.item
                                              ?.variants?[0].placeInWarehouse
                                              .toString(),
                                          sku: favouriteController.item?.sku
                                              .toString(),
                                          vendorSku: favouriteController
                                              .item?.vendorSku
                                              .toString(),
                                          image: favouriteController
                                              .item?.vendorImagesLinks![0],
                                          title:
                                              favouriteController.item?.title,
                                          oldPrice: favouriteController.item?.oldPrice.toString(),
                                          size: favouriteController.item?.variants?[0].size.toString(),
                                          quantity: 1,
                                          basicQuantity: favouriteController.item?.variants?[0].quantity,
                                          totalPrice: totalPrice1(favouriteController.item!.newPrice.toString(), 1),
                                          indexVariants: 0,
                                          newPrice: favouriteController.item?.newPrice,
                                          favourite: "true",
                                          hasOffer: hasOffer1);
                                      await showSnackBar(
                                          title: "تم أضافة المنتج في السلة",
                                          type: SnackBarType.success);
                                      NavigatorApp.pop();
                                      check = await cartController
                                          .checkCartItemById(
                                              productId: favouriteController
                                                      .item!.id ??
                                                  0);
                                    }
                                  }
                                },
                                heightIcon: 20.h,
                                colorFilter: ColorFilter.mode(
                                    Colors.black, BlendMode.srcIn),
                              ),
                            ),
                            InkWell(
                              overlayColor: WidgetStateColor.transparent,
                              highlightColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              onTap: () async {
                                await onPopDeleteFavouriteItem(
                                    productId: widget.favouriteItem.productId);
                              },
                              child: Icon(
                                CupertinoIcons.delete,
                                color: CustomColor.primaryColor,
                              ),
                            ),
                          ],
                        )
                      ],
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
}
