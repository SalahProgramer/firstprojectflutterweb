import 'dart:ui'; // استيراد مكتبة الرسم لـ Flutter (Canvas, Paint, وغيرها)
import 'package:flame/collisions.dart';
import 'package:flame/components.dart'; // استيراد مكونات Flame لإنشاء كائنات اللعبة
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة ScreenUtil لضبط الأحجام بشكل متجاوب مع الشاشة

/// **كائن يمثل العملات (Coins) في اللعبة**
class Coins extends PositionComponent {
  late Sprite _coinsSprite; // كائن `Sprite` لتخزين صورة العملة

  /// **المُنشئ (Constructor)**
  /// - `speed`: تحدد سرعة تحرك العملة (القيمة الافتراضية = 300)
  /// - `position`: تحدد موضع العملة عند إنشائها
  Coins({required super.position}) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // تحميل صورة العملة من مجلد الصور داخل اللعبة
    _coinsSprite = await Sprite.load("game_images/35.png");

    // ضبط حجم العملة ليكون متناسبًا مع حجم الشاشة باستخدام `ScreenUtil`
    size = Vector2(55.h, 60.h);
    add(CircleHitbox(collisionType: CollisionType.passive));

    return super.onLoad(); // استدعاء `onLoad` الأساسي بعد تحميل العملة
  }

  @override
  void render(Canvas canvas) {
    _coinsSprite.render(
      canvas, // تمرير `canvas` لرسم العملة عليه
      position: Vector2.zero(), // رسم الصورة عند النقطة (0,0) داخل العنصر
      size: size, // استخدام الحجم المحدد مسبقًا
    );

    // debugMode = true; // **(يمكن تفعيل هذا السطر لرؤية حدود العملة أثناء التصحيح)**

    super.render(
      canvas,
    ); // استدعاء `render` الأساسي لضمان استمرار عملية الرسم بشكل صحيح
  }
}
