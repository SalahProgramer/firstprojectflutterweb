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

class InfantBaby extends StatefulWidget {
  final CategoryModel category;

  const InfantBaby({super.key, required this.category});

  @override
  State<InfantBaby> createState() => _InfantBabyState();
}

class _InfantBabyState extends State<InfantBaby> with DepartmentViewMixin {
  /// Handle department navigation with sizes (MVC: View handles navigation)
  Future<void> _navigateWithSizes(String sizes) async {
    final controller = readDepartmentsController();
    
    await controller.clearAll();
    final category = CategoryModel.fromJsonListCategory(womenAndBaby);
    await controller.setSubCategoryDepartments(womenAndBaby, false);
    await controller.setSubCategorySpecificFirstMulti(category[0]);

    NavigatorApp.push(
      PageDapartment(
        title: 'الرضيع',
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
    final category = CategoryModel.fromJsonListCategory(womenAndBaby);
    await controller.setSubCategoryDepartments(womenAndBaby, false);
    await controller.setSubCategorySpecificFirstMulti(category[0]);
    await customPageController.changeIndexCategoryPage(1);

    NavigatorApp.push(
      PageDapartment(
        title: 'الرضيع',
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
      listStyle2: womenAndBabySizesList,
      isLoadingType: controller.isLoadingInfantBaby,
      methodChangeLoading: controller.changeLoadingInfantBaby,
      backgroundImage: "",
      title: 'الرضيع',
      check: controller.haveCheckInfantBaby,
      onPressedSure: () async {
        // MVC: View uses helper to extract data, then navigates
        final sizes = DepartmentViewHelpers.extractSelectedSizes(
          controller.isLoadingInfantBaby,
        );
        await _navigateWithSizes(sizes);
      },
      onPressedSkip: () async {
        await _navigateWithoutSizes();
      },
    );
  }
}

