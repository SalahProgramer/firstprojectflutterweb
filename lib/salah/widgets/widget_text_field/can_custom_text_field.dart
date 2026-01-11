import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../controllers/fetch_controller.dart';
import '../../utilities/style/text_style.dart';

class CanCustomTextFormField extends StatefulWidget {
  final String hintText;
  final dynamic prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validate;
  final TextInputType? inputType;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;

  final TextEditingController? controller;
  final String label;
  final TextAlign textAlign;
  final bool? hasSeePassIcon;
  final bool? seePassword;
  final bool? alignLabelWithHint;
  final bool hasTap;
  final bool hasFocusBorder;
  final bool hasFill;
  final int? maxLines;
  final int? maxLength;
  final void Function()? onTap;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final Color? borderColor;
  final bool? autofocus;
  final double? radius;
  // final FocusNode? focusNode;

  final dynamic controlPage;

  const CanCustomTextFormField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.validate,
    required this.inputType,
    required this.controller,
    this.label = "",
    this.hasSeePassIcon,
    this.seePassword,
    required this.controlPage,
    this.textAlign = TextAlign.start,
    this.alignLabelWithHint = false,
    this.hasTap = false,
    this.onTap,
    this.hasFocusBorder = true,
    this.hasFill = true,
    required this.maxLines,
    this.hintStyle,
    this.textStyle,
    this.onChanged,
    this.suffixIcon,
    this.maxLength,
    this.focusNode,
    this.borderColor,
    this.autofocus,
    this.radius,

    // this.focusNode
  });

  @override
  State<CanCustomTextFormField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CanCustomTextFormField> {
  // FocusNode focusNode = FocusNode();

  // @override
  // void dispose() {
  //   focusNode.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    FetchController fetchController = context.watch<FetchController>();

    return TextFormField(
      enabled: true,
      autofocus: widget.autofocus ?? false,

      // textInputAction: TextInputAction.e,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      selectionControls: DesktopTextSelectionControls(),
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      onTap: (widget.hasTap == false) ? null : widget.onTap,
      cursorColor: (widget.hasTap == false) ? Colors.black : Colors.transparent,
      validator: widget.validate,
      keyboardType: widget.inputType,
      controller: widget.controller,
      textDirection: TextDirection.rtl,
      focusNode: widget.focusNode,
      maxLines: widget.maxLines,
      style: widget.textStyle,

      obscureText: (widget.hasSeePassIcon == true)
          ? (widget.seePassword ?? false)
          : false,

      textAlign: widget.textAlign,
      canRequestFocus: (widget.hasFill) ? true : false,

      decoration: InputDecoration(
        hintText: widget.hintText,
        fillColor: (widget.hasFill)
            ? (fetchController.showEven == 1)
                  ? Colors.white
                  : Colors.white70
            : Colors.transparent,
        filled: (widget.hasFill) ? true : false,
        alignLabelWithHint: widget.alignLabelWithHint,
        hintStyle:
            widget.hintStyle ??
            CustomTextStyle().heading1L.copyWith(
              color: Colors.black45,
              fontSize: 12.sp,
            ),
        label: (widget.label != "")
            ? Text(
                widget.label,
                style: CustomTextStyle().heading1L.copyWith(
                  color: Colors.black,
                  fontSize: 12.sp,
                ),
              )
            : null,
        errorMaxLines: 3,
        border: (widget.hasFocusBorder)
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.radius ?? 12.r),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.radius ?? 12.r),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
        enabledBorder: (widget.hasFocusBorder)
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.radius ?? 12.r),
                borderSide: BorderSide(
                  width: 0,
                  color: widget.borderColor ?? Colors.blueGrey.shade100,
                ),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.radius ?? 12.r),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
        focusedBorder: (widget.hasFocusBorder)
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.radius ?? 12.r),
                borderSide: (widget.hasFocusBorder)
                    ? BorderSide(color: Colors.black, width: 1)
                    : BorderSide(width: 0, color: Colors.blueGrey.shade100),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.radius ?? 12.r),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
        prefixIcon: widget.prefixIcon,
        suffixIcon: (widget.hasSeePassIcon == true) ? widget.suffixIcon : null,
      ),
    );
  }
}

