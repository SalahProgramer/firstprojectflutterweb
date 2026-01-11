import 'package:fawri_app_refactor/salah/controllers/custom_page_controller.dart';
import 'package:fawri_app_refactor/salah/localDataBase/hive_data/data_sizes.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:fawri_app_refactor/salah/views/pages/departments/page_dapartment.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../constants/constant-categories/constant_data_convert.dart';
import '../../../../../models/constants/constant_model.dart';
import '../../../../../widgets/departments_home_widgets/widget_each_department.dart';
import '../../departments_base_view.dart';
import '../../departments_sizes_helpers.dart';

class KidsShoes extends StatefulWidget {
  const KidsShoes({super.key});

  @override
  State<KidsShoes> createState() => _KidsShoesState();
}

class _KidsShoesState extends State<KidsShoes> with DepartmentViewMixin {
  /// Handle department navigation with sizes (MVC: View handles navigation)
  Future<void> _navigateWithSizes(String sizes) async {
    final controller = readDepartmentsController();
    
    await controller.clearAll();
    final category = CategoryModel.fromJsonListCategory(kidsShoes);
    await controller.setSubCategoryDepartments(kidsShoes, false);
    await controller.setSubCategorySpecificFirstMulti(category[0]);

    NavigatorApp.push(
      PageDapartment(
        title: "أحذية أطفال",
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
    final category = CategoryModel.fromJsonListCategory(kidsShoes);
    await controller.setSubCategoryDepartments(kidsShoes, false);
    await controller.setSubCategorySpecificFirstMulti(category[0]);
    await customPageController.changeIndexCategoryPage(1);

    NavigatorApp.push(
      PageDapartment(
        title: "أحذية أطفال",
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
      listStyle2: kidsShoesSizesList,
      isLoadingType: controller.isLoadingKidsShoes,
      methodChangeLoading: controller.changeLoadingKidsShoes,
      backgroundImage: "",
      title: "أحذية أطفال",
      check: controller.haveCheckKidsShoes,
      onPressedSure: () async {
        // MVC: View uses helper to extract data, then navigates
        final sizes = DepartmentViewHelpers.extractSelectedSizes(
          controller.isLoadingKidsShoes,
        );
        await _navigateWithSizes(sizes);
      },
      onPressedSkip: () async {
        await _navigateWithoutSizes();
      },
    );
  }
}
