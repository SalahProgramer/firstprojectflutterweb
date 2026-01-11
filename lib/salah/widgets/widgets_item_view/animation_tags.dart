import 'dart:async';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/widgets/lottie_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glowy_borders/glowy_borders.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../views/pages/home/home_screen/home_screen.dart';
import '../../../server/domain/domain.dart';
import '../../controllers/sub_main_categories_conrtroller.dart';
import '../../controllers/timer_controller.dart';
import '../../models/items/item_model.dart';
import '../../utilities/global/app_global.dart';
import '../../utilities/style/colors.dart';
import '../../utilities/style/text_style.dart';

class AnimationTags extends StatefulWidget {
  final Item item;
  final EdgeInsetsGeometry? padding;

  const AnimationTags({super.key, required this.item, this.padding});

  @override
  State<AnimationTags> createState() => _AnimationTagsState();
}

class _AnimationTagsState extends State<AnimationTags>
    with TickerProviderStateMixin {
  late FixedExtentScrollController scrollController;
  Timer? timer;
  int currentIndex = 0;
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    scrollController = FixedExtentScrollController();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      timer = Timer.periodic(Duration(seconds: 3), (timer) {
        if (widget.item.tags!.isNotEmpty) {
          int nextIndex = (currentIndex + 1) % widget.item.tags!.length;

          // Animate without setState
          scrollController.animateToItem(
            nextIndex,
            duration: Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
          );

          currentIndex = nextIndex;
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    scrollController.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SubMainCategoriesController subMainCategoriesController = context
        .watch<SubMainCategoriesController>();

    TimerController timerController = context.watch<TimerController>();
    // printLog(widget.item.tags);
    return AnimatedOpacity(
      opacity: (widget.item.tags != null) ? 1 : 0,
      duration: Duration(milliseconds: 300),
      child: Container(
        color: Colors.transparent,
        padding: widget.padding ?? EdgeInsets.only(right: 0.52.sw),
        height: 0.05.sh,
        child: ListWheelScrollView(
          controller: scrollController,
          scrollBehavior: MaterialScrollBehavior(),
          physics: ClampingScrollPhysics(),
          overAndUnderCenterOpacity: 0.5,
          diameterRatio: 0.55,
          renderChildrenOutsideViewport: false,
          itemExtent: 30.h,

          // Height of each item
          children: List.generate(widget.item.tags?.length ?? 0, (index) {
            final item = widget.item.tags?[index % widget.item.tags!.length];

            Color? color = (item.toString() == "flash_sales")
                ? Colors.yellow
                : CustomColor.primaryColor;

            return InkWell(
              focusColor: Colors.transparent,
              overlayColor: WidgetStateColor.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                await subMainCategoriesController.clear();
                String tagName = item.toString();
                NavigatorApp.push(
                  homeScreenWidget(
                    bannerTitle: tagName.toString(),
                    type: tagName.toString(),
                    url: urlFLASHSALES,
                    scroll: subMainCategoriesController.scrollDynamicItems,
                  ),
                );
              },
              child: (item.toString() == "2025")
                  ? Container(
                      width: double.maxFinite,
                      height: 0.1.sh,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        // color: Colors.white.withValues(alpha: 0.8),
                        gradient: LinearGradient(
                          colors: [
                            CustomColor.primaryColor.withValues(alpha: 0.9),
                            Colors.yellow.withValues(alpha: 0.9),
                            CustomColor.chrismasColor.withValues(alpha: 0.9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.only(top: 3.h),
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(" 🎊 "),
                            Text(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              item.toString(),
                              style: CustomTextStyle().heading1L.copyWith(
                                fontSize: 16.sp,
                                color: CustomColor.blueColor,
                              ),
                            ),
                            Text(" 🎊 "),
                          ],
                        ),
                      ),
                    )
                  : ((item.toString() == "flash_sales"))
                  ? Container(
                      width: double.maxFinite,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Center(
                        child:
                            (timerController.hours == 0 &&
                                timerController.minutes == 0 &&
                                timerController.seconds == 0)
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  flashIcon(),
                                  Text(
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    " Flash sales ",
                                    style: CustomTextStyle().heading1L.copyWith(
                                      fontSize: 14.sp,
                                      color: (item.toString() == "flash_sales")
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                  flashIcon(),
                                ],
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "ينتهي خلال:",
                                    style: CustomTextStyle().heading1L.copyWith(
                                      color: CustomColor.chrismasColor,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      textCounter(
                                        text: timerController.seconds
                                            .toString()
                                            .padLeft(2, '0'),
                                      ),
                                      Text(
                                        ":",
                                        style: TextStyle(fontSize: 16.sp),
                                      ),
                                      textCounter(
                                        text: timerController.minutes
                                            .toString()
                                            .padLeft(2, '0'),
                                      ),
                                      Text(
                                        ":",
                                        style: TextStyle(fontSize: 16.sp),
                                      ),
                                      textCounter(
                                        text: timerController.hours
                                            .toString()
                                            .padLeft(2, '0'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                    )
                  : Container(
                      width: double.maxFinite,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            (item.toString() == "Christmas")
                                ? LottieWidget(
                                    name: Assets.lottie.snowMan,
                                    width: 30.w,
                                    height: 30.w,
                                  )
                                : SizedBox(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                LottieWidget(
                                  name: Assets.lottie.check,
                                  width: 50.w,
                                  boxFit: BoxFit.contain,
                                  height: 50.w,
                                ),
                                Text(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  (item.toString() == "Christmas")
                                      ? "Christmas"
                                      : item.toString(),
                                  style: CustomTextStyle().heading1L.copyWith(
                                    fontSize: 14.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            (item.toString() == "Christmas")
                                ? LottieWidget(
                                    name: Assets.lottie.snowMan,
                                    width: 30.w,
                                    height: 30.w,
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ),
                    ),
            );
          }),
        ),
      ),
    );
  }

  Widget flashIcon() {
    return SizedBox(
      width: 15.w,
      height: 15.w,
      child: Lottie.asset(
        Assets.lottie.animation1729073541927,
        height: 40.h,
        reverse: true,
        repeat: true,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget textCounter({required String text}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.w),
      child: AnimatedGradientBorder(
        gradientColors: [CustomColor.chrismasColor, Colors.white],
        glowSize: 0,
        borderSize: 1,
        borderRadius: BorderRadius.circular(5.r),
        child: Container(
          padding: EdgeInsets.all(4.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: CustomColor.chrismasColor,
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: CustomTextStyle().heading1L.copyWith(
              color: Colors.white,
              fontSize: 14.sp,
              height: 0.9.h,
            ),
          ),
        ),
      ),
    );
  }

  Widget homeScreenWidget({
    required String bannerTitle,
    required String type,
    String? url,
    required ScrollController scroll,
  }) {
    return HomeScreen(
      bannerTitle: bannerTitle,
      hasAppBar: true,
      endDate: "",
      type: type,
      url: "",
      title: "",
      slider: false,
      productsKinds: true,
      scrollController: scroll,
    );
  }
}
