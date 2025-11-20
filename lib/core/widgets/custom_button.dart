import '../utilities/style/colors.dart';
import 'package:fawri_app_refactor/core/widgets/lottie_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/controllers/fetch_controller.dart';
import '../utilities/style/text_style.dart';

class CustomButtonWithoutIcon extends StatelessWidget {
  final String text;
  final String textWaiting;
  final double? height;
  final double? borderRadius;

  final void Function()? onPressed;
  final bool? loadingButton;
  final EdgeInsetsGeometry? padding;
  final Color? backColor;
  final Color? forColor;
  final ColorFilter? iconColor;
  final List<BoxShadow>? boxShadow;
  final TextStyle? textStyle;

  const CustomButtonWithoutIcon({
    super.key,
    required this.text,
    required this.onPressed,
    this.loadingButton = false,
    this.padding,
    this.height,
    this.backColor,
    this.forColor,
    this.iconColor,
    this.borderRadius,
    this.boxShadow,
    required this.textWaiting,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backColor ?? Colors.black,
        foregroundColor: forColor ?? Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        overlayColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 22.r),
          side: const BorderSide(color: Colors.transparent, width: 0),
        ),
        padding: EdgeInsets.zero,
      ),
      child: Container(
        height: height ?? 35.h,
        decoration: BoxDecoration(
          color: backColor ?? Colors.black,
          boxShadow:
              boxShadow ??
              [
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 10.r,
                  spreadRadius: 1,
                ),
              ],
          borderRadius: BorderRadius.circular(borderRadius ?? 22.r),
        ),
        alignment: Alignment.center,
        child: (loadingButton == false)
            ? Text(
                text,
                textAlign: TextAlign.center,
                style:
                    textStyle ??
                    CustomTextStyle().heading1L.copyWith(
                      color: forColor ?? Colors.white,
                    ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AbsorbPointer(
                    absorbing: true,
                    child: SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(textWaiting, style: CustomTextStyle().heading1L),
                ],
              ),
      ),
    );
  }
}

class CustomTextButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final TextStyle? textStyle;

  const CustomTextButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      overlayColor: WidgetStateColor.transparent,
      hoverColor: Colors.transparent,
      child: Text(text, style: textStyle ?? CustomTextStyle().heading1L),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final double? opacity;
  final double? width;
  final double? height;
  final Widget? widgetIcon;

  const CustomIconButton({
    super.key,
    this.opacity,
    required this.widgetIcon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity ?? 1,
      duration: Duration(seconds: 2),
      child: Padding(
        padding: EdgeInsets.only(top: 4.h, right: 2.w),
        child: Container(
          width: width ?? 30.w,
          height: height ?? 30.w,
          padding: EdgeInsets.all(2.w),
          margin: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: Colors.transparent,
            boxShadow: [
              // BoxShadow(
              //     color: Colors.black54,
              //     blurRadius: 0.1,
              //     blurStyle: BlurStyle.outer,
              //     spreadRadius: 0.5)
            ],
            borderRadius: BorderRadius.circular(10.r),
            shape: BoxShape.rectangle,
          ),
          child: Center(child: widgetIcon),
        ),
      ),
    );
  }
}

class CustomButtonWithIconWithoutBackground extends StatelessWidget {
  final String text;
  final String textIcon;
  final void Function()? onPressed;
  final bool hasBackground;
  final double? height;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final bool? noChoiceSize;
  final BorderRadiusGeometry? borderRadius;
  final double? elevation;
  final TextStyle? textStyle;
  final ColorFilter? colorFilter;
  final IconAlignment? iconAlignment;

