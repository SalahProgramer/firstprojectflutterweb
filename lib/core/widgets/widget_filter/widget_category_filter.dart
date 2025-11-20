import 'package:chips_choice/chips_choice.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../controllers/search_controller.dart';
import '../../../models/constants/constant_model.dart';
import '../../utilities/style/colors.dart';
import '../../utilities/style/text_style.dart';
import '../custom_button.dart';
import '../widgets_main_screen/titles.dart';

class WidgetCategoryFilter extends StatefulWidget {
  const WidgetCategoryFilter({super.key});

  @override
  State<WidgetCategoryFilter> createState() => _WidgetCategoryFilterState();
}

class _WidgetCategoryFilterState extends State<WidgetCategoryFilter> {
  @override
  Widget build(BuildContext context) {
    SearchItemController searchItemController =
        context.watch<SearchItemController>();
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.w),
          child: Align(
            alignment: Alignment.centerRight,
            child: Titles(
              text: "الأقسام الرئيسية",
              flag: 0,
              showEven: 0,
            ),
          ),
        ),

        Container(
          height: 0.128.sh,
          width: double.maxFinite,
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
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: ChipsChoice<CategoryModel>.single(
              onChanged: (value) async {
                await searchItemController.setItemCategory(value);
              },
              value: searchItemController.itemCategory,
              choiceCheckmark: true,
              choiceLabelBuilder: (item, i) => Text(
                item.label,
                style: CustomTextStyle()
                    .heading1L
                    .copyWith(color: Colors.black, fontSize: 12.sp),
              ),
              choiceLeadingBuilder: (item, i) =>
                  (item.value == searchItemController.itemCategory)
                      ? IconSvg(
                          nameIcon: Assets.icons.yes,
                          onPressed: null,
                          width: 25.w,
                          height: 25.w,
                          backColor: Colors.transparent,
                        )
                      : SizedBox(),
              wrapped: true,
              mainAxisAlignment: MainAxisAlignment.center,
              choiceItems: C2Choice.listFrom(
                source: searchItemController.categories,
                value: (index, item) => item,
                label: (index, item) => item.name,
              ),
            ),
          ),
        ),
        // (searchItemController.selectTag.name == "")
        //     ? SizedBox()
        //     : SizedBox(
        //         height: 5.h,
        //       ),
        (searchItemController.itemCategory.name == "")
            ? SizedBox()
            : Padding(
                padding: EdgeInsets.only(top: 8.w),
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
                          searchItemController.itemCategory.name,
                          style: CustomTextStyle()
                              .heading1L
                              .copyWith(color: Colors.white, fontSize: 12.sp),
                        )),
                    // Positioned(
                    //   right: -10.w,
                    //   // Adjust this for horizontal alignment
                    //   top: -10.h,
                    //
                    //   child: IconSvg(
                    //     nameIcon: "cancel",
                    //     backColor: Colors.transparent,
                    //     onPressed: () async {
                    //       await searchItemController.removeTagFilter();
                    //     },
                    //     height: 22.w,
                    //     width: 22.w,
                    //   ),
                    // )
                  ],
                ),
              ),
      ],
    );
  }
}
