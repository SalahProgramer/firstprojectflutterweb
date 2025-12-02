import 'package:equatable/equatable.dart';
import 'package:fawri_app_refactor/salah/games/audio_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'games_state.dart';

class GamesCubit extends Cubit<GamesState> {
  GamesCubit(this.audioHelper) : super(const GamesState());
  final AudioHelper audioHelper;

  Future<void> startPlaying() async {
    audioHelper.playBackgroundAudio();
    emit(state.copyWith(
        currentPlayingState: PlayingState.playing, currentScore: 0));
  }

  void increaseScore() {
    audioHelper.playCoinAudio();
    emit(state.copyWith(currentScore: state.currentScore + 1));
  }

  void gameOver() {
    audioHelper.stopBackgroundAudio();
    emit(state.copyWith(currentPlayingState: PlayingState.gameOver));
  }

  Future<void> restartGame() async {
    emit(state.copyWith(
        currentPlayingState: PlayingState.none, currentScore: 0));
  }
}
