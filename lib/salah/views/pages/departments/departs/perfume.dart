import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:fawri_app_refactor/salah/views/pages/departments/page_dapartment.dart';
import 'package:fawri_app_refactor/server/functions/functions.dart';
import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants/constant_data_convert.dart';
import '../../../../controllers/custom_page_controller.dart';
import '../../../../controllers/departments_controller.dart';
import '../../../../models/constants/constant_model.dart';
import '../../../../widgets/departments_home_widgets/button_types.dart';
import '../../../../widgets/departments_home_widgets/widget_each_department.dart';

class PerfumeHome extends StatefulWidget {
  const PerfumeHome({super.key});

  @override
  State<PerfumeHome> createState() => _PerfumeHomeState();
}

class _PerfumeHomeState extends State<PerfumeHome> {
  AnalyticsService analyticsService = AnalyticsService();

  @override
  Widget build(BuildContext context) {
    DepartmentsController departmentsController =
        context.watch<DepartmentsController>();
    CustomPageController customPageController =
        context.watch<CustomPageController>();
    return WidgetEachDepartment(
      backgroundImage: Assets.images.departments.perfume.path,
      style: 1,
      listStyle2: [],
      title: "عطور",
      check: departmentsController.haveCheck,
      children: [
        ButtonTypes(
          text: 'عطور رجالية  ',
          haveBouncingWidget: false,
          colorFilter: ColorFilter.mode(Colors.blueAccent, BlendMode.srcIn),
          isLoading: departmentsController.isLoadingPerfumeType?[1],
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

            await departmentsController.changeLoadingPerfume(
                1, !departmentsController.isLoadingPerfumeType![1]!);
          },
        ),
        ButtonTypes(
          text: 'عطور نسائية  ',
          haveBouncingWidget: false,
          isLoading: departmentsController.isLoadingPerfumeType?[2],
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

            await departmentsController.changeLoadingPerfume(
                2, !departmentsController.isLoadingPerfumeType![2]!);
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

            await departmentsController.clear();
            await departmentsController.clearPerfume();
            var category = CategoryModel.fromJsonListCategory(perfume);

            await departmentsController.setSubCategoryDepartments([], true);

            await departmentsController.setSubCategorySpecific(category[0]);

            NavigatorApp.push(PageDapartment(
              showIconSizes: false,
              title: "عطور",
              sizes: '',
              scrollController: departmentsController.scrollPerfumeItems,
              category: departmentsController.selectSubCategorySpecific,
            ));
          },
        ),
      ],
      onPressedSure: () async {
        await departmentsController.clear();
        var category = CategoryModel.fromJsonListCategory(perfume);

        if (departmentsController.isLoadingPerfumeType!.values
            .every((value) => value == true)) {
          await departmentsController.setSubCategoryDepartments([], true);

          await departmentsController.setSubCategorySpecific(category[0]);
        } else {
          if (departmentsController.isLoadingPerfumeType?[1] == true) {
            await departmentsController
                .setSubCategoryDepartmentsPerfume(tagsMen);

            await departmentsController.setSubCategorySpecific(category[1]);
          } else {
            await departmentsController
                .setSubCategoryDepartmentsPerfume(womenTags);

            await departmentsController.setSubCategorySpecific(category[2]);
            await customPageController.changeIndexCategoryPage(1);
          }
        }
        printLog(
            "sub :   ${departmentsController.selectSubCategorySpecific.subCategory}");
        NavigatorApp.push(PageDapartment(
          title: "عطور",
          showIconSizes: false,
          sizes: '',
          scrollController: departmentsController.scrollPerfumeItems,
          category: departmentsController.selectSubCategorySpecific,
        ));
      },
    );
  }
}
