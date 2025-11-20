import 'package:fawri_app_refactor/core/widgets/widget_orders/specific_description_item_in_order.dart';
import 'package:fawri_app_refactor/core/widgets/widget_orders/widget_text_grid.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glowy_borders/glowy_borders.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../controllers/APIS/api_product_item.dart';
import '../../../controllers/favourite_controller.dart';
import '../../../controllers/order_controller.dart';
import '../../../controllers/page_main_screen_controller.dart';
import '../../../controllers/product_item_controller.dart';
import '../../../models/items/item_model.dart';
import '../../../models/items/variants_model.dart';
import '../../../models/order/order_detail_model.dart';
import '../../../views/pages/orders/order_details.dart';
import '../../dialogs/dialogs_order/dialogs_order.dart';
import '../../services/analytics/analytics_service.dart';
import '../../helpers/changes.dart';
import '../../utilities/global/app_global.dart';
import '../../utilities/print_looger.dart';
import '../../utilities/style/colors.dart';
import '../../utilities/style/text_style.dart';

import '../custom_button.dart';
import '../custom_image.dart';
import '../lottie_widget.dart';
import '../snackBarWidgets/snack_bar_style.dart';
import '../snackBarWidgets/snackbar_widget.dart';
import '../widgets_item_view/button_done.dart';

class WidgetSpecificOrder extends StatefulWidget {
  final int index;
  final OrderDetailModel newestOrder;
  final String userId;

  const WidgetSpecificOrder(
      {super.key,
      required this.index,
      required this.newestOrder,
      required this.userId});

  @override
  State<WidgetSpecificOrder> createState() => _WidgetSpecificOrderState();
}

