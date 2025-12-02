import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../salah/utilities/global/app_global.dart';
import '../../../salah/utilities/style/text_style.dart';

Future<void> dialogWaiting() {
  return showDialog(
    context: NavigatorApp.context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "قيد الإنتظار",
              style: CustomTextStyle().heading1L.copyWith(color: Colors.white),
            ),
            SizedBox(height: 20.h),
            SpinKitThreeBounce(
              color: Colors.white,
              size: 25.w,
            ),
          ],
        ),
      );
    },
  );
}
