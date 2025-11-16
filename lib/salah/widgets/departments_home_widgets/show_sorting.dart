import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/controllers/departments_controller.dart';
import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../models/constants/constant_model.dart';
import '../../utilities/global/app_global.dart';
import 'button_types.dart';

class ShowSorting extends StatefulWidget {
  final ScrollController scrollController;
  final String? sizes;
  final CategoryModel? category;
  const ShowSorting(
      {super.key, required this.scrollController, this.sizes, this.category});

  @override
  State<ShowSorting> createState() => _ShowSortingState();
}

class _ShowSortingState extends State<ShowSorting> {
  AnalyticsService analyticsService = AnalyticsService();
  @override
  Widget build(BuildContext context) {
    DepartmentsController departmentsController =
        context.watch<DepartmentsController>();
    return StreamBuilder<Object>(
        stream: null,
        builder: (context, snapshot) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 10.h,
              ),
              ButtonTypes(
                  text: "أحدث أولاً",
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  isLoading:
                      (departmentsController.numSort != 1) ? false : true,
                  colorShadow: Colors.blueGrey,
                  iconName: Assets.icons.sorting,
                  height: 30.h,
                  haveBouncingWidget: false,
                  onPressed: () async {
                    await analyticsService.logEvent(
                      eventName: "sort_latest_first",
                      parameters: {
                        "class_name": "ShowSorting",
                        "button_name": "أحدث أولاً sorting",
                        "sort_type": "latest_first",
                        "time": DateTime.now().toString(),
                      },
                    );

                    await departmentsController.setNumSort(1);
                    await departmentsController.clearSort();

                    NavigatorApp.pop();

                    if (widget.scrollController ==
                        departmentsController.scrollPerfumeItems) {
                      await departmentsController.getPerfume();
                    } else if (widget.scrollController ==
                        departmentsController.scrollMultiItems) {
                      await departmentsController.getData(
                          category: widget.category ??
                              CategoryModel(
                                  name: "",
                                  subCategory: "",
                                  image: "",
                                  mainCategory: "",
                                  icon: ""),
                          sizes: widget.sizes ?? "",
                          isFirst: false);
                    }
                  }),
              SizedBox(
                height: 10.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Divider(),
              ),
              SizedBox(
                height: 10.h,
              ),
              ButtonTypes(
                  text: "عشوائي",
                  iconName: Assets.icons.random,
                  colorShadow: Colors.blueGrey,
                  haveBouncingWidget: false,
                  height: 30.h,
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  isLoading:
                      (departmentsController.numSort != 2) ? false : true,
                  onPressed: () async {
                    await analyticsService.logEvent(
                      eventName: "sort_random",
                      parameters: {
                        "class_name": "ShowSorting",
                        "button_name": "ButtonTypes (عشوائي)",
                        "sort_type": "random",
                        "time": DateTime.now().toString(),
                      },
                    );

                    await departmentsController.setNumSort(2);
                    await departmentsController.clearSort();

                    NavigatorApp.pop();

                    if (widget.scrollController ==
                        departmentsController.scrollPerfumeItems) {
                      await departmentsController.getPerfume();
                    } else if (widget.scrollController ==
                        departmentsController.scrollMultiItems) {
                      await departmentsController.getData(
                          category: widget.category ??
                              CategoryModel(
                                  name: "",
                                  subCategory: "",
                                  image: "",
                                  mainCategory: "",
                                  icon: ""),
                          sizes: widget.sizes ?? "",
                          isFirst: false);
                    }
                  }),
              SizedBox(
                height: 10.h,
              ),
            ],
          );
        });
  }
}
