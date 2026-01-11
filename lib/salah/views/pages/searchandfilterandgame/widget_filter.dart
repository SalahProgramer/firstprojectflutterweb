import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/widgets/widgets_item_view/button_done.dart';
import 'package:fawri_app_refactor/server/functions/functions.dart';
import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../controllers/search_controller.dart';
import '../../../utilities/global/app_global.dart';
import '../../../widgets/app_bar_widgets/app_bar_custom.dart';
import '../../../widgets/snackBarWidgets/snack_bar_style.dart';
import '../../../widgets/snackBarWidgets/snackbar_widget.dart';
import '../../../widgets/widget_filter/widget_category_filter.dart';
import '../../../widgets/widget_filter/widget_price_filter.dart';
import '../../../widgets/widget_filter/widget_sizes_filter.dart';
import '../../../widgets/widget_filter/widget_sub_category_filter.dart';
import '../../../widgets/widget_filter/widget_tags_filter.dart';
import 'customs_bottom_sheets.dart';

class WidgetFilter extends StatefulWidget {
  final ScrollController scrollController;

  const WidgetFilter({super.key, required this.scrollController});

  @override
  State<WidgetFilter> createState() => _WidgetFilterState();
}

class _WidgetFilterState extends State<WidgetFilter> {
  bool hasReachedIndex = false;

  final ScrollController scrollController = ScrollController();
  AnalyticsService analyticsService = AnalyticsService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SearchItemController searchItemController = context
          .read<SearchItemController>();

      scrollController.addListener(() async {
        final itemWidth = 0.3.sw;
        final itemHeight =
            itemWidth / 0.40.h; // Calculated from childAspectRatio
        final rowHeight = itemHeight + 10; // Add mainAxisSpacing if applicable

        final index25Offset =
            (((searchItemController.subCategories.length ~/ 12)) * 3) *
            rowHeight;
        if (scrollController.offset >= index25Offset && !hasReachedIndex) {
          hasReachedIndex = true;
          if ((scrollController.position.pixels >=
              scrollController.position.maxScrollExtent)) {
            await searchItemController.changeSpinHaveMoreData(true);
          }
          if (widget.scrollController ==
              searchItemController.scrollFilterItems) {
            await searchItemController.getFilter();
          }
          hasReachedIndex = false;
        }
        if ((scrollController.position.extentAfter == 0.0)) {
          if ((searchItemController.haveMoreData == false)) {
            await searchItemController.changeSpinHaveMoreData(false);
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
  Widget build(BuildContext context) {
    SearchItemController searchItemController = context
        .watch<SearchItemController>();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: ButtonDone(
          text: "إجراء الفلترة الأن    ",
          isLoading: searchItemController.isLoading,
          iconName: Assets.icons.yes,
          onPressed: () async {
            await analyticsService.logEvent(
              eventName: "apply_filter_button_click",
              parameters: {
                "class_name": "WidgetFilter",
                "button_name": "إجراء الفلترة الأن",
                "selected_category": searchItemController.itemCategory
                    .toString(),
                "selected_sizes": searchItemController.listSelectedSizes.join(
                  ',',
                ),
                "min_price": searchItemController.minPrice.text,
                "max_price": searchItemController.maxPrice.text,
                "time": DateTime.now().toString(),
              },
            );
            printLog(searchItemController.itemCategory);
            await searchItemController.changeLoading(true);
            await searchItemController.clearItemSearch();
            await searchItemController.clear();

            await searchItemController.getFilter();

            if (searchItemController.subCategories.isEmpty) {
              await searchItemController.changeLoading(false);

              showSnackBar(title: "لا يوجد نتائج", type: SnackBarType.error);
            } else {
              String size = "";

              await searchItemController.changeLoading(false);
              if (searchItemController.listSelectedSizes.isNotEmpty) {
                int index = 0;

                for (var i in searchItemController.listSelectedSizes) {
                  if (index ==
                      searchItemController.listSelectedSizes.length - 1) {
                    size = "$size${i.trim().toString()}";
                  } else {
                    size = "$size${i.trim().toString()},";
                  }
                  index++;
                }
              }

              await showItemFilter(
                scrollController: scrollController,
                sizes: size,
              );
            }
          },
        ),
        appBar: CustomAppBar(
          title: "فلترة ",
          textButton: "رجوع",
          onPressed: () async {
            FocusScope.of(context).unfocus();

            NavigatorApp.pop();
          },
          colorWidgets: Colors.black,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WidgetCategoryFilter(),

              WidgetSubCategoryFilter(),
              WidgetSizesFilter(),

              WidgetTagsFilter(),

              WidgetPriceFilter(),

              // MinMaxPrice(),
            ],
          ),
        ),
      ),
    );
  }
}

// Padding(
//   padding: EdgeInsets.all(8.w),
//   child: Row(
//     children: [
//       Expanded(
//         child: Text(
//           "من :   ",
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           textAlign: TextAlign.left,
//           textDirection: TextDirection.rtl,
//           style: CustomTextStyle().heading1L.copyWith(
//                 color: Colors.black,
//
//                 overflow: TextOverflow.ellipsis,
//                 fontSize: 14.sp,
//
//                 fontWeight: FontWeight.bold,
//                 // decorationThickness: 1.5,
//               ),
//         ),
//       ),
//       SizedBox(
//         width: 5.w,
//       ),
//       Expanded(
//         flex: 4,
//         child: CanCustomTextFormField(
//             hintText: "أقل سعر",
//             seePassword: false,
//             hasSeePassIcon: true,
//             inputType: TextInputType.number,
//             controller: searchItemController.minPrice,
//             controlPage: searchItemController,
//             textStyle: CustomTextStyle()
//                 .heading1L
//                 .copyWith(color: Colors.black, fontSize: 12.sp),
//             maxLines: 1),
//       ),
//       SizedBox(
//         width: 5.w,
//       ),
//       Expanded(
//         child: Text(
//           "إلى :   ",
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           textAlign: TextAlign.left,
//           textDirection: TextDirection.rtl,
//           style: CustomTextStyle().heading1L.copyWith(
//                 color: Colors.black,
//
//                 overflow: TextOverflow.ellipsis,
//                 fontSize: 14.sp,
//
//                 fontWeight: FontWeight.bold,
//                 // decorationThickness: 1.5,
//               ),
//         ),
//       ),
//       SizedBox(
//         width: 5.w,
//       ),
//       Expanded(
//         flex: 4,
//         child: CanCustomTextFormField(
//             hintText: "أعلى سعر",
//             seePassword: false,
//             hasSeePassIcon: true,
//             textStyle: CustomTextStyle()
//                 .heading1L
//                 .copyWith(color: Colors.black, fontSize: 12.sp),
//             inputType: TextInputType.number,
//             controller: searchItemController.maxPrice,
//             controlPage: searchItemController,
//             maxLines: 1),
//       )
//     ],
//   ),
// ),
