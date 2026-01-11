import 'dart:io';

import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:fawri_app_refactor/salah/utilities/style/text_style.dart';
import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../controllers/APIS/api_product_item.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/favourite_controller.dart';
import '../../controllers/page_main_screen_controller.dart';
import '../../controllers/product_item_controller.dart';
import '../../controllers/sub_main_categories_conrtroller.dart';
import '../../utilities/style/colors.dart';
import '../../views/pages/home/home_screen/count-down-time-widget/count_down_time_widget.dart';
import '../../views/pages/home/main_screen/product_item_view.dart';
import '../custom_shimmer.dart';
import '../snackBarWidgets/snack_bar_style.dart';
import '../snackBarWidgets/snackbar_widget.dart';
import '../widget_sub_main/ui_specific_sub_main.dart';

class SubItems extends StatefulWidget {
  final ScrollController scrollController;
  final String? type;
  final bool hasAPI;
  final bool hasAppBar;
  final String? bannerTitle;
  final String url, title;
  final int? index;

  const SubItems({
    super.key,
    required this.scrollController,
    required this.type,
    required this.hasAPI,
    required this.bannerTitle,
    required this.hasAppBar,
    required this.url,
    required this.title,
    this.index,
  });

  @override
  State<SubItems> createState() => _SubItemsState();
}

class _SubItemsState extends State<SubItems> {
  bool hasReachedIndex = false;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SubMainCategoriesController subMainCategoriesController = context
          .read<SubMainCategoriesController>();
      if (widget.scrollController ==
          subMainCategoriesController.scrollBestSellersItems) {
        await subMainCategoriesController.getBestSallarSubMain();
      } else if (widget.scrollController ==
          subMainCategoriesController.scrollDynamicItems) {
        await subMainCategoriesController.getDynamicSubMain(widget.type);
      } else if (widget.scrollController ==
          subMainCategoriesController.scrollHomeItems) {
        await subMainCategoriesController.getHomeSubMain();
      } else if (widget.scrollController ==
          subMainCategoriesController.scrollSectionsItems) {
        await subMainCategoriesController.getSectionSubMain(widget.index!);
      } else if (widget.scrollController ==
          subMainCategoriesController.scrollProductsItems) {
        await subMainCategoriesController.getProduct1();
      } else if (widget.scrollController ==
          subMainCategoriesController.scrollFeaturesItems) {
        await subMainCategoriesController.getFeaturesSubMain();
      } else if (widget.scrollController ==
          subMainCategoriesController.scrollSlidersItems) {
        await subMainCategoriesController.getSlidersSubMain(widget.url);
      }

      // Check if scroll controller is still mounted before adding listener
      if (!scrollController.hasClients) return;

