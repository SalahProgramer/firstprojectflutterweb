import 'package:fawri_app_refactor/salah/games/games_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utilities/style/text_style.dart';

class TopScore extends StatelessWidget {
  const TopScore({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GamesCubit, GamesState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(top: 40.w),
          child: Align(
            alignment: Alignment.topCenter,
            child: Text(
              "${state.currentScore}",
              style: CustomTextStyle().chewy.copyWith(
                  color: Colors.black,
                  fontSize: 30.sp,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
