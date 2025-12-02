import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/utilities/style/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glowy_borders/glowy_borders.dart';
import 'package:provider/provider.dart';
import '../../controllers/custom_page_controller.dart';
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
  @override
  Widget build(BuildContext context) {
    CustomPageController customPageController =
        context.watch<CustomPageController>();
    final List<IconData> iconList = (widget.isCategoryPage == false)
        ? [
            Icons.home_filled,
            Icons.category,
            FontAwesomeIcons.solidHeart,
            FontAwesomeIcons.bars,
          ]
        : [
            FontAwesomeIcons.solidHeart,
            Icons.home_filled,
            FontAwesomeIcons.bars,
          ];

    final List<String> textList = (widget.isCategoryPage == false)
        ? [
            'الرئيسية',
            'الفئات',
            'المفضلة',
            'القائمة',
          ]
        : [
            'المفضلة',
            'الرئيسية',
            'القائمة',
          ];

    return (widget.isCategoryPage == false)
        ? Scaffold(
            extendBody: (customPageController.selectPage != 0) ? false : true,
            appBar: widget.appBar,
            backgroundColor: Colors.white,
            // resizeToAvoidBottomInset: false,
            body: MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              removeTop: true,
              child: widget.body ?? SizedBox(),
            ),
            floatingActionButton: AnimatedGradientBorder(
              borderRadius: BorderRadius.circular(120.r),
              gradientColors: [
                CustomColor.blueColor,
                CustomColor.chrismasColor
              ],
              glowSize: 0,
              borderSize: 2,
              child: CircleAvatar(
                  radius: 25.r,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(90.r),
                    child: Image(
                      image: AssetImage(
                        Assets.images.image.path,
                      ),

                      // 90% of screen width
                      fit: BoxFit.cover,
                    ),
                  )),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: bottomBar(
                iconList: iconList,
                textList: textList,
                customPageController: customPageController),
          )
        : bottomBar(
            iconList: iconList,
            textList: textList,
            customPageController: customPageController);
  }

  Widget bottomBar(
      {required List<IconData> iconList,
      required List<String> textList,
      required CustomPageController customPageController}) {
    return AnimatedBottomNavigationBar.builder(
      itemCount: iconList.length,
      tabBuilder: (int index, bool isActive) {
        final color = isActive ? CustomColor.blueColor : Colors.grey[500];
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconList[index], size: 17.sp, color: color),
            isActive
                ? Text(
                    textList[index],
                    style: CustomTextStyle().cairo.copyWith(
                        color: color,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w400),
                  )
                : SizedBox(),
          ],
        );
      },
      shadow: BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 5.r,
        offset: const Offset(0, -1),
        spreadRadius: 1,
      ),
      activeIndex: (widget.isCategoryPage == true)
          ? customPageController.selectCategoryPage
          : customPageController.selectPage,
      gapLocation:
          widget.isCategoryPage == true ? GapLocation.none : GapLocation.center,
      notchSmoothness: NotchSmoothness.softEdge,
      leftCornerRadius: 32.r,
      rightCornerRadius: 32.r,
      onTap: widget.onPressed,
      height: 42.h,
      backgroundColor: Colors.white,
    );
  }
}
