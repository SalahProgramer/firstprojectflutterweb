import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:fawri_app_refactor/salah/controllers/reels_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/custom_page_controller.dart';
import 'package:fawri_app_refactor/salah/widgets/widgets_pages/cart_widget.dart';
import 'widgets/reels_video_player.dart';
import 'widgets/reels_product_overlay.dart';
import 'widgets/reels_loading_indicator.dart';
import 'widgets/reels_flare_animation.dart';

class ReelsPage extends StatefulWidget {
  const ReelsPage({super.key});

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

// Separate widget to prevent unnecessary rebuilds
class _VideoPageItem extends StatefulWidget {
  final int index;
  final ReelsController controller;
  final Widget Function(int, ReelsController) buildVideoPlayer;

  const _VideoPageItem({
    required this.index,
    required this.controller,
    required this.buildVideoPlayer,
  });

  @override
  State<_VideoPageItem> createState() => _VideoPageItemState();
}

class _VideoPageItemState extends State<_VideoPageItem>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive {
    // Only keep alive if this is the current video or adjacent videos (within 1 index)
    final currentIndex = widget.controller.currentVideoIndex;
    final indexDiff = (widget.index - currentIndex).abs();
    return indexDiff <= 1; // Only keep current and adjacent videos alive
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: widget.buildVideoPlayer(widget.index, widget.controller),
    );
  }
}

class _ReelsPageState extends State<ReelsPage>
    with WidgetsBindingObserver, RouteAware {
  late ReelsController reelsController;
  bool _isPageVisible = false;
  bool _isAppActive = true;
  bool _hasModalRoute = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    reelsController = context.read<ReelsController>();
    
    // Initialize videos when app runs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        reelsController.initializeVideos();
        _updateVideoPlaybackState();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Update page visibility based on bottom navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkPageVisibility();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    reelsController.setPageVisibility(false);
    reelsController.pauseAllVideos();
    super.dispose();
  }

  /// Check if the reels page is currently selected in bottom navigation
  void _checkPageVisibility() {
    try {
      final customPageController = Provider.of<CustomPageController>(
        context,
        listen: false,
      );
      
      // Reels page is at index 1 in bottom navigation
      final shouldBeVisible = customPageController.selectPage == 1;
      
      if (_isPageVisible != shouldBeVisible) {
        _isPageVisible = shouldBeVisible;
        _updateVideoPlaybackState();
      }
    } catch (e) {
      debugPrint('Error checking page visibility: $e');
    }
  }

  /// Check if there's a modal route pushed on top of this page
  void _checkModalRoute() {
    try {
      final navigator = Navigator.maybeOf(context);
      final hasModal = navigator != null && navigator.canPop();
      
      if (_hasModalRoute != hasModal) {
        _hasModalRoute = hasModal;
        _updateVideoPlaybackState();
      }
    } catch (e) {
      debugPrint('Error checking modal route: $e');
    }
  }

  /// Update video playback state based on all conditions
  /// Videos should ONLY play when ALL conditions are true:
  /// 1. App is active (not in background)
  /// 2. Page is visible in bottom navigation
  /// 3. No modal route is pushed on top
  void _updateVideoPlaybackState() {
    if (!mounted) return;

    // Check modal route status
    _checkModalRoute();

    final shouldPlayVideos = _isAppActive && _isPageVisible && !_hasModalRoute;

    debugPrint(
      '🎬 Video State: appActive=$_isAppActive, pageVisible=$_isPageVisible, hasModal=$_hasModalRoute → shouldPlay=$shouldPlayVideos',
    );

    if (shouldPlayVideos) {
      // Only set visibility, but DON'T force play
      // Let the controller handle auto-play based on its own logic
      reelsController.setPageVisibility(true);
    } else {
      // Pause everything when conditions not met
      reelsController.setPageVisibility(false);
      reelsController.pauseAllVideos();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final wasActive = _isAppActive;

    // Update app active state
    if (state == AppLifecycleState.resumed) {
      _isAppActive = true;
      
      // CRITICAL: When resuming, check if modal route exists
      // If there's a modal (like ProductItemView), DON'T allow video play
      _checkModalRoute();
      if (_hasModalRoute) {
        debugPrint('⚠️ App resumed but modal route exists - keeping videos paused');
        reelsController.pauseAllVideos();
        return; // Don't update playback state
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _isAppActive = false;
    }

    // Update video playback if app active state changed
    if (wasActive != _isAppActive) {
      _updateVideoPlaybackState();
    }
  }

  Widget _buildVideoPlayer(int index, ReelsController controller) {
    if (index >= controller.videos.length) return const SizedBox();

    final item = controller.videos[index];
    final isLoading = controller.videoLoadingStates[index] ?? false;

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        // Video fills the entire screen
        ReelsVideoPlayer(index: index, controller: controller, item: item),

        // Top stack - IconCart
        Align(
          alignment: Alignment.topLeft,
          child: SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: IconCart(colorIcon: Colors.white),
            ),
          ),
        ),
        // Bottom stack - Product info and action buttons
        if (!isLoading)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: 0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Account for bottom navigation bar (42.h) + floating action button space (~30.h) + safe area
                final bottomPadding =
                    68.h + 30.h + MediaQuery.of(context).padding.bottom;
                return Padding(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: ReelsProductOverlay(
                    index: index,
                    controller: controller,
                    item: item,
                  ),
                );
              },
            ),
          ),

        // Flare animation overlay - only render for current video to avoid artboard conflicts
        // Use a key based on index to ensure proper disposal when switching videos
        if (index == controller.currentVideoIndex)
          Opacity(
            opacity: controller.showFlareAnimation ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !controller.showFlareAnimation,
              child: ReelsFlareAnimation(
                key: ValueKey('flare_$index'),
                flareControls: controller.flareControls,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to page controller changes to detect page switches
    return Consumer<CustomPageController>(
      builder: (context, customPageController, _) {
        // Update page visibility when bottom navigation changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _checkPageVisibility();
          }
        });

        return Consumer<ReelsController>(
          builder: (context, controller, child) {
            if (controller.videos.isEmpty && controller.isLoading) {
              return const Scaffold(
                backgroundColor: Colors.black,
                body: ReelsLoadingIndicator(),
              );
            }

            if (controller.videos.isEmpty) {
              return Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: Text(
                    'No videos available',
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                ),
              );
            }

            return Scaffold(
              backgroundColor: Colors.black,
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
              ),
              body: PageView.builder(
                controller: controller.pageController,
                scrollDirection: Axis.vertical,
                itemCount:
                    controller.videos.length + (controller.hasMore ? 1 : 0),
                onPageChanged: (index) {
                  try {
                    controller.onPageChanged(index);
                  } catch (e) {
                    debugPrint('Error in onPageChanged callback: $e');
                  }
                },
                itemBuilder: (context, index) {
                  if (index >= controller.videos.length) {
                    return const ReelsLoadingIndicator();
                  }

                  // Use AutomaticKeepAliveClientMixin to prevent rebuilding
                  // But only keep alive current and adjacent videos
                  return _VideoPageItem(
                    index: index,
                    controller: controller,
                    buildVideoPlayer: _buildVideoPlayer,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
