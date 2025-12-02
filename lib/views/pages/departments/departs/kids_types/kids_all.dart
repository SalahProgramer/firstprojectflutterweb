import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/constant_data/constant_data_convert.dart';
import '../../../../../controllers/custom_page_controller.dart';
import '../../../../../controllers/departments_controller.dart';
import '../../../../../core/services/analytics/analytics_service.dart';
import '../../../../../core/utilities/global/app_global.dart';
import '../../../../../core/utilities/routes.dart';
import '../../../../../core/widgets/departments_home_widgets/button_types.dart';
import '../../../../../core/widgets/departments_home_widgets/widget_each_department.dart';
import '../../../../../models/constants/constant_model.dart';


class KidsAll extends StatefulWidget {
  final CategoryModel category;

  const KidsAll({super.key, required this.category});

  @override
  State<KidsAll> createState() => _KidsAllState();
}

class _KidsAllState extends State<KidsAll> {
  AnalyticsService analyticsService = AnalyticsService();

  @override
  Widget build(BuildContext context) {
    DepartmentsController departmentsController =
        context.watch<DepartmentsController>();
    CustomPageController customPageController =
        context.watch<CustomPageController>();
    return WidgetEachDepartment(
      backgroundImage: Assets.images.departments.baby1.path,
      style: 1,
      listStyle2: [],
      title: widget.category.name,
      check: false,
      children: [
        ButtonTypes(
          text: "قسم الأولاد",
          haveBouncingWidget: false,
          colorFilter: ColorFilter.linearToSrgbGamma(),
          isLoading: false,
          iconName: Assets.icons.boy,
          onPressed: () async {
            await analyticsService.logEvent(
              eventName: "boy_kids_button_click",
              parameters: {
                "class_name": "KidsAll",
                "button_name": "قسم الأولاد",
                "time": DateTime.now().toString(),
              },
            );

            NavigatorApp.pushName(AppRoutes.boyKids);
          },
        ),
        ButtonTypes(
          text: 'قسم البنات',
          haveBouncingWidget: false,
          isLoading: false,
          iconName: Assets.icons.girl,
          onPressed: () async {
            await analyticsService.logEvent(
              eventName: "girl_kids_button_click",
              parameters: {
                "class_name": "KidsAll",
                "button_name": "قسم البنات",
                "time": DateTime.now().toString(),
              },
            );

            NavigatorApp.pushName(AppRoutes.girlKids);

            // await departmentsController
            //     .changeLoadingShoes(
            //     2,
            //     !departmentsController
            //         .isLoadingShoesTypes![2]!);
          },
        ),
        ButtonTypes(
          text: 'الرضيع',
          haveBouncingWidget: false,
          isLoading: departmentsController.isLoadingShoesTypes?[3],
          iconName: Assets.icons.pregnant,
          onPressed: () async {
            await analyticsService.logEvent(
              eventName: "women_and_baby_button_click",
              parameters: {
                "class_name": "KidsAll",
                "button_name": 'الرضيع',
                "time": DateTime.now().toString(),
              },
            );

            await departmentsController.clearMulti();

            var category = CategoryModel.fromJsonListCategory(womenAndBaby);

            await departmentsController.setSubCategoryDepartments(
                womenAndBaby, false);

            await departmentsController.setSubCategorySpecific(category[0]);
            NavigatorApp.pushName(
              AppRoutes.pageDepartment,
              arguments: {
                'title': 'الرضيع',
                'showIconSizes': false,
                'category': CategoryModel.fromJson(basicCategories[7]),
                'sizes': '',
                'scrollController': departmentsController.scrollMultiItems,
              },
            );
          },
        ),
        ButtonTypes(
          text: 'كلاهما',
          haveBouncingWidget: false,
          iconName: Assets.icons.allSelect,
          onPressed: () async {
            await analyticsService.logEvent(
              eventName: "all_kids_button_click",
              parameters: {
                "class_name": "KidsAll",
                "button_name": "كلاهما",
                "time": DateTime.now().toString(),
              },
            );

            await departmentsController.clearMulti();

            var category = CategoryModel.fromJsonListCategory(allkids);

            await departmentsController.setSubCategoryDepartments(
                allkids, false);

            await departmentsController.setSubCategorySpecific(category[0]);
            await customPageController.changeIndexCategoryPage(1);

            NavigatorApp.pushName(
              AppRoutes.pageDepartment,
              arguments: {
                'title': widget.category.name,
                'showIconSizes': false,
                'category': widget.category,
                'sizes': '',
                'scrollController': departmentsController.scrollMultiItems,
              },
            );
          },
        ),
      ],
      onPressedSure: () async {},
    );
  }
}
