import 'package:fawri_app_refactor/salah/controllers/game_controller.dart';
import 'package:fawri_app_refactor/salah/games/games_cubit.dart';
import 'package:fawri_app_refactor/salah/games/top_score.dart';
import 'package:fawri_app_refactor/salah/games/widget_game_over.dart';
import 'package:fawri_app_refactor/salah/utilities/style/text_style.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WidgetGame extends StatefulWidget {
  const WidgetGame({super.key});

  @override
  State<WidgetGame> createState() => _WidgetGameState();
}

class _WidgetGameState extends State<WidgetGame> {
  @override
  Widget build(BuildContext context) {
    GameController gameController = context.watch<GameController>();
    return BlocConsumer<GamesCubit, GamesState>(
      listener: (context, state) async {
        if ((state.currentPlayingState.isNone) &&
            (gameController.latestState == PlayingState.gameOver)) {
          await gameController.doInit();
        }

        await gameController.set(state.currentPlayingState);
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              GameWidget(game: gameController.flappyDashGame),
              if (state.currentPlayingState.isGameOver) GameOverWidget(),
              if (state.currentPlayingState.isNone)
                Align(
                  alignment: Alignment(0, 0.2),
                  child: IgnorePointer(
                    child: Text("TAP TO PLAY", style: CustomTextStyle().chewy)
                        .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true),
                        )
                        .scale(
                          begin: Offset(1.0, 1.0),
                          end: Offset(1.2, 1.2),
                          duration: Duration(milliseconds: 500),
                        ),
                  ),
                ),
              if (!state.currentPlayingState.isGameOver) TopScore(),
              if (state.currentPlayingState.isNone ||
                  state.currentPlayingState.isGameOver)
                Positioned(
                  top: 50.w,
                  right: 30.w,
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    overlayColor: WidgetStateColor.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "رجوع",
                      style: CustomTextStyle().heading1L.copyWith(
                        color: (state.currentPlayingState.isGameOver)
                            ? Colors.white
                            : Colors.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
