import 'package:bouncerwidget/bouncerwidget.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../controllers/fetch_controller.dart';
import '../../utilities/style/colors.dart';
import '../../utilities/style/text_style.dart';
import '../custom_button.dart';

class ButtonTypes extends StatefulWidget {
  final String text;
  final String iconName;
  final double? height;
  final double? heightIcon;
  final bool? isLoading;
  final Color? backColor;
  final Color? colorShadow;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final bool? haveBouncingWidget;
  final void Function()? onPressed;
  final double? widthIconInStartEnd;
  final double? heightIconInStartEnd;
  final ColorFilter? colorFilter;
  final String? subtitle;

  const ButtonTypes(
      {super.key,
      required this.text,
      required this.iconName,
      required this.onPressed,
      this.height,
      this.heightIcon,
      this.isLoading,
      this.backColor,
      this.haveBouncingWidget = true,
      this.padding,
      this.widthIconInStartEnd,
      this.heightIconInStartEnd,
      this.colorFilter,
      this.margin,
      this.colorShadow,
      this.subtitle});

  @override
  State<ButtonTypes> createState() => _ButtonTypesState();
}

class _ButtonTypesState extends State<ButtonTypes> {
  @override
  Widget build(BuildContext context) {
    FetchController fetchController = context.watch<FetchController>();

    return (widget.haveBouncingWidget == true)
        ? BouncingWidget(
            child: widgetButtonDone(showEven: fetchController.showEven))
        : widgetButtonDone(showEven: fetchController.showEven);
  }

  Widget widgetButtonDone({required int showEven}) {
    return Container(
        margin: widget.margin ??
            EdgeInsets.only(bottom: 22.h, left: 7.w, right: 7.w),
        width: double.maxFinite,
        height: widget.height ?? 43.h,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius:
              BorderRadius.circular((widget.isLoading == false) ? 20.r : 22.r),
          border: Border.all(color: CustomColor.greyTextColor, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.20),
              blurRadius: 8.r,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.none,
        child: (widget.iconName == "")
            ? CustomButtonWithCheck(
                padding: EdgeInsets.symmetric(vertical: 2),
                text: widget.text,
                subtitle: widget.subtitle,
                borderRadius: BorderRadius.circular(20.r),
                borderSide: BorderSide(
                    color: ((widget.isLoading == true)
                        ? Colors.black
                        : CustomColor.greyTextColor),
                    width: 1.w),
                textStyle: CustomTextStyle().heading1L.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: ((widget.isLoading == true)
                        ? Colors.white
                        : Colors.black)),
                subTitleStyle: CustomTextStyle().heading1L.copyWith(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.normal,
                    color: ((widget.isLoading == true)
                        ? const Color.fromARGB(255, 189, 189, 189)
                        : CustomColor.greyTextColor)),
                colorFilter: (widget.isLoading == true)
                    ? ColorFilter.mode(Colors.white, BlendMode.srcIn)
                    : ColorFilter.mode(Colors.black, BlendMode.srcIn),
                backgroundColor: widget.backColor ??
                    ((widget.isLoading == true) ? Colors.black : Colors.white),
                iconAlignment: IconAlignment.start,
                height: widget.heightIcon ?? 30.h,
                hasBackground: true,
                isChecked: widget.isLoading ?? false,
                onPressed: widget.onPressed)
            : CustomButtonWithIcon(
                padding: (widget.iconName == "")
                    ? EdgeInsets.symmetric(vertical: 2.h)
                    : EdgeInsets.zero,
                text: widget.text,
                subtitle: widget.subtitle,
                borderRadius: BorderRadius.circular(20.r),
                borderSide: BorderSide(
                    color: ((widget.isLoading == true)
                        ? Colors.black
                        : CustomColor.greyTextColor),
                    width: 1.w),
                textIcon:
                    //it doesn't exist
                    (widget.isLoading == true)
                        ? Assets.icons.yes
                        : widget.iconName,
                textStyle: CustomTextStyle().heading1L.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: ((widget.isLoading == true)
                        ? Colors.white
                        : Colors.black)),
                subTitleStyle: CustomTextStyle().heading1L.copyWith(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.normal,
                    color: ((widget.isLoading == true)
                        ? const Color.fromARGB(255, 189, 189, 189)
                        : CustomColor.greyTextColor)),
                colorFilter: (widget.isLoading == true)
                    ? ColorFilter.mode(Colors.white, BlendMode.srcIn)
                    : ColorFilter.mode(Colors.black, BlendMode.srcIn),
                backgroundColor: widget.backColor ??
                    ((widget.isLoading == true) ? Colors.black : Colors.white),
                iconAlignment: IconAlignment.start,
                height: widget.heightIcon ?? 30.h,
                hasBackground: true,
                isChecked: widget.isLoading ?? false,
                onPressed: widget.onPressed));
  }
}
