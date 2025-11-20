import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/favourite_controller.dart';
import '../../../../controllers/page_main_screen_controller.dart';
import '../../../../models/products_view_config.dart';
import '../../../utilities/print_looger.dart';
import 'custom_images_style_four.dart';
import 'item_shimmer_style_four.dart';

class WidgetStyleFour extends StatefulWidget {
  final ProductsViewConfigModel config;

  const WidgetStyleFour({
    super.key,
    required this.config,
  });

  @override
  State<WidgetStyleFour> createState() => _WidgetStyleFourState();
}

class _WidgetStyleFourState extends State<WidgetStyleFour> {
  SwiperController swiperController = SwiperController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    FavouriteController favouriteController =
        context.watch<FavouriteController>();
    PageMainScreenController pageMainScreenController =
        context.watch<PageMainScreenController>();
    return Container(
      height: widget.config.effectiveHeight,
      color: widget.config.bgColor,
      child: (widget.config.listItems.isEmpty || widget.config.listItems == [])
          ? AnimationLimiter(
              child: Row(
                children: [
                  Expanded(
                    child: Swiper(
                      index: 0,
                      itemCount: 10,
                      autoplay: true,
                      autoplayDelay: 600,

                      itemHeight:
                          widget.config.effectiveHeight, // ✅ Ensure height is not null
                      itemWidth:
                          widget.config.effectiveWidth, // ✅ Ensure width is not null
                      duration: 600, // ✅ Smooth transition speed
                      autoplayDisableOnInteraction:
                          true, // ✅ Keep autoplay running after user interaction
                      fade: 0.7, // ✅ Smooth fade effect
                      scale: 0.8, // ✅ Better stack visibility
                      viewportFraction: 0.7, // ✅ Proper spacing
                      loop: false, // ✅ Enable infinite looping
                      scrollDirection: Axis.horizontal,
                      layout: SwiperLayout.STACK,

                      axisDirection: AxisDirection.right,

                      itemBuilder: (context, index) {
                        return ItemShimmerStyleFour();
                      },
                    ),
                  ),
                ],
              ),
            )
          : AnimationLimiter(
              child: Row(
                children: [
                  Expanded(
                    child: Swiper(
                      index: 0,
                      itemCount: widget.config.listItems.length,
                      itemHeight:
                          widget.config.effectiveHeight, // ✅ Ensure height is not null
                      itemWidth:
                          widget.config.effectiveWidth, // ✅ Ensure width is not null
                      duration: 600, // ✅ Smooth transition speed
                      autoplayDisableOnInteraction:
                          false, // ✅ Keep autoplay running after user interaction
                      fade: 0.7, // ✅ Smooth fade effect
                      scale: 0.8, // ✅ Better stack visibility
                      viewportFraction: 0.7, // ✅ Proper spacing
                      loop: true, // ✅ Enable infinite looping
                      scrollDirection: Axis.horizontal,
                      layout: SwiperLayout.STACK,

                      axisDirection: AxisDirection.right,

                      onIndexChanged: (index) async {
                        printLog(
                            "Current Index: $index Total Items: ${widget.config.listItems.length}");

                        // ✅ Fetch new items every 22 items
                        if (index % 22 == 0 && index != 0) {
                          printLog("Fetching more data at index1: $index");

                          if (widget.config.scrollController ==
                              pageMainScreenController
                                  .scrollControllerNewArrival) {
                            await pageMainScreenController.getCachedProducts();
                          } else if (widget.config.scrollController ==
                              pageMainScreenController.scrollRecommendedItems) {
                            await pageMainScreenController
                                .fetchRecommendedItems();
                          } else if (widget.config.scrollController ==
                              pageMainScreenController.scrollViewedItems) {
                            await pageMainScreenController.getItemsViewed();
                          } else if (widget.config.scrollController ==
                              pageMainScreenController.scrollHomeItems) {
                            await pageMainScreenController.getHomeData();
                          } else if (widget.config.scrollController ==
                              pageMainScreenController.scrollFlashItems) {
                            await pageMainScreenController.getFlashItems();
                          } else if (widget.config.scrollController ==
                              pageMainScreenController
                                  .scrollControllerFeatures) {
                            await pageMainScreenController.getFeatureProducts();
                          } else if (widget.config.scrollController ==
                              pageMainScreenController
                                  .scrollControllerSection[widget.config.i]) {
                            await pageMainScreenController.getSectionIndex(
                                indexUrl: widget.config.i);
                          }
                        }
                      },

                      itemBuilder: (context, index) {
// int index1=widget.config.listItems.length-1-index;
                        var item = widget.config
                            .listItems[index]; // ✅ Now using normal index order

                        bool favourite =
                            favouriteController.checkFavouriteItemProductId(
                                productId: item.id!.toInt());
                        bool isFeature = (index % 7 == 0);

                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 0),
                          child: ScaleAnimation(
                            duration: Duration(milliseconds: 0),
                            scale: 0.8, // ✅ Keep items visible
                            curve: Curves.linear,
                            delay: Duration(milliseconds: 0),
                            child: FadeInAnimation(
                              child: CustomImagesStyleFour(
                                isFavourite: favourite,
                                hasAnimatedBorder: widget.config.hasAnimatedBorder,
                                hasBellChristmas: widget.config.hasBellChristmas,
                                isLoadingProduct: widget.config.isLoadingProduct,
                                colorsGradient: widget.config.colorsGradient,
                                i: index,
                                flag: widget.config.flag,
                                item: item,
                                image: item.vendorImagesLinks![0],
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
                ],
              ),
            ),
    );
  }
}
