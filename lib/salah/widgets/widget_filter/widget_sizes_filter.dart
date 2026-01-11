import 'package:chips_choice/chips_choice.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/utilities/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../controllers/search_controller.dart';
import '../../utilities/style/text_style.dart';
import '../custom_button.dart';
import '../widgets_main_screen/titles.dart';

class WidgetSizesFilter extends StatefulWidget {
  const WidgetSizesFilter({super.key});

  @override
  State<WidgetSizesFilter> createState() => _WidgetSizesFilterState();
}

class _WidgetSizesFilterState extends State<WidgetSizesFilter> {
  @override
  Widget build(BuildContext context) {
    SearchItemController searchItemController = context
        .watch<SearchItemController>();
    return Column(
      children: [
        (searchItemController.sizes.isEmpty)
            ? SizedBox()
            : Padding(
                padding: EdgeInsets.all(8.w),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Titles(text: "الأحجام", flag: 0, showEven: 0),
                ),
              ),
        (searchItemController.sizes.isEmpty)
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
                      blurStyle: BlurStyle.outer,
                    ),
                  ],
                  color: Colors.transparent,
                ),
                child: ChipsChoice<String>.multiple(
                  clipBehavior: Clip.antiAlias,
                  onChanged: (value) async {
                    await searchItemController.setListSizesSearch(value);
                  },
                  value: searchItemController.listSelectedSizes,
                  choiceCheckmark: true,
                  mainAxisAlignment: MainAxisAlignment.center,
                  choiceItems: C2Choice.listFrom(
                    source: searchItemController.sizes,
                    value: (index, item) => item,
                    label: (index, item) => item,
                  ),
                  choiceLabelBuilder: (item, i) => Text(
                    item.label,
                    style: CustomTextStyle().heading1L.copyWith(
                      color: Colors.black,
                      fontSize: 12.sp,
                    ),
                  ),
                  choiceLeadingBuilder: (item, i) =>
                      (searchItemController.listSelectedSizes.contains(
                        item.value,
                      ))
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
        (searchItemController.sizes.isEmpty ||
                searchItemController.listSelectedSizes.isEmpty)
            ? SizedBox()
            : SizedBox(height: 5.h),
        (searchItemController.sizes.isEmpty ||
                searchItemController.listSelectedSizes.isEmpty)
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
                      width: 0.2.sw,
                      clipBehavior: Clip.none,
                      child: Stack(
                        alignment: Alignment.topRight,
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 12.w, right: 8.w),
                            width: 0.2.sw,
                            height: 25.h,
                            clipBehavior: Clip.none,
                            padding: EdgeInsets.all(0.w),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: CustomColor.blueColor,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              searchItemController.listSelectedSizes[index],
                              textAlign: TextAlign.center,
                              style: CustomTextStyle().heading1L.copyWith(
                                color: Colors.white,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                          Positioned(
                            right: -5.w,
                            top: -6.h,
                            child: IconSvg(
                              nameIcon: Assets.icons.cancel,
                              backColor: CustomColor.primaryColor,
                              colorFilter: ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                              onPressed: () async {
                                await searchItemController.removeSizesFilter(
                                  searchItemController.listSelectedSizes[index],
                                );
                              },
                              height: 20.w,
                              width: 20.w,
                            ),
                          ),
                        ],
                      ),
                    ),
                    itemCount: searchItemController.listSelectedSizes.length,
                  ),
                ),
              ),
      ],
    );
  }
}
