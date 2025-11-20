import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/views/pages/home/main_screen/section_items.dart';
import 'package:fawri_app_refactor/views/pages/home/main_screen/widget_items_viewed.dart';
import '../../../../controllers/fetch_controller.dart';
import '../../../../controllers/points_controller.dart';
import '../../../../core/dialogs/dialogs_rating/dialog_rating.dart';
import '../../../../core/utilities/global/app_global.dart';
import '../../../../core/utilities/print_looger.dart';
import '../../../../core/utilities/style/colors.dart';
import '../../../../core/widgets/widgets_main_screen/button_spin_order.dart';
import '../../../../core/widgets/widgets_main_screen/marguee_visibality.dart';
import '../../../../core/widgets/widgets_main_screen/show11.dart';
import '../../../../core/widgets/widgets_main_screen/show_big_small_categories.dart';
import '../../../../core/widgets/widgets_main_screen/titles.dart';
import '../../../../models/products_view_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../controllers/rating_controller.dart';
import '../../searchandfilterandgame/widget_search_filter.dart';
import '../../../../controllers/order_controller.dart';
import '../../../../controllers/page_main_screen_controller.dart';
import '../../../../controllers/sub_main_categories_conrtroller.dart';
import '../../departments/basic_departments.dart';
import 'get_sliders.dart';
import 'more_data_home.dart';
import 'products_list.dart';
import 'survey_form_page.dart';

class PageMainScreen extends StatefulWidget {
  const PageMainScreen({super.key});

  @override
  State<PageMainScreen> createState() => _PageMainScreenState();
}

