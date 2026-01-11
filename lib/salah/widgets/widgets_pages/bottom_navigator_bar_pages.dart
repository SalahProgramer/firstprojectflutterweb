import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/utilities/style/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glowy_borders/glowy_borders.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../server/functions/functions.dart';
import '../../controllers/custom_page_controller.dart';
import '../../controllers/showcase_controller.dart';
import '../../controllers/reels_controller.dart';
import '../../utilities/style/colors.dart';

class BottomNavigatorBarPages extends StatefulWidget {
  final void Function(int) onPressed;
  final int? selectedIndex;
  final Widget? body;
  final PreferredSizeWidget? appBar;
  final bool? isCategoryPage;

  const BottomNavigatorBarPages({
    super.key,
    this.selectedIndex,
    required this.onPressed,
    this.body,
    this.appBar,
    this.isCategoryPage = false,
  });

  @override
  State<BottomNavigatorBarPages> createState() =>
      _BottomNavigatorBarPagesState();
}

class _BottomNavigatorBarPagesState extends State<BottomNavigatorBarPages> {
  int _lastBottomBarIndex = 0;
  final GlobalKey _reelsBottomBarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Check and show showcase for bottom bar reels icon
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkAndShowBottomBarReelsShowcase();
      }
    });
  }



  @override
  void didChangeDependencies() {
    printLog("salaheee");
    // Check and show showcase for bottom bar reels icon
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkAndShowBottomBarReelsShowcase();
      }
    });
    super.didChangeDependencies();

  }
  void _checkAndShowBottomBarReelsShowcase() {
    if (!mounted  || (widget.isCategoryPage ?? false)) return;

    try {
      final showcaseController = context.read<ShowcaseController>();

      // Only show showcase if it hasn't been shown before
      if (!showcaseController.showcaseBottomBarReelsShown) {
        // Wait for the bottom bar to be rendered and ShowCaseWidget to be available
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted ) return;
          try {
            final showcaseWidget = ShowCaseWidget.of(context);
            // Start showcase for the Reels icon
            showcaseWidget.startShowCase([_reelsBottomBarKey]);
            showcaseController.markBottomBarReelsShowcaseShown();
            debugPrint("Bottom bar reels showcase started successfully");
          } catch (e) {
            debugPrint("Error showing bottom bar reels showcase: $e");
          }
        });
      }
    } catch (e) {
      debugPrint("Error in _checkAndShowBottomBarReelsShowcase: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    CustomPageController customPageController = context
        .watch<CustomPageController>();


    // Update last bottom bar index when not on category page
    if (customPageController.selectPage != 2) {
      int currentBottomBarIndex;
      if (customPageController.selectPage == 0) {
        currentBottomBarIndex = 0; // Home
      } else if (customPageController.selectPage == 1) {
        currentBottomBarIndex = 1; // Reels
      } else if (customPageController.selectPage == 3) {
        currentBottomBarIndex = 2; // Favourite
      } else if (customPageController.selectPage == 4) {
        currentBottomBarIndex = 3; // Profile
      } else {
        currentBottomBarIndex = _lastBottomBarIndex;
      }

      if (_lastBottomBarIndex != currentBottomBarIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _lastBottomBarIndex = currentBottomBarIndex;
            });
          }
        });
      }
    }
    final List<IconData> iconList = (widget.isCategoryPage == false)
        ? [
            Icons.home_filled,
            Icons.play_circle,
            FontAwesomeIcons.solidHeart,
            FontAwesomeIcons.bars,
          ]
        : [
            FontAwesomeIcons.solidHeart,
            Icons.home_filled,
            FontAwesomeIcons.bars,
          ];

    final List<String> textList = (widget.isCategoryPage == false)
        ? ['الرئيسية', 'اكتشف', 'المفضلة', 'القائمة']
        : ['المفضلة', 'الرئيسية', 'القائمة'];

    return (widget.isCategoryPage == false)
        ? Scaffold(
            extendBody:
                (customPageController.selectPage != 0 &&
                    customPageController.selectPage != 1)
                ? false
                : true,
            appBar: (customPageController.selectPage == 1)
                ? null
                : widget.appBar,
            backgroundColor: Colors.white,
            // resizeToAvoidBottomInset: false,
            body: MediaQuery.removePadding(
              context: context,
              removeBottom: true,

              removeTop: true,
              child: widget.body ?? SizedBox(),
            ),
            floatingActionButton: GestureDetector(
              onTap: () async {
                // If we are currently on the Reels page, stop any playing
                // videos before navigating to the category page so that
                // audio/video does not continue in the background.
                if (customPageController.selectPage == 1) {
                  try {
                    final reelsController = context.read<ReelsController>();
                    reelsController.setPageVisibility(false);
                    reelsController.pauseAllVideos();
                  } catch (e) {
                    // If ReelsController is not available here, log and continue.
                    debugPrint(
                      'Error stopping reels videos from FAB navigation: $e',
                    );
                  }
                }
                await customPageController.changeIndexPage(2);
              },
              child: AnimatedGradientBorder(
                borderRadius: BorderRadius.circular(120.r),
                gradientColors: [
                  CustomColor.blueColor,
                  CustomColor.chrismasColor,
                ],
                glowSize: 0,
                borderSize: 2,
                child: CircleAvatar(
                  radius: 25.r,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(90.r),
                    child: Image(
                      image: AssetImage(Assets.images.image.path),

                      // 90% of screen width
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: bottomBar(
              iconList: iconList,
              textList: textList,
              customPageController: customPageController,
            ),
          )
        : bottomBar(
            iconList: iconList,
            textList: textList,
            customPageController: customPageController,
          );
  }

  // Maps page index to bottom bar index
  // Page indices: 0=Home, 1=Reels, 2=Category, 3=Favourite, 4=Profile
  // Bottom bar indices: 0=Home, 1=Reels, 2=Favourite, 3=Profile
  int _mapPageIndexToBottomBarIndex(int pageIndex) {
    if (pageIndex == 0) return 0; // Home
    if (pageIndex == 1) return 1; // Reels
    if (pageIndex == 2) {
      return _lastBottomBarIndex; // Category - use last selected bottom bar index
    }
    if (pageIndex == 3) return 2; // Favourite
    if (pageIndex == 4) return 3; // Profile
    return 0;
  }

  Widget bottomBar({
    required List<IconData> iconList,
    required List<String> textList,
    required CustomPageController customPageController,
  }) {
    // Detect the main category page (Pages index 2). We still use this only
    // for controlling when to disable the active state and the Reels showcase.
    final bool isMainCategoryPage =
        customPageController.selectPage == 2 && (widget.isCategoryPage != true);

    return AnimatedBottomNavigationBar.builder(
      itemCount: iconList.length,
      tabBuilder: (int index, bool isActive) {
        // On the main category page (opened via the floatingActionButton in
        // the main `Pages` widget), we want all items to look inactive
        // (no blue color, no title). On dedicated category pages
        // (`isCategoryPage == true`) we still want the normal active behavior.
        final bool shouldBeActive = isActive && !isMainCategoryPage;
        final color = shouldBeActive ? CustomColor.blueColor : Colors.grey[500];

        Widget iconWidget = Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconList[index], size: 17.sp, color: color),
            shouldBeActive
                ? Text(
                    textList[index],
                    style: CustomTextStyle().cairo.copyWith(
                      color: color,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                : SizedBox(),
          ],
        );

        // Attach showcase only to the Reels icon (index 1) when NOT on:
        // - the main category page (selectPage == 2), and
        // - the dedicated category pages that use `isCategoryPage == true`.
        if (!isMainCategoryPage &&
            widget.isCategoryPage != true &&
            index == 1) {
          return Showcase(
            key: _reelsBottomBarKey,
            title: 'اكتشف الفيديوهات',
            description: '🎥 انقر هنا للوصول ومشاهدة المنتج عن قرب',
            titleTextStyle: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            descTextStyle: TextStyle(fontSize: 14.sp, color: Colors.black),
            overlayColor: Colors.black54,
            overlayOpacity: 0.8,
            child: iconWidget,
          );
        }

        return iconWidget;
      },
      shadow: BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 5.r,
        offset: const Offset(0, -1),
        spreadRadius: 1,
      ),
      activeIndex: (widget.isCategoryPage == true)
          ? customPageController.selectCategoryPage
          : (customPageController.selectPage == 2
                ? _lastBottomBarIndex
                : _mapPageIndexToBottomBarIndex(
                    customPageController.selectPage,
                  )),
      gapLocation: widget.isCategoryPage == true
          ? GapLocation.none
          : GapLocation.center,
      notchSmoothness: NotchSmoothness.softEdge,
      leftCornerRadius: 32.r,
      rightCornerRadius: 32.r,
      onTap: widget.onPressed,
      height: 42.h,
      backgroundColor: Colors.white,
    );
  }
}
