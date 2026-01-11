import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:fawri_app_refactor/salah/controllers/reels_controller.dart';
import 'package:fawri_app_refactor/salah/utilities/style/colors.dart';

class ReelsPlayPauseButton extends StatefulWidget {
  final int index;
  final ReelsController controller;

  const ReelsPlayPauseButton({
    super.key,
    required this.index,
    required this.controller,
  });

  @override
  State<ReelsPlayPauseButton> createState() => _ReelsPlayPauseButtonState();
}

class _ReelsPlayPauseButtonState extends State<ReelsPlayPauseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReelsController>(
      builder: (context, controller, child) {
        final isPlaying = controller.isVideoPlaying(widget.index);
        final isCurrentVideo = widget.index == controller.currentVideoIndex;
        final isPageVisible = controller.isPageVisible;

        // Don't show button if page is not visible or video is playing
        final shouldShow = isCurrentVideo && !isPlaying && isPageVisible;

        return AnimatedOpacity(
          opacity: shouldShow ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 400),
          child: IgnorePointer(
            ignoring: !shouldShow,
            child: GestureDetector(
              onTap: () => controller.toggleVideoPlayPause(widget.index),
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: shouldShow ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            CustomColor.blueColor.withValues(alpha: 0.95),
                            CustomColor.blueColor.withValues(alpha: 0.85),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 25,
                            spreadRadius: 3,
                            offset: const Offset(0, 5),
                          ),
                          BoxShadow(
                            color: CustomColor.blueColor.withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 42.sp,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
