import 'dart:math';

import 'package:fawri_app_refactor/salah/games/pipe_pair.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../server/functions/functions.dart';
import 'bird_dash.dart';
import 'dash_background.dart';
import 'flappy_dash_game.dart';
import 'games_cubit.dart';

class FlappyDashRootComponent extends Component
    with HasGameRef<FlappyDashGame>, FlameBlocReader<GamesCubit, GamesState> {
  late BirdDash dashBird; // كائن الطائر
  late PipePair lastPipe; // كائن آخر أنبوب تمت إضافته

  final double basicDistance = 400.w; // المسافة الأساسية بين العناصر

  @override
  Future<void> onLoad() async {
    printLog("onLoad"); // طباعة رسالة عند تحميل العالم
    game.camera.viewfinder.zoom = 1.0; // الحفاظ على مستوى التكبير للكاميرا

    add(DashBackground()); // إضافة الخلفية المتحركة
    add(dashBird = BirdDash()); // إضافة الطائر
    _generatePipeAnDCoins(
      count: 5,
      fromX: 400.w,
    ); // إنشاء الأنابيب والعملات عند بدء اللعبة

    return super.onLoad();
  }

  /// **دالة لإنشاء العملات والأنابيب في العالم**
  void _generatePipeAnDCoins({required int count, double fromX = 0.0}) {
    for (int i = 0; i <= count; i++) {
      final y = Random().nextDouble() * 200.h; // تحديد موقع Y عشوائي

      add(
        lastPipe = PipePair(
          position: Vector2((fromX + ((i * (basicDistance)) + 100.w)), y),
        ),
      ); // إضافة أنبوب
    }
  }

  void onTapDown(TapDownEvent event) {
    _checkToStart();

    dashBird.jump(); // عند النقر على الشاشة، ينفذ الطائر القفز
  }

  /// **دالة يتم استدعاؤها عندما يتم الضغط على زر المسافة**
  void onSpaceDown() {
    _checkToStart();

    dashBird.jump(); // تنفيذ القفز عند الضغط على المسافة
  }

  @override
  void update(double dt) {
    if (dashBird.x >= lastPipe.x) {
      _generatePipeAnDCoins(
        count: 5,
        fromX: basicDistance,
      ); // توليد أنابيب وعملات جديدة
      _removeOldOnes(); // إزالة العناصر القديمة
    }
    // game.camera.viewfinder.zoom = 1.0; // الحفاظ على مستوى التكبير للكاميرا
    super.update(dt);
  }

  /// **إزالة الأنابيب والعملات القديمة للحفاظ على الأداء**
  void _removeOldOnes() {
    final pipes = children.whereType<PipePair>(); // جمع جميع الأنابيب
    final shouldBeRemovedPipes = max(
      pipes.length - 5,
      0,
    ); // إبقاء آخر 5 أنابيب فقط
    pipes.take(shouldBeRemovedPipes).forEach((pipe) {
      pipe.removeFromParent(); // حذف الأنابيب القديمة
    });
  }

  void _checkToStart() {
    if (bloc.state.currentPlayingState == PlayingState.none) {
      bloc.startPlaying();
    }
  }
}
