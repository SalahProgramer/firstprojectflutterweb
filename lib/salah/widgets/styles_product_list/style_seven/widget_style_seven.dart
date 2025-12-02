import 'package:cached_network_image/cached_network_image.dart';
import 'package:fawri_app_refactor/salah/animation/animate_swipe_items.dart';
import 'package:fawri_app_refactor/salah/widgets/styles_product_list/style_seven/specific_item_style_seven.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../controllers/page_main_screen_controller.dart';
import '../../../models/products_view_config.dart';

class WidgetStyleSeven extends StatefulWidget {
  final ProductsViewConfigModel config;

  const WidgetStyleSeven({
    super.key,
    required this.config,
  });

  @override
  State<WidgetStyleSeven> createState() => _WidgetStyleSevenState();
}

class _WidgetStyleSevenState extends State<WidgetStyleSeven> {
  bool hasReachedIndex = false;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      scrollController.addListener(() async {
        PageMainScreenController pageMainScreenController =
            context.read<PageMainScreenController>();
        final itemWidth = 0.1.sw;

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
      height: (widget.config.bgImage != "") ? widget.config.heightBGImage.h : widget.config.effectiveHeight,
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
                flex: (widget.config.styleModel.flexImage ?? 2), child: SizedBox()),
          Expanded(
            flex:
                (widget.config.bgImage != "") ? (widget.config.styleModel.flexStyle ?? 2) : 1,
            child: Container(
                color: (widget.config.bgImage == "")
                    ? widget.config.bgColor
                    : Colors.transparent,
                margin: EdgeInsets.only(right: 4.w),
                child: AnimateSwipeItems(
                  scrollController: scrollController,
                  customWidget: body(),
                  doSwipeAuto: widget.config.doSwipeAuto,
                )),
          ),
        ],
      ),
    );
  }

  Widget body() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: AlwaysScrollableScrollPhysics(),
      controller: scrollController,
      itemCount: (widget.config.listItems.length / 2).ceil(),
      itemBuilder: (context, columnIndex) {
        return SizedBox(
          width: 135.w,
          child: Column(
            children: [
              // Top item - normal position
              Expanded(
                child: _buildItem(columnIndex * 2),
              ),
              // Bottom item - offset position
              Expanded(
                child: Transform.translate(
                  offset:  Offset(15.w, 0),
                  child: _buildItem(columnIndex * 2 + 1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItem(int index) {
    if (index >= widget.config.listItems.length) {
      return SizedBox();
    }

    bool isFeature = (index) % 7 == 0;
    // Generate fixed width between 120.w and 135.w for each item based on index
    List<double> widthOptions = [120.w, 125.w, 130.w, 135.w];
    double fixedWidth = widthOptions[index % widthOptions.length];

    return Container(
      margin: (index==1)?EdgeInsets.only(right: 15.w,left: 3.w):EdgeInsets.all(3.w),

      width: fixedWidth,
      child: SpecificItemStyleSeven(
        i: index,
        image: widget.config.listItems[index].vendorImagesLinks![0],
        item: widget.config.listItems[index],
        hasAnimatedBorder: widget.config.hasAnimatedBorder,
        isFeature: isFeature,
        isLoadingProduct: widget.config.isLoadingProduct,
      ),
    );
  }
}