  const CustomButtonWithIconWithoutBackground({
    super.key,
    required this.text,
    required this.textIcon,
    required this.onPressed,
    this.padding,
    this.hasBackground = false,
    this.height,
    this.isLoading = false,
    this.textStyle,
    this.elevation,
    this.backgroundColor,
    this.colorFilter,
    this.iconAlignment,
    this.borderRadius,
    this.noChoiceSize,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      iconAlignment: iconAlignment ?? IconAlignment.end,
      clipBehavior: Clip.none,
      style: ElevatedButton.styleFrom(
        padding: padding ?? EdgeInsets.zero,
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
          side: ((noChoiceSize == true) && (text == "" || text == "اختر مقاسك"))
              ? BorderSide(color: CustomColor.primaryColor, width: 2)
              : BorderSide(color: Colors.transparent),
          borderRadius: borderRadius ?? BorderRadius.circular(10.r),
        ),
        shadowColor: Colors.transparent,
        overlayColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        backgroundColor: (hasBackground)
            ? backgroundColor ?? Colors.white.withValues(alpha: 0.9)
            : Colors.transparent,
        elevation: elevation ?? 0,
      ),
      onPressed: onPressed,
      icon: (textIcon == "")
          ? null
          : IconSvg(
              nameIcon: textIcon,
              onPressed: null,
              backColor: Colors.transparent,
              colorFilter: colorFilter,
              height: height ?? 13.h,
            ),
      label: (isLoading == false)
          ? Text(text, style: textStyle ?? CustomTextStyle().heading1L)
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: SizedBox(
                width: 30.w,
                height: 30.w,
                child: SpinKitFadingCircle(color: Colors.black, size: 20.h),
              ),
            ),
    );
  }
}

class CustomButtonWithIcon extends StatelessWidget {
  final String text;
  final String textIcon;
  final void Function()? onPressed;
  final bool hasBackground;
  final double? height;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final bool isChecked;
  final BorderRadiusGeometry? borderRadius;
  final double? elevation;
  final TextStyle? textStyle;
  final ColorFilter? colorFilter;
  final IconAlignment? iconAlignment;
  final BorderSide? borderSide;
  final String? subtitle;
  final TextStyle? subTitleStyle;

