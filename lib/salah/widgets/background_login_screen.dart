import 'package:flutter/material.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';

class BackgroundLoginScreen extends StatelessWidget {
  final Widget widget;

  const BackgroundLoginScreen({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  Assets.images.video.path,
                ),
                filterQuality: FilterQuality.high,
                fit: BoxFit.fill)),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.transparent,
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: widget,
          ),
        ));
  }
}
