import 'package:fawri_app_refactor/salah/localDataBase/hive_data/data_sizes.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:fawri_app_refactor/salah/views/pages/departments/page_dapartment.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../constants/constant_data_convert.dart';
import '../../../../../controllers/custom_page_controller.dart';
import '../../../../../controllers/departments_controller.dart';
import '../../../../../models/constants/constant_model.dart';
import '../../../../../widgets/departments_home_widgets/widget_each_department.dart';

class WomenShoes extends StatefulWidget {
  const WomenShoes({super.key});

  @override
  State<WomenShoes> createState() => _WomenShoesState();
}

class _WomenShoesState extends State<WomenShoes> {
  @override
  Widget build(BuildContext context) {
    DepartmentsController departmentsController =
        context.watch<DepartmentsController>();
    CustomPageController customPageController =
        context.watch<CustomPageController>();
    return WidgetEachDepartment(
      style: 2,
      subTitle: "الرجاء اختر الحجم المناسب لك ",
      listStyle2: womenShoesSizesList,
      isLoadingType: departmentsController.isLoadingWomenShoes,
      methodChangeLoading: departmentsController.changeLoadingWomenShoes,
      backgroundImage: "",
      title: "أحذية ستاتية",
      check: departmentsController.haveCheckWomenShoes,
      onPressedSure: () async {
        await departmentsController.clearAll();
        var category = CategoryModel.fromJsonListCategory(womenShoes);

        await departmentsController.setSubCategoryDepartments(
            womenShoes, false);
        await departmentsController
            .setSubCategorySpecificFirstMulti(category[0]);

        String? sizes = departmentsController.isLoadingWomenShoes?.entries
            .where((entry) => entry.value) // Filter only `true` values
            .map((entry) => entry.key) // Get the keys (clothing names)
            .join(","); // Join into a single string
        NavigatorApp.push(PageDapartment(
          title: "أحذية ستاتية",
          showIconSizes: true,
          category: category[0],
          sizes: sizes ?? "",
          scrollController: departmentsController.scrollMultiItems,
        ));
      },
      onPressedSkip: () async {
        await departmentsController.clearAll();
        var category = CategoryModel.fromJsonListCategory(womenShoes);

        await departmentsController.setSubCategoryDepartments(
            womenShoes, false);
        await departmentsController
            .setSubCategorySpecificFirstMulti(category[0]);
        await customPageController.changeIndexCategoryPage(1);

        NavigatorApp.push(PageDapartment(
          title: "أحذية ستاتية",
          showIconSizes: true,
          category: category[0],
          scrollController: departmentsController.scrollMultiItems,
        ));
      },
    );
  }
}
