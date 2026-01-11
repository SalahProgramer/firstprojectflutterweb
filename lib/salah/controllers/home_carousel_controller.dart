import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../models/items/item_model.dart';
import '../utilities/global/app_global.dart';
import 'APIS/api_page_main_controller.dart';
class HomeCarouselController extends ChangeNotifier {
  // Independent video list - separate from ReelsController
  final List<Item> videos = [];
  
  // Independent pagination state - separate from ReelsController
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  bool isLoadingMore = false;
  
  // Separate video controllers for home carousel - completely independent from ReelsController
  final Map<int, VideoPlayerController?> videoControllers = {};
  final Map<int, bool> videoLoadingStates = {};
  
  // Home carousel specific state - not shared with ReelsController
  int homeCarouselVisibleIndex = 0;
  
  // Range of controllers to keep around visible index (reduces memory usage)
  static const int _controllerRange = 5; // Keep 5 controllers on each side

  /// Normalizes and cleans video URLs, removing duplicate protocols and fixing malformed URLs
  String _normalizeVideoUrl(String url) {
    if (url.isEmpty) return url;

    String normalized = url.trim();

    // Handle duplicate protocols
    while (true) {
      final before = normalized;

      if (normalized.toLowerCase().startsWith('https:///')) {
        normalized = 'https://${normalized.substring(9)}';
      } else if (normalized.toLowerCase().startsWith('http:///')) {
        normalized = 'http://${normalized.substring(8)}';
      } else if (normalized.toLowerCase().startsWith('https://http://')) {
        normalized = 'https://${normalized.substring(14)}';
      } else if (normalized.toLowerCase().startsWith('http://https://')) {
        normalized = 'https://${normalized.substring(13)}';
      } else if (normalized.toLowerCase().startsWith('http://http://')) {
        normalized = 'http://${normalized.substring(13)}';
      } else if (normalized.toLowerCase().startsWith('https://https://')) {
        normalized = 'https://${normalized.substring(15)}';
      }

      if (before == normalized) break;
    }

    // Ensure URL starts with a protocol
    if (!normalized.toLowerCase().startsWith('http://') &&
        !normalized.toLowerCase().startsWith('https://')) {
      if (normalized.contains('://')) {
        final parts = normalized.split('://');
        if (parts.length > 2) {
          normalized = 'https://${parts.last}';
        } else if (parts.length == 2) {
          final protocol = parts[0].toLowerCase();
          if (protocol == 'http' || protocol == 'https') {
            normalized = '$protocol://${parts[1]}';
          } else {
            normalized = 'https://${parts[1]}';
          }
        }
      } else {
        if (normalized.startsWith('/')) {
          normalized = normalized.substring(1);
        }
        normalized = 'https://$normalized';
      }
    }

    return normalized;
  }