class _WidgetSpecificOrderState extends State<WidgetSpecificOrder> {
  @override
  Widget build(BuildContext context) {
    ProductItemController productItemController =
        context.watch<ProductItemController>();
    PageMainScreenController pageMainScreenController =
        context.watch<PageMainScreenController>();
    FavouriteController favouriteController =
        context.watch<FavouriteController>();
    OrderControllerSalah orderControllerSalah =
        context.watch<OrderControllerSalah>();
    ApiProductItemController apiProductItemController =
        context.watch<ApiProductItemController>();
    AnalyticsService analyticsService = AnalyticsService();

    return Padding(
      padding: EdgeInsets.only(right: 4.w),
      child: Row(
        children: [
          Text(
            "${widget.index + 1}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CustomTextStyle().heading1L.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                ),
          ),
          Expanded(
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 6.w),
              elevation: 0,
              color: Colors.white,
              child: Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  collapsedBackgroundColor:
                      (widget.newestOrder.isCancelled ?? false)
                          ? CustomColor.chrismasColor.withValues(alpha: 0.5)
                          : Colors.transparent,
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.r)),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    side: BorderSide(color: Colors.black, width: 0.1),
                  ),
                  collapsedIconColor: Colors.black,
                  tilePadding: EdgeInsets.symmetric(horizontal: 4.w),
                  backgroundColor: (widget.newestOrder.isCancelled ?? false)
                      ? CustomColor.chrismasColor.withValues(alpha: 0.4)
                      : Colors.transparent,
                  enabled: true,
                  clipBehavior: Clip.none,
                  iconColor: Colors.black,
                  leading: LottieWidget(
                    name: (widget.newestOrder.isCancelled ?? false)
                        ? Assets.lottie.cancelShopping
                        : Assets.lottie.order,
                    width: 35.w,
                    height: 35.w,
                  ),
                  trailing: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    child: Container(
                      clipBehavior: Clip.none,
                      // constraints: BoxConstraints(
                      //   minWidth: 100.w, // Minimum width for the trailing widget
                      //   maxWidth: 100.w, // Maximum width to control layout
                      // ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "عدد القطع : ${widget.newestOrder.listItemOrder?.length}",
                            textAlign: TextAlign.center,
                            style: CustomTextStyle().heading1L.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.sp,
                                ),
                          ),
                          SizedBox(height: 2.h),
                          // Add spacing between the elements
                          Text(
                            "${widget.newestOrder.totalPrice} ₪ ",
                            textAlign: TextAlign.center,
                            style: CustomTextStyle().heading1L.copyWith(
                                  color: CustomColor.chrismasColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                          ),
                          SizedBox(height: 2.h),
                          // Add spacing between the elements

                          Text(
                            widget.newestOrder.createdAt.toString(),
                            textAlign: TextAlign.center,
                            style: CustomTextStyle().heading1L.copyWith(
                                  color: CustomColor.blueColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9.sp,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  title: Text(
                    (widget.newestOrder.isCancelled ?? false)
                        ? "الطلب ملغى"
                        : "رقم تتبع الطلبية",
                    style: CustomTextStyle().heading1L.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
                  ),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 2.h,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            " # ${widget.newestOrder.orderId}",
                            style: CustomTextStyle().heading1L.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.sp,
                                ),
                          ),
                          SizedBox(
                            width: 5.w,
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 2.h),
                            child: Tooltip(
                                onTriggered: () {
                                  Clipboard.setData(ClipboardData(
                                      text: widget.newestOrder.orderId
                                          .toString()));

                                  showSnackBar(
                                      title: 'تم النسخ بنجاح!',
                                      type: SnackBarType.success);
                                },
                                triggerMode: TooltipTriggerMode.tap,
                                message: widget.newestOrder.orderId.toString(),
                                padding: EdgeInsets.zero,
                                child: IconSvgPicture(
                                  nameIcon: Assets.icons.copy,
                                  heightIcon: 16.h,
                                  colorFilter: ColorFilter.mode(
                                      Colors.black, BlendMode.srcIn),
                                )),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Text(
                        "اضغط لمشاهدة التفاصيل",
                        style: CustomTextStyle().heading1L.copyWith(
                              color: CustomColor.blueColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 9.sp,
                            ),
                      ),
                    ],
                  ),
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height:
                              (widget.newestOrder.listItemOrder?.length == 1)
                                  ? 0.18.sh
                                  : (widget.newestOrder.listItemOrder!.isEmpty)?0.h:0.4.sh,
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: widget.newestOrder.listItemOrder!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(right: 4.w),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      intToRoman(index + 1),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          CustomTextStyle().heading1L.copyWith(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11.sp,
                                              ),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        hoverColor: Colors.transparent,
                                        onTap: () async {
                                          String priceString = widget
                                              .newestOrder
                                              .listItemOrder![index]
                                              .price;
                                          String cleanedPriceString =
                                              priceString
                                                  .replaceAll('₪', '')
                                                  .trim();
                                          double price = double.tryParse(
                                                  cleanedPriceString) ??
                                              0.0;
                                          double old = price * 2.5;
                                          double newPrice = price;
                                          String oldString =
                                              old.toStringAsFixed(2);
                                          String newString =
                                              newPrice.toStringAsFixed(2);

                                          printLog("oldString${int.tryParse(widget.newestOrder
                                              .listItemOrder![index].id)}");
                                          printLog("newString${(widget.newestOrder
                                              ).toString()}");

                                          Item item = Item(
                                            id: int.tryParse(widget.newestOrder
                                                .listItemOrder![index].id),
                                            variants: [
                                              Variants(
                                                  employee: "",
                                                  oldPrice: "",
                                                  newPrice: "",
                                                  id: int.tryParse(widget
                                                      .newestOrder
                                                      .listItemOrder![index]
                                                      .id),
                                                  size: widget.newestOrder
                                                      .listItemOrder![index].id
                                                      .toString(),
                                                  placeInWarehouse: "",
                                                  quantity: "",
                                                  nickname: "",
                                                  season: "")
                                            ],
                                            oldPrice: "$oldString ₪",
                                            newPrice: "$newString ₪",
                                            sku: widget.newestOrder
                                                .listItemOrder![index].sku
                                                .toString(),
                                            title: widget.newestOrder
                                                .listItemOrder![index].name,
                                            vendorImagesLinks: [
                                              widget.newestOrder
                                                  .listItemOrder![index].image
                                                  .toString()
                                            ],
                                          );


                                          await pageMainScreenController
                                              .changePositionScroll(
                                                  item.id.toString(), 0);
                                          await productItemController
                                              .clearItemsData();
                                          await apiProductItemController
                                              .cancelRequests();
                                          bool favourite = favouriteController
                                              .checkFavouriteItemProductId(
                                                  productId: int.tryParse(widget
                                                      .newestOrder
                                                      .listItemOrder![index]
                                                      .id));
                                          NavigatorApp.push(
                                              SpecificDescriptionItemInOrder(
                                            item: item,
                                            indexVariants: widget
                                                .newestOrder
                                                .listItemOrder![index]
                                                .variantIndex,
                                            isFavourite: favourite,
                                            specificOrder: widget.newestOrder
                                                .listItemOrder![index],
                                          ));
                                        },
                                        child: Card(
                                          color: Colors.black12,
                                          elevation: 0,
                                          // Remove elevation to prevent constant recalculations
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.r)),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 3.w,
                                                right: 3.w,
                                                top: 3.w),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                SizedBox(
                                                  height: 135.w,
                                                  width: double.maxFinite,
                                                  child: IntrinsicHeight(
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                      children: [
                                                        // Image with animated border
                                                        Expanded(
                                                          flex: 3,
                                                          child:
                                                              AnimatedGradientBorder(
                                                            gradientColors: [
                                                              CustomColor
                                                                  .chrismasColor,
                                                              CustomColor
                                                                  .blueColor
                                                            ],
                                                            borderSize: 0.5,
                                                            glowSize: 2.h,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.r),
                                                            child:
                                                                CustomImageSponsored(
                                                              imageUrl: widget
                                                                  .newestOrder
                                                                  .listItemOrder![
                                                                      index]
                                                                  .image,
                                                              boxFit:
                                                                  BoxFit.cover,
                                                              borderCircle:
                                                                  10.r,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.r),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 5.w),
                                                        // Product details
                                                        Expanded(
                                                          flex: 5,
                                                          child: Column(
                                                            children: [
                                                              Expanded(
                                                                flex: 1,
                                                                child:
                                                                    SingleChildScrollView(
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            top:
                                                                                5.h),
                                                                    child: Text(
                                                                      widget
                                                                          .newestOrder
                                                                          .listItemOrder![
                                                                              index]
                                                                          .name,
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: CustomTextStyle().heading1L.copyWith(
                                                                          color: CustomColor
                                                                              .blueColor,
                                                                          fontSize:
                                                                              12.sp),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 5.h,
                                                              ),
                                                              Expanded(
                                                                flex: 2,
                                                                child: GridView(
                                                                  scrollDirection:
                                                                      Axis.vertical,
                                                                  physics:
                                                                      BouncingScrollPhysics(),
                                                                  shrinkWrap:
                                                                      true,
                                                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                                      crossAxisCount:
                                                                          2,
                                                                      childAspectRatio:
                                                                          2.h),
                                                                  children: [
                                                                    WidgetTextGrid(
                                                                        title:
                                                                            "SKU",
                                                                        subtitle: widget
                                                                            .newestOrder
                                                                            .listItemOrder![index]
                                                                            .sku),
                                                                    WidgetTextGrid(
                                                                        title:
                                                                            "الحجم",
                                                                        subtitle: widget
                                                                            .newestOrder
                                                                            .listItemOrder![index]
                                                                            .size),
                                                                    WidgetTextGrid(
                                                                        title:
                                                                            "السعر",
                                                                        subtitle: widget
                                                                            .newestOrder
                                                                            .listItemOrder![index]
                                                                            .price),
                                                                    WidgetTextGrid(
                                                                        title:
                                                                            "الكمية",
                                                                        subtitle: widget
                                                                            .newestOrder
                                                                            .listItemOrder![index]
                                                                            .quantity
                                                                            .toString()),
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 2.h),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 5.h),
                          ),
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        Container(
                          width: double.maxFinite,
                          margin: EdgeInsets.all(4.w),
                          child: (widget.newestOrder.isCancelled ?? false)
                              ? SizedBox()
                              : (orderControllerSalah.pageOrder == 0)
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                          Expanded(
                                            child: ButtonDone(
                                              text: 'تتبع الطلب',
                                              iconName: Assets.icons.check,
                                              fontSize: 11.sp,
                                              heightIcon: 20.h,
                                              widthIconInStartEnd: 20.w,
                                              heightIconInStartEnd: 20.w,
                                              borderRadius: 10.r,
                                              height: 27.h,
                                              haveBouncingWidget: false,
                                              onPressed: () async {
                                                await analyticsService.logEvent(
                                                  eventName:
                                                      "track_order_button_click",
                                                  parameters: {
                                                    "class_name":
                                                        "WidgetSpecificOrder",
                                                    "button_name":
                                                        " تتبع الطلب",
                                                    "order_id": widget
                                                        .newestOrder.orderId
                                                        .toString(),
                                                    "user_id": widget.userId,
                                                    "time": DateTime.now()
                                                        .toString(),
                                                  },
                                                );

                                                NavigatorApp.push(OrderDetails(
                                                  newestOrder:
                                                      widget.newestOrder,
                                                  done: false,
                                                ));
                                              },
                                            ),
                                          ),
                                          SizedBox(
                                            width: 40.w,
                                          ),
                                          Expanded(
                                            child: ButtonDone(
                                              text: 'إلغاء الطلب',
                                              borderRadius: 10.r,
                                              fontSize: 11.sp,
                                              heightIcon: 20.h,
                                              widthIconInStartEnd: 20.w,
                                              heightIconInStartEnd: 20.w,
                                              height: 27.h,
                                              haveBouncingWidget: false,
                                              backColor:
                                                  CustomColor.chrismasColor,
                                              iconName: Assets.icons.cancel,
                                              onPressed: () async {
                                                SharedPreferences prefs =
                                                    await SharedPreferences
                                                        .getInstance();

                                                String phone =
                                                    prefs.getString('phone') ??
                                                        "";
                                                double totalDiscount = 0;
                                                for (var item in widget
                                                    .newestOrder
                                                    .listItemOrder!) {
                                                  totalDiscount += (double
                                                          .parse(item.price
                                                              .replaceAll(
                                                                  "₪", "")
                                                              .trim()
                                                              .toString()) *
                                                      item.quantity.toInt());
                                                }
                                                // printLog(
                                                //     "total discount: $totalDiscount");

                                                await orderControllerSalah
                                                    .setDiscountAfterDelete(
                                                  widget.newestOrder.orderId
                                                      .toString(),
                                                  totalDiscount.toInt(),
                                                );

                                                showCancelOrderDialog(
                                                    phone: phone,
                                                    totalDiscountAfterDelete:
                                                        orderControllerSalah
                                                                    .totalDiscountAfterDelete[
                                                                widget
                                                                    .newestOrder
                                                                    .orderId
                                                                    .toString()] ??
                                                            0,
                                                    orderId: int.parse(widget
                                                        .newestOrder.orderId
                                                        .toString()),
                                                    userId: widget.userId);
                                              },
                                            ),
                                          ),
                                        ])
                                  : SizedBox(),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
