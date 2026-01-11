import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? icon;
  final bool obscureText;
  final bool showEdit;
  final Function onEdit;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final FormFieldValidator<String>? validator;
  final Color? borderColor;
  final Color? backgroundColor;
  final double? height;
  final int? maxLines;
  final int? maxLenght;
  final double? borderRadius;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.validator,
    required this.onEdit,
    this.icon,
    this.obscureText = false,
    this.maxLines = 1,
    this.showEdit = false,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.onChanged,
    this.borderColor,
    this.backgroundColor,
    this.height,
    this.borderRadius,
    this.maxLenght,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: widget.height,
      width: double.infinity,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: TextFormField(
        validator: widget.validator,
        maxLength: widget.maxLenght,
        controller: widget.controller,
        maxLines: widget.maxLines,
        decoration: InputDecoration(
          suffixIcon: Visibility(
            visible: widget.showEdit,
            child: InkWell(
              onTap: () {
                widget.onEdit();
              },
              child: Icon(Icons.edit),
            ),
          ),
          hintText: widget.hintText,
          contentPadding: EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 10.0,
          ),
          prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
          filled: true,
          fillColor: widget.backgroundColor ?? Colors.white,
        ),
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        focusNode: widget.focusNode,
        onChanged: widget.onChanged,
      ),
    );
  }
}
