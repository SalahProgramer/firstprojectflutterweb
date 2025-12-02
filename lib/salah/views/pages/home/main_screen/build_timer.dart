import 'package:fawri_app_refactor/salah/utilities/style/colors.dart';
import 'package:fawri_app_refactor/salah/utilities/style/text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glowy_borders/glowy_borders.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/timer_controller.dart';

class BuildTimer extends StatefulWidget {
  const BuildTimer({super.key});

  @override
  State<BuildTimer> createState() => _BuildTimerState();
}

class _BuildTimerState extends State<BuildTimer> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // TimerController timerController = context.read<TimerController>();
      // PageMainScreenController pageMainScreenController =
      //     context.read<PageMainScreenController>();
      // timerController
      //     .startTimers((pageMainScreenController.flash?.endDate ?? ""));
    });
    super.initState();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     TimerController timerController = context.read<TimerController>();
  //     PageMainScreenController pageMainScreenController =
  //         context.read<PageMainScreenController>();
  //
  //     timerController
  //         .startTimers((pageMainScreenController.flash?.endDate ?? ""));
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    TimerController timerController = context.watch<TimerController>();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildTimeCard(
              time: timerController.seconds.toString(), headers: 'ثواني'),
          SizedBox(
            width: 10.w,
          ),
          doubleDot(),
          buildTimeCard(
              time: timerController.minutes.toString(), headers: 'دقائق'),
          SizedBox(
            width: 10.w,
          ),
          doubleDot(),
          buildTimeCard(
              time: timerController.hours.toString(), headers: 'ساعة'),
        ],
      ),
    );
  }

  Widget doubleDot() {
    return Align(
      alignment: Alignment.center,
      child: Text(
        ":",
        textAlign: TextAlign.center,
        style: TextStyle(color: CupertinoColors.black, fontSize: 20.sp),
      ),
    );
  }

  buildTimeCard({required String time, required String headers}) {
    return Column(
      children: [
        AnimatedGradientBorder(
          glowSize: 3,
          gradientColors: [Colors.yellow, CustomColor.primaryColor],
          borderSize: 2,
          borderRadius: BorderRadius.circular(12.r),
          child: Center(
            child: Container(
              width: 38.w,
              height: 38.w,
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 5.h),
              decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(10.r)),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  time,
                  style: CustomTextStyle().heading1L.copyWith(
                      fontSize: 20.sp, color: CustomColor.primaryColor),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Text(
            textAlign: TextAlign.center,
            // text:
            // widget.flashSalesArray["name"] ??
            headers,
            style: CustomTextStyle().heading1L.copyWith(
                color: Colors.black,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
