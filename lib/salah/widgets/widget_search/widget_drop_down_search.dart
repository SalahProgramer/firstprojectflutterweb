import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/widgets/widgets_item_view/button_done.dart';
import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../server/functions/functions.dart';
import '../../controllers/APIS/api_product_item.dart';
import '../../controllers/page_main_screen_controller.dart';
import '../../controllers/product_item_controller.dart';
import '../../controllers/search_controller.dart';
import '../../models/constants/constant_model.dart';
import '../../utilities/global/app_global.dart';
import '../../utilities/style/colors.dart';
import '../../utilities/style/text_style.dart';
import '../../views/pages/home/main_screen/product_item_view.dart';
import '../../views/pages/searchandfilterandgame/customs_bottom_sheets.dart';
import '../lottie_widget.dart';

class WidgetDropDownSearch extends StatefulWidget {
  final ScrollController scrollController;

  const WidgetDropDownSearch({super.key, required this.scrollController});

  @override
  State<WidgetDropDownSearch> createState() => _WidgetDropDownSearchState();
}

class _WidgetDropDownSearchState extends State<WidgetDropDownSearch> {
  // SingleSelectController for managing item selection
  @override
  Widget build(BuildContext context) {
    SearchItemController searchController =
        context.watch<SearchItemController>();

    PageMainScreenController pageMainScreenController =
        context.watch<PageMainScreenController>();
    ProductItemController productItemController =
        context.watch<ProductItemController>();
    ApiProductItemController apiProductItemController =
        context.watch<ApiProductItemController>();
    AnalyticsService analyticsService = AnalyticsService();

    return Padding(
        padding: EdgeInsets.all(8.w),
        child: CustomDropdown<CategoryModel>.searchRequest(
          futureRequest: (String query) async {
            printLog("Search query: $query");
            List<CategoryModel> results = [];
            await searchController.setTextSearch(query.toString().trim());
            for (var i in searchController.categoriesSearch) {
              if (i.name
                  .toString()
                  .trim()
                  .toLowerCase()
                  .contains(query.toString().trim().toLowerCase())) {
                results.add(i);
              }
            }

            return results;
          },
          hintText:
              ' ابحث القسم أو نوع القسم أو Tag أو أدخل رقم المنتج أو رقم ال sku',
          noResultFoundText: "لا يوجد نتائج",
          initialItem: (searchController.itemSearch.name == "")
              ? null
              : searchController.itemSearch,
          headerBuilder: (context, selectedItem, enabled) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                selectedItem.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: CustomTextStyle().heading1L.copyWith(
                      color: Colors.black,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.asset(
                  selectedItem.image,
                  height: 50.w,
                  width: 50.w,
                ),
              ),
            );
          },
          searchHintText: "ابحث أو أدخل رقم المنتج أو رقم ال sku ",
          overlayHeight: 0.5.sh,
          decoration: CustomDropdownDecoration(
              expandedShadow: [
                BoxShadow(
                    color: Colors.black,
                    blurStyle: BlurStyle.outer,
                    blurRadius: 5)
              ],
              noResultFoundStyle: CustomTextStyle().heading1L.copyWith(
                    color: Colors.black,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 15.sp,

                    fontWeight: FontWeight.bold,
                    // decorationThickness: 1.5,
                  ),
              headerStyle: CustomTextStyle().heading1L.copyWith(
                    color: Colors.black,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 14.sp,

                    fontWeight: FontWeight.bold,
                    // decorationThickness: 1.5,
                  ),
              searchFieldDecoration: SearchFieldDecoration(
                textStyle: CustomTextStyle().heading1L.copyWith(
                      color: Colors.black,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 14.sp,

                      fontWeight: FontWeight.bold,
                      // decorationThickness: 1.5,
                    ),
                constraints: BoxConstraints(maxHeight: 60.h, minHeight: 55.h),
                hintStyle: CustomTextStyle().heading1L.copyWith(
                      color: Colors.black45,

                      overflow: TextOverflow.ellipsis,
                      fontSize: 12.sp,

                      fontWeight: FontWeight.bold,
                      // decorationThickness: 1.5,
                    ),
                prefixIcon: LottieWidget(
                  name: Assets.lottie.search1,
                  width: 30.w,
                  height: 30.w,
                ),
              ),
              hintStyle: CustomTextStyle().heading1L.copyWith(
                    color: Colors.black45,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 12.sp,

                    fontWeight: FontWeight.bold,
                    // decorationThickness: 1.5,
                  )),
          items: searchController.categoriesSearch,
          excludeSelected: false,
          maxlines: 2,
          hideSelectedFieldWhenExpanded: false,
          noResultFoundBuilder: (context, text) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "لا يوجد نتائج!! هل تبحث عن رقم المنتج أو ال SKU",
                style: CustomTextStyle().heading1L.copyWith(
                      color: Colors.black,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 10.h),
              ButtonDone(
                  text: "بحث",
                  iconName: Assets.icons.yes,
                  isLoading: searchController.isLoadingSearch,
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    await searchController.changeLoadingSearch(true);
                    await pageMainScreenController.changePositionScroll(
                        text.toString().trim(), 0);
                    await productItemController.clearItemsData();

                    await productItemController.getSpecificProduct(
                      searchController.searchText.toString().trim(),
                    );

                    if (productItemController.isTrue == true) {
                      await searchController.changeLoadingSearch(false);
                      await apiProductItemController.cancelRequests();
                      NavigatorApp.push(ProductItemView(
                        item: productItemController.specificItemData!,
                        sizes: '',
                      ));
                    }
                    await searchController.changeLoadingSearch(false);
                  })
            ],
          ),
          listItemBuilder: (context, item, isSelected, onItemSelect) {
            return ListTile(
              selectedColor: CustomColor.blueColor,
              contentPadding: EdgeInsets.zero,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              title: Text(
                item.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: CustomTextStyle().heading1L.copyWith(
                      color: Colors.black,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 14.sp,

                      fontWeight: FontWeight.bold,
                      // decorationThickness: 1.5,
                    ),
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.asset(
                  item.image,
                  height: 50.w,
                  width: 50.w,
                  fit: BoxFit.cover,
                ),
              ),
              onTap: () async {
                await analyticsService.logEvent(
                  eventName: "dropdown_search_item_select",
                  parameters: {
                    "class_name": "WidgetDropDownSearch",
                    "button_name": "dropdown_search_item_select ",
                    "category_id": item.id?.toString() ?? "",
                    "category_name": item.name,
                    "time": DateTime.now().toString(),
                  },
                );
                onItemSelect();

                printLog(
                    "ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss");
                if (searchController.itemSearch == item) {
                  await showItemSearch(
                      scrollController: widget.scrollController, sizes: '');
                }
                await searchController.setItemSearch(item);
              },
            );
          },
          onChanged: (value) async {
            await searchController.setItemSearch(value!);
            await searchController.clear();
            await searchController.getSearch();
          },
        ));
  }
}
