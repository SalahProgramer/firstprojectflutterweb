import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utilities/style/colors.dart';
import '../../utilities/style/text_style.dart';

class WidgetTextGrid extends StatelessWidget {
  final String title;
  final String subtitle;
  const WidgetTextGrid(
      {super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: CustomTextStyle()
                .heading1L
                .copyWith(color: Colors.black, fontSize: 12.sp),
          ),
        ),
        Expanded(
          child: Text(
            subtitle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: CustomTextStyle()
                .heading1L
                .copyWith(color: CustomColor.chrismasColor, fontSize: 10.sp),
          ),
        ),
      ],
    );
  }
}
