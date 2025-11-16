import 'dart:io';

import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/utilities/style/colors.dart';
import 'package:fawri_app_refactor/salah/widgets/departments_home_widgets/sub_department_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../controllers/APIS/api_product_item.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/departments_controller.dart';
import '../../../controllers/page_main_screen_controller.dart';
import '../../../controllers/product_item_controller.dart';
import '../../../controllers/favourite_controller.dart';
import '../../../models/constants/constant_model.dart';
import '../../../utilities/global/app_global.dart';
import '../../../widgets/custom_shimmer.dart';
import '../../../widgets/departments_home_widgets/sub_department_multi_selections.dart';
import '../../../widgets/departments_home_widgets/total_items_department.dart';
import '../../../widgets/empty_widget.dart';
import '../../../widgets/snackBarWidgets/snack_bar_style.dart';
import '../../../widgets/snackBarWidgets/snackbar_widget.dart';
import '../../../widgets/widget_sub_main/ui_specific_sub_main.dart';
import '../home/main_screen/product_item_view.dart';
import '../searchandfilterandgame/widget_search_filter.dart';

class HomePageDepartment extends StatefulWidget {
  final String sizes;
  final CategoryModel? category;
  final ScrollController scrollController;

  const HomePageDepartment(
      {super.key,
      required this.sizes,
      required this.scrollController,
      this.category});

  @override
  State<HomePageDepartment> createState() => _HomePageDepartmentState();
}

class _HomePageDepartmentState extends State<HomePageDepartment> {
  final ScrollController scrollController = ScrollController();
  bool hasReachedIndex = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      DepartmentsController departmentsController =
          context.read<DepartmentsController>();

      await departmentsController.connectedWifi();

      if (widget.scrollController == departmentsController.scrollPerfumeItems) {
        await departmentsController.getPerfume();
      } else if (widget.scrollController ==
          departmentsController.scrollMultiItems) {
        await departmentsController.getData(
            category: widget.category ??
                CategoryModel(
                    name: "",
                    subCategory: "",
                    image: "",
                    mainCategory: "",
                    icon: ""),
            sizes: widget.sizes,
            isFirst: true);
      }

