import 'package:chips_choice/chips_choice.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import '../../../controllers/search_controller.dart';
import '../../../models/constants/constant_model.dart';
import '../../utilities/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utilities/style/text_style.dart';
import '../custom_button.dart';
import '../widgets_main_screen/titles.dart';

class WidgetSubCategoryFilter extends StatefulWidget {
  const WidgetSubCategoryFilter({super.key});

  @override
  State<WidgetSubCategoryFilter> createState() =>
      _WidgetSubCategoryFilterState();
}

class _WidgetSubCategoryFilterState extends State<WidgetSubCategoryFilter> {
  @override
  Widget build(BuildContext context) {
    SearchItemController searchItemController =
        context.watch<SearchItemController>();
    return Column(
      children: [
        (searchItemController.subCategoriesSearch.isEmpty)
            ? SizedBox()
            : Padding(
                padding: EdgeInsets.all(8.w),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Titles(
                    text: "الأقسام الفرعية",
                    flag: 0,
                    showEven: 0,
                  ),
                ),
              ),
        (searchItemController.subCategoriesSearch.isEmpty)
            ? SizedBox()
            : Container(
                // width: double.maxFinite,
                margin: EdgeInsets.only(left: 8.w, right: 8.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black,
                        blurRadius: 1,
                        blurStyle: BlurStyle.outer)
                  ],
                  color: Colors.transparent,
                ),
                child: ChipsChoice<CategoryModel>.multiple(
                  clipBehavior: Clip.antiAlias,
                  onChanged: (value) async {
                    await searchItemController.setListSubItemSearch(value);
                  },
                  value: searchItemController.listSelectedSubMain,
                  choiceCheckmark: true,
                  mainAxisAlignment: MainAxisAlignment.center,
                  choiceItems: C2Choice.listFrom(
                    source: searchItemController.subCategoriesSearch,
                    value: (index, item) => item,
                    label: (index, item) => item.name,
                  ),
                  choiceLabelBuilder: (item, i) => Text(
                    item.label,
                    style: CustomTextStyle()
                        .heading1L
                        .copyWith(color: Colors.black, fontSize: 12.sp),
                  ),
                  choiceLeadingBuilder: (item, i) => (searchItemController
                          .listSelectedSubMain
                          .contains(item.value))
                      ? IconSvg(
                          nameIcon: Assets.icons.yes,
                          onPressed: null,
                          width: 25.w,
                          height: 25.w,
                          backColor: Colors.transparent,
                        )
                      : SizedBox(),
                ),
              ),
        (searchItemController.subCategoriesSearch.isEmpty ||
                searchItemController.listSelectedSubMain.isEmpty)
            ? SizedBox()
            : SizedBox(
                height: 5.h,
              ),
        (searchItemController.subCategoriesSearch.isEmpty ||
                searchItemController.listSelectedSubMain.isEmpty)
            ? SizedBox()
            : Padding(
                padding: EdgeInsets.all(8.w),
                child: SizedBox(
                  height: 0.05.sh,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    itemBuilder: (context, index) => Container(
                      margin: EdgeInsets.only(right: 8.w),
                      child: Stack(
                        alignment: Alignment.topRight,
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                              margin: EdgeInsets.only(left: 12.w, right: 8.w),
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                  color: CustomColor.blueColor,
                                  borderRadius: BorderRadius.circular(8.r)),
                              child: Text(
                                searchItemController
                                    .listSelectedSubMain[index].name,
                                style: CustomTextStyle().heading1L.copyWith(
                                    color: Colors.white, fontSize: 12.sp),
                              )),
                          Positioned(
                            right: -5.w,
                            top: -6.h,
                            child: IconSvg(
                              nameIcon: Assets.icons.cancel,
                              backColor: CustomColor.primaryColor,
                              colorFilter: ColorFilter.mode(
                                  Colors.white, BlendMode.srcIn),
                              onPressed: () async {
                                await searchItemController.removeSubItemFilter(
                                    searchItemController
                                        .listSelectedSubMain[index]);
                              },
                              height: 20.w,
                              width: 20.w,
                            ),
                          )
                        ],
                      ),
                    ),
                    itemCount: searchItemController.listSelectedSubMain.length,
                  ),
                ),
              ),
      ],
    );
  }
}
