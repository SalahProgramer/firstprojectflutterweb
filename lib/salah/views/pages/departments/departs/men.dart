import 'package:flutter/material.dart';
import '../../../../constants/constant-categories/constant_data_convert.dart';
import '../../../../localDataBase/hive_data/data_sizes.dart';
import '../../../../models/constants/constant_model.dart';
import '../departments_base_view.dart';
import 'base_clothing_department.dart';

class Men extends StatefulWidget {
  final CategoryModel category;

  const Men({super.key, required this.category});

  @override
  State<Men> createState() => _MenState();
}

class _MenState extends State<Men> with DepartmentViewMixin {
  @override
  Widget build(BuildContext context) {
    final controller = departmentsController; // From mixin

    return BaseClothingDepartment(
      config: ClothingDepartmentConfig.fromMapSizes(
        title: widget.category.name,
        categoryData: men,
        sizesMap: menSizesList,
        isLoadingType: controller.isLoadingMenClothesTypes,
        methodChangeLoading: controller.changeLoadingMenClothes,
        check: controller.haveCheckMenClothes,
        category: widget.category,
      ),
    );
  }
}