  const CustomButtonWithIcon({
    super.key,
    required this.text,
    required this.textIcon,
    required this.onPressed,
    this.padding,
    this.hasBackground = false,
    this.height,
    this.isLoading = false,
    this.textStyle,
    this.elevation,
    this.backgroundColor,
    this.colorFilter,
    this.iconAlignment,
    this.borderRadius,
    this.borderSide,
    this.subtitle,
    this.subTitleStyle,
    this.isChecked = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      iconAlignment: iconAlignment ?? IconAlignment.end,
      clipBehavior: Clip.none,
      style: ElevatedButton.styleFrom(
        padding: padding ?? EdgeInsets.zero,
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(25.r),
        ),
        shadowColor: Colors.transparent,
        overlayColor: Colors.transparent,
        foregroundColor: Colors.black,
        backgroundColor: (hasBackground)
            ? backgroundColor ?? Colors.white.withValues(alpha: 0.9)
            : Colors.transparent,
        elevation: elevation ?? 0,
      ),
      onPressed: onPressed,
      icon: (textIcon == "")
          ? SizedBox()
          : (isLoading == false)
          ? ((textIcon != "before")
                ? (textIcon.endsWith(".json"))
                      ? LottieWidget(
                          name: textIcon,
                          width: height ?? 40.w,
                          height: height ?? 40.w,
                        )
                      : IconSvg(
                          nameIcon: textIcon,
                          onPressed: null,
                          backColor: Colors.transparent,
                          colorFilter: colorFilter,
                          height: height ?? 13.h,
                        )
                : SizedBox())
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: SizedBox(
                width: 30.w,
                height: 30.w,
                child: SpinKitFadingCircle(color: Colors.white, size: 20.h),
              ),
            ),
      label: (subtitle == null || subtitle!.isEmpty)
          ? Text(text, style: textStyle ?? CustomTextStyle().heading1L)
          : Padding(
              padding: EdgeInsetsDirectional.fromSTEB(18, 0, 18, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.w),
                    ),
                    child: ((isChecked))
                        ? Align(
                            alignment: AlignmentDirectional(0, 0),
                            child: Icon(
                              Icons.check_rounded,
                              color: Colors.black,
                              size: 16.w,
                            ),
                          )
                        : SizedBox(),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        text,
                        style: textStyle ?? CustomTextStyle().heading1L,
                      ),
                      Text(
                        subtitle!,
                        style: subTitleStyle ?? CustomTextStyle().heading1L,
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class CustomButtonWithIconAndAnimations extends StatelessWidget {
  final String text;
  final String textIcon;
  final void Function()? onPressed;
  final bool hasBackground;
  final double? height;
  final int? showEven;
  final double? widthIconInStartEnd;
  final double? heightIconInStartEnd;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final BorderRadiusGeometry? borderRadius;
  final double? elevation;
  final TextStyle? textStyle;
  final ColorFilter? colorFilter;
  final IconAlignment? iconAlignment;

  const CustomButtonWithIconAndAnimations({
    super.key,
    required this.text,
    required this.textIcon,
    required this.onPressed,
    this.padding,
    this.hasBackground = false,
    this.height,
    this.isLoading = false,
    this.textStyle,
    this.elevation,
    this.backgroundColor,
    this.colorFilter,
    this.iconAlignment,
    this.borderRadius,
    this.widthIconInStartEnd,
    this.showEven = 0,
    this.heightIconInStartEnd,
  });

  @override
  Widget build(BuildContext context) {
    FetchController fetchController = context.watch<FetchController>();

    return ElevatedButton(
      clipBehavior: Clip.none,
      style: ElevatedButton.styleFrom(
        iconAlignment: iconAlignment ?? IconAlignment.end,
        padding: padding ?? EdgeInsets.zero,
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(25.r),
        ),
        shadowColor: Colors.transparent,
        overlayColor: Colors.transparent,
        foregroundColor: Colors.black,
        backgroundColor: (hasBackground)
            ? (fetchController.showEven == 11)
                  ? Color(0xFF8E8EFF)
                  : (fetchController.showEven == 30)
                  ? CustomColor.blackFridayColor
                  : backgroundColor ?? Colors.white.withValues(alpha: 0.9)
            : Colors.transparent,
        elevation: elevation ?? 0,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 5.w),
          LottieWidget(
            name: (showEven == 4)
                ?
                  // "Islamic Lantern"
                  Assets.lottie.eidSheep
                : (showEven == 30)
                ?
                  // "Islamic Lantern"
                  Assets.lottie.blackFriday
                : Assets.lottie.bigSale,
            width: widthIconInStartEnd ?? 50.w,
            height: heightIconInStartEnd ?? 50.w,
          ),
          Spacer(),
          Row(
            children: [
              (isLoading == false)
                  ? (textIcon == "")
                        ? SizedBox()
                        : IconSvg(
                            nameIcon: textIcon,
                            onPressed: null,
                            backColor: Colors.transparent,
                            colorFilter: colorFilter,
                            height: height ?? 13.h,
                          )
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: SizedBox(
                        width: 30.w,
                        height: 30.w,
                        child: SpinKitFadingCircle(
                          color: Colors.white,
                          size: 20.h,
                        ),
                      ),
                    ),
              Text(text, style: textStyle ?? CustomTextStyle().heading1L),
            ],
          ),
          Spacer(),
          LottieWidget(
            name: (showEven == 4)
                ?
                  // "Islamic Lantern"
                  Assets.lottie.eidSheep
                : (showEven == 30)
                ?
                  // "Islamic Lantern"
                  Assets.lottie.blackFriday
                : Assets.lottie.bigSale,
            width: widthIconInStartEnd ?? 50.w,
            height: heightIconInStartEnd ?? 50.w,
          ),
          SizedBox(width: 5.w),
        ],
      ),
    );
  }
}

