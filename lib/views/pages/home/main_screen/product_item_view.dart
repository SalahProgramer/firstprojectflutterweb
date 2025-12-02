import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../controllers/APIS/api_product_item.dart';
import '../../../../controllers/page_main_screen_controller.dart';
import '../../../../controllers/product_item_controller.dart';
import '../../../../core/dialogs/dialog_item_view/dialog_select_sizes_shoes.dart';
import '../../../../core/services/analytics/analytics_service.dart';
import '../../../../core/utilities/print_looger.dart';
import '../../../../core/widgets/widget_first_open_show.dart';
import '../../../../core/widgets/widgets_item_view/specefic_product_view.dart';
import '../../../../models/items/item_model.dart';

class ProductItemView extends StatefulWidget {
  final Item item;
  final bool? isFeature;
  final bool? isFlashOrBest;
  final String sizes;
  final int? indexVariants;

  const ProductItemView(
      {super.key,
      required this.item,
      this.isFeature = false,
      this.indexVariants = 0,
      required this.sizes,
      this.isFlashOrBest = false});

  @override
  State<ProductItemView> createState() => _ProductItemViewState();
}

class _ProductItemViewState extends State<ProductItemView> {
  Timer? timer; // Declare a Timer variable
  final CarouselSliderController carouselController =
      CarouselSliderController();
  AnalyticsService analyticsService = AnalyticsService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        // التأكد من أن الـ context جاهز قبل استخدام Provider
        if (!mounted) return;
        
        ProductItemController productItemController =
            context.read<ProductItemController>();

        ApiProductItemController apiProductItemController =
            context.read<ApiProductItemController>();
        PageMainScreenController pageMainScreenController =
            context.read<PageMainScreenController>();
        
        // start save the analytics
        analyticsService.logViewContent(
          contentId: widget.item.id?.toString() ?? "",
          contentType: "product",
          contentTitle: widget.item.title ?? "",
          price: double.tryParse(
                  widget.item.newPrice?.replaceAll("₪", "") ?? "0") ??
              0.0,
          parameters: {
            "class_name": "ProductItemView",
            "button_name": "view_product",
            "time": DateTime.now().toString(),
          },
        );

        await productItemController.clearItemsData();
        await apiProductItemController.resetRequests();

        if (widget.isFlashOrBest == true) {
          await productItemController.getItemDataBestOrFlash(
              widget.item, widget.sizes);
        } else {
          await productItemController.getItemData(widget.item, widget.sizes);
        }

        timer = Timer(Duration(seconds: 5), () async {
          if (!mounted) return;
          
          final prefs = await SharedPreferences.getInstance();
          bool showPopUpShoes = prefs.getBool('show_pop_up_shoes') ?? true;

          printLog("msgeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
          if (showPopUpShoes &&
              (pageMainScreenController.userActivity
                      .getEnumStatus('3')
                      .canUse ==
                  true)) {
            showPopUpShoesDialog();
          }
        });
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel(); // تنظيف الـ Timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ProductItemController productItemController =
        context.watch<ProductItemController>();
    AnalyticsService analyticsService = AnalyticsService();

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: (productItemController.showTutorial &&
                productItemController.isFirstOpenItem)
            ? true
            : false,
        body: Stack(children: [
          CarouselSlider.builder(
              itemCount: (productItemController.allItems.isEmpty)
                  ? 1
                  : productItemController.allItems.length,
              carouselController: carouselController,
              options: CarouselOptions(
                initialPage: 0,
                scrollDirection: Axis.horizontal,
                height: double.maxFinite,
                enlargeCenterPage: true,
                enableInfiniteScroll: false,
                enlargeStrategy: CenterPageEnlargeStrategy.scale,
                viewportFraction: 1,
                onPageChanged: (index, reason) async {
                  await analyticsService.logEvent(
                    eventName: "product_item_view_carousel_slider_change",
                    parameters: {
                      "class_name": "ProductItemView",
                      "button_name": "onPageChanged",
                      "new_index": index,
                      "time": DateTime.now().toString(),
                    },
                  );
                  if (index == productItemController.allItems.length - 3 &&
                      (productItemController.allItems.length - 3 >= 0)) {
                    printLog("Reached the last item: Index $index");
                    printLog(
                        "Reached the last item: Index ${productItemController.allItems[0].mainCategoris}");
                    printLog(
                        "Reached the last item: Index ${productItemController.allItems[0].subCategoris}");
                    if (widget.isFlashOrBest == true) {
                      await productItemController.getItemDataBestOrFlash(
                          widget.item, widget.sizes);
                    } else {
                      await productItemController.getItemData(
                          widget.item, widget.sizes);
                    }
                  }
                },
                autoPlayCurve: Curves.fastEaseInToSlowEaseOut,
                scrollPhysics: (productItemController.allItems.length == 1)
                    ? NeverScrollableScrollPhysics()
                    : ClampingScrollPhysics(),
              ),
              itemBuilder: (context, index, realIndex) {
                return SpecificProductView(
                  item: (productItemController.allItems.isEmpty)
                      ? widget.item
                      : productItemController.allItems[index],
                  isFeature: widget.isFeature ?? false,
                  indexVariants: widget.indexVariants ?? 0,
                );
              }),
          if (productItemController.showTutorial &&
              productItemController.isFirstOpenItem)
            WidgetFirstOpenShow()
        ]),
      ),
    );
  }
}
