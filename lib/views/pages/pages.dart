import 'package:fawri_app_refactor/views/pages/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/sub_main_categories_conrtroller.dart';
import '../../core/utilities/style/colors.dart';
import '../../core/widgets/app_bar_widgets/app_bar_custom.dart';
import '../../core/widgets/widgets_pages/bottom_navigator_bar_pages.dart';
import 'home/home_screen/home_screen.dart';
import '../../controllers/custom_page_controller.dart';
import '../../../controllers/fetch_controller.dart';
import '../../controllers/page_main_screen_controller.dart';
import 'favourite/favourite_page.dart';
import 'home/main_screen/page_category.dart';
import 'home/main_screen/page_main_screen.dart';

/// Wrapper widget that handles first page state switching without rebuilding IndexedStack
class _FirstPageWrapper extends StatefulWidget {
  const _FirstPageWrapper();

  @override
  State<_FirstPageWrapper> createState() => _FirstPageWrapperState();
}

class _FirstPageWrapperState extends State<_FirstPageWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final CustomPageController customPageController =
        context.watch<CustomPageController>();

    // Switch between widgets based on state without rebuilding parent
    return customPageController.first
        ? const PageMainScreen()
        : customPageController.widgetSubProductList()!;
  }

  @override
  bool get wantKeepAlive => true;
}

class Pages extends StatefulWidget {
  const Pages({super.key});

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> with AutomaticKeepAliveClientMixin {
  // Cache the entire widgets list to prevent rebuilding
  late final List<Widget> _cachedWidgets;

  @override
  void initState() {
    super.initState();
    _cachedWidgets = [
      const _FirstPageWrapper(),
      const PageCategory(),
      const FavouritePage(),
      const ProfileScreen(),
    ];
  }
  
  /// Scroll main screen to top and trigger refresh
  Future<void> scrollMainScreenToTop() async {
    try {
      // Access the main screen's scroll controller through the controller
      final PageMainScreenController pageMainScreenController =
          context.read<PageMainScreenController>();
      
      // Trigger refresh which will also scroll to top
      await pageMainScreenController.refreshMainScreen();
    } catch (e) {
      // Error handled silently - user will see normal behavior
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    CustomPageController customPageController =
        context.watch<CustomPageController>();

    FetchController fetchController = context.watch<FetchController>();
    SubMainCategoriesController subMainCategoriesController =
        context.watch<SubMainCategoriesController>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          // Allow back navigation
          return;
        } else {
          if (customPageController.first == false &&
              customPageController.selectPage == 0) {
            await customPageController.changeIndexPage(0);

            await customPageController.changePage0(true);
          } else {}
        }
      },
      child: BottomNavigatorBarPages(
          onPressed: (index) async {
            // If clicking the same index (especially index 0), scroll to top and refresh
            if (index == customPageController.selectPage) {
              if (index == 0 && customPageController.first) {
                // Trigger scroll to top and refresh for main screen
                await scrollMainScreenToTop();
              }
            } else {
              await customPageController.changeIndexPage(index);
            }
          },
          appBar: CustomAppBar(
            title:
                (customPageController.first) ? "الأقسام الرئيسية" : "الرئيسية",
            textButton: (customPageController.first) ? "تخطي" : "رجوع",
            onPressed: (customPageController.first)
                ? () async {
                    subMainCategoriesController.clear();
                    await customPageController.changeIndexPage(0);

                    customPageController.changeSubProductList(
                        widget: HomeScreen(
                      scrollController:
                          subMainCategoriesController.scrollProductsItems,
                    ));
                    await customPageController.changePage0(false);
                  }
                : () async {
                    subMainCategoriesController.clear();
                    await customPageController.changeIndexPage(0);

                    await customPageController.changePage0(true);
                  },
            colorWidgets: Colors.black,
          ),
          // bottomNavigationBar: BottomNavigatorBarPages(
          //   onPressed: (index) async {
          //     await customPageController.changeIndexPage(index);
          //   },
          //   body: listOfWidget[customPageController.selectPage],
          // ),
          body: Container(
            color: (fetchController.showEven == 0)
                ? Colors.white
                : (fetchController.showEven != 2)
                    ? Colors.white
                    : CustomColor.chrismasColor,
            child: IndexedStack(
              index: customPageController.selectPage,
              children: _cachedWidgets,
            ),
          )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
