
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../controllers/custom_page_controller.dart';
import '../../../../../controllers/departments_controller.dart';
import '../../../../../core/constants/constant_data/constant_data_convert.dart';
import '../../../../../core/services/database/hive_data/data_sizes.dart';
import '../../../../../core/utilities/global/app_global.dart';
import '../../../../../core/widgets/departments_home_widgets/widget_each_department.dart';
import '../../../../../models/constants/constant_model.dart';
import '../../page_dapartment.dart';

class MenShoes extends StatefulWidget {
  const MenShoes({super.key});

  @override
  State<MenShoes> createState() => _MenShoesState();
}

class _MenShoesState extends State<MenShoes> {
  @override
  Widget build(BuildContext context) {
    DepartmentsController departmentsController =
        context.watch<DepartmentsController>();
    CustomPageController customPageController =
        context.watch<CustomPageController>();
    return WidgetEachDepartment(
      style: 2,
      subTitle: "الرجاء اختر الحجم المناسب لك ",
      listStyle2: menShoesSizesList,
      isLoadingType: departmentsController.isLoadingMenShoes,
      methodChangeLoading: departmentsController.changeLoadingMenShoes,
      backgroundImage: "",
      title: "أحذية رجالية",
      check: departmentsController.haveCheckMenShoes,
      onPressedSure: () async {
        await departmentsController.clearAll();
        var category = CategoryModel.fromJsonListCategory(menShoes);

        await departmentsController.setSubCategoryDepartments(menShoes, false);
        await departmentsController
            .setSubCategorySpecificFirstMulti(category[0]);

        String? sizes = departmentsController.isLoadingMenShoes?.entries
            .where((entry) => entry.value) // Filter only `true` values
            .map((entry) => entry.key) // Get the keys (clothing names)
            .join(","); // Join into a single string
        NavigatorApp.push(PageDapartment(
          title: "أحذية رجالية",
          showIconSizes: true,
          category: category[0],
          sizes: sizes ?? "",
          scrollController: departmentsController.scrollMultiItems,
        ));
      },
      onPressedSkip: () async {
        await departmentsController.clearAll();
        var category = CategoryModel.fromJsonListCategory(menShoes);

        await departmentsController.setSubCategoryDepartments(menShoes, false);
        await departmentsController
            .setSubCategorySpecificFirstMulti(category[0]);
        await customPageController.changeIndexCategoryPage(1);

        NavigatorApp.push(PageDapartment(
          title: "أحذية رجالية",
          showIconSizes: true,
          category: category[0],
          scrollController: departmentsController.scrollMultiItems,
        ));
      },
    );
  }
}
