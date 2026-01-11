import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:fawri_app_refactor/salah/controllers/reels_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/favourite_controller.dart';
import 'package:fawri_app_refactor/salah/models/items/item_model.dart';
import 'package:fawri_app_refactor/salah/utilities/style/colors.dart';

class ReelsActionButtons extends StatelessWidget {
  final Item item;
  final ReelsController controller;
  final bool isProductInfoVisible;
  final VoidCallback onToggleProductInfo;

  const ReelsActionButtons({
    super.key,
    required this.item,
    required this.controller,
    required this.isProductInfoVisible,
    required this.onToggleProductInfo,
  });

  /// Format count for display (e.g., 1000 -> "1K", 1500 -> "1.5K")
  String _formatCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      final k = count / 1000;
      if (k % 1 == 0) {
        return '${k.toInt()}K';
      } else {
        return '${k.toStringAsFixed(1)}K';
      }
    } else {
      final m = count / 1000000;
      if (m % 1 == 0) {
        return '${m.toInt()}M';
      } else {
        return '${m.toStringAsFixed(1)}M';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavouriteController>(
      builder: (context, favouriteController, child) {
        final isFavorite = favouriteController.checkFavouriteItemProductId(
          productId: item.id,
        );

        return Column(
          children: [
            // Show visibility icon when product info is hidden
            Visibility(
              visible: !isProductInfoVisible,
              child: _ReelsActionButton(
                icon: Icons.visibility,

                onTap: onToggleProductInfo,
              ),
            ),

            SizedBox(height: 16.h),
            Column(
              children: [
                _ReelsActionButton(
                  icon: FontAwesome.heart,
                  onTap: () => controller.handleFavoriteTap(item),
                  isFavorite: isFavorite,
                ),
                SizedBox(height: 4.h),
                // Favorite count label with animation
                Consumer<ReelsController>(
                  builder: (context, reelsController, child) {
                    final favoriteCount = reelsController.getLikeCount(item);
                    return _AnimatedCountText(
                      count: favoriteCount,
                      formattedText: _formatCount(favoriteCount),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 4.h),
            _ReelsActionButton(
              icon: Icons.content_copy,
              onTap: () => controller.handleCopySku(item),
            ),
          ],
        );
      },
    );
  }
}

class _ReelsActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isFavorite;

  const _ReelsActionButton({
    required this.icon,
    required this.onTap,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: isFavorite ? CustomColor.primaryColor : Colors.white,
          size: 18.sp,
        ),
      ),
    );
  }
}

/// Animated count text widget that smoothly animates when the count changes
class _AnimatedCountText extends StatelessWidget {
  final int count;
  final String formattedText;

  const _AnimatedCountText({required this.count, required this.formattedText});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Scale and fade animation
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Text(
        formattedText,
        key: ValueKey<int>(
          count,
        ), // Key changes when count changes, triggering animation
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
