import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/controllers/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class HowToDeleteCard extends StatelessWidget {
  const HowToDeleteCard({super.key});

  @override
  Widget build(BuildContext context) {
    CartController cartController = context.watch<CartController>();

    return Positioned.fill(
      child: GestureDetector(
        onTap: () async {
          await cartController.stopShowLearnDelete();
        },
        child: Container(
          color: Colors.black.withValues(alpha: 0.7),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Assets.images.deleteIconn.path,
                alignment: Alignment.center,
                height: 0.4.sh,
                width: 0.8.sw,
              ),
              SizedBox(height: 20.h),
              Text(
                "قم بالتمرير لحذف المنتج",
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
