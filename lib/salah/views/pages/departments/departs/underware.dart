import 'package:flutter/cupertino.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:fawri_app_refactor/salah/views/pages/departments/page_dapartment.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants/constant-categories/constant_data_convert.dart';
import '../../../../controllers/custom_page_controller.dart';
import '../../../../controllers/departments_controller.dart';
import '../../../../localDataBase/hive_data/data_sizes.dart';
import '../../../../models/constants/constant_model.dart';
import '../../../../widgets/departments_home_widgets/widget_each_department.dart';

class Underware extends StatefulWidget {
  const Underware({super.key});

  @override
  State<Underware> createState() => _UnderwareState();
}

class _UnderwareState extends State<Underware> {
  @override
  Widget build(BuildContext context) {
    DepartmentsController departmentsController =
        context.watch<DepartmentsController>();
    CustomPageController customPageController =
        context.watch<CustomPageController>();
    return WidgetEachDepartment(
      style: 2,
      subTitle: "الرجاء اختر الحجم المناسب لك ",
      listStyle2: underwearSizes,
      isLoadingType: departmentsController.isLoadingUnderWareTypes,
      methodChangeLoading: departmentsController.changeLoadingUnderWareClothes,
      backgroundImage: "",
      title: "ملابس داخلية",
      check: departmentsController.haveCheckUnderWareClothes,
      onPressedSure: () async {
        await departmentsController.clearAll();
        var category = CategoryModel.fromJsonListCategory(underWare);

        await departmentsController.setSubCategoryDepartments(underWare, false);
        await departmentsController
            .setSubCategorySpecificFirstMulti(category[0]);

        String? sizes = departmentsController.isLoadingUnderWareTypes?.entries
            .where((entry) => entry.value) // Filter only `true` values
            .map((entry) => entry.key) // Get the keys (clothing names)
            .join(","); // Join into a single string
        NavigatorApp.push(PageDapartment(
          title: "ملابس داخلية",
          category: category[0],
          showIconSizes: true,
          sizes: sizes ?? "",
          scrollController: departmentsController.scrollMultiItems,
        ));
      },
      onPressedSkip: () async {
        await departmentsController.clearAll();
        var category = CategoryModel.fromJsonListCategory(underWare);

        await departmentsController.setSubCategoryDepartments(underWare, false);
        await departmentsController
            .setSubCategorySpecificFirstMulti(category[0]);
        await customPageController.changeIndexCategoryPage(1);

        NavigatorApp.push(PageDapartment(
          title: "ملابس داخلية",
          category: category[0],
          showIconSizes: true,
          scrollController: departmentsController.scrollMultiItems,
        ));
      },
    );
  }
}
