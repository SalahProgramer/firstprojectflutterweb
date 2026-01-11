import 'package:fawri_app_refactor/salah/widgets/widgets_main_screen/titles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:vibration/vibration.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import '../../controllers/home_carousel_controller.dart';
import '../../controllers/favourite_controller.dart';
import '../../controllers/page_main_screen_controller.dart';
import '../../controllers/product_item_controller.dart';
import '../../controllers/APIS/api_product_item.dart';
import '../../models/items/item_model.dart';
import '../../utilities/style/colors.dart';
import '../../utilities/style/text_style.dart';
import '../../utilities/global/app_global.dart';
import '../../../services/analytics/analytics_service.dart';
import '../../views/pages/home/main_screen/product_item_view.dart';
import '../custom_image.dart';
import '../custom_shimmer.dart';
import '../custom_text.dart';

class HomeVideoReelsCarousel extends StatefulWidget {
  const HomeVideoReelsCarousel({super.key});

  @override
  State<HomeVideoReelsCarousel> createState() => _HomeVideoReelsCarouselState();
}

class _HomeVideoReelsCarouselState extends State<HomeVideoReelsCarousel> {
  final ScrollController _scrollController = ScrollController();
  int _previousVideosLength = 0;
  Set<int> _visibleIndices = {}; // Track which video indices are visible on screen
  bool _videosPausedByUser = false; // Track if videos were paused by user interaction

  @override
  void initState() {
    super.initState();
    // Initialize videos for home carousel if not already initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final controller = context.read<HomeCarouselController>();
        if (controller.videos.isEmpty && !controller.isLoading) {
          controller.initializeVideosForHome();
        }
      }
    });

    // Listen to scroll to detect which videos are currently visible
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!mounted || !_scrollController.hasClients) return;

    final controller = context.read<HomeCarouselController>();
    if (controller.videos.isEmpty) return;

    // User is scrolling - allow videos to play again
    _videosPausedByUser = false;

    // Card width (0.45.sw) + left margin (6.w)
    final itemWidth = 0.45.sw + 6.w;
    final scrollOffset = _scrollController.offset;
    // Get viewport width
    final viewportWidth = _scrollController.position.viewportDimension;
    // Account for ListView padding (4.w on left)
    final padding = 4.w;
    
    // Calculate viewport bounds (left and right edges)
    final viewportLeft = scrollOffset + padding;
    final viewportRight = scrollOffset + viewportWidth - padding;
    
    // Calculate which items are visible within the viewport
    final newVisibleIndices = <int>{};
    for (int i = 0; i < controller.videos.length; i++) {
      final itemLeft = i * itemWidth;
      final itemRight = itemLeft + 0.45.sw; // Card width
      
      // Check if item overlaps with viewport (with some margin for partial visibility)
      if (itemRight >= viewportLeft && itemLeft <= viewportRight) {
        newVisibleIndices.add(i);
      }
    }

    // Update visible indices and pause/play videos accordingly
    if (newVisibleIndices != _visibleIndices) {
      _visibleIndices = newVisibleIndices;
      _updateVideoPlayback(controller);
    }

    // Calculate center index for controller tracking
    final viewportCenter = scrollOffset + (viewportWidth / 2);
    final adjustedCenter = viewportCenter - padding;
    final newIndex = (adjustedCenter / itemWidth).floor().clamp(0, controller.videos.length - 1);

    // Update visible index through controller (this will dispose controllers outside range)
    if (newIndex != controller.homeCarouselVisibleIndex) {
      controller.updateHomeCarouselVisibleIndex(newIndex);
      // Initialize controllers near the new visible index
      controller.initializeControllersNearVisibleIndex();
    }

    // Load more videos when scrolling near the end (for home carousel)
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final scrollPercentage = currentScroll / (maxScrollExtent > 0 ? maxScrollExtent : 1);
    
    // Load more when scrolled 80% or more, and we're near the end of current videos
    if (scrollPercentage >= 0.8 && 
        newIndex >= controller.videos.length - 3 &&
        controller.hasMore &&
        !controller.isLoading &&
        !controller.isLoadingMore) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && controller.hasMore && !controller.isLoading && !controller.isLoadingMore) {
          controller.loadVideosForHome();
        }
      });
    }
  }

  void _updateVideoPlayback(HomeCarouselController controller) {
    // Only update playback if videos are not paused by user
    if (_videosPausedByUser) return;
    
    // Pause videos that are no longer visible
    for (int i = 0; i < controller.videos.length; i++) {
      final videoController = controller.videoControllers[i];
      if (videoController != null && videoController.value.isInitialized) {
        if (_visibleIndices.contains(i)) {
          // Video is visible - ensure it's playing
          if (!videoController.value.isPlaying) {
            videoController.play();
          }
        } else {
          // Video is not visible - pause it
          if (videoController.value.isPlaying) {
            videoController.pause();
          }
        }
      }
    }
  }

  void _pauseAllVideos(HomeCarouselController controller) {
    // Pause all videos when user interacts and set flag
    _videosPausedByUser = true;
    for (int i = 0; i < controller.videos.length; i++) {
      final videoController = controller.videoControllers[i];
      if (videoController != null && videoController.value.isInitialized && videoController.value.isPlaying) {
        videoController.pause();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeCarouselController>(
      builder: (context, controller, child) {
        // Reset scroll position if videos were refreshed (length went from >0 to 0 and back)
        if (_previousVideosLength > 0 && controller.videos.isEmpty && !controller.isLoading) {
          // Videos were cleared (refresh happened)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _scrollController.hasClients) {
              _scrollController.jumpTo(0);
            }
          });
        }
        
        // Initialize controllers near visible index when videos are first loaded
        if (_previousVideosLength == 0 && 
            controller.videos.isNotEmpty && 
            !controller.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              controller.initializeControllersNearVisibleIndex();
              // Calculate initial visible indices
              if (_scrollController.hasClients) {
                _onScroll();
              }
            }
          });
        }
        
        // Calculate visible indices on first build
        if (_visibleIndices.isEmpty && controller.videos.isNotEmpty && _scrollController.hasClients) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _scrollController.hasClients) {
              _onScroll();
            }
          });
        }
        
        _previousVideosLength = controller.videos.length;

        if (controller.videos.isEmpty && controller.isLoading) {
          return SizedBox(
            height: 250.h,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (controller.videos.isEmpty) {
          return const SizedBox.shrink();
        }

        // Show all available videos (pagination will load more as needed)
        final videosToShow = controller.videos;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Titles(text: "اكتشف الفيديوهات", showEven: 0, flag: 1),
            SizedBox(height: 5.h),
            SizedBox(
              height: 200.h,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                physics: const ClampingScrollPhysics(),
                itemCount: videosToShow.length,
                itemBuilder: (context, index) {
                  final item = videosToShow[index];
                  return _VideoCard(
                    index: index,
                    item: item,
                    controller: controller,
                    isVisible: _visibleIndices.contains(index),
                    isPausedByUser: _videosPausedByUser,
                    onTap: () => _pauseAllVideos(controller),
                  );
                },
              ),
            ),
            SizedBox(height: 7.h),
          ],
        );
      },
    );
  }
}

