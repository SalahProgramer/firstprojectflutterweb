import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../controllers/APIS/api_product_item.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/favourite_controller.dart';
import '../../../controllers/fetch_controller.dart';
import '../../../models/items/item_model.dart';
import '../../../models/items/variants_model.dart';
import '../../dialogs/dialog_waiting/dialog_waiting.dart';
import '../../services/analytics/analytics_service.dart';
import '../../utilities/global/app_global.dart';
import '../../utilities/style/colors.dart';
import '../../utilities/style/text_style.dart';
import '../custom_button.dart';
import '../custom_image.dart';
import '../snackBarWidgets/snack_bar_style.dart';
import '../snackBarWidgets/snackbar_widget.dart';

class WidgetEachAddToTawsselFree extends StatefulWidget {
  final Item? item;
  final int index;
  final int remainder;
  final bool checkInCart;

  const WidgetEachAddToTawsselFree(
      {super.key,
      this.item,
      required this.index,
      required this.checkInCart,
      required this.remainder});

  @override
  State<WidgetEachAddToTawsselFree> createState() =>
      _WidgetEachAddToTawsselFreeState();
}

class _WidgetEachAddToTawsselFreeState
    extends State<WidgetEachAddToTawsselFree> {
  @override
  Widget build(BuildContext context) {
    AnalyticsService analyticsService = AnalyticsService();

    CartController cartController = context.watch<CartController>();
    FetchController fetchController = context.watch<FetchController>();

    FavouriteController favouriteController =
        context.watch<FavouriteController>();
    ApiProductItemController apiProductItemController =
        context.watch<ApiProductItemController>();
    Item itemSelected = Item(
      id: widget.item?.id,
      title: widget.item?.title,
      variants: [
        Variants(
            employee: "",
            oldPrice: "",
            newPrice: "",
            id: widget.item?.variants?[0].id,
            size: "${widget.item?.id}",
            placeInWarehouse: "",
            quantity: "",
            nickname: "",
            season: "")
      ],
      vendorImagesLinks: [widget.item?.vendorImagesLinks?[0] ?? ""],
      newPrice: widget.item?.newPrice,
      oldPrice: widget.item?.oldPrice,
    );
    return Container(
      width: 160.w,
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Card(
        elevation: 20,
        shadowColor: CustomColor.blueColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        child: Padding(
          padding:
              EdgeInsets.only(top: 2.h, bottom: 2.h, right: 5.w, left: 3.w),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      CustomImageSponsored(
                        imageUrl: widget.item?.vendorImagesLinks?[0] ?? "",
                        boxFit: BoxFit.fill,
                        borderCircle: 10.r,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      Visibility(
                        visible: widget.checkInCart,
                        child: Container(
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [Colors.black, Colors.black12],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter),
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
                ),
                SizedBox(
                  height: 5.h,
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Flexible(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            widget.item?.title ?? "",
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
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  text(name: "السعر : ", color: Colors.black),
                                  text(
                                      name:
                                          "${((widget.item?.newPrice.toString()))}",
                                      color: Colors.green),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Visibility(
                                visible: !widget.checkInCart,
                                child: IconSvg(
                                  nameIcon: Assets.icons.cart,
                                  backColor: Colors.transparent,
                                  onPressed: () async {
                                    await analyticsService.logEvent(
                                      eventName: "add_to_cart_tawssel_free",
                                      parameters: {
                                        "class_name":
                                            "WidgetEachAddToTawsselFree",
                                        "button_name":
                                            "cart_icon pressed free shipping",
                                        "product_id":
                                            widget.item?.id?.toString() ?? "",
                                        "product_title":
                                            widget.item?.title ?? "",
                                        "time": DateTime.now().toString(),
                                      },
                                    );
                                    // printLog(widget.item?.id);
                                    await apiProductItemController
                                        .resetRequests();
                                    dialogWaiting();

                                    await favouriteController
                                        .getItemData(itemSelected);

                                    if (favouriteController.item == null) {
                                    } else {
                                      bool check = await cartController
                                          .checkCartItemById(
                                              productId: favouriteController
                                                      .item!.id ??
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

                                        cartController.itemsWillAddToCart.add(
                                            "${favouriteController.item?.id}000");
                                        String price = (widget.item!.newPrice
                                            .toString()
                                            .replaceAll("₪", "")
                                            .trim()
                                            .toString());
                                        double price1 = double.parse(price);
                                        await cartController
                                            .calculateItemOfferTawseel(
                                                widget.remainder,
                                                price1.toInt());

                                        await cartController.insertDataToAddCartAfter(
                                            id:
                                                "${favouriteController.item?.id}000",

                                            variantId: favouriteController
                                                .item?.variants?[0].id,
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
                                            placeInHouse: favouriteController
                                                .item
                                                ?.variants?[0]
                                                .placeInWarehouse
                                                .toString(),
                                            sku: favouriteController.item?.sku
                                                .toString(),
                                            vendorSku: favouriteController
                                                .item?.vendorSku
                                                .toString(),
                                            image: favouriteController
                                                .item?.vendorImagesLinks![0],
                                            title: favouriteController.item?.title,
                                            oldPrice: favouriteController.item?.oldPrice.toString(),
                                            size: favouriteController.item?.variants?[0].size.toString(),
                                            quantity: 1,
                                            basicQuantity: favouriteController.item?.variants?[0].quantity,
                                            totalPrice: totalPrice1(favouriteController.item!.newPrice.toString(), 1),
                                            indexVariants: 0,
                                            newPrice: favouriteController.item?.newPrice,
                                            favourite: "true",
                                            hasOffer: hasOffer1);
                                        NavigatorApp.pop();
                                      }
                                    }
                                  },
                                  heightIcon: 20.h,
                                  colorFilter: ColorFilter.mode(
                                      Colors.black, BlendMode.srcIn),
                                ),
                              ),
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
            fontSize: size ?? 12.sp),
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
