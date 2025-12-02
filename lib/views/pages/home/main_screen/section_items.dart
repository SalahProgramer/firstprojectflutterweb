import 'package:fawri_app_refactor/views/pages/home/main_screen/products_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/fetch_controller.dart';
import '../../../../controllers/sub_main_categories_conrtroller.dart';
import '../../../../core/utilities/global/app_global.dart';
import '../../../../core/utilities/routes.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/custom_shimmer.dart';
import '../../../../core/widgets/widgets_main_screen/show_big_small_categories.dart';
import '../../../../core/widgets/widgets_main_screen/titles.dart';
import '../../../../models/sections/style_model.dart';
import '../../../../models/products_view_config.dart';
import '../../../../controllers/page_main_screen_controller.dart';


class SectionItems extends StatelessWidget {
  const SectionItems({super.key});

  @override
  Widget build(BuildContext context) {
    PageMainScreenController pageMainScreenController =
        context.watch<PageMainScreenController>();
    FetchController fetchController = context.watch<FetchController>();

    SubMainCategoriesController subMainCategoriesController =
        context.watch<SubMainCategoriesController>();

    return (pageMainScreenController.sections.isNotEmpty &&
            (pageMainScreenController.fetchAppSection == true))
        ? ListView.builder(
            itemCount: pageMainScreenController.sections.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              var bgColor = pageMainScreenController
                      .sections[index].style?.bGColor
                      .toString() ??
                  "";
              Color backgroundColor = bgColor.isNotEmpty
                  ? (fetchController.showEven == 1)
                      ? ((index % 2 == 0))
                          ? Colors.white
                          : Colors.transparent
                      : Color(int.parse(bgColor.replaceFirst('#', '0xff')))
                  : Colors.transparent;
              bool check = (index % 2) == 0;
              return (pageMainScreenController.sections[index].type ==
                      "section")
                  ? section(
                      index: index,
                      styleModel:
                          pageMainScreenController.sections[index].style!,
                      backgroundColor: backgroundColor,
                      pageMainScreenController: pageMainScreenController,
                      subMainCategoriesController: subMainCategoriesController,
                      fetchController: fetchController,
                      check: check)
                  : banner(
                      height: pageMainScreenController.sections[index].height,
                      bgImage: pageMainScreenController.sections[index].bgImage,
                      subMainCategoriesController: subMainCategoriesController,
                      index: index,
                      pageMainScreenController: pageMainScreenController);
            },
          )
        : shimmerListView(fetchController);
  }

  Widget section(
      {required int index,
      required Color backgroundColor,
      required PageMainScreenController pageMainScreenController,
      required SubMainCategoriesController subMainCategoriesController,
      required FetchController fetchController,
      required StyleModel styleModel,
      required bool check}) {
    return Column(
      children: [
        if (pageMainScreenController.sections[index].bgImage == "")
          Titles(
            text: pageMainScreenController.sections[index].name.toString(),
            showEven: fetchController.showEven,
            flag: 1,
            heightText: 1.4.h,
          ),
        if (pageMainScreenController.sections[index].bgImage == "")
          SizedBox(
            height: 2.h,
          ),
        Column(
          children: [
            ProductsViewInList(
              configModel: ProductsViewConfigModel(
                hasAnimatedBorder: false,
                flag: (check == true) ? 0 : 1,
                doSwipeAuto: pageMainScreenController.sections[index].animation,
                changeLoadingProduct:
                    pageMainScreenController.changeLoadingSectionsItems,
                i: index,
                bgColor: backgroundColor,
                styleModel: styleModel,
                scrollController:
                    pageMainScreenController.scrollControllerSection[index],
                listItems: pageMainScreenController.sectionsItems[index],
                numberStyle: (int.tryParse(pageMainScreenController
                            .sections[index].style?.styleId ??
                        "1")) ??
                    1,
                bgImage: pageMainScreenController.sections[index].bgImage,
                heightBGImage:
                    pageMainScreenController.sections[index].height.toDouble(),
                isLoadingProduct:
                    pageMainScreenController.isLoadingSectionsItems[index],
              ),
            ),
            ShowBigSmallCategories(
              isWhite: (backgroundColor == Colors.white) ? false : true,
              onTap: () async {
                await subMainCategoriesController.clear();

                NavigatorApp.pushName(
                  AppRoutes.homeScreen,
                  arguments: {
                    'i': index,
                    'scrollController':
                        subMainCategoriesController.scrollSectionsItems,
                    'type':
                        pageMainScreenController.sections[index].name.toString(),
                    'title': "",
                    'url': "",
                    'hasAppBar': true,
                    'bannerTitle': '',
                  },
                );
              },
              turn: 1,
            ),
          ],
        )
      ],
    );
  }

  Widget banner(
      {required String bgImage,
      required int height,
      required int index,
      required PageMainScreenController pageMainScreenController,
      required SubMainCategoriesController subMainCategoriesController}) {
    return (bgImage != "")
        ? InkWell(
            overlayColor: WidgetStateColor.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            onTap: () async {
              await subMainCategoriesController.clear();

              NavigatorApp.pushName(
                AppRoutes.homeScreen,
                arguments: {
                  'bannerTitle': "",
                  'endDate': "",
                  'hasAppBar': true,
                  'type': "normal",
                  'productsKinds': false,
                  'title': pageMainScreenController.sections[index].name,
                  'url': pageMainScreenController.sections[index].contentUrl,
                  'scrollController':
                      subMainCategoriesController.scrollSlidersItems,
                  'slider': true,
                },
              );
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 20.h, top: 2.h),
              width: double.maxFinite,
              height: height.h,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(0.r)
                  //       boxShadow: [
                  // BoxShadow(
                  //     color: Colors.grey,
                  //     blurStyle: BlurStyle.outer,
                  //     blurRadius: 4,
                  //     spreadRadius: 0)
                  // ]
                  ),
              child: CustomImageSponsored(
                imageUrl: bgImage,
                width: double.infinity,
                borderCircle: 0.r,
                borderRadius: BorderRadius.circular(0.r),
              ),
            ),
          )
        : SizedBox();
  }


  Widget shimmerListView( FetchController fetchController){
    return ListView.builder(
      itemCount: 8,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return SizedBox(
            height: 0.30.sh,
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Titles(
                  text: "                                             ",
                  showEven: fetchController.showEven,
                  flag: 1,
                  heightText: 1.4.h,
                ),
                SizedBox(
                  height: 2.h,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: 10,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => ItemShim(
                      hasAnimatedBorder: false,
                      width: 120.w,
                    ),
                  ),
                ),
              ],
            ));
      },
    );


  }
}
