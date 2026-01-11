// import 'package:chips_choice/chips_choice.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
//
// import '../../controllers/departments_controller.dart';
// import '../../models/constants/constant_model.dart';
// import '../../utilities/style/text_style.dart';
// import '../custom_button.dart';
//
// class SubDepartmentSelections extends StatefulWidget {
//   final ScrollController scrollController;
//
//   const SubDepartmentSelections({super.key, required this.scrollController});
//
//   @override
//   State<SubDepartmentSelections> createState() =>
//       _SubDepartmentMultiSelectionsState();
// }
//
// class _SubDepartmentMultiSelectionsState
//     extends State<SubDepartmentSelections> {
//   @override
//   Widget build(BuildContext context) {
//     DepartmentsController departmentsController =
//         context.watch<DepartmentsController>();
//     return (departmentsController.subCategoriesDepartment.isEmpty)
//         ? SizedBox()
//         : Container(
//             // width: double.maxFinite,
//             margin: EdgeInsets.only(left: 8.w, right: 8.w),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12.r),
//               boxShadow: [
//                 BoxShadow(
//                     color: Colors.black,
//                     blurRadius: 1,
//                     blurStyle: BlurStyle.outer)
//               ],
//               color: Colors.transparent,
//             ),
//             child: ChipsChoice<CategoryModel>.single(
//               onChanged: (value) async {
//                 await departmentsController.setSingleSubDepartments(value);
//                 await departmentsController.clearSubDepartment();
//
//                 if (widget.scrollController ==
//                     departmentsController.scrollPerfumeItems) {
//                   await departmentsController
//                       .getPerfume();
//                 }
//               },
//               value: departmentsController.subSelectedSingleSubCategoryDepartment,
//               choiceCheckmark: true,
//               choiceLabelBuilder: (item, i) => Text(
//                 item.label,
//                 style: CustomTextStyle()
//                     .heading1L
//                     .copyWith(color: Colors.black, fontSize: 12.sp),
//               ),
//               choiceLeadingBuilder: (item, i) =>
//                   (item.value == departmentsController.subSelectedSingleSubCategoryDepartment)
//                       ? IconSvg(
//                           nameIcon: "yes",
//                           onPressed: null,
//                           width: 25.w,
//                           height: 25.w,
//                           backColor: Colors.transparent,
//                         )
//                       : SizedBox(),
//               wrapped: false,
//               mainAxisAlignment: MainAxisAlignment.center,
//               choiceItems: C2Choice.listFrom(
//                 source: departmentsController.subCategoriesDepartment,
//                 value: (index, item) => item,
//                 label: (index, item) => item.name,
//               ),
//             ),
//           );
//   }
// }

import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/departments_controller.dart';
import '../../models/constants/constant_model.dart';

class SubDepartmentSelections extends StatefulWidget {
  final ScrollController scrollController;
  final CategoryModel? category;
  final String sizes;

  const SubDepartmentSelections({
    super.key,
    required this.scrollController,
    this.category,
    required this.sizes,
  });

  @override
  State<SubDepartmentSelections> createState() =>
      _SubDepartmentMultiSelectionsState();
}

class _SubDepartmentMultiSelectionsState
    extends State<SubDepartmentSelections> {
  @override
  Widget build(BuildContext context) {
    AnalyticsService analyticsService = AnalyticsService();

    DepartmentsController departmentsController = context
        .watch<DepartmentsController>();
    return (departmentsController.subCategoriesDepartment.isEmpty)
        ? SizedBox()
        : Padding(
            padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
            child: SizedBox(
              height: 40,
              width: double.infinity,
              child: ListView.builder(
                itemCount: departmentsController.subCategoriesDepartment.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return Visibility(
                    visible: true,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5, left: 5),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        overlayColor: WidgetStateColor.transparent,
                        focusColor: Colors.transparent,
                        onTap: () async {
                          await analyticsService.logEvent(
                            eventName: "sub_department_select",
                            parameters: {
                              "class_name": "SubDepartmentSelections",
                              "button_name":
                                  "InkWell (sub_department: ${departmentsController.subCategoriesDepartment[index].name})",
                              "sub_department_index": index,
                              "sub_department_name": departmentsController
                                  .subCategoriesDepartment[index]
                                  .name,
                              "time": DateTime.now().toString(),
                            },
                          );
                          if (departmentsController.selectedIndex == index) {
                            await departmentsController.changeIndex(0);
                          } else {
                            await departmentsController.changeIndex(index);
                          }

                          await departmentsController.setSingleSubDepartments(
                            departmentsController
                                .subCategoriesDepartment[index],
                          );
                          await departmentsController.clearSubDepartment();
                          //
                          if (widget.scrollController ==
                              departmentsController.scrollPerfumeItems) {
                            await departmentsController.getPerfume();
                          } else if (widget.scrollController ==
                              departmentsController.scrollMultiItems) {
                            await departmentsController.getData(
                              category:
                                  widget.category ??
                                  CategoryModel(
                                    name: "",
                                    subCategory: "",
                                    image: "",
                                    mainCategory: "",
                                    icon: "",
                                  ),
                              sizes: widget.sizes,
                              isFirst: false,
                            );
                          }
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              width: 2,
                              color:
                                  departmentsController.selectedIndex == index
                                  ? Colors.red
                                  : Colors.black,
                            ),
                            color: Colors.black,
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                departmentsController
                                    .subCategoriesDepartment[index]
                                    .name
                                    .toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
  }
}