class CustomButtonWithCheck extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  final bool hasBackground;
  final double? height;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final bool isChecked;
  final BorderRadiusGeometry borderRadius;
  final double? elevation;
  final TextStyle? textStyle;
  final ColorFilter? colorFilter;
  final IconAlignment? iconAlignment;
  final BorderSide? borderSide;
  final String? subtitle;
  final TextStyle? subTitleStyle;

  const CustomButtonWithCheck({
    super.key,
    required this.text,
    required this.onPressed,
    this.padding,
    this.hasBackground = false,
    this.height,
    this.textStyle,
    this.elevation,
    this.backgroundColor,
    this.colorFilter,
    this.iconAlignment,
    required this.borderRadius,
    this.borderSide,
    this.subtitle,
    this.subTitleStyle,
    this.isChecked = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      iconAlignment: iconAlignment ?? IconAlignment.end,
      clipBehavior: Clip.none,
      style: ElevatedButton.styleFrom(
        padding: padding ?? EdgeInsets.zero,
        alignment: Alignment.center,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        overlayColor: Colors.transparent,
        foregroundColor: Colors.black,
        backgroundColor: (hasBackground)
            ? backgroundColor ?? Colors.white.withValues(alpha: 0.9)
            : Colors.transparent,
        elevation: elevation ?? 0,
      ),
      onPressed: onPressed,
      label: (subtitle == null || subtitle!.isEmpty)
          ? Padding(
              padding: EdgeInsetsDirectional.fromSTEB(18, 0, 18, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.w),
                    ),
                    child: ((isChecked))
                        ? Align(
                            alignment: AlignmentDirectional(0, 0),
                            child: Icon(
                              Icons.check_rounded,
                              color: Colors.black,
                              size: 16.sp,
                            ),
                          )
                        : SizedBox(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        text,
                        style: textStyle ?? CustomTextStyle().heading1L,
                      ),
                    ),
                  ),
                ],
              ),
            )
          // Text(text, style: textStyle ?? CustomTextStyle().heading1L)
          : Padding(
              padding: EdgeInsetsDirectional.fromSTEB(18, 0, 18, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.w),
                    ),
                    child: ((isChecked))
                        ? Align(
                            alignment: AlignmentDirectional(0, 0),
                            child: Icon(
                              Icons.check_rounded,
                              color: Colors.black,
                              size: 16.sp,
                            ),
                          )
                        : SizedBox(),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          text,
                          style: textStyle ?? CustomTextStyle().heading1L,
                        ),
                        Text(
                          subtitle!,
                          style: subTitleStyle ?? CustomTextStyle().heading1L,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class IconSvg extends StatelessWidget {
  final String? nameIcon;
  final void Function()? onPressed;
  final ColorFilter? colorFilter;
  final Color? backColor;
  final double? height;
  final double? heightIcon;
  final double? width;

  const IconSvg({
    super.key,
    required this.nameIcon,
    required this.onPressed,
    this.colorFilter,
    this.backColor,
    this.height,
    this.width,
    this.heightIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: width ?? 40.w,
      width: height ?? 40.w,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backColor ?? Colors.black,
      ),
      child: (nameIcon != "")
          ? IconButton(
              splashRadius: 100,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: onPressed,
              icon: (colorFilter != null)
                  ? SvgPicture.asset(
                      nameIcon!,
                      height: heightIcon ?? 34.h,
                      clipBehavior: Clip.none,
                      colorFilter:
                          colorFilter ??
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    )
                  : SvgPicture.asset(
                      nameIcon!,
                      height: heightIcon ?? 34.h,
                      clipBehavior: Clip.none,
                    ),
            )
          : SizedBox(),
    );
  }
}

class IconSvgPicture extends StatelessWidget {
  final String? nameIcon;
  final ColorFilter? colorFilter;
  final double? heightIcon;

  const IconSvgPicture({
    super.key,
    required this.nameIcon,
    this.colorFilter,
    this.heightIcon,
  });

  @override
  Widget build(BuildContext context) {
    return (colorFilter != null)
        ? SvgPicture.asset(
            nameIcon!,
            height: heightIcon ?? 34.h,
            clipBehavior: Clip.none,
            colorFilter:
                colorFilter ??
                const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          )
        : SvgPicture.asset(
            nameIcon!,
            height: heightIcon ?? 34.h,
            clipBehavior: Clip.none,
          );
  }
}
