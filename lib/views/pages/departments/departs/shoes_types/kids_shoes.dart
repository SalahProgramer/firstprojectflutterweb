
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../controllers/custom_page_controller.dart';
import '../../../../../core/constants/constant_data/constant_data_convert.dart';
import '../../../../../controllers/departments_controller.dart';
import '../../../../../core/services/database/hive_data/data_sizes.dart';
import '../../../../../core/utilities/global/app_global.dart';
import '../../../../../core/utilities/routes.dart';
import '../../../../../core/widgets/departments_home_widgets/widget_each_department.dart';
import '../../../../../models/constants/constant_model.dart';

class KidsShoes extends StatefulWidget {
  const KidsShoes({super.key});

  @override
  State<KidsShoes> createState() => _KidsShoesState();
}

class _KidsShoesState extends State<KidsShoes> {
  @override
  Widget build(BuildContext context) {
    DepartmentsController departmentsController =
        context.watch<DepartmentsController>();
    CustomPageController customPageController =
        context.watch<CustomPageController>();
    return WidgetEachDepartment(
      style: 2,
      subTitle: "الرجاء اختر الحجم المناسب لك ",
      listStyle2: kidsShoesSizesList,
      isLoadingType: departmentsController.isLoadingKidsShoes,
      methodChangeLoading: departmentsController.changeLoadingKidsShoes,
      backgroundImage: "",
      title: "أحذية أطفال",
      check: departmentsController.haveCheckKidsShoes,
      onPressedSure: () async {
        await departmentsController.clearAll();
        var category = CategoryModel.fromJsonListCategory(kidsShoes);

        await departmentsController.setSubCategoryDepartments(kidsShoes, false);
        await departmentsController
            .setSubCategorySpecificFirstMulti(category[0]);

        String? sizes = departmentsController.isLoadingKidsShoes?.entries
            .where((entry) => entry.value) // Filter only `true` values
            .map((entry) => entry.key) // Get the keys (clothing names)
            .join(","); // Join into a single string
        NavigatorApp.pushName(
          AppRoutes.pageDepartment,
          arguments: {
            'title': "أحذية أطفال",
            'showIconSizes': true,
            'category': category[0],
            'sizes': sizes ?? "",
            'scrollController': departmentsController.scrollMultiItems,
          },
        );
      },
      onPressedSkip: () async {
        await departmentsController.clearAll();
        var category = CategoryModel.fromJsonListCategory(kidsShoes);

        await departmentsController.setSubCategoryDepartments(kidsShoes, false);
        await departmentsController
            .setSubCategorySpecificFirstMulti(category[0]);
        await customPageController.changeIndexCategoryPage(1);

        NavigatorApp.pushName(
          AppRoutes.pageDepartment,
          arguments: {
            'title': "أحذية أطفال",
            'showIconSizes': true,
            'category': category[0],
            'scrollController': departmentsController.scrollMultiItems,
          },
        );
      },
    );
  }
}
