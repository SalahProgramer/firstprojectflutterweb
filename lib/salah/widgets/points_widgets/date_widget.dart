import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utilities/style/colors.dart';
import '../../utilities/style/text_style.dart';

class DateTitle extends StatelessWidget {
  final String label;
  const DateTitle({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        label,
        style: CustomTextStyle().cairo.copyWith(
          fontSize: 12.sp,
          fontWeight: FontWeight.w800,
          color: CustomColor.greyTextColor,
        ),
      ),
    );
  }
}
