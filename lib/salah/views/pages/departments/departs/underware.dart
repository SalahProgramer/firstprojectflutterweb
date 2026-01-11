import 'package:flutter/material.dart';
import '../../../../constants/constant-categories/constant_data_convert.dart';
import '../../../../localDataBase/hive_data/data_sizes.dart';
import '../departments_base_view.dart';
import 'base_clothing_department.dart';

class Underware extends StatefulWidget {
  const Underware({super.key});

  @override
  State<Underware> createState() => _UnderwareState();
}

class _UnderwareState extends State<Underware> with DepartmentViewMixin {
  @override
  Widget build(BuildContext context) {
    final controller = departmentsController; // From mixin

    return BaseClothingDepartment(
      config: ClothingDepartmentConfig.fromListSizes(
        title: "ملابس داخلية",
        categoryData: underWare,
        sizesList: underwearSizes,
        isLoadingType: controller.isLoadingUnderWareTypes,
        methodChangeLoading: controller.changeLoadingUnderWareClothes,
        check: controller.haveCheckUnderWareClothes,
      ),
    );
  }
}
