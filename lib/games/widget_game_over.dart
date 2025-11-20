import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowy_borders/glowy_borders.dart';
import '../core/utilities/style/colors.dart';
import '../core/utilities/style/text_style.dart';
import 'games_cubit.dart';

class GameOverWidget extends StatelessWidget {
  const GameOverWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Game Over",
                style: CustomTextStyle().chewy.copyWith(
                    color: Color(0xFFFFCA00),
                    fontSize: 40.sp,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5.h,
              ),
              Text(
                "Score : ${context.read<GamesCubit>().state.currentScore}",
                style: CustomTextStyle().chewy.copyWith(
                    color: Colors.white,
                    fontSize: 20.sp,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10.h,
              ),
              AnimatedGradientBorder(
                borderRadius: BorderRadius.circular(10.r),
                gradientColors: [Color(0xFFFFCA00), CustomColor.blueColor],
                glowSize: 0,
                borderSize: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: ElevatedButton(
                    onPressed: () async {
                      context.read<GamesCubit>().restartGame();
                    },
                    style: ElevatedButton.styleFrom(
                      // padding:  EdgeInsets.symmetric( horizontal: 8.w),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                      alignment: Alignment.center,
                    ),
                    child: Text(
                      "العب مرة أخرى",
                      style: CustomTextStyle().chewy.copyWith(
                          color: CustomColor.blueColor,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
