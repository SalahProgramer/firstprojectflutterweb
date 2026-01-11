import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:fawri_app_refactor/salah/models/items/item_model.dart';
import 'package:fawri_app_refactor/salah/widgets/custom_image.dart';
import 'package:fawri_app_refactor/salah/utilities/style/text_style.dart';
import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:fawri_app_refactor/salah/controllers/reels_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/product_item_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/page_main_screen_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/APIS/api_product_item.dart';
import 'package:fawri_app_refactor/salah/views/pages/home/main_screen/product_item_view.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';

class ReelsProductInfoBox extends StatefulWidget {
  final Item item;
  final bool isVisible;
  final VoidCallback onToggleVisibility;
  final ReelsController controller;
  final int videoIndex;

  const ReelsProductInfoBox({
    super.key,
    required this.item,
    required this.isVisible,
    required this.onToggleVisibility,
    required this.controller,
    required this.videoIndex,
  });

  @override
  State<ReelsProductInfoBox> createState() => _ReelsProductInfoBoxState();
}

class _ReelsProductInfoBoxState extends State<ReelsProductInfoBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  static final _analyticsService = AnalyticsService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    // Set initial state based on isVisible
    _controller.value = widget.isVisible ? 0.0 : 1.0;
  }

  @override
  void didUpdateWidget(ReelsProductInfoBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update animation when visibility changes externally
    if (oldWidget.isVisible != widget.isVisible) {
      if (widget.isVisible) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleVisibility() {
    if (widget.isVisible) {
      _analyticsService.logEvent(
        eventName: "hide_product_info_reels",
        parameters: {
          "class_name": "ReelsPage",
          "button_name": "hide_product_info",
          "product_id": widget.item.id?.toString() ?? "",
          "product_title": widget.item.title ?? "",
          "time": DateTime.now().toString(),
        },
      );
    }
    widget.onToggleVisibility();
  }

  Future<void> _handleProductBoxTap() async {
    // Log analytics event
    await _analyticsService.logEvent(
      eventName: "product_info_box_tapped_reels",
      parameters: {
        "class_name": "ReelsPage",
        "button_name": "product_info_box",
        "product_id": widget.item.id?.toString() ?? "",
        "product_title": widget.item.title ?? "",
        "time": DateTime.now().toString(),
      },
    );

    // CRITICAL: Pause ALL videos before navigating
    widget.controller.pauseAllVideos();

    // Get required controllers
    final pageMainScreenController = context.read<PageMainScreenController>();
    final productItemController = context.read<ProductItemController>();
    final apiProductItemController = context.read<ApiProductItemController>();

    // Follow the same pattern as custom_images_style_one.dart
    await pageMainScreenController.changePositionScroll(
      widget.item.id.toString(),
      0,
    );
    await productItemController.clearItemsData();
    await apiProductItemController.cancelRequests();

    // Navigate to ProductItemView
    await NavigatorApp.push(
      ProductItemView(
        item: widget.item,
        isFeature: false,
        sizes: '',
        isFlashOrBest: false,
      ),
    );

    // When coming back: DON'T do anything
    // Keep all videos paused - user must manually play
    // This prevents any unwanted auto-play or audio from other videos
    if (mounted) {
      widget.controller.pauseAllVideos();
      debugPrint('🔇 Returned from product - all videos paused');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Flexible(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Opacity(
                opacity: _fadeAnimation.value,
                child: IgnorePointer(
                  ignoring: _fadeAnimation.value == 0,
                  child: GestureDetector(
                    onTap: _handleProductBoxTap,
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.topRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.25),
                            Colors.black.withValues(alpha: 0.8),
                          ],
                          stops: const [0.02, 0.1],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: _buildProductContent(),
                    ),
                  ),
                ),
              ),
              // Only show toggle button when box is visible
              if (widget.isVisible)
                Positioned(
                  top: -17.h,
                  left: -17.h,
                  child: _buildToggleButton(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.item.title != null && widget.item.title!.isNotEmpty)
                Text(
                  widget.item.title!,
                  textAlign: TextAlign.center,
                  style: CustomTextStyle().heading1L.copyWith(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 1),
                        blurRadius: 3,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              if (widget.item.title != null && widget.item.title!.isNotEmpty)
                SizedBox(height: 4.h),
              if (widget.item.newPrice != null)
                Text(
                  widget.item.newPrice.toString(),
                  style: CustomTextStyle().heading1L.copyWith(
                    color: const Color(0xFF00FF88),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                        color: Colors.black.withValues(alpha: 0.7),
                      ),
                      Shadow(
                        offset: const Offset(0, 0),
                        blurRadius: 10,
                        color: const Color(0xFF00FF88).withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: 4.w),
        if (widget.item.vendorImagesLinks != null &&
            widget.item.vendorImagesLinks!.isNotEmpty)
          _buildProductImage(),
      ],
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: 80.w,
      height: 80.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6.r),
        child: CustomImageSponsored(
          boxFit: BoxFit.cover,
          imageUrl: widget.item.vendorImagesLinks!.first,
          borderRadius: BorderRadius.circular(6.r),
          width: 80.w,
          height: 80.w,
          padding: EdgeInsets.zero,
          borderCircle: 0,
        ),
      ),
    );
  }

  Widget _buildToggleButton() {
    // Capture the whole area so the tap never reaches the video behind it
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleVisibility, // ONLY hide/show the box
      child: Container(
        width: 40.w, // bigger hit area than the visible circle
        height: 40.w,
        alignment: Alignment.center,
        child: Container(
          width: 30.w,
          height: 30.w,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(Icons.close, color: Colors.white, size: 18.sp),
        ),
      ),
    );
  }
}
