import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../../constants/constant-categories/constant_data_convert.dart';
import '../../../../controllers/custom_page_controller.dart';
import '../../../../controllers/departments_controller.dart';
import '../../../../localDataBase/hive_data/data_sizes.dart';
import '../../../../models/constants/constant_model.dart';
import '../../../../utilities/global/app_global.dart';
import '../../../../widgets/departments_home_widgets/widget_each_department.dart';
import '../page_dapartment.dart';

class Men extends StatefulWidget {
  final CategoryModel category;

  const Men({super.key, required this.category});

  @override
  State<Men> createState() => _MenState();
}

class _MenState extends State<Men> {
  @override
  Widget build(BuildContext context) {
    DepartmentsController departmentsController =
        context.watch<DepartmentsController>();
    CustomPageController customPageController =
        context.watch<CustomPageController>();
    return WidgetEachDepartment(
      style: 2,
      subTitle: "الرجاء اختر الحجم المناسب لك ",
      listStyle2: menSizesList.entries
          .map((entry) => {"sizeText": entry.key, "sizeSubtitle": entry.value})
          .toList(),
      isLoadingType: departmentsController.isLoadingMenClothesTypes,
      methodChangeLoading: departmentsController.changeLoadingMenClothes,
      backgroundImage: "",
      title: widget.category.name,
      check: departmentsController.haveCheckMenClothes,
      onPressedSure: () async {
        await departmentsController.clearAll();
        var category = CategoryModel.fromJsonListCategory(men);

        await departmentsController.setSubCategoryDepartments(men, false);
        await departmentsController
            .setSubCategorySpecificFirstMulti(category[0]);

        String? sizes = departmentsController.isLoadingMenClothesTypes?.entries
            .where((entry) => entry.value) // Filter only `true` values
            .map((entry) => entry.key) // Get the keys (clothing names)
            .join(","); // Join into a single string
        NavigatorApp.push(PageDapartment(
          title: widget.category.name,
          category: category[0],
          showIconSizes: true,
          sizes: sizes ?? "",
          scrollController: departmentsController.scrollMultiItems,
        ));
      },
      onPressedSkip: () async {
        await departmentsController.clearAll();
        var category = CategoryModel.fromJsonListCategory(men);

        await departmentsController.setSubCategoryDepartments(men, false);
        await departmentsController
            .setSubCategorySpecificFirstMulti(category[0]);
        await customPageController.changeIndexCategoryPage(1);

        NavigatorApp.push(PageDapartment(
          title: widget.category.name,
          category: category[0],
          showIconSizes: true,
          sizes: "",
          scrollController: departmentsController.scrollMultiItems,
        ));
      },
    );
  }
}
