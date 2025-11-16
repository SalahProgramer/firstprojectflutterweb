import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/server/functions/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marquee/marquee.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:provider/provider.dart';
import '../../controllers/showcase_controller.dart';
import '../../utilities/global/app_global.dart';
import '../../utilities/style/text_style.dart';

import '../custom_button.dart';
import '../widgets_pages/cart_widget.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Color? shadowColor;
  final Color? backgroundColor;
  final Color? colorWidgets;
  final String title;
  final String textButton;
  final List<Widget>? actions;
  final String? sizes;
  final bool? showIconSizes;
  final Color? textColor;
  final dynamic containerWidths, keys, mainCategory, name;

  final void Function()? onPressed;
  @override
  final Size preferredSize;

  CustomAppBar(
      {super.key,
      this.shadowColor,
      this.backgroundColor,
      this.colorWidgets,
      required this.title,
      required this.textButton,
      this.onPressed,
      this.actions,
      this.sizes = "",
      this.containerWidths,
      this.keys,
      this.mainCategory,
      this.name,
      this.showIconSizes = false,
      this.textColor})
      : preferredSize = Size.fromHeight(42.h);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  GlobalKey one = GlobalKey();
  String userId = "";

  // setSharedPref() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String userID = prefs.getString('user_id') ?? "";
  //   bool isSelectedSizeShared = prefs.getBool('is_selected_size') ?? false;
  //   userId = userID;
  //   isSelectedSize = isSelectedSizeShared;
  // }

  Future<void> startShowCase() async {
    if (!mounted) return;
    
    ShowcaseController showcaseController = context.read<ShowcaseController>();
    
    if (!showcaseController.showcaseSizeShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        
        try {
          ShowCaseWidget.of(context).startShowCase([one]);
          
          // Wait a moment then mark as shown
          await Future.delayed(Duration(milliseconds: 100));
          if (!mounted) return;
          await showcaseController.markSizeShowcaseShown();
        } catch (e) {
          printLog('Error starting showcase: $e');
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      
      if (widget.showIconSizes == true) {
        printLog("ddddddddddddddddddddddddddddddddddddddddd");
        await startShowCase();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              filterQuality: FilterQuality.high,
              fit: BoxFit.cover,
              image: AssetImage(
                Assets.images.backg.path,
              ))),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          AppBar(
            scrolledUnderElevation: 0,
            elevation: 0,
            shadowColor: widget.shadowColor ?? Colors.black87,
            backgroundColor: widget.backgroundColor ?? Colors.transparent,
            centerTitle: true,
            title: Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                widget.title,
                style: CustomTextStyle().heading1L.copyWith(
                    fontSize: 14.sp,
                    color: widget.textColor ?? Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
            leading: Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Align(
                alignment: Alignment.center,
                child: CustomTextButton(
                    text: widget.textButton,
                    textStyle: CustomTextStyle().heading1L.copyWith(
                        fontSize: 14.sp,
                        color: widget.textColor ?? Colors.black,
                        fontWeight: FontWeight.bold),
                    onPressed: widget.onPressed),
              ),
            ),
            actions: widget.actions ??
                [SafeArea(child: IconCart(color: Colors.black))],
          ),
          Padding(
            padding: EdgeInsets.only(right: 50.w),
            child: Visibility(
              visible: (widget.showIconSizes == false) ? false : true,
              child: Showcase(
                key: one,
                title: 'اختيار الحجم',
                description: 'هنا يتم اختيار الحجم',
                child: InkWell(
                  onTap: () {
                    NavigatorApp.pop();
                  },
                  child: Padding(
                    padding: EdgeInsets.all(5.w),
                    child: (widget.sizes != "")
                        ? Padding(
                            padding: EdgeInsets.only(top: 10.h),
                            child: SizedBox(
                              width: 45.w,
                              child: Marquee(
                                text: widget.sizes.toString().trim(),
                                style: CustomTextStyle().rubik.copyWith(
                                    color: Colors.black, fontSize: 10.sp),
                                scrollAxis: Axis.horizontal,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                blankSpace: 40.0,
                                velocity: 50.0,
                                pauseAfterRound: Duration(seconds: 1),
                                startPadding: 10.0,
                                accelerationDuration:
                                    Duration(milliseconds: 500),
                                decelerationDuration:
                                    Duration(milliseconds: 500),
                                accelerationCurve: Curves.linear,
                                decelerationCurve: Curves.easeOut,
                              ),
                            ),
                          )
                        : Image.asset(
                            (widget.sizes != "")
                                ? Assets.images.fullTshirt.path
                                : Assets.images.tshirt.path,
                            height: 27.w,
                            width: 27.w,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
