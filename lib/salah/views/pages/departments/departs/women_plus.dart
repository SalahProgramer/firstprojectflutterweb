import 'package:flutter/material.dart';
import '../../../../constants/constant-categories/constant_data_convert.dart';
import '../../../../localDataBase/hive_data/data_sizes.dart';
import '../../../../models/constants/constant_model.dart';
import '../departments_base_view.dart';
import 'base_clothing_department.dart';

class WomenPlus extends StatefulWidget {
  final CategoryModel category;

  const WomenPlus({super.key, required this.category});

  @override
  State<WomenPlus> createState() => _WomenPlusState();
}

class _WomenPlusState extends State<WomenPlus> with DepartmentViewMixin {
  @override
  Widget build(BuildContext context) {
    final controller = departmentsController; // From mixin

    return BaseClothingDepartment(
      config: ClothingDepartmentConfig.fromMapSizes(
        title: widget.category.name,
        categoryData: womenPlus,
        sizesMap: womenPlusSizesList,
        isLoadingType: controller.isLoadingWomenPlusClothesTypes,
        methodChangeLoading: controller.changeLoadingWomenPlusClothes,
        check: controller.haveCheckWomenPlusClothes,
        category: widget.category,
      ),
    );
  }
}
