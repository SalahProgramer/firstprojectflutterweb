import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../games/flappy_dash_game.dart';
import '../games/games_cubit.dart';

class GameController extends ChangeNotifier {
  GamesCubit gamesCubit = BlocProvider.of<GamesCubit>(NavigatorApp.context);
  FlappyDashGame flappyDashGame = FlappyDashGame(
    BlocProvider.of<GamesCubit>(NavigatorApp.context),
  );

  PlayingState? latestState;

  Future<void> doInit() async {
    flappyDashGame = FlappyDashGame(gamesCubit);

    notifyListeners();
  }

  Future<void> set(PlayingState playState) async {
    latestState = playState;
    notifyListeners();
  }
}
