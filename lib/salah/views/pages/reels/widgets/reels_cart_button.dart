import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:fawri_app_refactor/salah/controllers/reels_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/cart_controller.dart';
import 'package:fawri_app_refactor/salah/models/items/item_model.dart';
import 'package:fawri_app_refactor/salah/utilities/style/colors.dart';
import 'package:fawri_app_refactor/salah/utilities/style/text_style.dart';

class ReelsCartButton extends StatelessWidget {
  final Item item;
  final ReelsController controller;

  const ReelsCartButton({
    super.key,
    required this.item,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartController>(
      builder: (context, cartController, child) {
        final isInCart = cartController.cartItems.any(
          (cartItem) => cartItem.productId == item.id,
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (isInCart) {
              controller.handleRemoveFromCart(item);
            } else {
              controller.handleAddToCart(item);
            }
          },
          child: Container(
            height: 42.h,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isInCart ? Colors.red : CustomColor.blueColor)
                      .withValues(alpha: 0.35),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.2),
                  blurRadius: 6,
                  spreadRadius: 0,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isInCart
                        ? Icons.remove_shopping_cart_rounded
                        : Icons.shopping_cart_rounded,
                    color: Colors.black,
                    size: 16.sp,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    isInCart ? 'إزالة من السلة' : 'أضف إلى السلة',
                    style: CustomTextStyle().heading1L.copyWith(
                      color: Colors.black,
                      fontSize: 13.sp,

                      shadows: [
                        Shadow(
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
