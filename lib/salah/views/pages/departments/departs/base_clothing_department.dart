import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:fawri_app_refactor/salah/views/pages/departments/page_dapartment.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/custom_page_controller.dart';
import '../../../../models/constants/constant_model.dart';
import '../../../../widgets/departments_home_widgets/widget_each_department.dart';
import '../departments_base_view.dart';

/// Helper function to convert size map to list format
List<Map<String, String>> _convertSizesMapToList(Map<String, String> sizesMap) {
  return sizesMap.entries
      .map((entry) => {"sizeText": entry.key, "sizeSubtitle": entry.value})
      .toList();
}

/// Helper function to extract selected sizes from loading map
String _extractSelectedSizes(Map<String, bool>? isLoadingType) {
  return isLoadingType
          ?.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .join(",") ??
      "";
}

/// Configuration class for clothing department pages
class ClothingDepartmentConfig {
  final String title;
  final List<dynamic> categoryData;
  final List<dynamic> listStyle2;
  final Map<String, bool>? isLoadingType;
  final Function(String, bool) methodChangeLoading;
  final bool check;
  final CategoryModel? category;

  const ClothingDepartmentConfig({
    required this.title,
    required this.categoryData,
    required this.listStyle2,
    required this.isLoadingType,
    required this.methodChangeLoading,
    required this.check,
    this.category,
  });

  /// Factory constructor for creating config with Map-based sizes
  factory ClothingDepartmentConfig.fromMapSizes({
    required String title,
    required List<dynamic> categoryData,
    required Map<String, String> sizesMap,
    required Map<String, bool>? isLoadingType,
    required Function(String, bool) methodChangeLoading,
    required bool check,
    CategoryModel? category,
  }) {
    return ClothingDepartmentConfig(
      title: title,
      categoryData: categoryData,
      listStyle2: _convertSizesMapToList(sizesMap),
      isLoadingType: isLoadingType,
      methodChangeLoading: methodChangeLoading,
      check: check,
      category: category,
    );
  }

  /// Factory constructor for creating config with List-based sizes
  factory ClothingDepartmentConfig.fromListSizes({
    required String title,
    required List<dynamic> categoryData,
    required List<String> sizesList,
    required Map<String, bool>? isLoadingType,
    required Function(String, bool) methodChangeLoading,
    required bool check,
    CategoryModel? category,
  }) {
    return ClothingDepartmentConfig(
      title: title,
      categoryData: categoryData,
      listStyle2: sizesList,
      isLoadingType: isLoadingType,
      methodChangeLoading: methodChangeLoading,
      check: check,
      category: category,
    );
  }
}

/// Base widget for clothing department pages with size selection
class BaseClothingDepartment extends StatefulWidget {
  final ClothingDepartmentConfig config;

  const BaseClothingDepartment({
    super.key,
    required this.config,
  });

  @override
  State<BaseClothingDepartment> createState() => _BaseClothingDepartmentState();
}

class _BaseClothingDepartmentState extends State<BaseClothingDepartment>
    with DepartmentViewMixin {
  /// Prepare department data using controller (MVC: View calls Controller)
  Future<void> _prepareDepartmentData() async {
    final config = widget.config;
    final controller = readDepartmentsController();
    await controller.clearAll();
    final category = CategoryModel.fromJsonListCategory(config.categoryData);
    await controller.setSubCategoryDepartments(config.categoryData, false);
    await controller.setSubCategorySpecificFirstMulti(category[0]);
  }

  /// Navigate to department page (MVC: View handles navigation only)
  Future<void> _navigateToPageDapartment({
    required String sizes,
    bool shouldChangeIndex = false,
  }) async {
    final config = widget.config;
    final controller = readDepartmentsController();
    final category = CategoryModel.fromJsonListCategory(config.categoryData);
    final title = config.category?.name ?? config.title;
    final categoryModel = config.category ?? category[0];

    if (shouldChangeIndex) {
      final customPageController = context.read<CustomPageController>();
      await customPageController.changeIndexCategoryPage(1);
    }

    NavigatorApp.push(
      PageDapartment(
        title: title,
        category: categoryModel,
        showIconSizes: true,
        sizes: sizes,
        scrollController: controller.scrollMultiItems,
      ),
    );
  }

  /// Handle sure button press (MVC: View delegates to controller)
  Future<void> _handleSurePressed() async {
    await _prepareDepartmentData();
    final sizes = _extractSelectedSizes(widget.config.isLoadingType);
    await _navigateToPageDapartment(sizes: sizes);
  }

  /// Handle skip button press (MVC: View delegates to controller)
  Future<void> _handleSkipPressed() async {
    await _prepareDepartmentData();
    await _navigateToPageDapartment(
      sizes: "",
      shouldChangeIndex: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;

    return WidgetEachDepartment(
      style: 2,
      subTitle: "الرجاء اختر الحجم المناسب لك ",
      listStyle2: config.listStyle2,
      isLoadingType: config.isLoadingType,
      methodChangeLoading: config.methodChangeLoading,
      backgroundImage: "",
      title: config.category?.name ?? config.title,
      check: config.check,
      onPressedSure: _handleSurePressed,
      onPressedSkip: _handleSkipPressed,
    );
  }
}

