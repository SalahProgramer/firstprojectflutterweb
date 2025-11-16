import 'package:fawri_app_refactor/salah/games/games_cubit.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flame_bloc/flame_bloc.dart';

import 'flappy_dash_game.dart';

class DashBackground extends ParallaxComponent<FlappyDashGame>
    with FlameBlocReader<GamesCubit, GamesState> {
  @override
  Future<void> onLoad() async {
    anchor = Anchor.center; //يتم تعيين نقطة الارتكاز (Anchor) لتكون في المنتصف.
    parallax = await game.loadParallax([
      //يتم تحميل عدة صور للخلفية من مجلد game_images، حيث تمثل كل صورة طبقة مختلفة من الخلفية.

      ParallaxImageData('game_images/layer1-sky.png'),
      ParallaxImageData('game_images/layer2-clouds.png'),
      ParallaxImageData('game_images/layer3-clouds.png'),
      ParallaxImageData('game_images/layer4-clouds.png'),
      ParallaxImageData('game_images/layer5-huge-clouds.png'),
      ParallaxImageData('game_images/layer6-bushes.png'),
      ParallaxImageData(
          'game_images/layer7-bushes.png'), //يتم تحميل عدة صور للخلفية من مجلد game_images، حيث تمثل كل صورة طبقة مختلفة من الخلفية.
    ],
        baseVelocity: Vector2(1,
            0), //يتم تعيين السرعة الأساسية للخلفية بحيث تتحرك نحو اليسار (x = 1، y = 0).
        velocityMultiplierDelta: Vector2(1.7,
            0) //كل طبقة تتحرك بسرعات مختلفة، بحيث تتحرك الطبقات البعيدة أبطأ والطبقات القريبة أسرع، مما يخلق تأثير المنظور (Parallax).

        );

    await super.onLoad();
  }

  @override
  void update(double dt) {
    switch (bloc.state.currentPlayingState) {
      case PlayingState.none:
      case PlayingState.playing:
        super.update(dt);
        break;
      case PlayingState.paused:
      case PlayingState.gameOver:
        break;
    }
  }
}