class _PageMainScreenState extends State<PageMainScreen>
    with AutomaticKeepAliveClientMixin {
  ScrollController mainScrollController = ScrollController();
  bool _isScrollingToTop = false;
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  PageMainScreenController? pageMainScreenController;
  static const String surveyFormUrl = "https://forms.gle/kt8LTL7ufMStAxxq7";

  @override
  void initState() {
    super.initState();

    // Listen for refresh trigger from controller
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Add listener to detect refresh trigger
      pageMainScreenController = context.read<PageMainScreenController>();
      pageMainScreenController!.addListener(_onRefreshTriggered);
      await initializeMainScreen();
    });
  }

  /// Handle refresh trigger from controller
  void _onRefreshTriggered() {
    // Check if widget is still mounted and controller exists
    if (!mounted || pageMainScreenController == null) return;

    if (pageMainScreenController!.doRefresh && !_isScrollingToTop) {
      // Only trigger if user is not already at the top of the page
      if (mainScrollController.hasClients &&
          mainScrollController.position.pixels > 100) {
        scrollToTopAndRefresh();
      } else {
        // Already at top, just reset the refresh flag
        pageMainScreenController!.changeDoRefresh(false);
      }
    }
  }

  /// Scroll to top and trigger refresh with loading indicator
  Future<void> scrollToTopAndRefresh() async {
    if (_isScrollingToTop || !mounted || pageMainScreenController == null) {
      return;
    }
    _isScrollingToTop = true;

    try {
      // Check if scroll controller is still valid before using it
      if (mainScrollController.hasClients) {
        // Scroll to top with animation
        await mainScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }

      // Reset the refresh flag
      if (pageMainScreenController != null) {
        await pageMainScreenController!.changeDoRefresh(false);
      }

      // Trigger RefreshIndicator to show loading animation
      if (mounted && refreshIndicatorKey.currentState != null) {
        await refreshIndicatorKey.currentState!.show();
      }
    } catch (e) {
      printLog('Error in scroll to top and refresh: $e');
    } finally {
      _isScrollingToTop = false;
    }
  }

  Widget buildSurveyBanner() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: GestureDetector(
        onTap: () async {
          if (!mounted) return;
          await NavigatorApp.push(SurveyFormPage(url: surveyFormUrl));
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: SizedBox(
            height: 150.h,
            width: double.infinity,
            child: Assets.images.formFawri.image(
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  /// Initialize main screen with parallel execution and comprehensive error handling
  Future<void> initializeMainScreen() async {
    try {
      FocusScope.of(context).unfocus();

      // Get all required controllers
      final PageMainScreenController pageMainScreenController =
          context.read<PageMainScreenController>();
      final FetchController fetchController = context.read<FetchController>();
      final PointsController pointsControllerClass =
          context.read<PointsController>();
      final RatingController ratingController =
          context.read<RatingController>();
      final OrderControllerSalah orderControllerSalah =
          context.read<OrderControllerSalah>();

      final prefs = await SharedPreferences.getInstance();
      final String phone = prefs.getString('phone') ?? "";

      // Phase 1: Parallel execution of SharedPreferences operations
      await initializeSharedPreferences(
        ratingController: ratingController,
        fetchController: fetchController,
      );

      // Phase 2: Parallel execution of API calls
      await initializeAPIData(
        pointsControllerClass: pointsControllerClass,
        pageMainScreenController: pageMainScreenController,
        phone: phone,
      );

      // Phase 3: Handle rating dialog if needed
      await handleRatingDialog(
        pageMainScreenController: pageMainScreenController,
        phone: phone,
      );

      // Phase 4: Refresh app data if needed
      await refreshAppDataIfNeeded(
        pageMainScreenController: pageMainScreenController,
      );

      // Phase 5: Initialize orders
      await initializeOrders(
        orderControllerSalah: orderControllerSalah,
        phone: phone,
      );
    } catch (e) {
      printLog(e.toString());
    }
  }

  /// Initialize SharedPreferences data in parallel
  Future<void> initializeSharedPreferences({
    required RatingController ratingController,
    required FetchController fetchController,
  }) async {
    try {
      await Future.wait<void>([
        ratingController.getIsRating().catchError((e) {
          printLog(e.toString());
          throw e;
        }),
        fetchController.getWheelCoupon().catchError((e) {
          printLog(e.toString());
          throw e;
        }),
        fetchController.showFawrForm().catchError((e) {
          printLog(e.toString());
          throw e;
        }),
      ]);
    } catch (e) {
      printLog(e.toString());
    }
  }

  /// Initialize API data in parallel
  Future<void> initializeAPIData({
    required PointsController pointsControllerClass,
    required PageMainScreenController pageMainScreenController,
    required String phone,
  }) async {
    try {
      await Future.wait<void>([
        pointsControllerClass.getPointsFromAPI(phone: phone).catchError((e) {
          printLog(e.toString());
          throw e;
        }),
        pageMainScreenController.returnFirstImageEachMain().catchError((e) {
          printLog(e.toString());
          throw e;
        }),
      ]);
    } catch (e) {
      printLog(e.toString());
    }
  }

  /// Handle rating dialog display logic
  Future<void> handleRatingDialog({
    required PageMainScreenController pageMainScreenController,
    required String phone,
  }) async {
    try {
      if (phone != "" && !pageMainScreenController.wasShowRateOrder) {
        if (pageMainScreenController.userActivity.checkOrderStatus?.success ==
            true) {
          await dialogRatingSet();
        } else {
          await pageMainScreenController.changeWasFirstShowRateOrder(true);
        }
      }
    } catch (e) {
      printLog(e.toString());
    }
  }

  /// Refresh app data if needed with parallel execution
  Future<void> refreshAppDataIfNeeded({
    required PageMainScreenController pageMainScreenController,
  }) async {
    try {
      if (!pageMainScreenController.fetchAppSection ||
          pageMainScreenController.doRefresh) {
        await pageMainScreenController.changeDoRefresh(false);
        await pageMainScreenController.resetPagesNumber();

        // Run all data fetching operations in parallel
        await Future.wait<void>([
          pageMainScreenController.getCachedProducts().catchError((e) {
            printLog(e.toString());
            throw e;
          }),
          pageMainScreenController.getAllSliders().catchError((e) {
            printLog(e.toString());
            throw e;
          }),
          pageMainScreenController.getItemsViewed().catchError((e) {
            printLog(e.toString());
            throw e;
          }),
          pageMainScreenController.fetchRecommendedItems().catchError((e) {
            printLog(e.toString());
            throw e;
          }),
          pageMainScreenController.getAppSections().catchError((e) {
            printLog(e.toString());
            throw e;
          }),
        ]);
      }
    } catch (e) {
      printLog(e.toString());
    }
  }

  /// Initialize orders based on phone availability
  Future<void> initializeOrders({
    required OrderControllerSalah orderControllerSalah,
    required String phone,
  }) async {
    try {
      if (phone != "") {
        await orderControllerSalah.initialsOrders(phone: phone);
      } else {
        await orderControllerSalah.empty();
      }
    } catch (e) {
      printLog(e.toString());
    }
  }

  /// Handle pull-to-refresh with parallel execution and comprehensive error handling
  Future<void> handleRefresh({
    required PageMainScreenController pageMainScreenController,
    required OrderControllerSalah orderControllerSalah,
    required SubMainCategoriesController subMainCategoriesController,
  }) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String phone = prefs.getString('phone') ?? "";

      // Reset page numbers first
      await pageMainScreenController.resetPagesNumber();
      await pageMainScreenController.clearMoreData();
      // await subMainCategoriesController.clear();

      // Phase 1: Parallel execution of main data fetching operations
      await refreshMainData(
        pageMainScreenController: pageMainScreenController,
        subMainCategoriesController: subMainCategoriesController,
      );

      // Phase 2: Refresh orders based on phone availability
      await initializeOrders(
        orderControllerSalah: orderControllerSalah,
        phone: phone,
      );
    } catch (e) {
      printLog(e.toString());
    }
  }

  /// Refresh main data in parallel
  Future<void> refreshMainData({
    required PageMainScreenController pageMainScreenController,
    required SubMainCategoriesController subMainCategoriesController,
  }) async {
    try {
      // Run all data fetching operations in parallel
      await Future.wait<void>([
        pageMainScreenController.getCachedProducts().catchError((e) {
          printLog(e.toString());
          throw e;
        }),
        pageMainScreenController.getAllSliders().catchError((e) {
          printLog(e.toString());
          throw e;
        }),
        pageMainScreenController.getAppSections().catchError((e) {
          printLog(e.toString());
          throw e;
        }),
        pageMainScreenController.fetchRecommendedItems().catchError((e) {
          printLog(e.toString());
          throw e;
        }),
        pageMainScreenController.getItemsViewed().catchError((e) {
          printLog(e.toString());
          throw e;
        }),
        pageMainScreenController.getProductMoreData().catchError((e) {
          printLog(e.toString());
          throw e;
        }),
      ]);
    } catch (e) {
      printLog(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    PageMainScreenController pageMainScreenController =
        context.watch<PageMainScreenController>();
    FetchController fetchController = context.watch<FetchController>();
    SubMainCategoriesController subMainCategoriesController =
        context.watch<SubMainCategoriesController>();
    OrderControllerSalah orderControllerSalah =
        context.watch<OrderControllerSalah>();
    // FreeGiftController freeGiftController = context.watch<FreeGiftController>();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   checkForSurpriseGift(context, freeGiftController);
    // });

    final spacer = SizedBox(height: 7.h);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        children: [
          SafeArea(
            child: RefreshIndicator(
              key: refreshIndicatorKey,
              onRefresh: () => handleRefresh(
                pageMainScreenController: pageMainScreenController,
                orderControllerSalah: orderControllerSalah,
                subMainCategoriesController: subMainCategoriesController,
              ),
              strokeWidth: 2,
              color: CustomColor.blueColor,
              child: Column(
                children: [
                  WidgetSearchFilter(),
                  Expanded(
                    child: CustomScrollView(
                      controller: mainScrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              Show11(),
                              Sliders(
                                sliders: pageMainScreenController.cashedSliders,
                                withCategory: false,
                                showShadow: true,
                                click: true,
                              ),
                              ProductsViewInList(
                                configModel: ProductsViewConfigModel(
                                  hasAnimatedBorder: true,
                                  numberStyle: 1,
                                  bgColor: Colors.transparent,
                                  hasBellChristmas: true,
                                  colorsGradient: [
                                    CustomColor.blueColor,
                                    CustomColor.chrismasColor
                                  ],
                                  changeLoadingProduct: pageMainScreenController
                                      .changeLoadingProductNewArrival,
                                  scrollController: pageMainScreenController
                                      .scrollControllerNewArrival,
                                  listItems:
                                      pageMainScreenController.shortlisted,
                                  isLoadingProduct: pageMainScreenController
                                      .isLoadingProductNewArrival,
                                  flag: 1,
                                ),
                              ),
                              BasicDepartments(
                                discountCategories:
                                    fetchController.discountCategories,
                              ),
                              ShowBigSmallCategories(
                                isCategory: true,
                              ),
                              ButtonSpinOrder(),

                              spacer,
                              Sliders(
                                sliders: pageMainScreenController.slidersUrl,
                                click: true,
                                showShadow: true,
                                withCategory: true,
                              ),
                              if(fetchController.showFormFawri==true)spacer,
                              
                              // if (hours > 0) FlashSalesMain(),
                              // if (hours > 0)
                              //   SizedBox(
                              //     height: 7.h,
                              //   ),
                              if(fetchController.showFormFawri==true)buildSurveyBanner(),
                              if (pageMainScreenController.itemsViewed.length >=
                                  4)
                                WidgetItemsViewed(),
                              Titles(
                                text: "خصيصاً لك",
                                showEven: fetchController.showEven,
                                flag: 1,
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              Container(
                                color: Colors.white,
                                child: ProductsViewInList(
                                  configModel: ProductsViewConfigModel(
                                    hasAnimatedBorder: true,
                                    numberStyle: 1,
                                    flag: 0,
                                    bgColor: Colors.transparent,
                                    changeLoadingProduct: pageMainScreenController
                                        .changeLoadingProductRecommendedItems,
                                    scrollController: pageMainScreenController
                                        .scrollRecommendedItems,
                                    listItems: pageMainScreenController
                                        .recommendedItems,
                                    isLoadingProduct: pageMainScreenController
                                        .isLoadingRecommendedItems,
                                  ),
                                ),
                              ),
                              spacer,
                              MargueeVisibality(),
                              SizedBox(
                                height: 2.h,
                              ),
                              SectionItems(),
                            ],
                          ),
                        ),
                        MoreDataHome(
                          nameScrollTyeProduct:
                              pageMainScreenController.scrollMoreDataItems,
                          scrollController: mainScrollController,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
