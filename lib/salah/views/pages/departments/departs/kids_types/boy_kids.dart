import 'package:fawri_app_refactor/salah/localDataBase/hive_data/data_sizes.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:fawri_app_refactor/salah/views/pages/departments/page_dapartment.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../constants/constant-categories/constant_data_convert.dart';
import '../../../../../controllers/custom_page_controller.dart';
import '../../../../../controllers/departments_controller.dart';
import '../../../../../models/constants/constant_model.dart';
import '../../../../../widgets/departments_home_widgets/widget_each_department.dart';

class BoyKids extends StatefulWidget {
  const BoyKids({super.key});

  @override
  State<BoyKids> createState() => _BoyKidsState();
}

class _BoyKidsState extends State<BoyKids> {
  @override
  Widget build(BuildContext context) {
    DepartmentsController departmentsController =
        context.watch<DepartmentsController>();
    CustomPageController customPageController =
        context.watch<CustomPageController>();
    return WidgetEachDepartment(
      style: 2,
      subTitle: "الرجاء اختر الحجم المناسب لك ",
      listStyle2: kidsBoysSizesList,
      isLoadingType: departmentsController.isLoadingBoyKids,
      methodChangeLoading: departmentsController.changeLoadingBoyKids,
      backgroundImage: "",
      title: "قسم الأولاد",
      check: departmentsController.haveCheckBoyKids,
      onPressedSure: () async {
        await departmentsController.clearAll();
        var category = CategoryModel.fromJsonListCategory(boys);

        await departmentsController.setSubCategoryDepartments(boys, false);
        await departmentsController
            .setSubCategorySpecificFirstMulti(category[0]);

        String? sizes = departmentsController.isLoadingBoyKids?.entries
            .where((entry) => entry.value) // Filter only `true` values
            .map((entry) => entry.key) // Get the keys (clothing names)
            .join(","); // Join into a single string
        NavigatorApp.push(PageDapartment(
          title: "قسم الأولاد",
          showIconSizes: true,
          category: category[0],
          sizes: sizes ?? "",
          scrollController: departmentsController.scrollMultiItems,
        ));
      },
      onPressedSkip: () async {
        await departmentsController.clearAll();
        var category = CategoryModel.fromJsonListCategory(boys);

        await departmentsController.setSubCategoryDepartments(boys, false);
        await departmentsController
            .setSubCategorySpecificFirstMulti(category[0]);
        await customPageController.changeIndexCategoryPage(1);

        NavigatorApp.push(PageDapartment(
          title: "قسم الأولاد",
          showIconSizes: true,
          category: category[0],
          scrollController: departmentsController.scrollMultiItems,
        ));
      },
    );
  }
}
