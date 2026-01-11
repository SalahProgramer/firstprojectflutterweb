import 'package:auto_size_text/auto_size_text.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/models/constants/constant_model.dart';
import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../controllers/custom_page_controller.dart';
import '../../controllers/departments_controller.dart';
import '../../controllers/page_main_screen_controller.dart';
import '../../models/first_images_model.dart';
import '../../utilities/style/colors.dart';
import '../custom_image.dart';

class CategoryDesignSpecificWidget extends StatelessWidget {
  final CategoryModel categoryModel;
  final bool isDiscounted;

  const CategoryDesignSpecificWidget({
    super.key,
    required this.categoryModel,
    required this.isDiscounted,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        DesignCategoryWidget(
          setBorder: isDiscounted,
          categoryModel: categoryModel,
        ),
        if (isDiscounted)
          Lottie.asset(
            Assets.lottie.animation1726302974575,
            height: 25.h,
            reverse: true,
            repeat: true,
            fit: BoxFit.cover,
          ),
      ],
    );
  }
}

class DesignCategoryWidget extends StatelessWidget {
  final CategoryModel categoryModel;
  final bool setBorder;

  const DesignCategoryWidget({
    super.key,
    required this.categoryModel,
    required this.setBorder,
  });

  @override
  Widget build(BuildContext context) {
    AnalyticsService analyticsService = AnalyticsService();

    CustomPageController customPageController = context
        .watch<CustomPageController>();
    PageMainScreenController pageMainScreenController = context
        .watch<PageMainScreenController>();
    DepartmentsController departmentsController = context
        .watch<DepartmentsController>();
    final smallCategory =
        (pageMainScreenController.setBigCategories == false &&
        ((customPageController.selectPage == 0)));
    return InkWell(
      onTap: () async {
        await analyticsService.logViewContent(
          contentId: categoryModel.id?.toString() ?? "",
          contentType: "category",
          contentTitle: categoryModel.name,
          parameters: {
            "class_name": "CategoryDesignSpecificWidget",
            "button_name": "category: ${categoryModel.name}",
            "category_id": categoryModel.id.toString(),
            "category_name": categoryModel.name,
            "time": DateTime.now().toString(),
          },
        );
        await departmentsController.clear();
        await customPageController.changeIndexCategoryPage(1);
        await departmentsController.tapSelectCategory(
          categoryModel: categoryModel,
        );
      },
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      overlayColor: WidgetStateColor.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: smallCategory
                ? [Colors.transparent, Colors.transparent]
                : [CustomColor.blueColor, Colors.blue.shade500],
          ),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          children: [
            Expanded(
              flex: smallCategory ? 2 : 6,
              child: Stack(
                children: [
                  smallCategory
                      ? Container(
                          margin: EdgeInsets.only(top: 4.h),
                          decoration: boxDecoration(
                            isSmallCategory: smallCategory,
                          ),
                          child: CircleAvatar(
                            radius: 35.r,
                            backgroundImage: Image(
                              fit: BoxFit.contain,
                              image: AssetImage(categoryModel.image),
                            ).image,
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: boxDecoration(),
                          child: Builder(
                            builder: (context) {
                              FirstImagesModel category =
                                  pageMainScreenController.imagesFirstCategories
                                      .firstWhere(
                                        (item) {
                                          return item.id.toString().trim() ==
                                              categoryModel.id
                                                  .toString()
                                                  .trim();
                                        },
                                        orElse: () => FirstImagesModel(
                                          mainCategory: "",
                                          image: "",
                                          id: "1",
                                        ),
                                      );
                              // If category is found, pass the image URL
                              return CustomImageSponsored(
                                imageUrl: category.image,
                                width: double.maxFinite,
                                height: double.maxFinite,
                                borderRadius: BorderRadius.circular(10.r),
                                borderCircle: 0,
                                boxFit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                width: double.maxFinite,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: AutoSizeText(
                  categoryModel.name,
                  maxLines: 2,
                  wrapWords: true,
                  maxFontSize: (!smallCategory) ? 18 : 14,
                  // textScaleFactor: 0.95,
                  minFontSize: (!smallCategory) ? 18 : 14,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: (smallCategory) ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: (pageMainScreenController.setBigCategories)
                        ? 18.sp
                        : 13.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration boxDecoration({bool isSmallCategory = false}) {
    return BoxDecoration(
      boxShadow: isSmallCategory
          ? [
              BoxShadow(
                color: colorBox(),
                blurRadius: 5.r,
                blurStyle: BlurStyle.outer,
              ),
            ]
          : null,
      border: Border(
        bottom: BorderSide(
          color: colorBox(), // Light Coral
          width: (isSmallCategory) ? 4.3.w : 5.w,
        ),
      ),
      color: Color(0xFFFFFFFF),
      shape: (isSmallCategory) ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: (isSmallCategory) ? null : BorderRadius.circular(14.r),
    );
  }

  Color colorBox() {
    return setBorder
        ? Color(0xFF2ECC71) // Emerald Green
        : Color(0xFFFF6F61);
  }
}
