import 'dart:ui';
import 'package:fawri_app_refactor/games/pipe.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import '../controllers/game_controller.dart';
import '../controllers/page_main_screen_controller.dart';
import '../controllers/points_controller.dart';
import '../core/dialogs/dialog_phone/dialog_add_phone.dart';
import '../core/dialogs/dialogs_spin_and_points/dialogs_points.dart';
import '../core/utilities/global/app_global.dart';
import '../core/utilities/print_looger.dart';
import 'coins.dart';
import 'flappy_dash_game.dart';
import 'games_cubit.dart';

/// **كائن يمثل الطائر (Dash) في اللعبة**
class BirdDash extends PositionComponent
    with
        CollisionCallbacks,
        HasGameRef<FlappyDashGame>,
        FlameBlocReader<GamesCubit, GamesState> {
  BirdDash()
      : super(
            position: Vector2(0, 0),
            // تعيين موضع الطائر عند بدء اللعبة (نقطة الأصل)
            size: Vector2(40.h, 40.h),
            // ضبط حجم الطائر بناءً على أبعاد الشاشة باستخدام `ScreenUtil`
            anchor: Anchor.center,
            // تحديد نقطة الارتكاز في المركز (لتسهيل التمركز)
            priority:
                10); // تحديد أولوية العرض بحيث يظهر الطائر فوق العناصر ذات الأولوية الأقل

  late Sprite dashSprite; // كائن `Sprite` لتخزين صورة الطائر
  late GameController gameController; // Add GameController
  late PointsController pointsController; // Add GameController
  late PageMainScreenController api; // Add GameController

  final Vector2 _gravity = Vector2(
      0, 1400.0); // تحديد قوة الجاذبية المؤثرة على الطائر (يدفعه للأسفل)
  final Vector2 _jumpForce =
      Vector2(0, -420); // قوة القفز التي تدفع الطائر للأعلى عند النقر
  Vector2 _velocity = Vector2(0, 0); // متغير لتخزين سرعة الطائر الحالية

  @override
  Future<void> onLoad() async {
    api = NavigatorApp.context.read<PageMainScreenController>();
    gameController = NavigatorApp.context.read<GameController>();
    pointsController = NavigatorApp.context.read<PointsController>();

    // تحميل صورة الطائر عند تشغيل اللعبة
    dashSprite = await Sprite.load("game_images/dash.png");
    double radius = size.x / 2;
    add(CircleHitbox(radius: radius));
    return super.onLoad(); // استدعاء `onLoad` الأساسي بعد تحميل الصورة
  }

  @override
  void update(double dt) {
    if (bloc.state.currentPlayingState != PlayingState.playing) {
      return;
    }

    _velocity +=
        _gravity * dt; // تطبيق تأثير الجاذبية على السرعة (يزيد من سرعة السقوط)
    position += _velocity * dt; // تحديث موضع الطائر بناءً على سرعته الحالية

    super.update(dt); // استدعاء `update` الأساسي لتحديث العنصر في اللعبة
  }

  /// **دالة تجعل الطائر يقفز عند استدعائها**
  void jump() {
    if (bloc.state.currentPlayingState != PlayingState.playing) {
      return;
    }

    _velocity =
        _jumpForce; // عند القفز، يتم إعادة تعيين السرعة لقوة القفز لجعل الطائر يرتفع
  }

  @override
  void render(Canvas canvas) {
    printLog("$canvas"); // طباعة بيانات `canvas` لأغراض التصحيح (اختياري)
    dashSprite.render(canvas,
        size: size); // رسم صورة الطائر داخل `canvas` بحجم العنصر

    super.render(
        canvas); // استدعاء `render` الأساسي لضمان استمرار عملية الرسم بشكل صحيح
  }

  @override
  Future<void> onCollision(
      Set<Vector2> intersectionPoints, PositionComponent other) async {
    super.onCollision(intersectionPoints, other);
    if (bloc.state.currentPlayingState != PlayingState.playing) {
      return;
    }

    if (other is Coins) {
      printLog("lets increase the coins");
      bloc.increaseScore();
      other.removeFromParent();
    } else if (other is Pipes) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String phone = prefs.getString('phone') ?? "";

      // إجمع النقاط من الجيم الحالية مع المحفوظة
      int score = prefs.getInt("score_game") ?? 0;
      score += bloc.state.currentScore;

      // ✅ تحقق من هل جمع اللاعب 5 نقاط أو أكثر؟
      final hasEnoughPoints = score >= 5;

      // ✅ تحقق من الشروط معًا
      if (hasEnoughPoints) {
        bloc.gameOver();
        printLog("Game over !!!!");
        if (phone == "") {
          await showAddPhone(goToSpin: false);
          phone = prefs.getString('phone') ?? "";
        }

        if (phone != "") {
          if ((api.userActivity.getEnumStatus('1').canUse == true)) {
            phone = prefs.getString('phone') ?? "";
            await pointsController.updateUserPointsAndLevel(
                phone: phone, newAmount: "5", enumNumber: 1);
            final f1 = api.getUserActivity(phone: phone);
            final f2 = pointsController.getPointsFromAPI(phone: phone);

            await Future.wait([f1, f2]);
            await dialogGetPoint("5 نقاط");
            await prefs.setInt('score_game', 0); // تصفير العداد
          }
        }
      } else {
        await prefs.setInt('score_game', score); // حفظ التراكم
        if (hasEnoughPoints) {
          await prefs.setInt('score_game', 0); // حفظ التراكم
        }
        bloc.gameOver();
      }
    }
  }
}
