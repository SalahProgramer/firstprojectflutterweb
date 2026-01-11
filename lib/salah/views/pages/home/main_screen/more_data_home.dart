import 'package:fawri_app_refactor/salah/views/pages/home/main_screen/product_item_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../../../controllers/APIS/api_product_item.dart';
import '../../../../controllers/cart_controller.dart';
import '../../../../controllers/favourite_controller.dart';
import '../../../../controllers/page_main_screen_controller.dart';
import '../../../../controllers/product_item_controller.dart';
import '../../../../utilities/global/app_global.dart';
import '../../../../utilities/style/colors.dart';
import '../../../../widgets/custom_shimmer.dart';
import '../../../../widgets/snackBarWidgets/snack_bar_style.dart';
import '../../../../widgets/snackBarWidgets/snackbar_widget.dart';
import '../../../../widgets/widgets_main_screen/ui_specific_item_more_data.dart';

class MoreDataHome extends StatefulWidget {
  final ScrollController nameScrollTyeProduct;
  final ScrollController scrollController;

  const MoreDataHome({
    super.key,
    required this.nameScrollTyeProduct,
    required this.scrollController,
  });

  @override
  State<MoreDataHome> createState() => _MoreDataHomeState();
}

class _MoreDataHomeState extends State<MoreDataHome> {
  bool hasReachedIndex = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final pageMainScreenController = context.read<PageMainScreenController>();

      if (widget.nameScrollTyeProduct ==
          pageMainScreenController.scrollMoreDataItems) {
        await pageMainScreenController.getProductMoreData();
      }

      widget.scrollController.addListener(() async {
        if (widget.scrollController.position.extentAfter == 0.0) {
          if (pageMainScreenController.haveMoreData == false) {
            await showSnackBar(
              title: "لقد وصلت إلى النهاية ",
              description: 'لا توجد منتجات إضافية من هذا القسم ',
              type: SnackBarType.info,
            );
          } else {
            if (!pageMainScreenController.showSpinKitMoreData &&
                pageMainScreenController.itemsMoreData.isNotEmpty) {
              await pageMainScreenController.changeSpinHaveMoreData(true);

              if (widget.nameScrollTyeProduct ==
                  pageMainScreenController.scrollMoreDataItems) {
                await pageMainScreenController.getProductMoreData();
              }

              await pageMainScreenController.changeSpinHaveMoreData(false);
            }
          }
        }
      });
    });
  }

  @override
  void dispose() {
    widget.scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PageMainScreenController pageMainScreenController = context
        .watch<PageMainScreenController>();
    ProductItemController productItemController = context
        .watch<ProductItemController>();
    FavouriteController favouriteController = context
        .watch<FavouriteController>();

    CartController cartController = context.watch<CartController>();
    ApiProductItemController apiProductItemController = context
        .watch<ApiProductItemController>();

    return (pageMainScreenController.itemsMoreData.isEmpty ||
            pageMainScreenController.itemsMoreData == [])
        ? SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ShimmerItemMoreData(),
              childCount: 12,
            ),
            gridDelegate: setGridDelegate(),
          )
        : SliverGrid.builder(
            itemCount: (pageMainScreenController.haveMoreData)
                ? pageMainScreenController.itemsMoreData.length + 1
                : pageMainScreenController.itemsMoreData.length,
            gridDelegate: setGridDelegate(),
            addAutomaticKeepAlives: true,
            itemBuilder: (context, index) {
              if (index == pageMainScreenController.itemsMoreData.length) {
                // Show loader at the end
                return pageMainScreenController.showSpinKitMoreData
                    ? Center(
                        child: SpinKitSpinningLines(
                          color: CustomColor.blueColor,
                          size: 30.h,
                        ),
                      )
                    : SizedBox(); // Empty widget if not loading
              }
              bool favourite = favouriteController.checkFavouriteItemProductId(
                productId: pageMainScreenController.itemsMoreData[index].id!
                    .toInt(),
              );

              bool inCart = cartController.checkCartItemProductId(
                productId: pageMainScreenController.itemsMoreData[index].id!
                    .toInt(),
                selectedSize: "",
              );
              return InkWell(
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                overlayColor: WidgetStatePropertyAll(Colors.transparent),
                onTap: () async {
                  await pageMainScreenController.changePositionScroll(
                    pageMainScreenController.itemsMoreData[index].id.toString(),
                    0,
                  );
                  await productItemController.clearItemsData();
                  await apiProductItemController.cancelRequests();

                  NavigatorApp.push(
                    ProductItemView(
                      item: pageMainScreenController.itemsMoreData[index],
                      isFeature: false,
                      sizes: '',
                    ),
                  );
                },
                child: UiSpecificItemMoreData(
                  favourite: favourite,
                  index: index,
                  inCart: inCart,
                  item: pageMainScreenController.itemsMoreData[index],
                ),
              );
            },
          );
  }

  SliverGridDelegateWithFixedCrossAxisCount setGridDelegate() {
    return SliverGridDelegateWithFixedCrossAxisCount(
      childAspectRatio: 0.375.h,
      crossAxisCount: 3,
      mainAxisSpacing: 2.sp,
      crossAxisSpacing: 2.sp,
    );
  }
}
