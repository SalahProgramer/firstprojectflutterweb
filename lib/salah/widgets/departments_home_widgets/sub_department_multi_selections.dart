import 'package:chips_choice/chips_choice.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/views/pages/departments/departs/underware.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/constant-categories/constant_data_convert.dart';
import '../../controllers/departments_controller.dart';
import '../../models/constants/constant_model.dart';
import '../../utilities/global/app_global.dart';
import '../../utilities/style/text_style.dart';
import '../../views/pages/departments/departs/shoes_types/men_shoes.dart';
import '../../views/pages/departments/departs/shoes_types/women_shoes.dart';
import '../../views/pages/departments/page_dapartment.dart';
import '../custom_button.dart';

class SubDepartmentMultiSelections extends StatefulWidget {
  final ScrollController scrollController;
  final CategoryModel? category;
  final String sizes;

  const SubDepartmentMultiSelections(
      {super.key,
      required this.scrollController,
      this.category,
      required this.sizes});

  @override
  State<SubDepartmentMultiSelections> createState() =>
      _SubDepartmentMultiSelectionsState();
}

class _SubDepartmentMultiSelectionsState
    extends State<SubDepartmentMultiSelections> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      DepartmentsController departmentsController =
          context.read<DepartmentsController>();

      if (departmentsController.subCategoriesDepartment.isNotEmpty) {
        await departmentsController.setSubCategorySpecificFirstMulti(
            departmentsController.subCategoriesDepartment[0]);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DepartmentsController departmentsController =
        context.watch<DepartmentsController>();
    return (departmentsController.subCategoriesDepartment.isEmpty)
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
                bool dontHave = true;
                for (var i in value) {
                  if (i.name == "أحذية رجالية") {
                    if (Navigator.canPop(context)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.popUntil(context, (route) => route.isFirst);
                        NavigatorApp.push(MenShoes());
                      });
                    } else {
                      NavigatorApp.push(MenShoes());
                    }
                    dontHave = false;
                    break;
                  } else if (i.name == "ملابس نسائية داخلية") {
                    if (Navigator.canPop(context)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.popUntil(context, (route) => route.isFirst);
                        NavigatorApp.push(Underware());
                      });
                    } else {
                      NavigatorApp.push(Underware());
                    }
                    dontHave = false;
                    break;
                  } else if (i.name == "اكسسوارات نسائية") {
                    await departmentsController.clearMulti();

                    var category = CategoryModel.fromJsonListCategory(beauty);

                    await departmentsController.setSubCategoryDepartments(
                        beauty, false);

                    await departmentsController
                        .setSubCategorySpecific(category[0]);
                    if (Navigator.canPop(context)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.popUntil(context, (route) => route.isFirst);
                        NavigatorApp.push(PageDapartment(
                          title: "اكسسوارات",
                          category: category[0],
                          sizes: '',
                          showIconSizes: false,
                          scrollController:
                              departmentsController.scrollMultiItems,
                        ));
                      });
                    } else {
                      NavigatorApp.push(PageDapartment(
                        title: "اكسسوارات",
                        category: category[0],
                        sizes: '',
                        showIconSizes: false,
                        scrollController:
                            departmentsController.scrollMultiItems,
                      ));
                    }
                    dontHave = false;
                    break;
                  } else if (i.name == "الموضة والجمال نسائية") {
                    await departmentsController.clearMulti();

                    var category = CategoryModel.fromJsonListCategory(apparel);

                    await departmentsController.setSubCategoryDepartments(
                        apparel, false);

                    await departmentsController
                        .setSubCategorySpecific(category[0]);
                    if (Navigator.canPop(context)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.popUntil(context, (route) => route.isFirst);
                        NavigatorApp.push(PageDapartment(
                          title: "الموضة والجمال",
                          category: category[0],
                          sizes: '',
                          showIconSizes: false,
                          scrollController:
                              departmentsController.scrollMultiItems,
                        ));
                      });
                    } else {
                      NavigatorApp.push(PageDapartment(
                        title: "الموضة والجمال",
                        category: category[0],
                        sizes: '',
                        showIconSizes: false,
                        scrollController:
                            departmentsController.scrollMultiItems,
                      ));
                    }

                    dontHave = false;
                    break;
                  } else if (i.name == "أحذية نسائية") {
                    if (Navigator.canPop(context)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.popUntil(context, (route) => route.isFirst);
                        // Ensure push happens after popUntil completes
                        NavigatorApp.push(WomenShoes());
                      });
                    } else {
                      // If already at the first route, directly push the new screen
                      NavigatorApp.push(WomenShoes());
                    }
                    dontHave = false;
                    break;
                  }
                }
                if (dontHave == false) {
                } else if (dontHave == true) {
                  await departmentsController.clearMulti();
                  await departmentsController
                      .setMultiSelectSubDepartments(value);
                  if (widget.scrollController ==
                      departmentsController.scrollPerfumeItems) {
                    await departmentsController.getPerfume();
                  } else if (widget.scrollController ==
                      departmentsController.scrollMultiItems) {
                    await departmentsController.getData(
                        category: widget.category ??
                            CategoryModel(
                                name: "",
                                subCategory: "",
                                image: "",
                                mainCategory: "",
                                icon: ""),
                        sizes: widget.sizes,
                        isFirst: false);
                  }
                }
              },
              value:
                  departmentsController.listSelectedMultiSubCategoryDepartment,
              choiceCheckmark: true,
              mainAxisAlignment: MainAxisAlignment.center,
              choiceItems: C2Choice.listFrom(
                source: departmentsController.subCategoriesDepartment,
                value: (index, item) => item,
                label: (index, item) => item.name,
              ),
              choiceLabelBuilder: (item, i) => Text(
                item.label,
                style: CustomTextStyle()
                    .heading1L
                    .copyWith(color: Colors.black, fontSize: 12.sp),
              ),
              choiceLeadingBuilder: (item, i) => (departmentsController
                      .listSelectedMultiSubCategoryDepartment
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
          );
  }
}
