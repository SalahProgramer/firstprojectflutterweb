import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:fawri_app_refactor/salah/views/pages/departments/page_dapartment.dart';
import 'package:fawri_app_refactor/server/functions/functions.dart';
import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants/constant-categories/constant_data_convert.dart';
import '../../../../controllers/custom_page_controller.dart';
import '../../../../models/constants/constant_model.dart';
import '../../../../widgets/departments_home_widgets/button_types.dart';
import '../../../../widgets/departments_home_widgets/widget_each_department.dart';
import '../departments_base_view.dart';

class PerfumeHome extends StatefulWidget {
  const PerfumeHome({super.key});

  @override
  State<PerfumeHome> createState() => _PerfumeHomeState();
}

class _PerfumeHomeState extends State<PerfumeHome> with DepartmentViewMixin {
  AnalyticsService analyticsService = AnalyticsService();

  /// Handle navigation to all perfumes (MVC: View handles navigation)
  Future<void> _navigateToAllPerfumes() async {
    final controller = readDepartmentsController();
    
    await controller.clear();
    await controller.clearPerfume();
    final category = CategoryModel.fromJsonListCategory(perfume);
    await controller.setSubCategoryDepartments([], true);
    await controller.setSubCategorySpecific(category[0]);

    NavigatorApp.push(
      PageDapartment(
        showIconSizes: false,
        title: "عطور",
        sizes: '',
        scrollController: controller.scrollPerfumeItems,
        category: controller.selectSubCategorySpecific,
      ),
    );
  }

  /// Handle sure button navigation for perfumes (MVC: View handles navigation)
  Future<void> _navigatePerfumeSure() async {
    final controller = readDepartmentsController();
    final customPageController = context.read<CustomPageController>();
    
    await controller.clear();
    final category = CategoryModel.fromJsonListCategory(perfume);

    if (controller.isLoadingPerfumeType!.values.every((value) => value == true)) {
      await controller.setSubCategoryDepartments([], true);
      await controller.setSubCategorySpecific(category[0]);
    } else {
      if (controller.isLoadingPerfumeType?[1] == true) {
        await controller.setSubCategoryDepartmentsPerfume(tagsMen);
        await controller.setSubCategorySpecific(category[1]);
      } else {
        await controller.setSubCategoryDepartmentsPerfume(womenTags);
        await controller.setSubCategorySpecific(category[2]);
        await customPageController.changeIndexCategoryPage(1);
      }
    }
    
    printLog("sub :   ${controller.selectSubCategorySpecific.subCategory}");
    
    NavigatorApp.push(
      PageDapartment(
        title: "عطور",
        showIconSizes: false,
        sizes: '',
        scrollController: controller.scrollPerfumeItems,
        category: controller.selectSubCategorySpecific,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = departmentsController; // From mixin
    return WidgetEachDepartment(
      backgroundImage: Assets.images.departments.perfume.path,
      style: 1,
      listStyle2: [],
      title: "عطور",
      check: controller.haveCheck,
      children: [
        ButtonTypes(
          text: 'عطور رجالية  ',
          haveBouncingWidget: false,
          colorFilter: ColorFilter.mode(Colors.blueAccent, BlendMode.srcIn),
          isLoading: controller.isLoadingPerfumeType?[1],
          iconName: Assets.icons.perfumeIcon,
          onPressed: () async {
            await analyticsService.logEvent(
              eventName: "men_perfume_button_click",
              parameters: {
                "class_name": "PerfumeHome",
                "button_name": "عطور رجالية",
                "time": DateTime.now().toString(),
              },
            );

            await controller.changeLoadingPerfume(
              1,
              !departmentsController.isLoadingPerfumeType![1]!,
            );
          },
        ),
        ButtonTypes(
          text: 'عطور نسائية  ',
          haveBouncingWidget: false,
          isLoading: controller.isLoadingPerfumeType?[2],
          iconName: Assets.icons.perfumeIcon,
          colorFilter: ColorFilter.mode(Colors.pinkAccent, BlendMode.srcIn),
          onPressed: () async {
            await analyticsService.logEvent(
              eventName: "women_perfume_button_click",
              parameters: {
                "class_name": "PerfumeHome",
                "button_name": "عطور نسائية",
                "time": DateTime.now().toString(),
              },
            );

            await controller.changeLoadingPerfume(
              2,
              !departmentsController.isLoadingPerfumeType![2]!,
            );
          },
        ),
        ButtonTypes(
          text: 'الجميع',
          haveBouncingWidget: false,
          iconName: Assets.icons.allSelect,
          onPressed: () async {
            await analyticsService.logEvent(
              eventName: "all_perfume_button_click",
              parameters: {
                "class_name": "PerfumeHome",
                "button_name": "الجميع العطور",
                "time": DateTime.now().toString(),
              },
            );

            await _navigateToAllPerfumes();
          },
        ),
      ],
      onPressedSure: () async {
        await _navigatePerfumeSure();
      },
    );
  }
}
