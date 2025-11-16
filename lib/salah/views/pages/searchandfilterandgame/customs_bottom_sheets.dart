import 'dart:io';

import 'package:fawri_app_refactor/salah/controllers/search_controller.dart';
import 'package:fawri_app_refactor/salah/utilities/style/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../../../controllers/APIS/api_product_item.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/page_main_screen_controller.dart';
import '../../../controllers/product_item_controller.dart';
import '../../../controllers/favourite_controller.dart';
import '../../../utilities/global/app_global.dart';
import '../../../utilities/style/colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_shimmer.dart';
import '../../../widgets/widget_sub_main/ui_specific_sub_main.dart';
import '../home/main_screen/product_item_view.dart';

Future<void> showItemSearch(
    {required ScrollController scrollController, required String sizes}) async {
  return await showModalBottomSheet(
    context: NavigatorApp.context,
    isDismissible: false,
    sheetAnimationStyle: AnimationStyle(
        duration: const Duration(milliseconds: 800),
        reverseDuration: const Duration(milliseconds: 800)),
    isScrollControlled: true,
    builder: (context) {
      PageMainScreenController pageMainScreenController =
          context.watch<PageMainScreenController>();
      ProductItemController productItemController =
          context.watch<ProductItemController>();
      FavouriteController favouriteController =
          context.watch<FavouriteController>();
      SearchItemController searchItemController =
          context.watch<SearchItemController>();

      CartController cartController = context.watch<CartController>();
      ApiProductItemController apiProductItemController =
          context.watch<ApiProductItemController>();
      // Use parentContext to show Snackbar
      return SafeArea(
        child: Container(
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(vertical: 5.h),
          margin: EdgeInsets.only(top: 20.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.only(
                topStart: Radius.circular(20.r), topEnd: Radius.circular(20.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 8.h, right: 8.w),
                      child: Align(
                        alignment: Alignment.center,
                        child: CustomTextButton(
                            text: "رجوع",
                            textStyle: CustomTextStyle().heading1L.copyWith(
                                fontSize: 14.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                            onPressed: () {
                              NavigatorApp.pop();
                            }),
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 100.w,
                      height: 5.h,
                      margin: EdgeInsets.only(left: 33.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(10.r),
                        color: Colors.black54,
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black,
                              blurRadius: 4,
                              blurStyle: BlurStyle.outer,
                              spreadRadius: 1)
                        ],
                      ),
                    ),
                    Spacer()
                  ],
                ),
              ),
              (searchItemController.itemSearch.name != "")
                  ? SizedBox(
                      height: 10.h,
                    )
                  : SizedBox(),
              (searchItemController.itemSearch.name != "")
                  ? Text(
                      searchItemController.itemSearch.name,
                      style: CustomTextStyle()
                          .heading1L
                          .copyWith(color: Colors.black, fontSize: 16.sp),
                    )
                  : SizedBox(),
              SizedBox(
                height: 10.h,
              ),
              Expanded(
                child: (searchItemController.subCategories.isEmpty ||
                        searchItemController.subCategories == [])
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
                            crossAxisSpacing: 5.sp),
                        itemBuilder: (context, index) {
                          // Trigger loadMore function when arriving at index 12

                          return SubItemShim();
                        },
                      )
                    : GridView.builder(
                        controller: scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: (searchItemController.haveMoreData)
                            ? searchItemController.subCategories.length + 1
                            : searchItemController.subCategories.length,
                        physics: Platform.isIOS
                            ? ClampingScrollPhysics()
                            : AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 0.38.h,
                            crossAxisCount: 2,
                            mainAxisSpacing: 5.sp,
                            crossAxisSpacing: 5.sp),
                        itemBuilder: (context, index) {
                          if (index ==
                              searchItemController.subCategories.length) {
                            // Show loader at the end
                            return searchItemController.showSpinKitMoreData
                                ? Center(
                                    child: SpinKitSpinningLines(
                                      color: CustomColor.blueColor,
                                      size: 30.h,
                                    ),
                                  )
                                : SizedBox(); // Empty widget if not loading
                          }
                          bool favourite =
                              favouriteController.checkFavouriteItemProductId(
                                  productId: searchItemController
                                      .subCategories[index].id!
                                      .toInt());

                          bool inCart = cartController.checkCartItemProductId(
                              productId: searchItemController
                                  .subCategories[index].id!
                                  .toInt(),
                              selectedSize: "");
                          return InkWell(
                            hoverColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            overlayColor:
                                WidgetStatePropertyAll(Colors.transparent),
                            onTap: () async {
                              await pageMainScreenController
                                  .changePositionScroll(
                                      searchItemController
                                          .subCategories[index].id
                                          .toString(),
                                      0);
                              await productItemController.clearItemsData();
                              await apiProductItemController.cancelRequests();
                              NavigatorApp.push(ProductItemView(
                                item: searchItemController.subCategories[index],
                                isFeature: false,
                                sizes: sizes,
                              ));
                            },
                            child: UiSpecificSubMain(
                              favourite: favourite,
                              index: index,
                              inCart: inCart,
                              item: searchItemController.subCategories[index],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> showItemFilter(
    {required ScrollController scrollController, required String sizes}) async {
  return await showModalBottomSheet(
    context: NavigatorApp.context,
    sheetAnimationStyle: AnimationStyle(
        duration: const Duration(milliseconds: 800),
        reverseDuration: const Duration(milliseconds: 800)),
    isScrollControlled: true,
    builder: (context) {
      PageMainScreenController pageMainScreenController =
          context.watch<PageMainScreenController>();
      ProductItemController productItemController =
          context.watch<ProductItemController>();
      FavouriteController favouriteController =
          context.watch<FavouriteController>();
      SearchItemController searchItemController =
          context.watch<SearchItemController>();

      CartController cartController = context.watch<CartController>();
      ApiProductItemController apiProductItemController =
          context.watch<ApiProductItemController>();

      return SafeArea(
        child: Container(
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(vertical: 5.h),
          margin: EdgeInsets.only(top: 20.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.only(
                topStart: Radius.circular(20.r), topEnd: Radius.circular(20.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 8.h, right: 8.w),
                      child: Align(
                        alignment: Alignment.center,
                        child: CustomTextButton(
                            text: "رجوع",
                            textStyle: CustomTextStyle().heading1L.copyWith(
                                fontSize: 14.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                            onPressed: () {
                              NavigatorApp.pop();
                            }),
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 100.w,
                      height: 5.h,
                      margin: EdgeInsets.only(left: 33.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(10.r),
                        color: Colors.black54,
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black,
                              blurRadius: 4,
                              blurStyle: BlurStyle.outer,
                              spreadRadius: 1)
                        ],
                      ),
                    ),
                    Spacer()
                  ],
                ),
              ),
              (searchItemController.itemSearch.name != "")
                  ? SizedBox(
                      height: 10.h,
                    )
                  : SizedBox(),
              (searchItemController.itemSearch.name != "")
                  ? Text(
                      searchItemController.itemSearch.name,
                      style: CustomTextStyle()
                          .heading1L
                          .copyWith(color: Colors.black, fontSize: 16.sp),
                    )
                  : SizedBox(),
              SizedBox(
                height: 10.h,
              ),
              ((searchItemController.selectTag.name != "") &&
                      (searchItemController.itemCategory.name == ""))
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(
                        children: [
                          Expanded(child: Text("")),
                          Center(
                            child: Text(
                              (searchItemController.selectTag.name == "2025")
                                  ? " 🎊 ${searchItemController.selectTag.name} 🎊 "
                                  : " 🔖 ${searchItemController.selectTag.name} 🔖 ",
                              textAlign: TextAlign.center,
                              style: CustomTextStyle().heading1L.copyWith(
                                  color: Colors.black, fontSize: 20.sp),
                            ),
                          ),
                          ((searchItemController.rangePrice.end.toString() ==
                                          "1000.0" &&
                                      searchItemController.rangePrice.start
                                              .toString() ==
                                          "0.0") ||
                                  (searchItemController.rangePrice.end
                                              .toString() ==
                                          "0.0" &&
                                      searchItemController.rangePrice.start
                                              .toString() ==
                                          "0.0"))
                              ? Expanded(child: Text(""))
                              : Expanded(
                                  child: Center(
                                    child: Text(
                                      textAlign: TextAlign.end,
                                      "₪ ${searchItemController.rangePrice.start.toString()}  -  ₪ ${searchItemController.rangePrice.end.toString()}",
                                      style: CustomTextStyle()
                                          .heading1L
                                          .copyWith(
                                              color: CustomColor.chrismasColor,
                                              fontSize: 12.sp),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ((searchItemController.selectTag.name == ""))
                              ? Expanded(child: Text(""))
                              : Expanded(
                                  child: Center(
                                    child: Text(
                                      textAlign: TextAlign.center,
                                      (searchItemController.selectTag.name ==
                                              "2025")
                                          ? " 🎊 ${searchItemController.selectTag.name} 🎊 "
                                          : " 🔖 ${searchItemController.selectTag.name} 🔖 ",
                                      style: CustomTextStyle()
                                          .heading1L
                                          .copyWith(
                                              color: CustomColor.chrismasColor,
                                              fontSize: 12.sp),
                                    ),
                                  ),
                                ),
                          (searchItemController.itemCategory.name != "")
                              ? Expanded(
                                  child: Center(
                                    child: Text(
                                      searchItemController.itemCategory.name,
                                      textAlign: TextAlign.center,
                                      style: CustomTextStyle()
                                          .heading1L
                                          .copyWith(
                                              color: Colors.black,
                                              fontSize: 20.sp),
                                    ),
                                  ),
                                )
                              : Expanded(child: Text("")),
                          ((searchItemController.rangePrice.end.toString() ==
                                          "1000.0" &&
                                      searchItemController.rangePrice.start
                                              .toString() ==
                                          "0.0") ||
                                  (searchItemController.rangePrice.end
                                              .toString() ==
                                          "0.0" &&
                                      searchItemController.rangePrice.start
                                              .toString() ==
                                          "0.0"))
                              ? Expanded(child: Text(""))
                              : Expanded(
                                  child: Center(
                                    child: Text(
                                      textAlign: TextAlign.end,
                                      "₪ ${searchItemController.rangePrice.start.toString()}  -  ₪ ${searchItemController.rangePrice.end.toString()}",
                                      style: CustomTextStyle()
                                          .heading1L
                                          .copyWith(
                                              color: CustomColor.chrismasColor,
                                              fontSize: 12.sp),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
              (searchItemController.listSelectedSubMain.isNotEmpty)
                  ? SizedBox(
                      height: 4.h,
                    )
                  : SizedBox(),
              (searchItemController.listSelectedSubMain.isEmpty)
                  ? SizedBox()
                  : Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Container(
                        height: 0.03.sh,
                        alignment: Alignment.center,
                        child: Center(
                          // Ensures the content is centered
                          child: ListView.separated(
                            shrinkWrap: true,
                            separatorBuilder: (context, index) => Text(
                              " | ",
                              textAlign: TextAlign.center,
                              style: CustomTextStyle().heading1L.copyWith(
                                  color: Colors.black, fontSize: 13.sp),
                            ),
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            itemBuilder: (context, index) => Container(
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Text(
                                searchItemController
                                    .listSelectedSubMain[index].name,
                                textAlign: TextAlign.center,
                                style: CustomTextStyle().heading1L.copyWith(
                                    color: Colors.black, fontSize: 13.sp),
                              ),
                            ),
                            itemCount:
                                searchItemController.listSelectedSubMain.length,
                          ),
                        ),
                      ),
                    ),
              (searchItemController.sizes.isEmpty ||
                      searchItemController.listSelectedSizes.isEmpty)
                  ? SizedBox()
                  : Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Container(
                        height: 0.04.sh,
                        alignment: Alignment.center,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          itemBuilder: (context, index) => Container(
                            clipBehavior: Clip.none,
                            width: 0.2.sw,
                            height: 25.h,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            padding: EdgeInsets.all(4.w),
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Text(
                              searchItemController.listSelectedSizes[index],
                              textAlign: TextAlign.center,
                              style: CustomTextStyle().heading1L.copyWith(
                                  color: Colors.white, fontSize: 12.sp),
                            ),
                          ),
                          itemCount:
                              searchItemController.listSelectedSizes.length,
                        ),
                      ),
                    ),
              SizedBox(
                height: 10.h,
              ),
              Expanded(
                // width: double.maxFinite,
                // height: (searchItemController.itemSearch.name != "")
                //     ? 0.85.sh
                //     : 0.9.sh,
                child: (searchItemController.subCategories.isEmpty ||
                        searchItemController.subCategories == [])
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
                            crossAxisSpacing: 5.sp),
                        itemBuilder: (context, index) {
                          // Trigger loadMore function when arriving at index 12

                          return SubItemShim();
                        },
                      )
                    : GridView.builder(
                        controller: scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: (searchItemController.haveMoreData)
                            ? searchItemController.subCategories.length + 1
                            : searchItemController.subCategories.length,
                        physics: Platform.isIOS
                            ? ClampingScrollPhysics()
                            : AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 0.38.h,
                            crossAxisCount: 2,
                            mainAxisSpacing: 5.sp,
                            crossAxisSpacing: 5.sp),
                        itemBuilder: (context, index) {
                          if (index ==
                              searchItemController.subCategories.length) {
                            // Show loader at the end
                            return searchItemController.showSpinKitMoreData
                                ? Center(
                                    child: SpinKitSpinningLines(
                                      color: CustomColor.blueColor,
                                      size: 30.h,
                                    ),
                                  )
                                : SizedBox(); // Empty widget if not loading
                          }
                          bool favourite =
                              favouriteController.checkFavouriteItemProductId(
                                  productId: searchItemController
                                      .subCategories[index].id!
                                      .toInt());

                          bool inCart = cartController.checkCartItemProductId(
                              productId: searchItemController
                                  .subCategories[index].id!
                                  .toInt(),
                              selectedSize: "");
                          return InkWell(
                            hoverColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            overlayColor:
                                WidgetStatePropertyAll(Colors.transparent),
                            onTap: () async {
                              await pageMainScreenController
                                  .changePositionScroll(
                                      searchItemController
                                          .subCategories[index].id
                                          .toString(),
                                      0);
                              await productItemController.clearItemsData();
                              await apiProductItemController.cancelRequests();
                              NavigatorApp.push(ProductItemView(
                                item: searchItemController.subCategories[index],
                                isFeature: false,
                                sizes: sizes,
                              ));
                            },
                            child: UiSpecificSubMain(
                              favourite: favourite,
                              index: index,
                              inCart: inCart,
                              item: searchItemController.subCategories[index],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
