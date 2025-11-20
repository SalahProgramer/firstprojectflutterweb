import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/fetch_controller.dart';
import '../../../../core/widgets/widgets_main_screen/titles.dart';

class GridViewCategory extends StatefulWidget {
  final List<int> discountCategories;
  final bool alwaysChangeBig;

  const GridViewCategory(
      {super.key,
      required this.discountCategories,
      this.alwaysChangeBig = true});

  @override
  State<GridViewCategory> createState() => _GridViewCategoryState();
}

class _GridViewCategoryState extends State<GridViewCategory> {
  @override
  Widget build(BuildContext context) {
    FetchController fetchController = context.watch<FetchController>();
    return Column(
      children: [
        InkWell(
          onTap: () async {},
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
        // Container(
        //   color: Colors.white,
        //   child: Padding(
        //     padding: EdgeInsets.only(
        //         right: 2.w,
        //         top: 5.h,
        //         bottom: 5.h,
        //         left: (pageMainScreenController.setBigCategories &&
        //                 (widget.alwaysChangeBig))
        //             ? 2.w
        //             : 0.w),
        //     child: (widget.alwaysChangeBig)
        //         ? pageMainScreenController.setBigCategories
        //             ? GridView.builder(
        //                 scrollDirection: Axis.vertical,
        //                 physics: NeverScrollableScrollPhysics(),
        //                 shrinkWrap: true,
        //                 itemCount: categories.length,
        //                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //                   crossAxisCount: 2,
        //                   crossAxisSpacing: 6,
        //                   mainAxisSpacing: 6,
        //                   childAspectRatio: 1.0,
        //                 ),
        //                 itemBuilder: (context, index) {
        //                   bool isDiscounted = widget.discountCategories
        //                       .contains(int.parse(
        //                           categories[index]["id"].toString()));
        //                   return CategorySpecificWidget(
        //                     index: index,
        //                     category: categories,
        //                     isDiscounted: isDiscounted,
        //                   );
        //                 },
        //               )
        //             : SizedBox(
        //                 height: 0.25.sh,
        //                 child: GridView.builder(
        //                   scrollDirection: Axis.horizontal,
        //                   physics: BouncingScrollPhysics(),
        //                   shrinkWrap: true,
        //                   itemCount: categories.length,
        //                   gridDelegate:
        //                       SliverGridDelegateWithFixedCrossAxisCount(
        //                     crossAxisCount: 2,
        //                     crossAxisSpacing: 6,
        //                     mainAxisSpacing: 6,
        //                     childAspectRatio: 1,
        //                   ),
        //                   itemBuilder: (context, index) {
        //                     bool isDiscounted = widget.discountCategories
        //                         .contains(int.parse(
        //                             categories[index]["id"].toString()));
        //                     return CategorySpecificWidget(
        //                       index: index,
        //                       category: categories,
        //                       isDiscounted: isDiscounted,
        //                     );
        //                   },
        //                 ),
        //               )
        //         // :
        //
        //     // Column(
        //     //         children: [
        //     //           GridView.builder(
        //     //             scrollDirection: Axis.vertical,
        //     //             physics: NeverScrollableScrollPhysics(),
        //     //             shrinkWrap: true,
        //     //             itemCount: categoriesFirstSliders.length,
        //     //             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //     //               crossAxisCount: 2,
        //     //               crossAxisSpacing: 6,
        //     //               mainAxisSpacing: 6,
        //     //               childAspectRatio: 1.0,
        //     //             ),
        //     //             itemBuilder: (context, index) {
        //     //               bool isDiscounted = widget.discountCategories
        //     //                   .contains(int.parse(categoriesFirstSliders[index]
        //     //                           ["id"]
        //     //                       .toString()));
        //     //               return CategorySpecificWidget(
        //     //                 index: index,
        //     //                 category: categoriesFirstSliders,
        //     //                 isDiscounted: isDiscounted,
        //     //               );
        //     //             },
        //     //           ),
        //     //           SizedBox(
        //     //             height: 5,
        //     //           ),
        //     //           Sliders(
        //     //             sliders: pageMainScreenController.cashedSliders,
        //     //             withCategory: false,
        //     //             showShadow: true,
        //     //             click: true,
        //     //           ),
        //     //           GridView.builder(
        //     //             scrollDirection: Axis.vertical,
        //     //             physics: NeverScrollableScrollPhysics(),
        //     //             shrinkWrap: true,
        //     //             itemCount: categoriesSecondSliders.length,
        //     //             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //     //               crossAxisCount: 2,
        //     //               crossAxisSpacing: 6,
        //     //               mainAxisSpacing: 6,
        //     //               childAspectRatio: 1.0,
        //     //             ),
        //     //             itemBuilder: (context, index) {
        //     //               bool isDiscounted = widget.discountCategories
        //     //                   .contains(int.parse(categoriesSecondSliders[index]
        //     //                           ["id"]
        //     //                       .toString()));
        //     //               return CategorySpecificWidget(
        //     //                 index: index,
        //     //                 category: categoriesSecondSliders,
        //     //                 isDiscounted: isDiscounted,
        //     //               );
        //     //             },
        //     //           ),
        //     //           SizedBox(
        //     //             height: 5,
        //     //           ),
        //     //           Sliders(
        //     //             sliders: pageMainScreenController.slidersUrl,
        //     //             click: true,
        //     //             showShadow: true,
        //     //             withCategory: true,
        //     //           ),
        //     //           GridView.builder(
        //     //             scrollDirection: Axis.vertical,
        //     //             physics: NeverScrollableScrollPhysics(),
        //     //             shrinkWrap: true,
        //     //             itemCount: remainigCategoriesAfterSliders.length,
        //     //             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //     //               crossAxisCount: 2,
        //     //               crossAxisSpacing: 6,
        //     //               mainAxisSpacing: 6,
        //     //               childAspectRatio: 1.0,
        //     //             ),
        //     //             itemBuilder: (context, index) {
        //     //               bool isDiscounted = widget.discountCategories
        //     //                   .contains(int.parse(
        //     //                       remainigCategoriesAfterSliders[index]["id"]
        //     //                           .toString()));
        //     //               return CategorySpecificWidget(
        //     //                 index: index,
        //     //                 category: remainigCategoriesAfterSliders,
        //     //                 isDiscounted: isDiscounted,
        //     //               );
        //     //             },
        //     //           ),
        //     //         ],
        //     //       ),
        //   ),
        // ),
      ],
    );
  }
}
