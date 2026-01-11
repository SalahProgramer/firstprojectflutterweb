import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/controllers/departments_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/showcase_controller.dart';
import 'package:fawri_app_refactor/salah/utilities/style/text_style.dart';
import 'package:fawri_app_refactor/salah/widgets/custom_button.dart';
import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:popover/popover.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../../server/functions/functions.dart';
import '../../../models/constants/constant_model.dart';
import '../../../utilities/style/colors.dart';
import '../../../widgets/departments_home_widgets/show_sorting.dart';
import 'game.dart';

class WidgetSearchFilter extends StatefulWidget {
  final bool? haveSort;
  final ScrollController? scrollController;
  final String? sizes;
  final CategoryModel? category;

  const WidgetSearchFilter({
    super.key,
    this.haveSort = false,
    this.scrollController,
    this.sizes = "",
    this.category,
  });

  @override
  State<WidgetSearchFilter> createState() => _WidgetSearchFilterState();
}

class _WidgetSearchFilterState extends State<WidgetSearchFilter> {
  GlobalKey two = GlobalKey();
  bool _isWaitingForSizeShowcase = false;
  bool _showcaseTriggered = false;

  @override
  void initState() {
    super.initState();

    // Listen for size showcase completion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.haveSort == true) {
        _checkAndShowSortShowcase();
      }
    });
  }

  @override
  void dispose() {
    _showcaseTriggered = false;
    _isWaitingForSizeShowcase = false;
    super.dispose();
  }

  void _checkAndShowSortShowcase() {
    if (!mounted || _showcaseTriggered) return;

    try {
      ShowcaseController showcaseController = context
          .read<ShowcaseController>();

      printLog("showcaseSizeShown: ${showcaseController.showcaseSizeShown}");
      printLog("showcaseSortShown: ${showcaseController.showcaseSortShown}");

      // If size showcase has been shown but sort hasn't
      if (showcaseController.showcaseSizeShown &&
          !showcaseController.showcaseSortShown) {
        // Wait 1 second then show sort showcase
        printLog(
          "Size showcase completed! Waiting 1 second before showing sort showcase...",
        );
        _showcaseTriggered = true;

        Future.delayed(Duration(seconds: 1)).then((_) {
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                try {
                  ShowCaseWidget.of(context).startShowCase([two]);
                  showcaseController.markSortShowcaseShown();
                } catch (e) {
                  printLog("Error showing sort showcase: $e");
                }
              }
            });
          }
        });
      } else if (!showcaseController.showcaseSizeShown &&
          !_isWaitingForSizeShowcase) {
        // Size showcase hasn't been shown yet, we'll wait for it via provider
        _isWaitingForSizeShowcase = true;
        printLog("Waiting for size showcase to complete...");
      }
    } catch (e) {
      printLog("Error in _checkAndShowSortShowcase: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    AnalyticsService analyticsService = AnalyticsService();
    // SearchItemController searchController = context
    //     .watch<SearchItemController>();
    // FetchController fetchController = context.watch<FetchController>();
    DepartmentsController departmentsController = context
        .watch<DepartmentsController>();
    ShowcaseController showcaseController = context.watch<ShowcaseController>();

    // Watch for size showcase completion to trigger sort showcase
    if (widget.haveSort == true &&
        showcaseController.showcaseSizeShown &&
        !showcaseController.showcaseSortShown &&
        _isWaitingForSizeShowcase &&
        !_showcaseTriggered) {
      _isWaitingForSizeShowcase = false;
      _showcaseTriggered = true;
      printLog(
        "Size showcase just completed via provider! Triggering sort showcase...",
      );

      // Wait 3 seconds then show sort showcase
      Future.delayed(Duration(seconds: 3)).then((_) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              try {
                ShowCaseWidget.of(context).startShowCase([two]);
                showcaseController.markSortShowcaseShown();
              } catch (e) {
                printLog("Error showing sort showcase in build: $e");
              }
            }
          });
        }
      });
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          // Welcome Text Section
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Welcome Title
                Row(
                  textDirection: TextDirection.rtl,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (widget.haveSort==true)?"اختيار الترتيب": 'اهلا بك',
                      style: CustomTextStyle().heading1L.copyWith(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    // Decorative sparkle icons
                    ...List.generate(3, (index) => Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: Text(
                        '✨',
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    )),
                  ],
                ),
                SizedBox(height: 3.h),
                // Subtitle with sparkle
                Row(
                  textDirection: TextDirection.rtl,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (widget.haveSort==true)?"هنا يتم اختيار ترتيب المنتجات ♻︎": 'حلّق بداش وتجاوز الحواجز… 🚀',
                      style: CustomTextStyle().heading1L.copyWith(
                        fontSize: 14.sp,
                        color: CustomColor.blueColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          
          // Search/Filter Row
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // InkWell(
                //   highlightColor: Colors.transparent,
                //   overlayColor: WidgetStateColor.transparent,
                //   focusColor: WidgetStateColor.transparent,
                //   onTap: () async {
                //     FocusScope.of(context).unfocus();
                //     dialogWaiting();
                //     // if (searchController.categoriesSearch.isEmpty) {
                //     await searchController.getCategories();
                //     NavigatorApp.pop();
                //     NavigatorApp.push(
                //       WidgetFilter(
                //         scrollController: searchController.scrollFilterItems,
                //       ),
                //     );
                //   },
                //   child: LottieWidget(name: Assets.lottie.filter),
                // ),

                // SizedBox(width: 5.w),
                // Expanded(
                //   flex: (widget.haveSort == true) ? 1 : 6,
                //   child: CustomTextFormField(
                //     hintText: 'ابحث',
                //     hasFill: true,
                //     hasTap: true,
                //     hasFocusBorder: (fetchController.showEven == 1) ? false : true,
                //     onTap: () async {
                //       FocusScope.of(context).unfocus();
                //       dialogWaiting();
                //       // if (searchController.categoriesSearch.isEmpty) {
                //       await searchController.getCategories();
                //       // }
                //
                //       NavigatorApp.pop();
                //       NavigatorApp.pushAnimation(
                //         MainSearch(
                //           scrollController: searchController.scrollSearchItems,
                //         ),
                //       );
                //     },
                //     prefixIcon: Padding(
                //       padding: EdgeInsets.all(2.w),
                //       child: LottieWidget(
                //         name: Assets.lottie.search1,
                //         width: 18.w,
                //         height: 18.w,
                //       ),
                //     ),
                //     alignLabelWithHint: true,
                //     inputType: TextInputType.text,
                //     controller: searchController.nullSearch,
                //     controlPage: searchController,
                //     maxLines: 1,
                //   ),
                // ),
                // if (widget.haveSort == true) SizedBox(width: 5.w),
                if (widget.haveSort == true)
                  IconSvg(
                    nameIcon: (departmentsController.numSort == 1)
                        ? Assets.icons.sorting
                        : Assets.icons.random,
                    backColor: Colors.transparent,
                    height: 65.w,
                    width: 65.w,
                    onPressed: () async {
                      await analyticsService.logEvent(
                        eventName: "sort_icon_pressed",
                        parameters: {
                          "class_name": "WidgetSearchFilter",
                          "button_name": "sort icon pressed ",
                          "sort_type": (departmentsController.numSort == 1)
                              ? "sorting"
                              : "random",
                          "time": DateTime.now().toString(),
                        },
                      );
                      FocusScope.of(context).unfocus();
                      showPopover(
                        context: context,
                        bodyBuilder: (context) => ShowSorting(
                          scrollController: widget.scrollController!,
                          sizes: widget.sizes,
                          category: widget.category,
                        ),
                        direction: PopoverDirection.bottom,
                        backgroundColor: Colors.white,
                        barrierColor: Colors.transparent,
                        width: 0.4.sw,
                        shadow: [
                          BoxShadow(
                            blurRadius: 40.r,
                            color: Colors.blueGrey,
                            blurStyle: BlurStyle.outer,
                            spreadRadius: 0,
                          ),
                        ],
                        arrowDxOffset: -130.w,
                        arrowDyOffset: -25.h,
                      );

                      // sort(
                      //     sizes: widget.sizes ?? "",
                      //     category: widget.category,
                      //     scrollController: widget.scrollController!);
                    },
                  ),
                if (widget.haveSort == false) SizedBox(width: 2.w),
                if (widget.haveSort == false)
                  ShowCaseWidget(
                    builder: (context) => CustomGameWidget(haveSort: widget.haveSort),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
