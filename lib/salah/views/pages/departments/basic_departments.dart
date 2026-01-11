import 'package:fawri_app_refactor/salah/models/constants/constant_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../constants/constant-categories/constant_data_convert.dart';
import '../../../controllers/fetch_controller.dart';
import '../../../controllers/page_main_screen_controller.dart';
import '../../../widgets/departments_home_widgets/category_specific_widget.dart';
import '../../../widgets/widgets_main_screen/titles.dart';
import '../home/main_screen/get_sliders.dart';

class BasicDepartments extends StatefulWidget {
  final List<int> discountCategories;
  final bool alwaysChangeBig;

  const BasicDepartments({
    super.key,
    required this.discountCategories,
    this.alwaysChangeBig = true,
  });

  @override
  State<BasicDepartments> createState() => _BasicDepartmentsState();
}

class _BasicDepartmentsState extends State<BasicDepartments> {
  @override
  Widget build(BuildContext context) {
    PageMainScreenController pageMainScreenController = context
        .watch<PageMainScreenController>();
    FetchController fetchController = context.watch<FetchController>();
    return Column(
      children: [
        InkWell(
          overlayColor: WidgetStateColor.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(2.w),
            margin: EdgeInsets.all(2.w),
            alignment: Alignment.centerRight,
            width: double.maxFinite,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Titles(
                  text: "الأقسام الرئيسية",
                  showEven: fetchController.showEven,
                  flag: 1,
                  heightText: 1.4.h,
                ),
              ],
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(
              right: 4.w,
              top: 5.h,
              bottom: 5.h,
              left: 4.w,
            ),
            child: (widget.alwaysChangeBig)
                ? pageMainScreenController.setBigCategories
                      ? gridViewCategorySubList(sublist: basicCategories)
                      : SizedBox(
                          height: 0.30.sh,
                          child: gridViewCategorySubList(
                            sublist: basicCategories,
                            axisDirection: Axis.horizontal,
                            aspectRatio: 0.75,
                          ),
                        )
                : Column(
                    children: [
                      gridViewCategorySubList(
                        sublist: basicCategories.sublist(0, 3),
                        isFromFirstThreeCategories: true,
                      ),
                      SizedBox(height: 5),
                      Sliders(
                        sliders: pageMainScreenController.cashedSliders,
                        withCategory: false,
                        showShadow: true,
                        click: true,
                      ),
                      gridViewCategorySubList(
                        sublist: basicCategories.sublist(3, 7),
                      ),
                      SizedBox(height: 5),
                      Sliders(
                        sliders: pageMainScreenController.slidersUrl,
                        click: true,
                        showShadow: true,
                        withCategory: true,
                      ),
                      gridViewCategorySubList(
                        sublist: basicCategories.sublist(7),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget gridViewCategorySubList({
    required List<Map<String, String>> sublist,
    Axis axisDirection = Axis.vertical,
    bool isFromFirstThreeCategories = false,
    double aspectRatio = 0.65,
  }) {
    return GridView.builder(
      scrollDirection: axisDirection,
      physics: (axisDirection == Axis.vertical)
          ? NeverScrollableScrollPhysics()
          : AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: sublist.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isFromFirstThreeCategories ? 1 : 2,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: isFromFirstThreeCategories ? 1.15.sp : aspectRatio.sp,
      ),
      itemBuilder: (context, index) {
        bool isDiscounted = widget.discountCategories.contains(
          int.parse(sublist[index]["id"].toString()),
        );
        return CategoryDesignSpecificWidget(
          categoryModel: CategoryModel.fromJson(sublist[index]),
          isDiscounted: isDiscounted,
        );
      },
    );
  }
}
