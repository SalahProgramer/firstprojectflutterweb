
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../controllers/custom_page_controller.dart';
import '../../../core/services/analytics/analytics_service.dart';
import '../../../core/utilities/global/app_global.dart';
import '../../../core/utilities/style/colors.dart';
import '../../../core/widgets/app_bar_widgets/app_bar_custom.dart';
import '../../../core/widgets/widgets_pages/bottom_navigator_bar_pages.dart';
import '../../../models/constants/constant_model.dart';
import '../favourite/favourite_page.dart';
import '../profile/profile.dart';
import 'home_page_department.dart';

class PageDapartment extends StatefulWidget {
  final String title;
  final String? sizes;
  final CategoryModel category;
  final bool showIconSizes;

  final ScrollController scrollController;

  const PageDapartment(
      {super.key,
      required this.title,
      this.sizes = "",
      required this.scrollController,
      required this.category,
      required this.showIconSizes});

  @override
  State<PageDapartment> createState() => _PageDapartmentState();
}

class _PageDapartmentState extends State<PageDapartment> {
  AnalyticsService analyticsService = AnalyticsService();

  @override
  Widget build(BuildContext context) {
    CustomPageController customPageController =
        context.watch<CustomPageController>();

    List<Widget> listOfWidget = <Widget>[
      FavouritePage(),
      HomePageDepartment(
        sizes: widget.sizes ?? "",
        category: widget.category,
        scrollController: widget.scrollController,
      ),
      ProfileScreen(),
    ];
    return ShowCaseWidget(builder: (context) {
      return Container(
        color: mainColor,
        child: Scaffold(
            extendBody: true,
            backgroundColor: (customPageController.selectCategoryPage == 1)
                ? null
                : Colors.white,
            bottomNavigationBar: BottomNavigatorBarPages(
              isCategoryPage: true,
              selectedIndex: customPageController.selectCategoryPage,
              onPressed: (index) async {
                await analyticsService.logEvent(
                  eventName: "bottom_nav_category_page_click",
                  parameters: {
                    "class_name": "PageDapartment",
                    "button_name": "BottomNavigatorBarPages (index: $index)",
                    "selected_index": index,
                    "time": DateTime.now().toString(),
                  },
                );
                if (customPageController.selectCategoryPage == index &&
                    index == 1) {
                  NavigatorApp.pop();
                  NavigatorApp.pop();
                  NavigatorApp.pop();
                } else {
                  await customPageController.changeIndexCategoryPage(index);
                }
              },
            ),
            appBar: CustomAppBar(
              title: widget.title,
              sizes: widget.sizes ?? "",
              showIconSizes: widget.showIconSizes,
              textButton: "رجوع",
              onPressed: () {
                NavigatorApp.pop();
              },
            ),
            body: listOfWidget[customPageController.selectCategoryPage]),
      );
    });
  }
}
