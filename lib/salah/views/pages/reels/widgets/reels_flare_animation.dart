import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fawri_app_refactor/salah/utilities/style/colors.dart';

class ReelsFlareAnimation extends StatelessWidget {
  final FlareControls flareControls;

  const ReelsFlareAnimation({super.key, required this.flareControls});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: SizedBox(
          width: 80.w,
          height: 80.w,
          child: FlareActor(
            Assets.images.instagramLike,
            controller: flareControls,
            color: CustomColor.primaryColor,
            animation: 'idle',
            fit: BoxFit.contain,
            shouldClip: false,
          ),
        ),
      ),
    );
  }
}
