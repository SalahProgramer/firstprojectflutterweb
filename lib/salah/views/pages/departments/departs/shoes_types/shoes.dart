import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/constants/constant-categories/constant_data_convert.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:fawri_app_refactor/salah/views/pages/departments/departs/shoes_types/kids_shoes.dart';
import 'package:fawri_app_refactor/salah/views/pages/departments/departs/shoes_types/men_shoes.dart';
import 'package:fawri_app_refactor/salah/views/pages/departments/departs/shoes_types/women_shoes.dart';
import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../controllers/custom_page_controller.dart';
import '../../../../../models/constants/constant_model.dart';
import '../../../../../widgets/departments_home_widgets/button_types.dart';
import '../../../../../widgets/departments_home_widgets/widget_each_department.dart';
import '../../departments_base_view.dart';
import '../../page_dapartment.dart';

class Shoes extends StatefulWidget {
  final CategoryModel category;

  const Shoes({super.key, required this.category});

  @override
  State<Shoes> createState() => _ShoesState();
}

class _ShoesState extends State<Shoes> with DepartmentViewMixin {
  AnalyticsService analyticsService = AnalyticsService();

  /// Handle navigation to all shoes (MVC: View handles navigation)
  Future<void> _navigateToAllShoes() async {
    final controller = readDepartmentsController();
    final customPageController = context.read<CustomPageController>();

    await controller.clearMulti();
    final category = CategoryModel.fromJsonListCategory(allShoes);
    await controller.setSubCategoryDepartments(allShoes, false);
    await controller.setSubCategorySpecific(category[0]);
    await customPageController.changeIndexCategoryPage(1);

    NavigatorApp.push(
      PageDapartment(
        title: widget.category.name,
        category: widget.category,
        showIconSizes: false,
        sizes: '',
        scrollController: controller.scrollMultiItems,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = departmentsController; // From mixin
    return WidgetEachDepartment(
      backgroundImage: Assets.images.departments.forShoes.path,
      style: 1,
      listStyle2: [],
      title: "أحذية",
      check: false,
      children: [
        ButtonTypes(
          text: 'أحذية الستاتية',
          haveBouncingWidget: false,
          colorFilter: ColorFilter.linearToSrgbGamma(),
          isLoading: controller.isLoadingShoesTypes?[1],
          iconName: Assets.icons.shoesWoman,
          onPressed: () async {
            await analyticsService.logEvent(
              eventName: "women_shoes_button_click",
              parameters: {
                "class_name": "Shoes",
                "button_name": "أحذية الستاتية",
                "time": DateTime.now().toString(),
              },
            );

            NavigatorApp.push(WomenShoes());
          },
        ),
        ButtonTypes(
          text: 'أحذية رجالية',
          haveBouncingWidget: false,
          isLoading: controller.isLoadingShoesTypes?[2],
          iconName: Assets.icons.shoesMen,
          onPressed: () async {
            await analyticsService.logEvent(
              eventName: "men_shoes_button_click",
              parameters: {
                "class_name": "Shoes",
                "button_name": "أحذية رجالية",
                "time": DateTime.now().toString(),
              },
            );

            NavigatorApp.push(MenShoes());

            // await departmentsController
            //     .changeLoadingShoes(
            //     2,
            //     !departmentsController
            //         .isLoadingShoesTypes![2]!);
          },
        ),
        ButtonTypes(
          text: 'أحذية أطفال',
          haveBouncingWidget: false,
          isLoading: controller.isLoadingShoesTypes?[3],
          iconName: Assets.icons.shoesBaby,
          onPressed: () async {
            await analyticsService.logEvent(
              eventName: "kids_shoes_button_click",
              parameters: {
                "class_name": "Shoes",
                "button_name": "أحذية أطفال",
                "time": DateTime.now().toString(),
              },
            );

            // await departmentsController
            //     .changeLoadingShoes(
            //     3,
            //     !departmentsController
            //         .isLoadingShoesTypes![3]!);
            NavigatorApp.push(KidsShoes());
          },
        ),
        ButtonTypes(
          text: 'الجميع',
          haveBouncingWidget: false,
          iconName: Assets.icons.allSelect,
          onPressed: () async {
            await analyticsService.logEvent(
              eventName: "all_shoes_button_click",
              parameters: {
                "class_name": "Shoes",
                "button_name": "الجميع",
                "time": DateTime.now().toString(),
              },
            );
            await _navigateToAllShoes();
          },
        ),
      ],
      onPressedSure: () async {},
    );
  }
}
