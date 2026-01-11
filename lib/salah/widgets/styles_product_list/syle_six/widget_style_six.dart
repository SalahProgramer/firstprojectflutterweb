import 'package:cached_network_image/cached_network_image.dart';
import 'package:fawri_app_refactor/salah/animation/animate_swipe_items.dart';
import 'package:fawri_app_refactor/salah/widgets/styles_product_list/syle_six/specific_item_style_six.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../controllers/page_main_screen_controller.dart';
import '../../../models/products_view_config.dart';

class WidgetStyleSix extends StatefulWidget {
  final ProductsViewConfigModel config;

  const WidgetStyleSix({super.key, required this.config});

  @override
  State<WidgetStyleSix> createState() => _WidgetStyleSixState();
}

class _WidgetStyleSixState extends State<WidgetStyleSix> {
  bool hasReachedIndex = false;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      scrollController.addListener(() async {
        PageMainScreenController pageMainScreenController = context
            .read<PageMainScreenController>();
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
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (widget.config.bgImage != "")
          ? widget.config.heightBGImage.h
          : widget.config.effectiveHeight,
      decoration: BoxDecoration(
        image: (widget.config.bgImage == "")
            ? null
            : DecorationImage(
                image: CachedNetworkImageProvider(widget.config.bgImage),
                fit: BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.high,
              ),
      ),
      child: Column(
        children: [
          if (widget.config.bgImage != "")
            Expanded(
              flex: (widget.config.styleModel.flexImage ?? 2),
              child: SizedBox(),
            ),
          Expanded(
            flex: (widget.config.bgImage != "")
                ? (widget.config.styleModel.flexStyle ?? 2)
                : 1,
            child: Container(
              color: (widget.config.bgImage == "")
                  ? widget.config.bgColor
                  : Colors.transparent,
              padding: EdgeInsets.only(
                top: 4.h,
                bottom: 4.h,
                right: 4.w,
                left: 1.w,
              ),
              child: AnimateSwipeItems(
                scrollController: scrollController,
                customWidget: body(),
                doSwipeAuto: widget.config.doSwipeAuto,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget body() {
    return ListView.builder(
      controller: scrollController,
      shrinkWrap: true,
      reverse: widget.config.reverse,
      clipBehavior: Clip.none,
      scrollDirection: Axis.horizontal,
      itemCount: widget.config.listItems.length,
      itemBuilder: (context, int index) {
        {
          bool isFeature = (index) % 7 == 0;

          return CustomImagesStyleSix(
            hasAnimatedBorder: widget.config.hasAnimatedBorder,
            hasBellChristmas: widget.config.hasBellChristmas,
            isLoadingProduct: widget.config.isLoadingProduct,
            colorsGradient: widget.config.colorsGradient,
            i: widget.config.i,
            flag: widget.config.flag,
            item: widget.config.listItems[index],
            image: widget.config.listItems[index].vendorImagesLinks![0],
            changeLoadingProduct: widget.config.changeLoadingProduct,
            width: 140.w,
            isFeature: isFeature,
          );
        }
      },
    );
  }
}
