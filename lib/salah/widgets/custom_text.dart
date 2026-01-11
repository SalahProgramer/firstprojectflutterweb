import 'package:fawri_app_refactor/salah/utilities/style/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomText extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final TextDecoration? textDecoration;
  final TextDirection? textDirection;
  final int? maxLines;
  final AlignmentGeometry? alignmentGeometry;

  const CustomText({
    super.key,
    required this.text,
    this.textStyle,
    this.fontSize,
    this.textDecoration,
    this.color,
    this.fontWeight,
    this.textDirection,
    this.maxLines,
    this.alignmentGeometry,
  });

  @override
  State<CustomText> createState() => _CustomTextState();
}

class _CustomTextState extends State<CustomText> {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Align(
        alignment: widget.alignmentGeometry ?? Alignment.topCenter,
        child: RichText(
          textDirection: widget.textDirection ?? TextDirection.rtl,
          maxLines: widget.maxLines ?? 1,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            style:
                widget.textStyle ??
                CustomTextStyle().crimson.copyWith(
                  color: widget.color ?? Colors.black,
                  shadows: [
                    Shadow(
                      blurRadius: 4.0,
                      color: Colors.black26,
                      offset: Offset(1, 1),
                    ),
                  ],
                  fontSize: widget.fontSize ?? 9.sp,
                ),
            children: <TextSpan>[
              TextSpan(
                text: widget.text,
                style:
                    widget.textStyle ??
                    CustomTextStyle().rubik.copyWith(
                      color: widget.color ?? Colors.black,
                      overflow: TextOverflow.ellipsis,
                      fontSize: widget.fontSize ?? 9.sp,
                      decoration:
                          widget.textDecoration ?? TextDecoration.lineThrough,
                      fontWeight: widget.fontWeight ?? FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 4.0,
                          color: Colors.black26,
                          offset: Offset(1, 1),
                        ),
                      ],
                      // decorationThickness: 1.5,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextWiithoutFlexible extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final TextDecoration? textDecoration;
  final TextDirection? textDirection;
  final int? maxLines;
  final AlignmentGeometry? alignmentGeometry;

  const CustomTextWiithoutFlexible({
    super.key,
    required this.text,
    this.textStyle,
    this.fontSize,
    this.textDecoration,
    this.color,
    this.fontWeight,
    this.textDirection,
    this.maxLines,
    this.alignmentGeometry,
  });

  @override
  State<CustomTextWiithoutFlexible> createState() =>
      _CustomTextWiithoutFlexibleState();
}

class _CustomTextWiithoutFlexibleState
    extends State<CustomTextWiithoutFlexible> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignmentGeometry ?? Alignment.topCenter,
      child: RichText(
        textDirection: widget.textDirection ?? TextDirection.rtl,
        maxLines: widget.maxLines ?? 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style:
              widget.textStyle ??
              CustomTextStyle().crimson.copyWith(
                color: widget.color ?? Colors.black,
                shadows: [
                  Shadow(
                    blurRadius: 4.0,
                    color: Colors.black26,
                    offset: Offset(1, 1),
                  ),
                ],
                fontSize: widget.fontSize ?? 9.sp,
              ),
          children: <TextSpan>[
            TextSpan(
              text: widget.text,
              style:
                  widget.textStyle ??
                  CustomTextStyle().rubik.copyWith(
                    color: widget.color ?? Colors.black,
                    overflow: TextOverflow.ellipsis,
                    fontSize: widget.fontSize ?? 9.sp,
                    decoration:
                        widget.textDecoration ?? TextDecoration.lineThrough,
                    fontWeight: widget.fontWeight ?? FontWeight.bold,
                    // decorationThickness: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