class CustomTextFormFieldProfile extends StatefulWidget {
  final String hintText;
  final dynamic prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validate;
  final TextInputType? inputType;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;

  final TextEditingController? controller;
  final String label;
  final TextAlign textAlign;
  final bool? hasSeePassIcon;
  final bool? seePassword;
  final bool? alignLabelWithHint;
  final bool hasTap;
  final bool hasFocusBorder;
  final bool hasFill;
  final int? maxLines;
  final int? maxLength;
  final void Function()? onTap;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  // final FocusNode? focusNode;

  final dynamic controlPage;

  const CustomTextFormFieldProfile({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.validate,
    required this.inputType,
    required this.controller,
    this.label = "",
    this.hasSeePassIcon,
    this.seePassword,
    required this.controlPage,
    this.textAlign = TextAlign.start,
    this.alignLabelWithHint = false,
    this.hasTap = false,
    this.onTap,
    this.hasFocusBorder = true,
    this.hasFill = true,
    required this.maxLines,
    this.hintStyle,
    this.textStyle,
    this.onChanged,
    this.suffixIcon,
    this.maxLength,
    this.focusNode,

    // this.focusNode
  });

  @override
  State<CustomTextFormFieldProfile> createState() =>
      _CustomTextFormFieldProfileState();
}

class _CustomTextFormFieldProfileState
    extends State<CustomTextFormFieldProfile> {
  // FocusNode focusNode = FocusNode();

  // @override
  // void dispose() {
  //   focusNode.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    FetchController fetchController = context.watch<FetchController>();

    return TextFormField(
      enabled: true,
      // textInputAction: TextInputAction.e,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      selectionControls: DesktopTextSelectionControls(),
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      onTap: (widget.hasTap == false) ? null : widget.onTap,
      cursorColor: (widget.hasTap == false) ? Colors.black : Colors.transparent,
      validator: widget.validate,
      keyboardType: widget.inputType,
      controller: widget.controller,
      textDirection: TextDirection.rtl,
      focusNode: widget.focusNode,
      maxLines: widget.maxLines,
      style: widget.textStyle,

      obscureText: (widget.hasSeePassIcon == true)
          ? (widget.seePassword ?? false)
          : false,

      textAlign: widget.textAlign,
      canRequestFocus: (widget.hasFill) ? true : false,

      decoration: InputDecoration(
        hintText: widget.hintText,
        fillColor: (widget.hasFill)
            ? (fetchController.showEven == 1)
                  ? Colors.white
                  : Colors.transparent
            : Colors.transparent,
        filled: (widget.hasFill) ? true : false,
        alignLabelWithHint: widget.alignLabelWithHint,
        hintStyle:
            widget.hintStyle ??
            CustomTextStyle().heading1L.copyWith(
              color: Colors.black45,
              fontSize: 12.sp,
            ),
        label: (widget.label != "")
            ? Text(
                widget.label,
                style: CustomTextStyle().heading1L.copyWith(
                  color: Colors.black,
                  fontSize: 10.sp,
                ),
              )
            : null,
        errorMaxLines: 3,
        border: (widget.hasFocusBorder)
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Colors.black, width: 2),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
        enabledBorder: (widget.hasFocusBorder)
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(width: 1, color: Colors.black),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
        focusedBorder: (widget.hasFocusBorder)
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: (widget.hasFocusBorder)
                    ? BorderSide(color: Colors.black, width: 1)
                    : BorderSide(width: 1, color: Colors.blueGrey.shade100),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
        prefixIcon: widget.prefixIcon,
        suffixIcon: (widget.hasSeePassIcon == true) ? widget.suffixIcon : null,
      ),
    );
  }
}
