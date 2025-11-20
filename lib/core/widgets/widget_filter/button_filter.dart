import 'package:bouncerwidget/bouncerwidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../controllers/fetch_controller.dart';
import '../../utilities/style/text_style.dart';
import '../custom_button.dart';

class ButtonTypesFilter extends StatefulWidget {
  final String text;
  final String iconName;
  final double? height;
  final double? heightIcon;
  final bool? isLoading;
  final Color? backColor;
  final EdgeInsets? padding;
  final bool? haveBouncingWidget;
  final void Function()? onPressed;
  final double? widthIconInStartEnd;
  final double? heightIconInStartEnd;
  final ColorFilter? colorFilter;

  const ButtonTypesFilter(
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
      this.colorFilter});

  @override
  State<ButtonTypesFilter> createState() => _ButtonTypesState();
}

class _ButtonTypesState extends State<ButtonTypesFilter> {
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
      margin: EdgeInsets.only(bottom: 0.h, left: 1.w, right: 1.w),
      width: double.maxFinite,
      height: widget.height ?? 23.h,
      color: Colors.transparent,
      clipBehavior: Clip.none,
      child: CustomButtonWithoutIcon(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        text: widget.text,
        borderRadius: 20.r,

        textStyle: CustomTextStyle().heading1L.copyWith(
            fontSize: 14.sp,
            color: ((widget.isLoading == true) ? Colors.black : Colors.white)),
        // colorFilter:
        //
        // widget.colorFilter ??
        //     ColorFilter.mode(Colors.white, BlendMode.srcIn),
        // isLoading: widget.isLoading ?? false,

        height: widget.heightIcon ?? 30.h,

        onPressed: widget.onPressed, textWaiting: '',
      ),
    );
  }
}
