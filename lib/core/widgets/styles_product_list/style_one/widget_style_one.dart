import 'package:fawri_app_refactor/animation/animate_swipe_items.dart';
import 'package:fawri_app_refactor/controllers/favourite_controller.dart';
import 'package:fawri_app_refactor/core/widgets/custom_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../../../../models/products_view_config.dart';
import '../../../../controllers/page_main_screen_controller.dart';
import 'custom_images_style_one.dart';

class WidgetStyleOne extends StatefulWidget {
  final ProductsViewConfigModel config;

  const WidgetStyleOne({
    super.key,
    required this.config,
  });

  @override
  State<WidgetStyleOne> createState() => _WidgetStyleOneState();
}

class _WidgetStyleOneState extends State<WidgetStyleOne> {
  bool hasReachedIndex = false;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      scrollController.addListener(() async {
        PageMainScreenController pageMainScreenController =
            context.read<PageMainScreenController>();
        final itemWidth = 0.2.sw;

        final index25Offset =
            (((widget.config.listItems.length ~/ 28)) * 25) * itemWidth;

        if (scrollController.offset >= index25Offset && !hasReachedIndex) {
          hasReachedIndex = true;

          if (widget.config.scrollController ==
              pageMainScreenController.scrollControllerNewArrival) {
            await pageMainScreenController.getCachedProducts();
          } else if (widget.config.scrollController ==
              pageMainScreenController.scrollViewedItems) {
            await pageMainScreenController.getItemsViewed();
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
              pageMainScreenController.scrollControllerSection[widget.config.i]) {
            await pageMainScreenController.getSectionIndex(indexUrl: widget.config.i);
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
    FavouriteController favouriteController =
        context.watch<FavouriteController>();
    return Container(
      height: widget.config.effectiveHeight,
      color: widget.config.bgColor,
      child: AnimateSwipeItems(
        scrollController: scrollController,
        customWidget: (widget.config.listItems.isEmpty || widget.config.listItems == [])
            ? ListView.builder(
                itemCount: 10,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => ItemShim(
                  hasAnimatedBorder: widget.config.hasAnimatedBorder,
                  width: widget.config.effectiveWidth,
                ),
              )
            : AnimationLimiter(
                child: Row(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        shrinkWrap: true,
                        reverse: widget.config.reverse,
                        clipBehavior: Clip.none,
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.config.listItems.length,
                        itemBuilder: (context, int index) {
                          {
                            bool favourite =
                                favouriteController.checkFavouriteItemProductId(
                                    productId:
                                        widget.config.listItems[index].id!.toInt());
                            bool isFeature = (index) % 7 == 0;

                            return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 0),
                                child: ScaleAnimation(
                                    duration: Duration(milliseconds: 0),
                                    scale: 0.6,
                                    curve: Curves.linear,
                                    delay: Duration(milliseconds: 0),
                                    child: FadeInAnimation(
                                        child: CustomImagesStyleOne(
                                      isFavourite: favourite,
                                      hasAnimatedBorder:
                                          widget.config.hasAnimatedBorder,
                                      hasBellChristmas: widget.config.hasBellChristmas,
                                      isLoadingProduct: widget.config.isLoadingProduct,
                                      colorsGradient: widget.config.colorsGradient,
                                      i: widget.config.i,
                                      flag: widget.config.flag,
                                      item: widget.config.listItems[index],
                                      image: widget.config.listItems[index]
                                          .vendorImagesLinks![0],
                                      changeLoadingProduct:
                                          widget.config.changeLoadingProduct,
                                      width: widget.config.effectiveWidth,
                                      isFeature: isFeature,
                                    ))));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
        doSwipeAuto: widget.config.doSwipeAuto,
      ),
    );
  }
}
