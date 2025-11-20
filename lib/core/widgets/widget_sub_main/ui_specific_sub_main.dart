import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../../../controllers/favourite_controller.dart';
import '../../../controllers/page_main_screen_controller.dart';
import '../../../controllers/product_item_controller.dart';
import '../../../models/items/item_model.dart';
import '../../services/analytics/analytics_service.dart';
import '../../utilities/style/colors.dart';
import '../../utilities/style/text_style.dart';
import '../custom_image.dart';
import '../custom_text.dart';
import '../widgets_item_view/animation_tag_sub.dart';

class UiSpecificSubMain extends StatelessWidget {
  final bool favourite;
  final bool inCart;
  final int index;
  final Item item;

  const UiSpecificSubMain(
      {super.key,
      required this.favourite,
      required this.index,
      required this.inCart,
      required this.item});

  @override
  Widget build(BuildContext context) {
    AnalyticsService analyticsService = AnalyticsService();

    PageMainScreenController pageMainScreenController =
        context.watch<PageMainScreenController>();
    ProductItemController productItemController =
        context.watch<ProductItemController>();
    FavouriteController favouriteController =
        context.watch<FavouriteController>();
    return Container(
        margin: EdgeInsets.all(4.w),
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey, blurStyle: BlurStyle.outer, blurRadius: 5)
            ]),
        child: Column(
          children: [
            Expanded(
              child: ImageSlideshow(
                initialPage: 0,
                indicatorColor: mainColor,
                indicatorBackgroundColor: Colors.grey,
                // onPageChanged: (value) {},
                onPageChanged: (value) {
                  // printLog('Page changed to $value');
                },
                // autoPlayInterval:
                //     widget.item.vendorImagesLinks!.length == 1 ? 0 : 3000,
                isLoop: item.vendorImagesLinks!.length == 1 ? false : true,
                children: item.vendorImagesLinks!.map((url) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1.w),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomImageSponsored(
                                borderRadius: BorderRadius.circular(5.r),
                                borderCircle: 5.r,
                                boxFit: BoxFit.fill,
                                padding: EdgeInsets.only(bottom: 17.h),
                                imageUrl: url),
                            Visibility(
                              visible: inCart,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 17.h),
                                child: Container(
                                  width: double.maxFinite,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(169, 0, 0, 0),
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(5.r),
                                        topLeft: Radius.circular(5.r)),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "تم إضافته للسلة",
                                        style: CustomTextStyle()
                                            .heading1L
                                            .copyWith(
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
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: AnimationTagInSub(
                            item: item,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CustomText(
                                  fontSize: 8.sp,
                                  alignmentGeometry: Alignment.topRight,
                                  fontWeight: FontWeight.normal,
                                  text: item.oldPrice),
                              SizedBox(
                                height: 4.h,
                              ),
                              CustomText(
                                fontSize: 10.sp,
                                color: Colors.red,
                                alignmentGeometry: Alignment.topRight,
                                textDecoration: TextDecoration.none,
                                text: item.newPrice,
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Expanded(
                          child: InkWell(
                            overlayColor:
                                WidgetStatePropertyAll(Colors.transparent),
                            onTap: () async {
                              await analyticsService.logEvent(
                                eventName: "favourite_icon_click",
                                parameters: {
                                  "class_name": "UiSpecificSubMain",
                                  "button_name": "favourite_heart",
                                  "time": DateTime.now().toString(),
                                },
                              );

                              if (await favouriteController.checkFavouriteItem(
                                      productId: item.id) ==
                                  false) {
                                productItemController.flareControls
                                    .play("like");
                                await pageMainScreenController
                                    .changeIsFavourite(
                                        item.id.toString(), true);
                                List<String> tags = (item.tags ?? []);

                                await favouriteController.insertData(
                                  id: "${item.id}000",
                                  variantId: item.variants![0].id,
                                  productId: item.id,
                                  image: item.vendorImagesLinks![0],
                                  title: item.title,
                                  oldPrice: item.oldPrice.toString(),
                                  newPrice: item.newPrice,
                                  tags: '$tags',
                                );
                                Vibration.vibrate(duration: 100);

                                // await pageMainScreenController.changeIsFavourite(
                                //     widget.item.id.toString(),
                                //     !(pageMainScreenController
                                //         .isFavourite[widget.item.id.toString()])!);
                                await analyticsService.logAddToWishlist(
                                  productId: item.id?.toString() ?? "",
                                  productTitle: item.title ?? "",
                                  price: (double.tryParse(
                                          item.newPrice?.replaceAll("₪", "") ??
                                              "0") ??
                                      0.0),
                                  parameters: {
                                    "class_name": "UiSpecificSubMain",
                                    "button_name": "favourite_heart",
                                    "product_id": item.id?.toString() ?? "",
                                    "product_title": item.title ?? "",
                                    "price": (double.tryParse(item.newPrice
                                                    ?.replaceAll("₪", "") ??
                                                "0") ??
                                            0.0)
                                        .toString(),
                                    "time": DateTime.now().toString(),
                                  },
                                );
                              } else {
                                await favouriteController.deleteItem(
                                    productId: item.id);
                              }
                            },
                            child: Icon(FontAwesome.heart,
                                color: (favourite == false)
                                    ? Colors.grey
                                    : CustomColor.primaryColor),
                          ),
                        ),
                      ],
                    ),
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          item.title ?? "",
                          textDirection: TextDirection.rtl,

                          textAlign: TextAlign.right,
                          style: CustomTextStyle()
                              .heading1L
                              .copyWith(fontSize: 12.sp, color: Colors.black),
                          // textDecoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ));
  }
}
