import 'package:fawri_app_refactor/salah/localDataBase/hive_data/data_sizes.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:fawri_app_refactor/salah/views/pages/departments/page_dapartment.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../constants/constant-categories/constant_data_convert.dart';
import '../../../../../controllers/custom_page_controller.dart';
import '../../../../../models/constants/constant_model.dart';
import '../../../../../widgets/departments_home_widgets/widget_each_department.dart';
import '../../departments_base_view.dart';
import '../../departments_sizes_helpers.dart';

class BoyKids extends StatefulWidget {
  const BoyKids({super.key});

  @override
  State<BoyKids> createState() => _BoyKidsState();
}

class _BoyKidsState extends State<BoyKids> with DepartmentViewMixin {
  /// Handle department navigation with sizes (MVC: View handles navigation)
  Future<void> _navigateWithSizes(String sizes) async {
    final controller = readDepartmentsController();
    
    await controller.clearAll();
    final category = CategoryModel.fromJsonListCategory(boys);
    await controller.setSubCategoryDepartments(boys, false);
    await controller.setSubCategorySpecificFirstMulti(category[0]);

    NavigatorApp.push(
      PageDapartment(
        title: "قسم الأولاد",
        showIconSizes: true,
        category: category[0],
        sizes: sizes,
        scrollController: controller.scrollMultiItems,
      ),
    );
  }

  /// Handle skip navigation (MVC: View handles navigation)
  Future<void> _navigateWithoutSizes() async {
    final controller = readDepartmentsController();
    final customPageController = context.read<CustomPageController>();
    
    await controller.clearAll();
    final category = CategoryModel.fromJsonListCategory(boys);
    await controller.setSubCategoryDepartments(boys, false);
    await controller.setSubCategorySpecificFirstMulti(category[0]);
    await customPageController.changeIndexCategoryPage(1);

    NavigatorApp.push(
      PageDapartment(
        title: "قسم الأولاد",
        showIconSizes: true,
        category: category[0],
        scrollController: controller.scrollMultiItems,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = departmentsController; // From mixin
    
    return WidgetEachDepartment(
      style: 2,
      subTitle: "الرجاء اختر الحجم المناسب لك ",
      listStyle2: kidsBoysSizesList,
      isLoadingType: controller.isLoadingBoyKids,
      methodChangeLoading: controller.changeLoadingBoyKids,
      backgroundImage: "",
      title: "قسم الأولاد",
      check: controller.haveCheckBoyKids,
      onPressedSure: () async {
        // MVC: View uses helper to extract data, then navigates
        final sizes = DepartmentViewHelpers.extractSelectedSizes(
          controller.isLoadingBoyKids,
        );
        await _navigateWithSizes(sizes);
      },
      onPressedSkip: () async {
        await _navigateWithoutSizes();
      },
    );
  }
}
