import 'package:fawri_app_refactor/salah/utilities/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

import '../../controllers/fetch_controller.dart';
import '../../utilities/style/text_style.dart';

class MargueeVisibality extends StatelessWidget {
  const MargueeVisibality({super.key});

  @override
  Widget build(BuildContext context) {
    FetchController fetchController = context.watch<FetchController>();
    return Visibility(
      visible: fetchController.marque.toString() == "" ? false : true,
      child: Container(
        height: 30.h,
        width: double.maxFinite,
        color: (fetchController.showEven != 0)
            ? ((fetchController.showEven == 1)
                ? Colors.white
                : CustomColor.eidColor)
            : Colors.red,
        child: Marquee(
          text: fetchController.marque.toString(),
          style: CustomTextStyle().heading1L.copyWith(
              fontWeight: FontWeight.bold,
              color: (fetchController.showEven == 1)
                  ? CustomColor.primaryColor
                  : Colors.white,
              fontSize: 15.sp),
          scrollAxis: Axis.horizontal,
          blankSpace: 20.0,
          accelerationCurve: Curves.linear,
          decelerationCurve: Curves.linear,
        ),
      ),
    );
  }
}
