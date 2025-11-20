import 'package:fawri_app_refactor/games/pipe.dart';
import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';

import 'coins.dart';
import 'games_cubit.dart';

/// **كائن يمثل زوجًا من الأنابيب في اللعبة (PipePair)**
/// هذا الكائن يحتوي على أنبوبين (علوي وسفلي) مع وجود فجوة بينهما.
class PipePair extends PositionComponent
    with FlameBlocReader<GamesCubit, GamesState> {
  final double gap; // الفجوة بين الأنبوبين (يحدد ارتفاع المساحة الفارغة بينهما)
  final double speed; // سرعة تحرك الأنابيب نحو اليسار

  /// **المُنشئ (Constructor)**
  /// - `gap`: تحدد المسافة بين الأنبوب العلوي والسفلي (افتراضيًا 200).
  /// - `speed`: تحدد سرعة حركة الأنابيب (افتراضيًا 300).
  /// - `position`: تحدد موضع الزوج الأولي في العالم.
  PipePair({
    this.gap = 280,
    this.speed = 300,
    required super.position,
  });

  @override
  Future<void> onLoad() async {
    // **إضافة الأنبوبين (علوي وسفلي) مع ضبط مواضعهما بناءً على `gap`**
    addAll([
      Pipes(isFlipped: false, position: Vector2(0, (gap / 2))),
      // أنبوب سفلي
      Pipes(isFlipped: true, position: Vector2(0, -(gap / 2))),
      // أنبوب علوي مقلوب

      Coins(position: Vector2.zero())
    ]);

    await super
        .onLoad(); // استدعاء `onLoad` الأساسي لضمان تحميل المكون بشكل صحيح
  }

  @override
  void update(double dt) {
    switch (bloc.state.currentPlayingState) {
      case PlayingState.paused:
      case PlayingState.gameOver:
      case PlayingState.none:
        break;

      case PlayingState.playing:
        position.x -= speed * dt; // تحريك زوج الأنابيب نحو اليسار باستمرار
        break;
    }

    super.update(dt); // استدعاء `update` الأساسي لضمان تحديث العنصر بشكل صحيح
  }
}
