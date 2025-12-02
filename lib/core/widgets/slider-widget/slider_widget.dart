import 'package:fawri_app_refactor/models/constants/constant_model.dart';
import '../../../controllers/custom_page_controller.dart';
import '../../../controllers/departments_controller.dart';
import '../../../controllers/sub_main_categories_conrtroller.dart';
import '../../../models/slider_model.dart';
import '../../services/analytics/analytics_service.dart';
import '../../utilities/global/app_global.dart';
import '../../utilities/routes.dart';

import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../constants/constant_data/constant_data_convert.dart';
import '../custom_image.dart';

class SlideImage extends StatefulWidget {
  final List<SliderModel> sliderImage;
  final bool showShadow;

  final bool withCategory;

  final bool click;

  const SlideImage({
    super.key,
    required this.sliderImage,
    this.withCategory = false,
    this.showShadow = false,
    this.click = false,
  });

  @override
  State<SlideImage> createState() => _SlideImageState();
}

class _SlideImageState extends State<SlideImage> {
  AnalyticsService analyticsService = AnalyticsService();

  @override
  Widget build(BuildContext context) {
    SubMainCategoriesController subMainCategoriesController =
        context.watch<SubMainCategoriesController>();
    DepartmentsController departmentsController =
        context.watch<DepartmentsController>();
    CustomPageController customPageController =
        context.watch<CustomPageController>();
    
    return ImageSlideshow(
      width: double.maxFinite,
      indicatorColor: Colors.black,
      indicatorRadius: 2.6.r,
      indicatorPadding: 10.h,

      isLoop: widget.sliderImage.length == 1 ? false : true,
      height: 0.28.sh,
      autoPlayInterval: 7000,

      children: widget.sliderImage
          .map((e) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: GestureDetector(
                  onTap: () async {
                    await analyticsService.logViewContent(
                      contentId: e.id?.toString() ?? "",
                      contentType: "banner",
                      contentTitle: e.title,
                      parameters: {
                        "class_name": "SlideImage",
                        "button_name": "view_banner",
                        "time": DateTime.now().toString(),
                      },
                    );
                    await subMainCategoriesController.clear();
                    await departmentsController.clear();
                    await customPageController.changeIndexCategoryPage(1);
                    if (widget.withCategory) {
                      if (e.action.toString() == "5") {
                        NavigatorApp.pushName(
                          AppRoutes.shoes,
                          arguments: {
                            'category': CategoryModel.fromJson(basicCategories[5]),
                          },
                        );
                      } else if (e.action.toString() == "3") {
                        NavigatorApp.pushName(
                          AppRoutes.kidsAll,
                          arguments: {
                            'category': CategoryModel.fromJson(basicCategories[2]),
                          },
                        );
                      } else if (e.action.toString() == "17") {
                        await departmentsController.clearMulti();

                        var category =
                            CategoryModel.fromJsonListCategory(sports);

                        await departmentsController.setSubCategoryDepartments(
                            sports, false);

                        await departmentsController
                            .setSubCategorySpecific(category[0]);
                        NavigatorApp.pushName(
                          AppRoutes.pageDepartment,
                          arguments: {
                            'title': "ملابس رياضية",
                            'category': CategoryModel.fromJson(basicCategories[17]),
                            'showIconSizes': false,
                            'sizes': '',
                            'scrollController':
                                departmentsController.scrollMultiItems,
                          },
                        );
                      } else if (e.action.toString() == "7") {
                        await departmentsController.clearMulti();

                        var category = CategoryModel.fromJsonListCategory(home);

                        await departmentsController.setSubCategoryDepartments(
                            home, false);

                        await departmentsController
                            .setSubCategorySpecific(category[0]);
                        NavigatorApp.pushName(
                          AppRoutes.pageDepartment,
                          arguments: {
                            'title': "للمنزل",
                            'category': CategoryModel.fromJson(basicCategories[9]),
                            'showIconSizes': false,
                            'sizes': '',
                            'scrollController':
                                departmentsController.scrollMultiItems,
                          },
                        );
                      }
                      else if (e.action.toString() == "6") {
                        await departmentsController.clearMulti();

                        var category =
                            CategoryModel.fromJsonListCategory(womenAndBaby);

                        await departmentsController.setSubCategoryDepartments(
                            womenAndBaby, false);

                        await departmentsController
                            .setSubCategorySpecific(category[0]);
                        NavigatorApp.pushName(
                          AppRoutes.pageDepartment,
                          arguments: {
                            'title': "للرضيع",
                            'showIconSizes': false,
                            'category': CategoryModel.fromJson(basicCategories[7]),
                            'sizes': '',
                            'scrollController':
                                departmentsController.scrollMultiItems,
                          },
                        );
                      }
                      else if (e.action.toString() == "10") {
                        await departmentsController.clearMulti();

                        var category =
                            CategoryModel.fromJsonListCategory(apparel);

                        await departmentsController.setSubCategoryDepartments(
                            apparel, false);

                        await departmentsController
                            .setSubCategorySpecific(category[0]);
                        NavigatorApp.pushName(
                          AppRoutes.pageDepartment,
                          arguments: {
                            'title': "مجوهرات و ساعات",
                            'category': CategoryModel.fromJson(basicCategories[10]),
                            'showIconSizes': false,
                            'sizes': '',
                            'scrollController':
                                departmentsController.scrollMultiItems,
                          },
                        );
                      } else if (e.action.toString() == "9") {
                        await departmentsController.clearMulti();

                        var category =
                            CategoryModel.fromJsonListCategory(beauty);

                        await departmentsController.setSubCategoryDepartments(
                            beauty, false);

                        await departmentsController
                            .setSubCategorySpecific(category[0]);
                        NavigatorApp.pushName(
                          AppRoutes.pageDepartment,
                          arguments: {
                            'title': "اكسسوارات",
                            'category': CategoryModel.fromJson(basicCategories[11]),
                            'sizes': '',
                            'showIconSizes': false,
                            'scrollController':
                                departmentsController.scrollMultiItems,
                          },
                        );
                      } else if (e.action.toString() == "13") {
                        await departmentsController.clearMulti();

                        await departmentsController
                            .setSubCategoryDepartments([], false);

                        await departmentsController.setSubCategorySpecific(
                            CategoryModel.fromJson(basicCategories[15]));
                        NavigatorApp.pushName(
                          AppRoutes.pageDepartment,
                          arguments: {
                            'title': "مستحضرات تجميلية",
                            'category': CategoryModel.fromJson(basicCategories[15]),
                            'showIconSizes': false,
                            'sizes': '',
                            'scrollController':
                                departmentsController.scrollMultiItems,
                          },
                        );
                      } else if (e.action.toString() == "16") {
                        await departmentsController.clearMulti();

                        var category =
                            CategoryModel.fromJsonListCategory(electronics);

                        await departmentsController.setSubCategoryDepartments(
                            electronics, false);

                        await departmentsController
                            .setSubCategorySpecific(category[0]);
                        NavigatorApp.pushName(
                          AppRoutes.pageDepartment,
                          arguments: {
                            'title': "الكترونيات",
                            'showIconSizes': false,
                            'category': category[0],
                            'sizes': '',
                            'scrollController':
                                departmentsController.scrollMultiItems,
                          },
                        );
                      } else if (e.action.toString() == "15") {
                        await departmentsController.clearMulti();

                        var category = CategoryModel.fromJsonListCategory(bags);

                        await departmentsController.setSubCategoryDepartments(
                            bags, false);

                        await departmentsController
                            .setSubCategorySpecific(category[0]);
                        NavigatorApp.pushName(
                          AppRoutes.pageDepartment,
                          arguments: {
                            'title': "حقائب",
                            'category': category[0],
                            'showIconSizes': false,
                            'sizes': '',
                            'scrollController':
                                departmentsController.scrollMultiItems,
                          },
                        );
                      } else if (e.action.toString() == "11") {
                        await departmentsController.clearMulti();

                        await departmentsController
                            .setSubCategoryDepartments([], false);

                        await departmentsController.setSubCategorySpecific(
                            CategoryModel.fromJson(basicCategories[13]));
                        NavigatorApp.pushName(
                          AppRoutes.pageDepartment,
                          arguments: {
                            'title':
                                CategoryModel.fromJson(basicCategories[13]).name,
                            'showIconSizes': false,
                            'category': CategoryModel.fromJson(basicCategories[13]),
                            'sizes': '',
                            'scrollController':
                                departmentsController.scrollMultiItems,
                          },
                        );
                      } else if (e.action.toString() == "12") {
                        await departmentsController.clearMulti();

                        await departmentsController
                            .setSubCategoryDepartments([], false);

                        await departmentsController.setSubCategorySpecific(
                            CategoryModel.fromJson(basicCategories[12]));
                        NavigatorApp.pushName(
                          AppRoutes.pageDepartment,
                          arguments: {
                            'title':
                                CategoryModel.fromJson(basicCategories[12]).name,
                            'category': CategoryModel.fromJson(basicCategories[12]),
                            'showIconSizes': false,
                            'sizes': '',
                            'scrollController':
                                departmentsController.scrollMultiItems,
                          },
                        );
                      } else if (e.action.toString() == "14") {
                        await departmentsController.clearMulti();

                        await departmentsController
                            .setSubCategoryDepartments([], false);

                        await departmentsController.setSubCategorySpecific(
                            CategoryModel.fromJson(basicCategories[14]));
                        NavigatorApp.pushName(
                          AppRoutes.pageDepartment,
                          arguments: {
                            'title':
                                CategoryModel.fromJson(basicCategories[14]).name,
                            'showIconSizes': false,
                            'category': CategoryModel.fromJson(basicCategories[14]),
                            'sizes': '',
                            'scrollController':
                                departmentsController.scrollMultiItems,
                          },
                        );
                      } else {
                        if (e.action.toString() == "2") {
                          NavigatorApp.pushName(
                            AppRoutes.women,
                            arguments: {
                              'category':
                                  CategoryModel.fromJson(basicCategories[0]),
                            },
                          );
                        } else if (e.action.toString() == "1") {
                          NavigatorApp.pushName(
                            AppRoutes.men,
                            arguments: {
                              'category':
                                  CategoryModel.fromJson(basicCategories[1]),
                            },
                          );
                        } else if (e.action.toString() == "4") {
                          NavigatorApp.pushName(
                            AppRoutes.womenPlus,
                            arguments: {
                              'category':
                                  CategoryModel.fromJson(basicCategories[3]),
                            },
                          );
                        }

                        // else if (e.action.toString() == "18") {
                        //   NavigatorApp.push(PerfumeHome());
                        // }

                        else if (e.action.toString() == "8") {
                          NavigatorApp.pushName(AppRoutes.underware);
                        }
                      }
                    } else {
                      NavigatorApp.pushName(
                        AppRoutes.homeScreen,
                        arguments: {
                          'bannerTitle': "",
                          'endDate': "",
                          'hasAppBar': true,
                          'type': "normal",
                          'productsKinds': false,
                          'title': e.title.toString() == ""
                              ? "سلايدر 1 سلايدر 1"
                              : e.title,
                          'url': e.action,
                          'scrollController':
                              subMainCategoriesController.scrollSlidersItems,
                          'slider': true,
                        },
                      );
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20.h, top: 2.h),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey,
                              blurStyle: BlurStyle.outer,
                              blurRadius: 4,
                              spreadRadius: 0)
                        ]),
                    child: CustomImageSponsored(
                      imageUrl: e.image,
                      width: double.infinity,
                      borderCircle: 12.r,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ))
          .toList(),
      // isLoop: true,
    );
  }
}
