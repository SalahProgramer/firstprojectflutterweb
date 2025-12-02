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

class WomenPlus extends StatefulWidget {
  final CategoryModel category;

  const WomenPlus({super.key, required this.category});

  @override
  State<WomenPlus> createState() => _WomenPlusState();
}

class _WomenPlusState extends State<WomenPlus> {
  @override
  Widget build(BuildContext context) {
    DepartmentsController departmentsController =
        context.watch<DepartmentsController>();
    CustomPageController customPageController =
        context.watch<CustomPageController>();
    return WidgetEachDepartment(
      style: 2,
      subTitle: "الرجاء اختر الحجم المناسب لك ",
      listStyle2: womenPlusSizesList.entries
          .map((entry) => {"sizeText": entry.key, "sizeSubtitle": entry.value})
          .toList(),
      isLoadingType: departmentsController.isLoadingWomenPlusClothesTypes,
      methodChangeLoading: departmentsController.changeLoadingWomenPlusClothes,
      backgroundImage: "",
      title: widget.category.name,
      check: departmentsController.haveCheckWomenPlusClothes,
      onPressedSure: () async {
        await departmentsController.clearAll();
        var category = CategoryModel.fromJsonListCategory(womenPlus);

        await departmentsController.setSubCategoryDepartments(womenPlus, false);
        await departmentsController
            .setSubCategorySpecificFirstMulti(category[0]);

        String? sizes =
            departmentsController.isLoadingWomenPlusClothesTypes?.entries
                .where((entry) => entry.value) // Filter only `true` values
                .map((entry) => entry.key) // Get the keys (clothing names)
                .join(","); // Join into a single string
        NavigatorApp.pushName(
          AppRoutes.pageDepartment,
          arguments: {
            'title': widget.category.name,
            'category': widget.category,
            'showIconSizes': true,
            'sizes': sizes ?? "",
            'scrollController': departmentsController.scrollMultiItems,
          },
        );
      },
      onPressedSkip: () async {
        await departmentsController.clearAll();
        var category = CategoryModel.fromJsonListCategory(womenPlus);

        await departmentsController.setSubCategoryDepartments(womenPlus, false);
        await departmentsController
            .setSubCategorySpecificFirstMulti(category[0]);
        await customPageController.changeIndexCategoryPage(1);

        NavigatorApp.pushName(
          AppRoutes.pageDepartment,
          arguments: {
            'title': widget.category.name,
            'category': widget.category,
            'showIconSizes': true,
            'scrollController': departmentsController.scrollMultiItems,
          },
        );
      },
    );
  }
}
