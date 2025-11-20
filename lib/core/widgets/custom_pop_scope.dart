import 'package:flutter/cupertino.dart';

class CustomPopScope extends StatelessWidget {
  final Widget widget;

  const CustomPopScope({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: false, child: widget);
  }
}
