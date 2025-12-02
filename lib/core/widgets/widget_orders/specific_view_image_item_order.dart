import 'package:dots_indicator/dots_indicator.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../utilities/vibration_helper.dart';
import '../../../controllers/favourite_controller.dart';
import '../../../controllers/fetch_controller.dart';
import '../../../controllers/page_main_screen_controller.dart';
import '../../../controllers/product_item_controller.dart';
import '../../../models/items/item_model.dart';
import '../widgets_item_view/animation_tags.dart';
import '../widgets_item_view/favourite.dart';
import '../widgets_item_view/slider_images_view.dart';

class SpecificViewImageItemOrder extends StatefulWidget {
  final Item item;
  final int indexVariants;
  final bool favourite;
  const SpecificViewImageItemOrder(
      {super.key,
      required this.item,
      required this.indexVariants,
      required this.favourite});

  @override
  State<SpecificViewImageItemOrder> createState() =>
      _SpecificViewImageItemOrderState();
}

class _SpecificViewImageItemOrderState
    extends State<SpecificViewImageItemOrder> {
  @override
  Widget build(BuildContext context) {
    PageMainScreenController pageMainScreenController =
        context.watch<PageMainScreenController>();

    ProductItemController productItemController =
        context.watch<ProductItemController>();

    FavouriteController favouriteController =
        context.watch<FavouriteController>();
    FetchController fetchController = context.watch<FetchController>();
    return Container(
      color: Colors.transparent,
      height: 0.55.sh,
      width: double.maxFinite,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          InkWell(
            onDoubleTap: () async {
              // Trigger vibration
              await VibrationHelper.vibrate(duration: 100);

              if (await favouriteController.checkFavouriteItem(
                      productId: widget.item.id) ==
                  true) {
                productItemController.flareControls.play("like");
              } else {
                productItemController.flareControls.play("like");
                List<String> tags = (widget.item.tags ?? []);

                await favouriteController.insertData(
                  id: "${widget.item.id}000",
                  variantId:
                  widget.item.variants![0].id,
                  productId: widget.item.id,
                  image: widget.item.vendorImagesLinks![0],
                  title: widget.item.title,
                  oldPrice: widget.item.oldPrice.toString(),
                  newPrice: widget.item.newPrice,
                  tags: '$tags',
                );
              }
            },
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    SliderImagesView(
                      id: widget.item.id.toString(),
                      videoUrl: widget.item.videoUrl,
                      images: widget.item.vendorImagesLinks ?? [],
                      onPageChange: (index, reason) async {
                        await pageMainScreenController.changePositionScroll(
                            widget.item.id.toString(), index.toDouble());
                      },
                    ),
                    FavouriteIconDouble(),
                    SizedBox(
                      height: double.maxFinite,
                      width: double.maxFinite,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Visibility(
                                visible:
                                    widget.item.vendorImagesLinks?.length == 1
                                        ? false
                                        : true,
                                child: DotsIndicator(
                                  onTap: (position) async {},
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  position:
                                      pageMainScreenController.positionScroll[
                                              widget.item.id.toString()] ??
                                          0,
                                  dotsCount: widget
                                          .item.vendorImagesLinks!.isEmpty
                                      ? 0
                                      : widget.item.vendorImagesLinks!.length,
                                  axis: Axis.vertical,
                                  decorator: DotsDecorator(
                                    size: Size.square(7.r),
                                    activeSize: Size(12.w, 12.w),
                                    activeShape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.r),
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
                if (fetchController.showEven == 1)
                  IgnorePointer(
                      ignoring: true,
                      child: Image.asset(
                        Assets.images.salah.path,
                        width: 170.w,
                        height: 170.w,
                      ))
              ],
            ),
          ),
          if (widget.item.tags != null)
            AnimationTags(
              item: widget.item,
            )
        ],
      ),
    );
  }

  Widget flashIcon() {
    return SizedBox(
      width: 15.w,
      height: 15.w,
      child: Lottie.asset(
        Assets.lottie.animation1729073541927,
        height: 40.h,
        reverse: true,
        repeat: true,
        fit: BoxFit.cover,
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
