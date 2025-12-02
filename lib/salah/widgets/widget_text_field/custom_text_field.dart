import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../controllers/fetch_controller.dart';
import '../../utilities/style/text_style.dart';

class NoKeyboardFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class CustomTextFormField extends StatefulWidget {
  final String hintText;
  final dynamic prefixIcon;
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
  final void Function()? onTap;
  final void Function(String)? onChanged;

  // final FocusNode? focusNode;

  final dynamic controlPage;

  const CustomTextFormField({
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

    // this.focusNode
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextFormField> {
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
      focusNode: NoKeyboardFocusNode(),
      enabled: true,
      // textInputAction: TextInputAction.e,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      selectionControls: DesktopTextSelectionControls(),

      onChanged: widget.onChanged,
      onTap: (widget.hasTap == false) ? null : widget.onTap,
      cursorColor: (widget.hasTap == false) ? Colors.black : Colors.transparent,
      validator: widget.validate,
      keyboardType: widget.inputType,
      controller: widget.controller,
      textDirection: TextDirection.rtl,
      maxLines: widget.maxLines,
      style: widget.textStyle,
      obscureText: (widget.hasSeePassIcon == true)
          ? (widget.seePassword ?? false)
          : false,

      textAlign: widget.textAlign,

      decoration: InputDecoration(
          hintText: widget.hintText,
          fillColor: (widget.hasFill)
              ? (fetchController.showEven == 1)
                  ? Colors.white
                  : Colors.white70
              : Colors.transparent,
          filled: true,
          alignLabelWithHint: widget.alignLabelWithHint,
          hintStyle: widget.hintStyle ??
              CustomTextStyle()
                  .heading1L
                  .copyWith(color: Colors.black45, fontSize: 12.sp),
          label: (widget.label != "")
              ? Text(
                  widget.label,
                  style: CustomTextStyle()
                      .heading1L
                      .copyWith(color: Colors.black, fontSize: 12.sp),
                )
              : null,
          border: (widget.hasFocusBorder)
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                )
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.transparent)),
          enabledBorder: (widget.hasFocusBorder)
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                      width: (fetchController.showEven == 1) ? 0 : 1,
                      color: (fetchController.showEven == 1)
                          ? Colors.blueGrey.shade100
                          : Colors.black),
                )
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.transparent)),
          focusedBorder: (widget.hasFocusBorder)
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: (widget.hasFocusBorder)
                      ? BorderSide(color: Colors.black, width: 1)
                      : BorderSide(width: 0, color: Colors.blueGrey.shade100),
                )
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.transparent)),
          prefixIcon: widget.prefixIcon,
          suffixIcon: (widget.hasSeePassIcon == true)
              ? IconButton(
                  onPressed: () {
                    widget.controlPage
                        .changeSeePassword(widget.seePassword ?? false);
                  },
                  icon: Icon(
                    (widget.seePassword == true)
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.black,
                  ))
              : null),
    );
  }
}
