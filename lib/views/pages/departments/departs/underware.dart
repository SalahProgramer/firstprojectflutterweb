import 'package:flutter/cupertino.dart';
import '../../../../core/utilities/global/app_global.dart';
import '../../../../core/utilities/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constant_data/constant_data_convert.dart';
import '../../../../controllers/custom_page_controller.dart';
import '../../../../controllers/departments_controller.dart';
import '../../../../core/services/database/hive_data/data_sizes.dart';
import '../../../../core/widgets/departments_home_widgets/widget_each_department.dart';
import '../../../../models/constants/constant_model.dart';

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
        NavigatorApp.pushName(
          AppRoutes.pageDepartment,
          arguments: {
            'title': "ملابس داخلية",
            'category': category[0],
            'showIconSizes': true,
            'sizes': sizes ?? "",
            'scrollController': departmentsController.scrollMultiItems,
          },
        );
      },
      onPressedSkip: () async {
        await departmentsController.clearAll();
        var category = CategoryModel.fromJsonListCategory(underWare);

        await departmentsController.setSubCategoryDepartments(underWare, false);
        await departmentsController
            .setSubCategorySpecificFirstMulti(category[0]);
        await customPageController.changeIndexCategoryPage(1);

        NavigatorApp.pushName(
          AppRoutes.pageDepartment,
          arguments: {
            'title': "ملابس داخلية",
            'category': category[0],
            'showIconSizes': true,
            'scrollController': departmentsController.scrollMultiItems,
          },
        );
      },
    );
  }
}
