part of 'games_cubit.dart';

class GamesState with EquatableMixin {
  final int currentScore;

  final PlayingState currentPlayingState;

  const GamesState({
    this.currentScore = 0,
    this.currentPlayingState = PlayingState.none,
  });

  GamesState copyWith({int? currentScore, PlayingState? currentPlayingState}) =>
      GamesState(
        currentScore: currentScore ?? this.currentScore,
        currentPlayingState: currentPlayingState ?? this.currentPlayingState,
      );

  @override
  List<Object> get props => [currentScore, currentPlayingState];
}

enum PlayingState {
  none,
  playing,
  paused,
  gameOver;

  bool get isNone => this == PlayingState.none;
  bool get isPlaying => this == PlayingState.playing;
  bool get isPaused => this == PlayingState.paused;
  bool get isGameOver => this == PlayingState.gameOver;
}
