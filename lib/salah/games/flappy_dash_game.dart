import 'dart:async'; // استيراد مكتبة التعامل مع العمليات غير المتزامنة
import 'package:fawri_app_refactor/salah/games/audio_helper.dart';
import 'package:fawri_app_refactor/salah/games/games_cubit.dart';
import 'package:fawri_app_refactor/salah/games/service_locator.dart';
import 'package:flame/components.dart'; // استيراد مكونات Flame لإنشاء كائنات اللعبة
import 'package:flame/events.dart'; // استيراد إدارة الأحداث في Flame
import 'package:flame/game.dart'; // استيراد محرك الألعاب Flame
import 'package:flutter/cupertino.dart'; // استيراد عناصر واجهة Flutter
import 'package:flutter/services.dart'; // استيراد معالجة الإدخال من لوحة المفاتيح
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد `ScreenUtil` لضبط الأحجام بناءً على حجم الشاشة
import 'package:flame_bloc/flame_bloc.dart';
import 'flappy_dash_root_component.dart'; // استيراد الخلفية المتحركة

/// **كائن يمثل لعبة Flappy Dash باستخدام محرك Flame**
class FlappyDashGame extends FlameGame<FlappyDashWorld>
    with KeyboardEvents, HasCollisionDetection {
  FlappyDashGame(this.gamesCubit)
    : super(
        world: FlappyDashWorld(), // تحديد العالم الافتراضي للعبة
        camera: CameraComponent.withFixedResolution(
          width: 1.03.sw,
          height: 1.sh,
        ), // ضبط الكاميرا لتناسب أبعاد الشاشة
      );

  final GamesCubit gamesCubit;

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isKeyDown = event is KeyDownEvent; // التحقق مما إذا كان الزر مضغوطًا
    final isSpace = keysPressed.contains(
      LogicalKeyboardKey.space,
    ); // التحقق مما إذا كان زر المسافة مضغوطًا

    if (isSpace && isKeyDown) {
      world.onSpaceDown(); // استدعاء `onSpaceDown()` عند الضغط على زر المسافة
      return KeyEventResult.handled; // إبلاغ النظام بأن الحدث قد تم التعامل معه
    }
    return KeyEventResult.ignored; // إذا لم يكن الحدث مطلوبًا، يتم تجاهله
  }
}

/// **كائن يمثل عالم اللعبة الذي يحتوي على جميع العناصر**
class FlappyDashWorld extends World
    with TapCallbacks, HasGameRef<FlappyDashGame> {
  late FlappyDashRootComponent rootComponent;
  @override
  Future<void> onLoad() async {
    await getIt.get<AudioHelper>().initialize();
    add(
      FlameBlocProvider<GamesCubit, GamesState>(
        create: () => game.gamesCubit,
        children: [rootComponent = FlappyDashRootComponent()],
      ),
    );
    super.onLoad();
  }

  void onSpaceDown() {
    rootComponent.onSpaceDown();
  }

  @override
  void onTapDown(TapDownEvent event) {
    rootComponent.onTapDown(event); // عند النقر على الشاشة، ينفذ الطائر القفز
    super.onTapDown(event);
  }
}