      scrollController.addListener(() async {
        if (scrollController.position.extentAfter == 0.0) {
          if (departmentsController.haveMoreData == false) {
            await departmentsController.changeSpinHaveMoreData(false);

            await showSnackBar(
              title: "لقد وصلت إلى النهاية ",
              description: 'لا توجد منتجات إضافية من هذا القسم ',
              type: SnackBarType.info,
            );
          } else {
            if (!departmentsController.showSpinKitMoreData &&
                departmentsController.itemsData.isNotEmpty) {
              await departmentsController.changeSpinHaveMoreData(true);

              if (widget.scrollController ==
                  departmentsController.scrollPerfumeItems) {
                await departmentsController.getPerfume();
              } else if (widget.scrollController ==
                  departmentsController.scrollMultiItems) {
                await departmentsController.getData(
                    category: widget.category ??
                        CategoryModel(
                            name: "",
                            subCategory: "",
                            image: "",
                            mainCategory: "",
                            icon: ""),
                    sizes: widget.sizes,
                    isFirst: false);
              }

              await departmentsController.changeSpinHaveMoreData(false);
            }
          }
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DepartmentsController departmentsController =
        context.watch<DepartmentsController>();
    PageMainScreenController pageMainScreenController =
        context.watch<PageMainScreenController>();
    ProductItemController productItemController =
        context.watch<ProductItemController>();
    FavouriteController favouriteController =
        context.watch<FavouriteController>();
    CartController cartController = context.watch<CartController>();
    ApiProductItemController apiProductItemController =
        context.watch<ApiProductItemController>();
    return (departmentsController.checkWifi == false)
        ? Center(
            child: EmptyWidget(
              text: 'لا يوجد اتصال بالإنترنت',
              iconName: Assets.lottie.nowifi,
            ),
          )
        : SafeArea(
            child: Column(
              children: [
                ShowCaseWidget(
                  builder: (context) => WidgetSearchFilter(
                    haveSort: true,
                    category: widget.category,
                    sizes: widget.sizes,
                    scrollController: widget.scrollController,
                  ),
                ),
                TotalItemsDepartment(),
                SizedBox(
                  height: 5.h,
                ),
                (departmentsController.subCategoriesDepartment.isEmpty)
                    ? SizedBox()
                    : (widget.scrollController !=
                            departmentsController.scrollPerfumeItems)
                        ? SubDepartmentMultiSelections(
                            scrollController: widget.scrollController,
                            sizes: widget.sizes,
                            category: widget.category,
                          )
                        : SubDepartmentSelections(
                            scrollController: widget.scrollController,
                            sizes: widget.sizes,
                            category: widget.category,
                          ),
                (departmentsController.subCategoriesDepartment.isEmpty)
                    ? SizedBox()
                    : SizedBox(
                        height: 5.h,
                      ),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: ((departmentsController.itemsData.isEmpty ||
                                  departmentsController.itemsData == []) &&
                              (departmentsController.showShimmer == true))
                          ? GridView.builder(
                              controller: scrollController,
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              itemCount: 12,
                              physics: Platform.isIOS
                                  ? ClampingScrollPhysics()
                                  : AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      childAspectRatio: 0.38.h,
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 5.sp,
                                      crossAxisSpacing: 5.sp),
                              itemBuilder: (context, index) {
                                // Trigger loadMore function when arriving at index 12

                              return SubItemShim();
                            },
                          )
                        : ( (departmentsController.itemsData.isEmpty ||
                          departmentsController.itemsData == []) &&
                          (departmentsController.showShimmer == false) )
                            ? EmptyWidget(
                                text: "لا يوجد منتجات من هذا النوع",
                                height: 90.w,
                                width: 90.w,
                                iconName: Assets.lottie.emptyItems,
                              )
                            : GridView.builder(
                                controller: scrollController,
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                itemCount: (departmentsController.haveMoreData)
                                    ? departmentsController.itemsData.length + 1
                                    : departmentsController.itemsData.length,
                                physics: Platform.isIOS
                                    ? ClampingScrollPhysics()
                                    : AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        childAspectRatio: 0.38.h,
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 5.sp,
                                        crossAxisSpacing: 5.sp),
                                itemBuilder: (context, index) {
                                  if (index ==
                                      departmentsController.itemsData.length) {
                                    // Show loader at the end
                                    return departmentsController
                                            .showSpinKitMoreData
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
                                            productId: departmentsController
                                                .itemsData[index].id!
                                                .toInt());

                                    bool inCart =
                                        cartController.checkCartItemProductId(
                                      productId: departmentsController
                                          .itemsData[index].id!
                                          .toInt(),
                                      selectedSize: "",
                                    );

                                    return InkWell(
                                      hoverColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      overlayColor: WidgetStatePropertyAll(
                                          Colors.transparent),
                                      onTap: () async {
                                        await pageMainScreenController
                                            .changePositionScroll(
                                                departmentsController
                                                    .itemsData[index].id
                                                    .toString(),
                                                0);
                                        await productItemController
                                            .clearItemsData();
                                        await apiProductItemController
                                            .cancelRequests();
                                        NavigatorApp.push(ProductItemView(
                                          item: departmentsController
                                              .itemsData[index],
                                          isFeature: false,
                                          sizes: widget.sizes,
                                        ));
                                      },
                                      child: UiSpecificSubMain(
                                        favourite: favourite,
                                        index: index,
                                        inCart: inCart,
                                        item: departmentsController
                                            .itemsData[index],
                                      ),
                                    );
                                  },
                                )),
                )
              ],
            ),
          );
  }
}
