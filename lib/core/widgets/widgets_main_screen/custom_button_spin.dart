import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utilities/style/colors.dart';
import '../../utilities/style/text_style.dart';
import '../lottie_widget.dart';

class CustomButtonSpin extends StatelessWidget {
  final String text;
  final String nameLottie;
  final double? width;
  final double? height;
  final double? fontSize;
  final int? flex;
  final TextStyle? textStyle;
  final void Function()? onTap;
  final bool canTap;

  const CustomButtonSpin(
      {super.key,
      required this.text,
      required this.onTap,
      required this.nameLottie,
      this.width,
      this.height,
      this.fontSize,
      this.flex,
      this.textStyle,
      this.canTap = true});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex ?? 2,
      child: InkWell(
        highlightColor: Colors.transparent,
        overlayColor: WidgetStateColor.transparent,
        focusColor: WidgetStateColor.transparent,
        hoverColor: Colors.transparent,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              gradient: LinearGradient(
                  colors: (canTap == false)
                      ? [
                          Colors.grey.shade600,
                          Colors.grey.shade600,
                        ]
                      : [
                          CustomColor.blueColor,
                          CustomColor.blueColor.withValues(alpha: 0.7),
                        ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter),
              boxShadow: [
                BoxShadow(
                    color: Colors.black,
                    blurStyle: BlurStyle.outer,
                    spreadRadius: 0.r,
                    blurRadius: 10.r)
              ]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (nameLottie != "")
                LottieWidget(
                  name: nameLottie,
                  width: 60.w,
                  height: 60.w,
                ),
              Container(
                padding: EdgeInsets.all(2.w),
                margin: EdgeInsets.all(2.w),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    maxLines: 3,

                    overflow: TextOverflow.ellipsis,
                    text,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: textStyle ??
                        CustomTextStyle().heading1L.copyWith(
                            height: 1.h,
                            fontSize: (fontSize) ?? 12.sp,
                            color: Colors.white),
                    // textDecoration: TextDecoration.none,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
