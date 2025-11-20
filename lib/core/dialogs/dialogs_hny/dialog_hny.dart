import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utilities/global/app_global.dart';
import '../../utilities/style/colors.dart';
import '../../widgets/lottie_widget.dart';

Future<void> dialogHNY() {
  return showDialog(
    context: NavigatorApp.context,
    builder: (context) {
      return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(0),
          child: InkWell(
            onTap: () async {
              NavigatorApp.pop();
            },
            child: Container(
              decoration: BoxDecoration(
                  // color: Colors.white.withValues(alpha: 0.8),
                  gradient: RadialGradient(
                colors: [
                  CustomColor.primaryColor.withValues(alpha: 0.5),
                  Colors.yellow.withValues(alpha: 0.5),
                  CustomColor.chrismasColor.withValues(alpha: 0.5),
                ],
              )),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "🎊",
                              style: TextStyle(fontSize: 40.sp),
                            ),
                            Text("🎊", style: TextStyle(fontSize: 40.sp))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "🎊",
                              style: TextStyle(fontSize: 40.sp),
                            ),
                            Text("🎊", style: TextStyle(fontSize: 40.sp))
                          ],
                        ),
                      ],
                    ),
                  ),
                  Center(
                      child: LottieWidget(
                    name: Assets.lottie.hny,
                    width: double.maxFinite,
                    height: 0.5.sh,
                  )),
                ],
              ),
            ),
          ));
    },
  );
}
