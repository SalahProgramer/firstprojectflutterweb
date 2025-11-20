// import 'package:add_to_cart_animation/add_to_cart_animation.dart';
// import 'package:dots_indicator/dots_indicator.dart';
// import 'package:fawri_app_refactor/salah/controllers/fetch_controller.dart';
// import 'package:fawri_app_refactor/salah/controllers/page_main_screen_controller.dart';
// import 'package:fawri_app_refactor/salah/controllers/product_item_controller.dart';
// import 'package:fawri_app_refactor/salah/widgets/widgets_item_view/quantity_view.dart';
//
// import 'package:fawri_app_refactor/salah/widgets/widgets_item_view/slider_images_view.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:lottie/lottie.dart';
// import 'package:provider/provider.dart';
// import 'package:vibration/vibration.dart';
// import '../../localDataBase/controllers/favourite_controller.dart';
// import '../../models/items/item_model.dart';
// import 'animation_tags.dart';
// import 'description_specafic_item.dart';
// import 'favourite.dart';
//
// class SliderViewImagesSpesaficItem extends StatefulWidget {
//   final Item item;
//   final int indexVariants;
//   final bool favourite;
//   final bool isFeature;
//   late  Function(GlobalKey) runAddToCartAnimation;
//   final GlobalKey<CartIconKey> cartKey;
//   final GlobalKey widgetKey;
//
//    SliderViewImagesSpesaficItem(
//       {super.key,
//       required this.item,
//       required this.indexVariants,
//       required this.favourite,
//       required this.cartKey,
//       required this.isFeature,
//       required this.runAddToCartAnimation,
//       required this.widgetKey});
//
//   @override
//   State<SliderViewImagesSpesaficItem> createState() =>
//       _SliderViewImagesSpesaficItemState();
// }
//
// class _SliderViewImagesSpesaficItemState
//     extends State<SliderViewImagesSpesaficItem> {
//   GlobalKey widgetKey = GlobalKey();
//
//   GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
//   late Function(GlobalKey) runAddToCartAnimation;
//   @override
//   Widget build(BuildContext context) {
//     PageMainScreenController pageMainScreenController =
//         context.watch<PageMainScreenController>();
//
//     ProductItemController productItemController =
//         context.watch<ProductItemController>();
//
//     FavouriteController favouriteController =
//         context.watch<FavouriteController>();
//     FetchController fetchController = context.watch<FetchController>();
//     return Stack(
//       children: [
//         AddToCartAnimation(
//           cartKey: widget.cartKey,
//           dragAnimation: const DragToCartAnimationOptions(rotation: true),
//           createAddToCartAnimation: (runAddToCart) {
//             widget.runAddToCartAnimation = runAddToCart;
//           },
//           height: 40.w,
//           width: 20.h,
//           opacity: 0.99,
//           jumpAnimation:
//               const JumpAnimationOptions(duration: Duration(microseconds: 200)),
//           child: Stack(
//             alignment: Alignment.center,
//             clipBehavior: Clip.none,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Container(
//                     color: Colors.transparent,
//                     height: 0.55.sh,
//                     width: double.maxFinite,
//                     key: widget.widgetKey,
//                     child: Stack(
//                       alignment: Alignment.bottomLeft,
//                       children: [
//                         InkWell(
//                           onDoubleTap: () async {
//                             // Trigger vibration
//                             Vibration.vibrate(duration: 100);
//
//                             if (await favouriteController.checkFavouriteItem(
//                                     productId: widget.item.id) ==
//                                 true) {
//                               productItemController.flareControls.play("like");
//                             } else {
//                               productItemController.flareControls.play("like");
//
//                               await favouriteController.insertData(
//                                 id: "${widget.item.id}000",
//                                 productId: widget.item.id,
//                                 image: widget.item.vendorImagesLinks![0],
//                                 title: widget.item.title,
//                                 oldPrice: widget.item.oldPrice.toString(),
//                                 newPrice: widget.item.newPrice,
//                               );
//                             }
//                           },
//                           child: Stack(
//                             alignment: Alignment.topLeft,
//                             children: [
//                               Stack(
//                                 alignment: Alignment.center,
//                                 clipBehavior: Clip.none,
//                                 children: [
//                                   SliderImagesView(
//                                     id: widget.item.id.toString(),
//                                     images: widget.item.vendorImagesLinks ?? [],
//                                     onPageChange: (index, reason) async {
//                                       await pageMainScreenController
//                                           .changePositionScroll(
//                                               widget.item.id.toString(), index);
//                                     },
//                                   ),
//                                   FavouriteIconDouble(),
//                                   SizedBox(
//                                     height: double.maxFinite,
//                                     width: double.maxFinite,
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Column(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             Visibility(
//                                               visible: widget
//                                                           .item
//                                                           .vendorImagesLinks
//                                                           ?.length ==
//                                                       1
//                                                   ? false
//                                                   : true,
//                                               child: DotsIndicator(
//                                                 onTap: (position) async {},
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 position:
//                                                     pageMainScreenController
//                                                                 .positionScroll[
//                                                             widget.item.id
//                                                                 .toString()] ??
//                                                         0,
//                                                 dotsCount: widget
//                                                         .item
//                                                         .vendorImagesLinks!
//                                                         .isEmpty
//                                                     ? 0
//                                                     : widget
//                                                         .item
//                                                         .vendorImagesLinks!
//                                                         .length,
//                                                 axis: Axis.vertical,
//                                                 decorator: DotsDecorator(
//                                                   size: Size.square(7.r),
//                                                   activeSize: Size(12.w, 12.w),
//                                                   activeShape:
//                                                       RoundedRectangleBorder(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             5.r),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               if (fetchController.showEven == 1)
//                                 IgnorePointer(
//                                     ignoring: true,
//                                     child: Image.asset(
//                                       "assets/images/salah.gif",
//                                       width: 170.w,
//                                       height: 170.w,
//                                     ))
//                             ],
//                           ),
//                         ),
//                         if (widget.item.tags != null)
//                           AnimationTags(
//                             item: widget.item,
//                           )
//                       ],
//                     ),
//                   ),
//                   SizedBox(
//                     height: 5.h,
//                   ),
//                   DescriptionSpecaficItem(
//                     item: widget.item,
//                     isFeature: widget.isFeature,
//                     favourite: widget.favourite,
//                     indexVariants: widget.indexVariants,
//                   ),
//                   SizedBox(
//                     height: 10.h,
//                   ),
//                   QuantityView(
//                     item: widget.item,
//                   ),
//                   SizedBox(
//                     height: 10.h,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         if ((widget.item.variants?[0].size == ""))
//           Container(
//             color: Colors.black.withValues(alpha: 0.7),
//             height: 1.sh,
//             alignment: Alignment.center,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Lottie.asset(
//                     "assets/lottie_animations/Animation - 1726740976006.json",
//                     height: 120.h,
//                     reverse: true,
//                     repeat: true,
//                     fit: BoxFit.cover),
//                 SizedBox(
//                   height: 20.h,
//                 ),
//                 Text(
//                   'عذرا لم يعد متوفر كمية من هذا المنتج يمكنك التمرير لمشاهدة المنتجات الشبيهة',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget flashIcon() {
//     return SizedBox(
//       width: 15.w,
//       height: 15.w,
//       child: Lottie.asset(
//         "assets/lottie_animations/Animation - 1729073541927.json",
//         height: 40.h,
//         reverse: true,
//         repeat: true,
//         fit: BoxFit.cover,
//       ),
//     );
//   }
//
//   String totalPrice1(String price, int quantity) {
//     double total;
//
//     String cleaned = price.replaceAll('₪', '');
//     double value = double.parse(cleaned);
//     total = value * quantity;
//     String f = total.toStringAsFixed(2);
//     total = double.parse(f);
//     return "$total ₪";
//   }
// }