  /// Initialize videos for home carousel
  void initializeVideosForHome() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadVideosForHome();
    });
  }

  /// Load videos for home carousel - lighter version without heavy validation
  /// This method is completely independent from ReelsController.loadVideos()
  /// Both controllers can load videos simultaneously without conflicts
  Future<void> loadVideosForHome() async {
    if (isLoading || isLoadingMore || !hasMore) return;

    try {
      if (videos.isEmpty) {
        isLoading = true;
      } else {
        isLoadingMore = true;
      }
      notifyListeners();

      // Use independent API call - separate from ReelsController
      // Both controllers can call this simultaneously with their own currentPage
      final apiController = NavigatorApp.context.read<ApiPageMainController>();
      final result = await apiController.apiGetVideos(currentPage);

      await result.fold(
        (failure) async {
          isLoading = false;
          isLoadingMore = false;
          notifyListeners();
        },
        (items) async {
          if (items.isEmpty) {
            hasMore = false;
          } else {
            try {
              // Simple validation - just check for video URL
              final validVideos = items.where((item) {
                final videoUrl = item.videoUrl?.toString() ?? '';
                return videoUrl.isNotEmpty;
              }).toList();

              if (validVideos.isNotEmpty) {
                videos.addAll(validVideos);
                currentPage++;
              } else {
                if (currentPage < 10) {
                  currentPage++;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    loadVideosForHome();
                  });
                } else {
                  hasMore = false;
                }
              }
            } catch (e, stack) {
              debugPrint('❌ Error adding videos for home: $e');
              debugPrint('Stack: $stack');
            }
          }
          isLoading = false;
          isLoadingMore = false;
          notifyListeners();
        },
      );
    } catch (e, stack) {
      debugPrint('❌ Critical error in loadVideosForHome: $e');
      debugPrint('Stack: $stack');
      isLoading = false;
      isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Refresh videos for home carousel - reset and reload from beginning
  Future<void> refreshVideosForHome() async {
    // Reset state
    currentPage = 1;
    hasMore = true;
    isLoading = false;
    isLoadingMore = false;
    homeCarouselVisibleIndex = 0;

    // Dispose all video controllers
    for (var entry in videoControllers.entries) {
      try {
        entry.value?.dispose();
      } catch (e) {
        debugPrint('Error disposing video controller at index ${entry.key}: $e');
      }
    }
    videoControllers.clear();
    videoLoadingStates.clear();

    // Clear videos
    videos.clear();
    notifyListeners();

    // Reload videos
    await loadVideosForHome();
  }

  /// Initialize video controller for home carousel
  void initializeVideoControllerForHome(int index, {bool mute = true, bool autoPlay = false}) {
    if (index < 0 || index >= videos.length) return;

    // Skip if already initialized
    if (videoControllers[index] != null) return;

    final item = videos[index];
    var videoUrl = item.videoUrl?.toString() ?? '';

    if (videoUrl.isEmpty) return;

    // Normalize the URL to fix malformed URLs
    videoUrl = _normalizeVideoUrl(videoUrl);

    final isVimeo = videoUrl.contains("vimeo.com");
    final isMp4 =
        videoUrl.endsWith(".mp4") || videoUrl.contains("ltwebstatic.com");
    final isWebm = videoUrl.endsWith(".webm");

    if ((isMp4 || isWebm) && !isVimeo) {
      try {
        videoLoadingStates[index] = true;
        notifyListeners();

        videoControllers[index] =
            VideoPlayerController.networkUrl(Uri.parse(videoUrl))
              ..initialize()
                  .then((_) {
                    if (NavigatorApp.context.mounted &&
                        videoControllers[index] != null &&
                        index < videos.length) {
                      videoControllers[index]!
                        ..setLooping(true)
                        ..setVolume(mute ? 0.0 : 1.0); // Mute for home page
                      videoLoadingStates[index] = false;
                      notifyListeners();
                      
                      // Auto-play video if requested (for visible videos on Android)
                      // This ensures videos start playing immediately after initialization
                      if (autoPlay) {
                        // Use a small delay to ensure the controller is fully ready
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (NavigatorApp.context.mounted &&
                              videoControllers[index] != null &&
                              videoControllers[index]!.value.isInitialized &&
                              !videoControllers[index]!.value.isPlaying) {
                            try {
                              videoControllers[index]?.play();
                            } catch (e) {
                              debugPrint('Error auto-playing video at index $index: $e');
                            }
                          }
                        });
                      }
                    }
                  })
                  .catchError((e) {
                    debugPrint('Error initializing video controller for home: $e');
                    if (NavigatorApp.context.mounted && index < videos.length) {
                      videoLoadingStates[index] = false;
                      notifyListeners();
                    }
                  });
      } catch (e) {
        debugPrint('Error creating video controller for home: $e');
        if (NavigatorApp.context.mounted && index < videos.length) {
          videoLoadingStates[index] = false;
          notifyListeners();
        }
      }
    }
  }

  /// Dispose controllers outside the visible range to prevent memory issues
  void _disposeControllersOutsideRange(int centerIndex) {
    final keepStart = (centerIndex - _controllerRange).clamp(0, videos.length);
    final keepEnd = (centerIndex + _controllerRange + 1).clamp(0, videos.length);

    // Dispose video controllers outside range
    final keysToRemove = <int>[];
    for (var key in videoControllers.keys) {
      if (key < keepStart || key >= keepEnd) {
        try {
          videoControllers[key]?.dispose();
        } catch (e) {
          debugPrint('Error disposing video controller at index $key: $e');
        }
        keysToRemove.add(key);
      }
    }
    for (var key in keysToRemove) {
      videoControllers.remove(key);
      videoLoadingStates.remove(key);
    }
  }

  /// Update visible index for home carousel and cleanup controllers outside range
  void updateHomeCarouselVisibleIndex(int newIndex) {
    if (newIndex == homeCarouselVisibleIndex || newIndex < 0 || newIndex >= videos.length) {
      return;
    }

    // Dispose controllers outside range BEFORE updating index
    _disposeControllersOutsideRange(newIndex);

    homeCarouselVisibleIndex = newIndex;
    notifyListeners();
  }

  /// Initialize video controllers near the visible index (lazy loading)
  void initializeControllersNearVisibleIndex() {
    if (videos.isEmpty) return;

    final startIndex = (homeCarouselVisibleIndex - _controllerRange).clamp(0, videos.length);
    final endIndex = (homeCarouselVisibleIndex + _controllerRange + 1).clamp(0, videos.length);

    // Only initialize controllers within range
    // Auto-play videos that are at or near the visible index
    for (int index = startIndex; index < endIndex; index++) {
      if (!videoControllers.containsKey(index) || videoControllers[index] == null) {
        // Auto-play if this is the visible index or very close to it
        final shouldAutoPlay = (index - homeCarouselVisibleIndex).abs() <= 1;
        initializeVideoControllerForHome(index, mute: true, autoPlay: shouldAutoPlay);
      }
    }
  }



  /// Dispose all resources
  @override
  void dispose() {
    // Dispose all video controllers
    for (var entry in videoControllers.entries) {
      try {
        entry.value?.dispose();
      } catch (e) {
        debugPrint('Error disposing video controller at index ${entry.key}: $e');
      }
    }
    videoControllers.clear();
    videoLoadingStates.clear();
    super.dispose();
  }
}

