import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:flutter/material.dart';

import '../../utilities/style/colors.dart';

enum SnackBarType { info, success, warning, error }

class SnackBarStyle {
  final List<Color> fill;
  final List<Color> border;
  final Color badge;
  final Color textColor;
  final String lottieName;
  final Color? lottieColor;

  const SnackBarStyle({
    required this.fill,
    required this.border,
    required this.textColor,
    required this.badge,
    required this.lottieName,
    this.lottieColor,
  });
}

Map<SnackBarType, SnackBarStyle> stylesSnackBar = {
  SnackBarType.error: SnackBarStyle(
    fill: CustomColor.errorGradient,
    border: CustomColor.errorOutline,
    badge: CustomColor.errorAccent,
    textColor: Colors.white,
    lottieName: Assets.lottie.sad,
  ),
  SnackBarType.warning: SnackBarStyle(
    fill: CustomColor.warningGradient,
    border: CustomColor.warningOutline,
    textColor: Colors.white,
    badge: CustomColor.warningAccent,
    lottieName: Assets.lottie.alert,
  ),
  SnackBarType.success: SnackBarStyle(
    fill: CustomColor.successGradient,
    border: CustomColor.successOutline,
    badge: CustomColor.successAccent,
    textColor: Colors.white,
    lottieName: Assets.lottie.happy2,
  ),
  SnackBarType.info: SnackBarStyle(
    fill: CustomColor.infoGradient,
    border: CustomColor.infoOutline,
    badge: CustomColor.infoAccent,
    textColor: Colors.white,
    lottieName: Assets.lottie.lightBulb,
  ),
};
