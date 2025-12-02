import 'dart:ui'; // استيراد مكتبة الرسم لـ Flutter (Canvas, Paint, وغيرها)
import 'package:flame/collisions.dart';
import 'package:flame/components.dart'; // استيراد مكونات Flame لإنشاء كائنات اللعبة
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة ScreenUtil لضبط الأحجام بشكل متجاوب مع الشاشة
import '../../server/functions/functions.dart'; // استيراد ملف يحتوي على وظائف إضافية مثل `printLog`

/// **كائن يمثل الأنابيب (Pipes) في اللعبة**
class Pipes extends PositionComponent {
  late Sprite _pipsSprite; // كائن Sprite لتخزين صورة الأنبوب
  final bool isFlipped; // متغير يحدد ما إذا كان الأنبوب مقلوبًا رأسياً أم لا

  /// **المُنشئ (Constructor)**
  /// - `isFlipped`: يحدد ما إذا كان سيتم قلب الأنبوب رأسياً
  /// - `position`: يحدد موضع الأنبوب في العالم
  Pipes({
    required this.isFlipped, // تحديد ما إذا كان الأنبوب مقلوبًا أم لا
    required super.position, // تحديد موضع الأنبوب
  }) : super(
            priority:
                2); // إعطاء الأولوية للأنبوب أثناء العرض (يظهر فوق العناصر ذات الأولوية الأقل)

  @override
  Future<void> onLoad() async {
    // تحميل صورة الأنبوب من مجلد الصور داخل اللعبة
    _pipsSprite = await Sprite.load("game_images/pipe.png");

    // تحديد نقطة الارتكاز لتكون في أعلى المركز، مما يسهل ضبط موضع الأنبوب عند إضافته إلى العالم
    anchor = Anchor.topCenter;

    // حساب نسبة العرض إلى الارتفاع للصورة الأصلية
    final ratio = _pipsSprite.srcSize.y / _pipsSprite.srcSize.x;

    // تعيين عرض الأنبوب بناءً على حجم الشاشة (متجاوب مع `ScreenUtil`)
    width = 50.w;

    // ضبط حجم الأنبوب بناءً على نسبة العرض إلى الارتفاع
    size = Vector2(width, (width * ratio * 2.5));

    // إذا كان `isFlipped = true`، يتم قلب الأنبوب رأسياً
    if (isFlipped) {
      flipVertically();
    }

    add(RectangleHitbox());

    return super.onLoad(); // استدعاء `onLoad` الأساسي بعد تحميل الأنبوب
  }

  @override
  void render(Canvas canvas) {
    printLog("$canvas"); // طباعة معلومات `canvas` لأغراض التصحيح
    _pipsSprite.render(
      canvas, // تمرير الكانفاس لرسم الأنبوب عليه
      position: Vector2.zero(), // رسم الصورة عند النقطة (0,0) داخل العنصر
      size: size, // استخدام الحجم المحدد مسبقًا
    );

    // debugMode = true; // **(يمكن تفعيل هذا السطر لرؤية حدود الأنبوب أثناء التصحيح)**

    super.render(
        canvas); // استدعاء `render` الأساسي لضمان استمرار عملية الرسم بشكل صحيح
  }
}
