import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../controllers/product_item_controller.dart';

class WidgetFirstOpenShow extends StatelessWidget {
  const WidgetFirstOpenShow({super.key});

  @override
  Widget build(BuildContext context) {
    ProductItemController productItemController =
        context.watch<ProductItemController>();
    return Positioned.fill(
      child: GestureDetector(
        onTap: () async {
          await productItemController.stopTutorial();
        },
        child: Container(
          color: Colors.black.withValues(alpha: 0.7),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(Assets.lottie.animation1726740976006,
                  height: 120.h,
                  reverse: true,
                  repeat: true,
                  fit: BoxFit.cover),
              SizedBox(
                height: 20.h,
              ),
              Text(
                "قم بالتمرير لمشاهدة القطع المتشابهة",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
