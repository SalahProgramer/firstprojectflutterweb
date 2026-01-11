import 'package:fawri_app_refactor/salah/animation/animate_swipe_items.dart';
import 'package:fawri_app_refactor/salah/controllers/favourite_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../../../controllers/page_main_screen_controller.dart';
import '../../../models/products_view_config.dart';
import 'custom_images_style_two.dart';
import 'item_shimmer_style_two.dart';

class WidgetStyleTwo extends StatefulWidget {
  final ProductsViewConfigModel config;

  const WidgetStyleTwo({super.key, required this.config});

  @override
  State<WidgetStyleTwo> createState() => _WidgetStyleTwoState();
}

class _WidgetStyleTwoState extends State<WidgetStyleTwo> {
  bool hasReachedIndex = false;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      scrollController.addListener(() async {
        PageMainScreenController pageMainScreenController = context
            .read<PageMainScreenController>();
        final itemWidth = 0.2.sw; // Adjust based on your item width
        final index25Offset =
            (((widget.config.listItems.length ~/ 25)) * 20) * itemWidth;

        if (scrollController.offset >= index25Offset && !hasReachedIndex) {
          hasReachedIndex = true;

          if (widget.config.scrollController ==
              pageMainScreenController.scrollControllerNewArrival) {
            await pageMainScreenController.getCachedProducts();
          } else if (widget.config.scrollController ==
              pageMainScreenController.scrollRecommendedItems) {
            await pageMainScreenController.fetchRecommendedItems();
          } else if (widget.config.scrollController ==
              pageMainScreenController.scrollHomeItems) {
            await pageMainScreenController.getHomeData();
          } else if (widget.config.scrollController ==
              pageMainScreenController.scrollFlashItems) {
            await pageMainScreenController.getFlashItems();
          } else if (widget.config.scrollController ==
              pageMainScreenController.scrollControllerFeatures) {
            await pageMainScreenController.getFeatureProducts();
          } else if (widget.config.scrollController ==
              pageMainScreenController.scrollControllerSection[widget
                  .config
                  .i]) {
            await pageMainScreenController.getSectionIndex(
              indexUrl: widget.config.i,
            );
          }
          hasReachedIndex = false;
        }
      });
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FavouriteController favouriteController = context
        .watch<FavouriteController>();
    return Container(
      height: widget.config.effectiveHeight,
      color: widget.config.bgColor,
      child: AnimateSwipeItems(
        scrollController: scrollController,
        customWidget:
            (widget.config.listItems.isEmpty || widget.config.listItems == [])
            ? GridView.builder(
                controller: scrollController,
                shrinkWrap: true,
                reverse: widget.config.reverse,
                clipBehavior: Clip.none,
                scrollDirection: Axis.horizontal,
                itemCount: 12,
                physics: BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // ✅ 2 items per row
                  mainAxisExtent: 160.w, // ✅ Ensures 2 rows per slide
                  mainAxisSpacing: 5.w,
                  // ✅ Ensures proper item shape
                ),
                itemBuilder: (context, int index) {
                  return ItemShimmerStyleTwo(
                    hasAnimatedBorder: widget.config.hasAnimatedBorder,
                    width: widget.config.effectiveWidth,
                  );
                },
              )
            : AnimationLimiter(
                child: GridView.builder(
                  controller: scrollController,
                  shrinkWrap: true,
                  reverse: widget.config.reverse,
                  clipBehavior: Clip.none,
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.config.listItems.length,
                  physics: BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // ✅ 2 items per row
                    mainAxisExtent: 160.w, // ✅ Ensures 2 rows per slide
                    mainAxisSpacing: 5.w,
                    // ✅ Ensures proper item shape
                  ),
                  itemBuilder: (context, int index) {
                    bool isFeature = (index) % 7 == 0;
                    bool favourite = favouriteController
                        .checkFavouriteItemProductId(
                          productId: widget.config.listItems[index].id!.toInt(),
                        );
                    // printLog(
                    //     "favourite:  ${widget.listItems[index].id}   $favourite");

                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      columnCount: 2,
                      duration: const Duration(milliseconds: 300),
                      child: ScaleAnimation(
                        scale: 1,
                        curve: Curves.easeInOut,
                        child: FadeInAnimation(
                          child: CustomImagesStyleTwo(
                            hasAnimatedBorder: widget.config.hasAnimatedBorder,
                            hasBellChristmas: widget.config.hasBellChristmas,
                            isLoadingProduct: widget.config.isLoadingProduct,
                            colorsGradient: widget.config.colorsGradient,
                            i: widget.config.i,
                            flag: widget.config.flag,
                            item: widget.config.listItems[index],
                            isFavourite: favourite,
                            image: widget
                                .config
                                .listItems[index]
                                .vendorImagesLinks![0],
                            changeLoadingProduct:
                                widget.config.changeLoadingProduct,
                            width: widget.config.effectiveWidth,
                            isFeature: isFeature,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
        doSwipeAuto: widget.config.doSwipeAuto,
      ),
    );
  }
}
