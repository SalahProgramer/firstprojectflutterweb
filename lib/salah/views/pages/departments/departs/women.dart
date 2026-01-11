import 'package:flutter/material.dart';
import '../../../../constants/constant-categories/constant_data_convert.dart';
import '../../../../localDataBase/hive_data/data_sizes.dart';
import '../../../../models/constants/constant_model.dart';
import '../departments_base_view.dart';
import 'base_clothing_department.dart';

class Women extends StatefulWidget {
  final CategoryModel category;

  const Women({super.key, required this.category});

  @override
  State<Women> createState() => _WomenState();
}

class _WomenState extends State<Women> with DepartmentViewMixin {
  @override
  Widget build(BuildContext context) {
    final controller = departmentsController; // From mixin

    return BaseClothingDepartment(
      config: ClothingDepartmentConfig.fromMapSizes(
        title: "ملابس النسائية",
        categoryData: women,
        sizesMap: womenSizesList,
        isLoadingType: controller.isLoadingWomenClothesTypes,
        methodChangeLoading: controller.changeLoadingWomenClothes,
        check: controller.haveCheckWomenClothes,
        category: widget.category,
      ),
    );
  }
}
