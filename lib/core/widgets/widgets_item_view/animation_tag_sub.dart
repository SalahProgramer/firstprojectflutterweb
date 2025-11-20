import 'dart:async';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glowy_borders/glowy_borders.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../controllers/sub_main_categories_conrtroller.dart';
import '../../../controllers/timer_controller.dart';
import '../../../models/items/item_model.dart';
import '../../../views/pages/home/home_screen/home_screen.dart';
import '../../constants/domain.dart';
import '../../utilities/global/app_global.dart';
import '../../utilities/style/colors.dart';
import '../../utilities/style/text_style.dart';
import '../lottie_widget.dart';

class AnimationTagInSub extends StatefulWidget {
  final Item item;
  final EdgeInsetsGeometry? padding;

  const AnimationTagInSub({super.key, required this.item, this.padding});

  @override
  State<AnimationTagInSub> createState() => _AnimationTagInSubsState();
}

class _AnimationTagInSubsState extends State<AnimationTagInSub>
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

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //
  //   // WidgetsBinding.instance.addPostFrameCallback((_) {
  //   //   TimerController timerController = context.read<TimerController>();
  //   //   PageMainScreenController pageMainScreenController =
  //   //       context.read<PageMainScreenController>();
  //   //
  //   //   timerController
  //   //       .startTimers((pageMainScreenController.flash?.endDate ?? ""));
  //   // });
  // }

  @override
  void dispose() {
    timer?.cancel();
    scrollController.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SubMainCategoriesController subMainCategoriesController =
        context.watch<SubMainCategoriesController>();

    TimerController timerController = context.watch<TimerController>();
    // printLog(widget.item.tags);
    return AnimatedOpacity(
      opacity: (widget.item.tags != null) ? 1 : 0,
      duration: Duration(milliseconds: 300),
      child: Container(
        alignment: Alignment.topRight,
        constraints: BoxConstraints(minWidth: 80.w, maxWidth: 100.w),
        height: 0.03.sh,
        child: ListWheelScrollView(
          controller: scrollController,
          scrollBehavior: MaterialScrollBehavior(),
          physics: ClampingScrollPhysics(),
          overAndUnderCenterOpacity: 0.5,
          diameterRatio: 0.55,

          renderChildrenOutsideViewport: false,
          itemExtent: 20.h,

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
                NavigatorApp.push(homeScreenWidget(
                  bannerTitle: tagName.toString(),
                  type: tagName.toString(),
                  url: urlFLASHSALES,
                  scroll: subMainCategoriesController.scrollDynamicItems,
                ));
              },
              child: (item.toString() == "2025")
                  ? Container(
                      width: double.maxFinite,
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              CustomColor.primaryColor.withValues(alpha: 0.9),
                              Colors.yellow.withValues(alpha: 0.9),
                              CustomColor.chrismasColor.withValues(alpha: 0.9),
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5.r),
                              bottomLeft: Radius.circular(5.r))),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          "🎊 ${item.toString()} 🎊",
                          style: CustomTextStyle().heading1L.copyWith(
                                fontSize: 9.sp,
                                color: CustomColor.blueColor,
                              ),
                        ),
                      ),
                    )
                  : ((item.toString() == "flash_sales"))
                      ? Container(
                          width: double.maxFinite,
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(5.r),
                                bottomLeft: Radius.circular(5.r)),
                          ),
                          child: Center(
                              child: (timerController.hours == 0 &&
                                      timerController.minutes == 0 &&
                                      timerController.seconds == 0)
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        flashIcon(),
                                        Text(
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          "Flash sales",
                                          style: CustomTextStyle()
                                              .heading1L
                                              .copyWith(
                                                fontSize: 9.sp,
                                                color: (item.toString() ==
                                                        "flash_sales")
                                                    ? Colors.black
                                                    : Colors.white,
                                              ),
                                        ),
                                        flashIcon()
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "ينتهي خلال:",
                                          style: CustomTextStyle()
                                              .heading1L
                                              .copyWith(
                                                  color:
                                                      CustomColor.chrismasColor,
                                                  fontSize: 9.sp),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            textCounter(
                                                text: timerController.seconds
                                                    .toString()
                                                    .padLeft(2, '0')),
                                            Text(
                                              ":",
                                              style: TextStyle(fontSize: 6.sp),
                                            ),
                                            textCounter(
                                                text: timerController.minutes
                                                    .toString()
                                                    .padLeft(2, '0')),
                                            Text(
                                              ":",
                                              style: TextStyle(fontSize: 6.sp),
                                            ),
                                            textCounter(
                                                text: timerController.hours
                                                    .toString()
                                                    .padLeft(2, '0')),
                                          ],
                                        )
                                      ],
                                    )),
                        )
                      : Container(
                          width: double.maxFinite,
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(5.r),
                                bottomLeft: Radius.circular(5.r)),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                (item.toString() == "Christmas")
                                    ? LottieWidget(
                                        name: Assets.lottie.snowMan,
                                        width: 15.w,
                                        height: 15.w,
                                      )
                                    : SizedBox(),
                                Row(
                                  children: [
                                    LottieWidget(
                                      name: Assets.lottie.check,
                                      width: 19.w,
                                      height: 19.w,
                                    ),
                                    Text(
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      (item.toString() == "Christmas")
                                          ? "Christmas"
                                          : item.toString(),
                                      style:
                                          CustomTextStyle().heading1L.copyWith(
                                                fontSize: 9.sp,
                                                color: Colors.white,
                                              ),
                                    ),
                                  ],
                                ),
                                (item.toString() == "Christmas")
                                    ? LottieWidget(
                                        name: Assets.lottie.snowMan,
                                        width: 15.w,
                                        height: 15.w,
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
        height: 15.h,
        reverse: true,
        repeat: true,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget textCounter({required String text}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.w),
      child: AnimatedGradientBorder(
        gradientColors: [CustomColor.chrismasColor, Colors.white],
        glowSize: 0,
        borderSize: 1,
        borderRadius: BorderRadius.circular(2.r),
        child: Container(
          padding: EdgeInsets.all(1.w),
          alignment: Alignment.center,
          height: 0.013.sh,
          decoration: BoxDecoration(
              color: CustomColor.chrismasColor,
              borderRadius: BorderRadius.circular(2.r)),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: CustomTextStyle()
                .heading1L
                .copyWith(color: Colors.white, fontSize: 6.sp, height: 0.5.h),
          ),
        ),
      ),
    );
  }

  Widget homeScreenWidget(
      {required String bannerTitle,
      required String type,
      String? url,
      required ScrollController scroll}) {
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