      scrollController.addListener(() async {
        // Safety check: ensure scroll controller is still valid
        if (!scrollController.hasClients) return;

        final itemWidth = 0.3.sw;
        final itemHeight =
            itemWidth / 0.40.h; // Calculated from childAspectRatio
        final rowHeight = itemHeight + 10; // Add mainAxisSpacing if applicable

        final index25Offset =
            (((subMainCategoriesController.subCategories.length ~/ 12)) * 3) *
            rowHeight;
        if (scrollController.offset >= index25Offset && !hasReachedIndex) {
          hasReachedIndex = true;
          if ((scrollController.position.pixels >=
              scrollController.position.maxScrollExtent)) {
            await subMainCategoriesController.changeSpinHaveMoreData(true);
          }

          if (widget.scrollController ==
              subMainCategoriesController.scrollBestSellersItems) {
            await subMainCategoriesController.getBestSallarSubMain();
          } else if (widget.scrollController ==
              subMainCategoriesController.scrollFeaturesItems) {
            await subMainCategoriesController.getFeaturesSubMain();
          } else if (widget.scrollController ==
              subMainCategoriesController.scrollDynamicItems) {
            await subMainCategoriesController.getDynamicSubMain(widget.type);
          } else if (widget.scrollController ==
              subMainCategoriesController.scrollSlidersItems) {
            await subMainCategoriesController.getSlidersSubMain(widget.url);
          } else if (widget.scrollController ==
              subMainCategoriesController.scrollHomeItems) {
            await subMainCategoriesController.getHomeSubMain();
          } else if (widget.scrollController ==
              subMainCategoriesController.scrollSectionsItems) {
            await subMainCategoriesController.getSectionSubMain(widget.index!);
          } else if (widget.scrollController ==
              subMainCategoriesController.scrollProductsItems) {
            await subMainCategoriesController.getProduct1();
          }

          hasReachedIndex = false;
        }

        if ((scrollController.position.extentAfter == 0.0)) {
          if ((subMainCategoriesController.haveMoreData == false)) {
            await subMainCategoriesController.changeSpinHaveMoreData(false);
            await showSnackBar(
              title: "لقد وصلت إلى النهاية ",
              description: 'لا توجد منتجات إضافية من هذا القسم ',
              type: SnackBarType.info,
            );
          }
        }
      });
    });
  }

  @override
  void dispose() {
    // scrollController.removeListener(_onScroll);
    if (scrollController.hasClients) {
      scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AnalyticsService analyticsService = AnalyticsService();

    PageMainScreenController pageMainScreenController = context
        .watch<PageMainScreenController>();
    ProductItemController productItemController = context
        .watch<ProductItemController>();
    FavouriteController favouriteController = context
        .watch<FavouriteController>();
    SubMainCategoriesController subMainCategoriesController = context
        .watch<SubMainCategoriesController>();

    CartController cartController = context.watch<CartController>();
    ApiProductItemController apiProductItemController = context
        .watch<ApiProductItemController>();

    return Scaffold(
      // appBar: (widget.hasAppBar)
      //     ? CustomAppBar(
      //         title: "الرئيسية",
      //         textButton: "رجوع",
      //         onPressed: () async {
      //           await subMainCategoriesController.clear();
      //           NavigatorApp.pop();
      //         },
      //         colorWidgets: Colors.black,
      //       )
      //     : null,
      body: Column(
        children: [
          CountdownTimerWidget(
            hasAPI:
                widget.type == "11.11" ||
                    widget.type == "discount" ||
                    widget.type == "Christmas"
                ? true
                : widget.hasAPI,
            type: widget.type ?? "",
          ),
          SizedBox(height: 5.h),
          if (widget.type.toString().toLowerCase() != "normal")
            Text(
              (widget.type == "2025") ? "🎊 2025 🎊" : widget.type!.toString(),
              style: CustomTextStyle().heading1L.copyWith(
                color: Colors.black,
                fontSize: 18.sp,
              ),
            ),
          if (widget.scrollController ==
              subMainCategoriesController.scrollSlidersItems)
            Text(
              widget.title.toString(),
              style: CustomTextStyle().heading1L.copyWith(
                color: Colors.black,
                fontSize: 18.sp,
              ),
            ),
          Expanded(
            child:
                (subMainCategoriesController.subCategories.isEmpty ||
                    subMainCategoriesController.subCategories == [])
                ? GridView.builder(
                    shrinkWrap: true,
                    controller: scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: 12,
                    physics: Platform.isIOS
                        ? ClampingScrollPhysics()
                        : AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 0.38.h,
                      crossAxisCount: 2,
                      mainAxisSpacing: 5.sp,
                      crossAxisSpacing: 5.sp,
                    ),
                    itemBuilder: (context, index) {
                      // Trigger loadMore function when arriving at index 12

                      return SubItemShim();
                    },
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    controller: scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: (subMainCategoriesController.haveMoreData)
                        ? subMainCategoriesController.subCategories.length + 1
                        : subMainCategoriesController.subCategories.length,
                    physics: Platform.isIOS
                        ? ClampingScrollPhysics()
                        : AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 0.38.h,
                      crossAxisCount: 2,
                      mainAxisSpacing: 5.sp,
                      crossAxisSpacing: 5.sp,
                    ),
                    itemBuilder: (context, index) {
                      if (index ==
                          subMainCategoriesController.subCategories.length) {
                        // Show loader at the end
                        return subMainCategoriesController.showSpinKitMoreData
                            ? Center(
                                child: SpinKitSpinningLines(
                                  color: CustomColor.blueColor,
                                  size: 30.h,
                                ),
                              )
                            : SizedBox(); // Empty widget if not loading
                      }
                      bool favourite = favouriteController
                          .checkFavouriteItemProductId(
                            productId: subMainCategoriesController
                                .subCategories[index]
                                .id!
                                .toInt(),
                          );

                      bool inCart = cartController.checkCartItemProductId(
                        productId: subMainCategoriesController
                            .subCategories[index]
                            .id!
                            .toInt(),
                        selectedSize: "",
                      );
                      return InkWell(
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        overlayColor: WidgetStatePropertyAll(
                          Colors.transparent,
                        ),
                        onTap: () async {
                          await analyticsService.logEvent(
                            eventName: "sub_item_click",
                            parameters: {
                              "class_name": "SubItems",
                              "button_name": "sub_item_index_$index",
                              "product_id":
                                  subMainCategoriesController
                                      .subCategories[index]
                                      .id
                                      ?.toString() ??
                                  "",
                              "product_title":
                                  subMainCategoriesController
                                      .subCategories[index]
                                      .title ??
                                  "",
                              "time": DateTime.now().toString(),
                            },
                          );
                          await pageMainScreenController.changePositionScroll(
                            subMainCategoriesController.subCategories[index].id
                                .toString(),
                            0,
                          );
                          await productItemController.clearItemsData();
                          await apiProductItemController.cancelRequests();

                          NavigatorApp.push(
                            ProductItemView(
                              item: subMainCategoriesController
                                  .subCategories[index],
                              isFeature: false,
                              sizes: '',
                            ),
                          );
                        },
                        child: UiSpecificSubMain(
                          favourite: favourite,
                          index: index,
                          inCart: inCart,
                          item:
                              subMainCategoriesController.subCategories[index],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
