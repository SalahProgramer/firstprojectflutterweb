import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fawri_app_refactor/salah/utilities/style/text_style.dart';

class ReelsLoadingIndicator extends StatelessWidget {
  const ReelsLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "قيد الإنتظار",
            style: CustomTextStyle().heading1L.copyWith(color: Colors.white),
          ),
          SizedBox(height: 20.h),
          SpinKitThreeBounce(color: Colors.white, size: 25.w),
        ],
      ),
    );
  }
}
