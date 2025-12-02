import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class LottieWidget extends StatelessWidget {
  final String? name;
  final double? height;
  final double? width;
  final bool? animate;
  final BoxFit? boxFit;
  const LottieWidget(
      {super.key,
      this.name,
      this.height,
      this.width,
      this.animate = true,
      this.boxFit});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(name!,
        height: height ?? 40.w,
        width: width ?? 40.w,
        fit: boxFit ?? BoxFit.cover,
        animate: animate ?? true);
  }
}