class _VideoCard extends StatefulWidget {
  final int index;
  final Item item;
  final HomeCarouselController controller;
  final bool isVisible;
  final bool isPausedByUser;
  final VoidCallback onTap;

  const _VideoCard({
    required this.index,
    required this.item,
    required this.controller,
    required this.isVisible,
    required this.isPausedByUser,
    required this.onTap,
  });

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  VideoPlayerController? _currentVideoController;
  VoidCallback? _videoListener;

  @override
  void initState() {
    super.initState();
    // Initialize video controller for this index when card is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.controller.videos.length > widget.index) {
        _initializeVideoController();
        _setupVideoListener();
        // Play video if visible
        if (widget.isVisible) {
          _playVideoIfReady();
        }
      }
    });
  }

  void _setupVideoListener() {
    // Remove old listener if exists
    _removeVideoListener();
    
    // Get current video controller
    final videoController = widget.controller.videoControllers[widget.index];
    if (videoController != null) {
      _currentVideoController = videoController;
      
      // Add listener to auto-play when video becomes initialized
      _videoListener = () {
        if (!mounted) return;
        
        final controller = widget.controller.videoControllers[widget.index];
        if (controller != null && 
            controller.value.isInitialized && 
            widget.isVisible && 
            !widget.isPausedByUser &&
            !controller.value.isPlaying) {
          // Video is initialized and visible - play it
          try {
            controller.play();
          } catch (e) {
            debugPrint('Error auto-playing video from listener: $e');
          }
        }
      };
      
      videoController.addListener(_videoListener!);
    }
  }

  void _removeVideoListener() {
    if (_currentVideoController != null && _videoListener != null) {
      try {
        _currentVideoController!.removeListener(_videoListener!);
      } catch (e) {
        debugPrint('Error removing video listener: $e');
      }
    }
    _currentVideoController = null;
    _videoListener = null;
  }

  void _initializeVideoController() {
    if (widget.index >= widget.controller.videos.length) return;

    // Skip if already initialized
    if (widget.controller.videoControllers.containsKey(widget.index) &&
        widget.controller.videoControllers[widget.index] != null) {
      // If already initialized and visible, play it
      if (widget.isVisible) {
        _playVideoIfReady();
      }
      return;
    }

    // Only initialize if within range of visible index (lazy loading)
    // Android uses smaller range (3), iOS uses larger (5)
    final visibleIndex = widget.controller.homeCarouselVisibleIndex;
    final range = 3; // Use smaller range for safety (Android needs less)
    if (widget.index >= visibleIndex - range && widget.index <= visibleIndex + range) {
      // Use the controller's method for initializing home page videos (muted)
      // Pass autoPlay=true if visible to ensure videos play on Android
      widget.controller.initializeVideoControllerForHome(
        widget.index,
        mute: true,
        autoPlay: widget.isVisible, // Auto-play if visible
      );

      // Setup listener for when video becomes initialized
      _setupVideoListener();

      // Also try to play video if visible (with a delay to ensure initialization)
      // This provides a fallback in case autoPlay doesn't work
      if (widget.isVisible) {
        _playVideoIfReady();
      }
    }
  }

  void _playVideoIfReady() {
    if (!widget.isVisible || widget.isPausedByUser) return; // Don't play if not visible or paused by user
    
    // Try to play immediately if controller is ready
    final videoController = widget.controller.videoControllers[widget.index];
    if (videoController != null && videoController.value.isInitialized) {
      if (!videoController.value.isPlaying) {
        try {
          videoController.play();
          return; // Success, no need for delayed retry
        } catch (e) {
          debugPrint('Error playing video immediately: $e');
        }
      } else {
        return; // Already playing
      }
    }
    
    // If not ready, retry with delays (for Android initialization timing)
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted || !widget.isVisible || widget.isPausedByUser) return;
      final videoController = widget.controller.videoControllers[widget.index];
      if (videoController != null && videoController.value.isInitialized) {
        if (!videoController.value.isPlaying) {
          try {
            videoController.play();
          } catch (e) {
            debugPrint('Error playing video after delay: $e');
          }
        }
      } else {
        // Retry after longer delay if not ready (Android may need more time)
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && widget.isVisible && !widget.isPausedByUser) {
            final retryController = widget.controller.videoControllers[widget.index];
            if (retryController != null && retryController.value.isInitialized) {
              if (!retryController.value.isPlaying) {
                try {
                  retryController.play();
                } catch (e) {
                  debugPrint('Error playing video after second delay: $e');
                }
              }
            }
          }
        });
      }
    });
  }

  void _pauseVideoIfPlaying() {
    final videoController = widget.controller.videoControllers[widget.index];
    if (videoController != null && 
        videoController.value.isInitialized && 
        videoController.value.isPlaying) {
      videoController.pause();
    }
  }

  @override
  void didUpdateWidget(_VideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update video listener if controller changed
    if (oldWidget.controller.videoControllers[oldWidget.index] != 
        widget.controller.videoControllers[widget.index]) {
      _setupVideoListener();
    }
    
    // Handle visibility changes - only if not paused by user
    if (oldWidget.isVisible != widget.isVisible && !widget.isPausedByUser) {
      if (widget.isVisible) {
        // Video became visible - play it (only if not paused by user)
        _playVideoIfReady();
      } else {
        // Video is no longer visible - pause it
        _pauseVideoIfPlaying();
      }
    }
    // If videos were paused by user, ensure they stay paused
    if (widget.isPausedByUser && !oldWidget.isPausedByUser) {
      _pauseVideoIfPlaying();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update video listener when dependencies change
    _setupVideoListener();
    // Check visibility when dependencies change - only if not paused by user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (widget.isPausedByUser) {
          // Keep paused if user paused
          _pauseVideoIfPlaying();
        } else if (widget.isVisible) {
          _playVideoIfReady();
        } else {
          _pauseVideoIfPlaying();
        }
      }
    });
  }

  @override
  void dispose() {
    _removeVideoListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoUrl = widget.item.videoUrl?.toString() ?? '';
    final isLoading =
        widget.controller.videoLoadingStates[widget.index] ?? false;
    final hasVideo = videoUrl.isNotEmpty;

    return FutureBuilder<bool>(
      future: _checkFavorite(),
      builder: (context, snapshot) {
        final isFavourite = snapshot.data ?? false;

        final pageMainScreenController = context.read<PageMainScreenController>();
        final productItemController = context.read<ProductItemController>();
        final apiProductItemController = context.read<ApiProductItemController>();

        return InkWell(
          onTap: () async {
            // Pause all videos when user taps on any item
            widget.onTap();
            
            await pageMainScreenController.changePositionScroll(
              widget.item.id.toString(),
              0,
            );
            await productItemController.clearItemsData();
            await apiProductItemController.cancelRequests();

            NavigatorApp.push(
              ProductItemView(
                item: widget.item,
                isFeature: false,
                sizes: '',
                isFlashOrBest: false,
              ),
            );
          },
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          highlightColor: Colors.transparent,
          overlayColor: WidgetStatePropertyAll(Colors.transparent),
          child: Container(
            width: 0.45.sw,
            margin: EdgeInsets.only(left: 6.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: Colors.white,
             
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Video/Image Container - Fixed height for consistency
              Expanded(
                flex: 2,
                child: Padding(
                  padding:  EdgeInsets.all(4.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      topRight: Radius.circular(12.r),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Video or Image
                        if (hasVideo && !isLoading)
                          _buildVideoContent()
                        else if (hasVideo && isLoading)
                          _buildLoadingIndicator()
                        else
                          _buildImageFallback(),

                        // Heart icon (top right)
                        Positioned(
                          top: 8.h,
                          right: 8.w,
                          child: Container(
                            width: 30.w,
                            height: 30.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: InkWell(
                              onTap: () {
                                // Pause all videos when user taps favorite button
                                widget.onTap();
                                _toggleFavorite(isFavourite);
                              },
                              overlayColor: WidgetStatePropertyAll(
                                Colors.transparent,
                              ),
                              child: Icon(
                                FontAwesome.heart,
                                color: isFavourite
                                    ? CustomColor.primaryColor
                                    : Colors.grey,
                                size: 15.h,
                              ),
                            ),
                          ),
                        ),

                        // Video indicator badge (bottom left)
                        if (hasVideo)


                          Positioned(
                            bottom: 8.h,
                            left: 8.w,


                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.play_circle_filled,
                                    color: Colors.white,
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'فيديو',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Product Info at bottom
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(flex: 3,
                        child: Text(
                         widget. item.title ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          strutStyle: StrutStyle(
                            fontSize: 10.sp,
                            fontFamily: 'CrimsonText',
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          style: CustomTextStyle().crimson.copyWith(
                            fontSize: 10.sp,
                            color: Colors.black,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Spacer(),
                      CustomText(
                        fontWeight: FontWeight.bold,
                        fontSize: 9.sp,
                        text: widget.item.newPrice ?? "0",
                        color:
                       Colors.red
                            ,
                        textDecoration: TextDecoration.none,
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
          ),
        );
      },
    );
  }

  Future<bool> _checkFavorite() async {
    final favouriteController = context.read<FavouriteController>();
    return await favouriteController.checkFavouriteItem(
      productId: widget.item.id,
    );
  }

  Future<void> _toggleFavorite(bool isFavourite) async {
    final favouriteController = context.read<FavouriteController>();
    final analyticsService = AnalyticsService();
    final item = widget.item;

    if (!isFavourite) {
      // Add to favorites
      List<String> tags = (item.tags ?? []);

      await favouriteController.insertData(
        id: "${item.id}000",
        variantId: item.variants?.isNotEmpty == true
            ? item.variants![0].id
            : null,
        productId: item.id,
        image: item.vendorImagesLinks?.isNotEmpty == true
            ? item.vendorImagesLinks!.first
            : '',
        title: item.title,
        oldPrice: item.oldPrice.toString(),
        newPrice: item.newPrice,
        tags: '$tags',
      );

      Vibration.vibrate(duration: 100);

      await analyticsService.logAddToWishlist(
        productId: item.id?.toString() ?? "",
        productTitle: item.title ?? "",
        price:
            double.tryParse(item.newPrice?.replaceAll("₪", "") ?? "0") ?? 0.0,
        parameters: {
          "class_name": "HomeVideoReelsCarousel",
          "button_name": "wishlist_heart_icon",
          "product_id": item.id?.toString() ?? "",
          "product_title": item.title ?? "",
          "price":
              (double.tryParse(item.newPrice?.replaceAll("₪", "") ?? "0") ??
                      0.0)
                  .toString(),
          "time": DateTime.now().toString(),
        },
      );
    } else {
      // Remove from favorites
      await favouriteController.deleteItem(productId: item.id);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildVideoContent() {
    final videoController = widget.controller.videoControllers[widget.index];

    if (videoController != null && videoController.value.isInitialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6.r),
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            
            child: SizedBox(
              width: videoController.value.size.width,
              height: videoController.value.size.height,
              child: VideoPlayer(videoController),
            ),
          ),
        ),
      );
    }

    return _buildImageFallback();
  }

  Widget _buildImageFallback() {
    final imageUrl = widget.item.vendorImagesLinks?.isNotEmpty == true
        ? widget.item.vendorImagesLinks!.first
        : '';

    if (imageUrl.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6.r),
        child: Image(
          image: AssetImage(Assets.images.fawri.path),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    return CustomImageSponsored(
      imageUrl: imageUrl,
      boxFit: BoxFit.cover,
      borderRadius: BorderRadius.circular(6.r),
      padding: EdgeInsets.zero,
      borderCircle: 6.r,
    );
  }

  Widget _buildLoadingIndicator() {
    return ShimmerImagePost(
      borderRadius: BorderRadius.circular(6.r),
      width: double.infinity,
      height: double.infinity,
    );
  }
}
