import 'package:bouncerwidget/bouncerwidget.dart';
import 'package:fawri_app_refactor/salah/utilities/style/colors.dart';
import 'package:fawri_app_refactor/salah/utilities/style/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../controllers/fetch_controller.dart';
import '../custom_button.dart';

class ButtonDone extends StatefulWidget {
  final String text;
  final String? iconName;
  final double? height;
  final double? width;
  final Color? textColor;
  final Color? borderColor;

  final double? heightIcon;
  final double? borderRadius;
  final bool? isLoading;
  final Color? backColor;
  final double? fontSize;
  final EdgeInsets? padding;
  final bool? haveBouncingWidget;
  final void Function()? onPressed;
  final double? widthIconInStartEnd;
  final double? heightIconInStartEnd;
  final Color? shadowColor;
  const ButtonDone({
    super.key,
    required this.text,
    this.iconName,
    required this.onPressed,
    this.height,
    this.heightIcon,
    this.isLoading,
    this.backColor,
    this.haveBouncingWidget = true,
    this.padding,
    this.widthIconInStartEnd,
    this.heightIconInStartEnd,
    this.borderRadius,
    this.fontSize,
    this.width,
    this.shadowColor,
    this.textColor,
    this.borderColor,
  });

  @override
  State<ButtonDone> createState() => _ButtonDoneState();
}

class _ButtonDoneState extends State<ButtonDone> {
  @override
  Widget build(BuildContext context) {
    FetchController fetchController = context.watch<FetchController>();

    return (widget.haveBouncingWidget == true)
        ? BouncingWidget(
            child: widgetButtonDone(showEven: fetchController.showEven),
          )
        : widgetButtonDone(showEven: fetchController.showEven);
  }

  Widget widgetButtonDone({required int showEven}) {
    return Container(
      margin: (widget.haveBouncingWidget == false)
          ? EdgeInsets.only(bottom: 2.h, left: 7.w, right: 7.w)
          : EdgeInsets.only(bottom: 22.h, left: 7.w, right: 7.w),
      width: widget.width ?? double.maxFinite,
      height: widget.height ?? 43.h,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: widget.borderColor ?? Colors.transparent),
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 20.r),
        boxShadow: [
          BoxShadow(
            color: widget.shadowColor ?? Colors.transparent,
            blurRadius: 10.r,
            spreadRadius: 1.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      clipBehavior: Clip.none,
      child: (showEven == 11)
          ? CustomButtonWithIconAndAnimations(
              padding: widget.padding ?? EdgeInsets.symmetric(vertical: 2.h),
              text: widget.text,
              textIcon: widget.iconName ?? '',
              textStyle: CustomTextStyle().heading1L.copyWith(
                fontSize: widget.fontSize ?? 14.sp,
              ),
              colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              isLoading: widget.isLoading ?? false,
              backgroundColor: (showEven == 1)
                  ? CustomColor.primaryColor
                  : CustomColor.eidColor,
              showEven: showEven,
              iconAlignment: IconAlignment.start,
              heightIconInStartEnd: (showEven == 2)
                  ? widget.heightIconInStartEnd ?? 35.w
                  : widget.heightIconInStartEnd,
              widthIconInStartEnd: (showEven == 2)
                  ? widget.heightIconInStartEnd ?? 35.w
                  : widget.heightIconInStartEnd,
              height: widget.heightIcon ?? 30.h,
              hasBackground: true,
              onPressed: widget.onPressed,
            )
          : (showEven == 30)
          ? CustomButtonWithIconAndAnimations(
              padding: widget.padding ?? EdgeInsets.symmetric(vertical: 2.h),
              text: widget.text,
              textIcon: widget.iconName ?? '',
              textStyle: CustomTextStyle().heading1L.copyWith(
                fontSize: widget.fontSize ?? 14.sp,
              ),
              colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              isLoading: widget.isLoading ?? false,
              backgroundColor: CustomColor.blackFridayColor,
              showEven: showEven,
              iconAlignment: IconAlignment.start,
              heightIconInStartEnd: widget.heightIconInStartEnd,
              widthIconInStartEnd: widget.heightIconInStartEnd,
              height: widget.heightIcon ?? 30.h,
              hasBackground: true,
              onPressed: widget.onPressed,
            )
          : CustomButtonWithIcon(
              padding: widget.padding ?? EdgeInsets.symmetric(vertical: 2.h),
              text: widget.text,
              textIcon: widget.iconName ?? '',
              textStyle: CustomTextStyle().heading1L.copyWith(
                fontSize: widget.fontSize ?? 14.sp,
                color: widget.textColor ?? Colors.white,
              ),
              colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              isLoading: widget.isLoading ?? false,
              backgroundColor:
                  widget.backColor ??
                  ((showEven == 4) ? CustomColor.eidColor : Colors.black),
              iconAlignment: IconAlignment.start,
              height: widget.heightIcon ?? 30.h,
              hasBackground: true,
              onPressed: widget.onPressed,
            ),
    );
  }
}
