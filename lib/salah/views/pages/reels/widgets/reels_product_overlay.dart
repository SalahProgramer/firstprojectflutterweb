import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:fawri_app_refactor/salah/controllers/reels_controller.dart';
import 'package:fawri_app_refactor/salah/models/items/item_model.dart';
import 'reels_product_info_box.dart';
import 'reels_action_buttons.dart';
import 'reels_cart_button.dart';

class ReelsProductOverlay extends StatelessWidget {
  final int index;
  final ReelsController controller;
  final Item item;

  const ReelsProductOverlay({
    super.key,
    required this.index,
    required this.controller,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ReelsController>(
      builder: (context, controller, child) {
        return SafeArea(
          child: Stack(
            children: [
              _buildGradientShadow(),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  spacing: 12.h,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      spacing: 5.w,
                      children: [
                        SizedBox(width: 4.w),
                        ReelsActionButtons(
                          item: item,
                          controller: controller,
                          isProductInfoVisible: controller.isProductInfoVisible,
                          onToggleProductInfo: () =>
                              controller.toggleProductInfoVisibility(),
                        ),
                        SizedBox(width: 4.w),

                        ReelsProductInfoBox(
                          item: item,
                          isVisible: controller.isProductInfoVisible,
                          onToggleVisibility: () =>
                              controller.toggleProductInfoVisibility(),
                          controller: controller,
                          videoIndex: index,
                        ),
                        SizedBox(width: 15.w),
                      ],
                    ),
                    ReelsCartButton(item: item, controller: controller),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGradientShadow() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Container(
          height: 350.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.7),
                Colors.black.withValues(alpha: 0.9),
              ],
              stops: const [0.0, 0.4, 0.7, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
