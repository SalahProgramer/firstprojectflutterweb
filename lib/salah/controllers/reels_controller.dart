import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flare_flutter/flare_controls.dart';
import '../models/items/item_model.dart';
import '../utilities/global/app_global.dart';
import 'APIS/api_page_main_controller.dart';
import 'cart_controller.dart';
import 'favourite_controller.dart';
import 'fetch_controller.dart';
import 'APIS/api_product_item.dart';
import '../widgets/snackBarWidgets/snackbar_widget.dart';
import '../widgets/snackBarWidgets/snack_bar_style.dart';
import '../../../dialog/dialogs/dialog_waiting/dialog_waiting.dart';
import '../../../dialog/dialogs/dialogs_cart/dialogs_cart_delete_and_check_available.dart';
import '../../../services/reels_likes/reels_likes_service.dart';

/// Controller for reels page videos - completely independent from HomeCarouselController
/// 
/// IMPORTANT: This controller is COMPLETELY INDEPENDENT from HomeCarouselController:
/// - Separate video list (videos)
/// - Separate pagination state (currentPage, isLoading, hasMore)
/// - Separate video player controllers (videoControllers)
/// - Separate loading states (videoLoadingStates)
/// - Supports Vimeo videos via webViewControllers (not in HomeCarouselController)
/// - Can load videos simultaneously with HomeCarouselController without conflicts
/// 
/// Usage:
/// - Used by: ReelsPage widget
/// - NOT used by: HomeVideoReelsCarousel (uses HomeCarouselController instead)
/// This controller manages:
/// - Reels page video list and pagination (separate from home carousel)
/// - Video player controllers (separate from home carousel)
/// - Vimeo web view controllers
/// - Loading states and error tracking
/// - Page visibility and playback control
class ReelsController extends ChangeNotifier {
  final PageController pageController = PageController();

  // Independent video list - separate from HomeCarouselController
  final List<Item> videos = [];
  
  // Independent pagination state - separate from HomeCarouselController
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  bool isLoadingMore = false;
  
  // Separate video controllers for reels page - completely independent from HomeCarouselController
  final Map<int, VideoPlayerController?> videoControllers = {};

  // Reels page specific controllers (Vimeo support)
  final Map<int, InAppWebViewController?> webViewControllers = {};
  final Map<int, bool> videoLoadingStates = {};
  final Map<int, bool> vimeoVideoErrors = {}; // Track Vimeo video errors
  final Map<int, bool> vimeoVideoPlayingStates =
      {}; // Track Vimeo video playing state
  final Set<String> _failedVideoUrls =
      {}; // Track failed video URLs to prevent re-adding
  final Set<int> _playedVideoIndices =
      {}; // Track which video indices have been played before
  int currentVideoIndex = 0;
  bool isPageVisible =
      false; // Start as false, only set to true when page is actually visible
  bool isProductInfoVisible =
      true; // Shared visibility state for product info box across all videos

  FlareControls flareControls =
      FlareControls(); // Flare animation controls for double tap
  bool showFlareAnimation = false; // Control flare animation visibility
  bool _videosInitialized = false; // Track if videos have been initialized

  // Firebase likes tracking
  final Map<String, int> videoLikeCounts = {}; // Map of videoId -> like count
  final Map<String, StreamSubscription<int>> _likeCountSubscriptions =
      {}; // Stream subscriptions for like counts
  final ReelsLikesService _likesService = ReelsLikesService.instance;

  // Memory management: Keep only controllers for videos within this range
  // Keep only the current video and the direct neighbours alive to reduce load
  static const int _controllerRange =
      1; // Keep controllers for 1 video before and after current

  // Track last cleanup time to prevent excessive cleanup calls
  DateTime? _lastCleanupTime;

  // Auto‑pause timer to avoid very long continuous playback (helps with heating)
  Timer? _autoPauseTimer;
  static const Duration _maxContinuousPlayDuration = Duration(minutes: 3);

  void _cancelAutoPauseTimer() {
    _autoPauseTimer?.cancel();
    _autoPauseTimer = null;
  }

  void _resetAutoPauseTimer() {
    _cancelAutoPauseTimer();
    if (!isPageVisible || videos.isEmpty) return;

    _autoPauseTimer = Timer(_maxContinuousPlayDuration, () {
      try {
        pauseAllVideos();
      } catch (_) {}
      notifyListeners();
    });
  }

  /// Normalizes and cleans video URLs, removing duplicate protocols and fixing malformed URLs
  String _normalizeVideoUrl(String url) {
    if (url.isEmpty) return url;

    // Remove duplicate protocols (e.g., https://http:// -> https://)
    String normalized = url.trim();

    // Handle cases like https://http:// or http://https://
    // Use a more robust approach to handle any combination
    // Remove all duplicate protocol patterns
    while (true) {
      final before = normalized;

      // Handle https:/// (three slashes)
      if (normalized.toLowerCase().startsWith('https:///')) {
        normalized = 'https://${normalized.substring(9)}'; // Remove 'https:///'
      }
      // Handle http:/// (three slashes)
      else if (normalized.toLowerCase().startsWith('http:///')) {
        normalized = 'http://${normalized.substring(8)}'; // Remove 'http:///'
      }
      // Handle https://http://
      else if (normalized.toLowerCase().startsWith('https://http://')) {
        normalized =
            'https://${normalized.substring(14)}'; // Remove 'https://http://'
      }
      // Handle http://https://
      else if (normalized.toLowerCase().startsWith('http://https://')) {
        normalized =
            'https://${normalized.substring(13)}'; // Remove 'http://https://'
      }
      // Handle http://http://
      else if (normalized.toLowerCase().startsWith('http://http://')) {
        normalized =
            'http://${normalized.substring(13)}'; // Remove 'http://http://'
      }
      // Handle https://https://
      else if (normalized.toLowerCase().startsWith('https://https://')) {
        normalized =
            'https://${normalized.substring(15)}'; // Remove 'https://https://'
      }
      // Handle http://http://http:// (triple)
      else if (normalized.toLowerCase().startsWith('http://http://http://')) {
        normalized =
            'http://${normalized.substring(20)}'; // Remove 'http://http://http://'
      }
      // Handle https://https://https:// (triple)
      else if (normalized.toLowerCase().startsWith(
        'https://https://https://',
      )) {
        normalized =
            'https://${normalized.substring(23)}'; // Remove 'https://https://https://'
      }

      // If no change was made, break the loop
      if (before == normalized) break;
    }

    // Ensure URL starts with a protocol
    if (!normalized.toLowerCase().startsWith('http://') &&
        !normalized.toLowerCase().startsWith('https://')) {
      // Try to add https:// if it looks like a URL
      if (normalized.contains('://')) {
        // Already has a protocol but might be malformed, try to fix
        final parts = normalized.split('://');
        if (parts.length > 2) {
          // Multiple :// found, take the last valid part
          normalized = 'https://${parts.last}';
        } else if (parts.length == 2) {
          // Single :// but might be malformed protocol
          final protocol = parts[0].toLowerCase();
          if (protocol == 'http' || protocol == 'https') {
            normalized = '$protocol://${parts[1]}';
          } else {
            normalized = 'https://${parts[1]}';
          }
        }
      } else {
        // No protocol, add https://
        // Remove leading slash if present to avoid https:///
        if (normalized.startsWith('/')) {
          normalized = normalized.substring(1);
        }
        normalized = 'https://$normalized';
      }
    }

    return normalized;
  }

  void initializeVideos() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadVideos();
    });
  }

  /// Load videos for reels page - full version with validation
  /// This method is completely independent from HomeCarouselController.loadVideosForHome()
  /// Both controllers can load videos simultaneously without conflicts
  /// Each controller maintains its own pagination state (currentPage)
  Future<void> loadVideos() async {
    if (isLoading || isLoadingMore || !hasMore) return;

    // Prevent multiple simultaneous loads within this controller only
    // This does not affect HomeCarouselController
    if (isLoading || isLoadingMore) return;

    try {
      if (videos.isEmpty) {
        isLoading = true;
      } else {
        isLoadingMore = true;
      }
      notifyListeners();

      // Use independent API call - separate from HomeCarouselController
      // Both controllers can call this simultaneously with their own currentPage
      final apiController = NavigatorApp.context.read<ApiPageMainController>();
      final result = await apiController.apiGetVideos(currentPage);

      await result.fold(
        (failure) async {
          isLoading = false;
          isLoadingMore = false;
          notifyListeners();
          if (NavigatorApp.context.mounted) {
            ScaffoldMessenger.of(NavigatorApp.context).showSnackBar(
              SnackBar(
                content: Text('Error loading videos: ${failure.message}'),
              ),
            );
          }
        },
        (items) async {
          if (items.isEmpty) {
            hasMore = false;
          } else {
            // Add items safely
            final previousLength = videos.length;
            try {
              // Filter out invalid videos before adding
              final validVideos = _filterValidVideos(items);

              if (validVideos.isEmpty) {
                debugPrint('⚠️ No valid videos in this batch, skipping...');
                // If no valid videos, try next page
                if (currentPage < 10) {
                  // Limit retries
                  currentPage++;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    loadVideos();
                  });
                } else {
                  hasMore = false;
                }
              } else {
                // Pre-validate videos before adding (especially Vimeo)
                final preValidatedVideos = await _preValidateVideos(
                  validVideos,
                );

                videos.addAll(preValidatedVideos);
                currentPage++;

                debugPrint(
                  '✅ Loaded ${preValidatedVideos.length} pre-validated videos (filtered ${validVideos.length - preValidatedVideos.length} invalid). Total: ${videos.length}',
                );

                // Initialize like counts for new videos
                _initializeLikeCountsForVideos(preValidatedVideos);

                // Only initialize controllers for videos near current index
                // This prevents memory issues with large lists
                _initializeControllersForRange();

                // Clean up old controllers (disposes controllers for videos outside visible range)
                // This manages memory while keeping all videos in the list for unlimited scrolling
                _cleanupOldControllers();
              }
            } catch (e, stack) {
              debugPrint('❌ Error adding videos: $e');
              debugPrint('Stack: $stack');
              // Rollback on error
              if (videos.length > previousLength) {
                videos.removeRange(previousLength, videos.length);
              }
            }
          }
          isLoading = false;
          isLoadingMore = false;
          notifyListeners();
        },
      );
    } catch (e, stack) {
      debugPrint('❌ Critical error in loadVideos: $e');
      debugPrint('Stack: $stack');
      isLoading = false;
      isLoadingMore = false;
      notifyListeners();
    }
  }

  List<Item> _filterValidVideos(List<Item> items) {
    final validVideos = <Item>[];

    for (final item in items) {
      var videoUrl = item.videoUrl?.toString() ?? '';

      if (videoUrl.isEmpty) {
        continue; // Skip items without video URL
      }

      // Normalize the URL to fix malformed URLs
      videoUrl = _normalizeVideoUrl(videoUrl);

      // Skip if this video URL has already failed
      if (_failedVideoUrls.contains(videoUrl)) {
        debugPrint('⏭️ Skipping previously failed video: $videoUrl');
        continue;
      }

      final isVimeo = videoUrl.toLowerCase().contains("vimeo.com");
      final isMp4 =
          videoUrl.endsWith(".mp4") || videoUrl.contains("ltwebstatic.com");
      final isWebm = videoUrl.endsWith(".webm");

      if (isVimeo) {
        // Validate Vimeo video ID
        final vimeoId = _extractVimeoId(videoUrl);
        if (vimeoId.isNotEmpty && vimeoId.length >= 5) {
          validVideos.add(item);
          debugPrint('✅ Valid Vimeo video: $vimeoId');
        } else {
          debugPrint('❌ Invalid Vimeo video URL (no valid ID): $videoUrl');
          _failedVideoUrls.add(videoUrl);
        }
      } else if (isMp4) {
        // Validate MP4 URL format
        try {
          final uri = Uri.parse(videoUrl);
          if (uri.hasScheme &&
              (uri.scheme == 'http' || uri.scheme == 'https')) {
            validVideos.add(item);
            debugPrint('✅ Valid MP4 video: $videoUrl');
          } else {
            debugPrint('❌ Invalid MP4 URL format: $videoUrl');
            _failedVideoUrls.add(videoUrl);
          }
        } catch (e) {
          debugPrint('❌ Invalid MP4 URL (parse error): $videoUrl');
          _failedVideoUrls.add(videoUrl);
        }
      } else if (isWebm) {
        // Validate WebM URL format
        try {
          final uri = Uri.parse(videoUrl);
          if (uri.hasScheme &&
              (uri.scheme == 'http' || uri.scheme == 'https')) {
            validVideos.add(item);
            debugPrint('✅ Valid WebM video: $videoUrl');
          } else {
            debugPrint('❌ Invalid WebM URL format: $videoUrl');
            _failedVideoUrls.add(videoUrl);
          }
        } catch (e) {
          debugPrint('❌ Invalid WebM URL (parse error): $videoUrl');
          _failedVideoUrls.add(videoUrl);
        }
      } else {
        debugPrint('❌ Unknown video format: $videoUrl');
        _failedVideoUrls.add(videoUrl);
      }
    }

    return validVideos;
  }

  Future<List<Item>> _preValidateVideos(List<Item> items) async {
    // For faster loading, validate only first few videos immediately
    // Rest will be validated when user scrolls near them
    final validatedVideos = <Item>[];
    final itemsToValidateNow = items
        .take(10)
        .toList(); // Validate first 10 immediately
    final itemsToValidateLater = items
        .skip(10)
        .toList(); // Add rest without validation

    // Validate first batch in parallel
    if (itemsToValidateNow.isNotEmpty) {
      final validationResults = await Future.wait(
        itemsToValidateNow.map((item) => _validateSingleVideo(item)),
      );

      for (int i = 0; i < itemsToValidateNow.length; i++) {
        if (validationResults[i]) {
          validatedVideos.add(itemsToValidateNow[i]);
        }
      }
    }

    // Add rest without validation (will be validated when loading)
    // But still filter out obviously invalid ones
    for (final item in itemsToValidateLater) {
      var videoUrl = item.videoUrl?.toString() ?? '';
      if (videoUrl.isNotEmpty) {
        // Normalize the URL to fix malformed URLs
        videoUrl = _normalizeVideoUrl(videoUrl);

        if (!_failedVideoUrls.contains(videoUrl)) {
          // Basic format check only
          final isVimeo = videoUrl.toLowerCase().contains("vimeo.com");
          if (isVimeo) {
            final vimeoId = _extractVimeoId(videoUrl);
            if (vimeoId.isNotEmpty && vimeoId.length >= 5) {
              validatedVideos.add(item);
            } else {
              _failedVideoUrls.add(videoUrl);
            }
          } else {
            validatedVideos.add(item);
          }
        }
      }
    }

    return validatedVideos;
  }

  Future<bool> _validateSingleVideo(Item item) async {
    var videoUrl = item.videoUrl?.toString() ?? '';
    if (videoUrl.isEmpty) return false;

    // Normalize the URL to fix malformed URLs
    videoUrl = _normalizeVideoUrl(videoUrl);

    // Skip if already failed
    if (_failedVideoUrls.contains(videoUrl)) {
      return false;
    }

    final isVimeo = videoUrl.toLowerCase().contains("vimeo.com");

    if (isVimeo) {
      final vimeoId = _extractVimeoId(videoUrl);
      if (vimeoId.isEmpty || vimeoId.length < 5) {
        _failedVideoUrls.add(videoUrl);
        return false;
      }

      // Quick validation using Vimeo oEmbed API with short timeout
      try {
        final oEmbedUrl =
            'https://vimeo.com/api/oembed.json?url=https://vimeo.com/$vimeoId';
        final response = await http
            .get(Uri.parse(oEmbedUrl))
            .timeout(
              const Duration(seconds: 2), // Short timeout for faster validation
              onTimeout: () {
                // Timeout - assume valid, will be checked when loading
                debugPrint(
                  '⏱️ Timeout validating Vimeo $vimeoId, will check when loading',
                );
                return http.Response('', 200);
              },
            );

        if (response.statusCode == 200 && response.body.isNotEmpty) {
          try {
            final json = jsonDecode(response.body);
            // Check if video exists and is not private/restricted
            if (json['video_id'] != null || json['html'] != null) {
              // Check for error messages in response
              final responseText = response.body.toLowerCase();
              if (responseText.contains('not found') ||
                  responseText.contains('does not exist') ||
                  responseText.contains('private') ||
                  responseText.contains('unavailable')) {
                debugPrint('❌ Vimeo video invalid or restricted: $vimeoId');
                _failedVideoUrls.add(videoUrl);
                return false;
              }
              debugPrint('✅ Pre-validated Vimeo video: $vimeoId');
              return true;
            }
          } catch (e) {
            // Invalid JSON - might be error page
            debugPrint('⚠️ Invalid JSON response for Vimeo $vimeoId');
          }
        } else if (response.statusCode == 404) {
          debugPrint('❌ Vimeo video not found (404): $vimeoId');
          _failedVideoUrls.add(videoUrl);
          return false;
        }

        // If status is not 200 or 404, assume valid (will be checked when loading)
        return true;
      } catch (e) {
        debugPrint('⚠️ Could not pre-validate Vimeo video $vimeoId: $e');
        // Assume valid, will be checked when loading
        return true;
      }
    } else {
      // For MP4 and WebM videos, just validate URL format
      final isMp4 =
          videoUrl.endsWith(".mp4") || videoUrl.contains("ltwebstatic.com");
      final isWebm = videoUrl.endsWith(".webm");

      if (isMp4 || isWebm) {
        try {
          final uri = Uri.parse(videoUrl);
          if (uri.hasScheme &&
              (uri.scheme == 'http' || uri.scheme == 'https')) {
            return true;
          }
        } catch (e) {
          _failedVideoUrls.add(videoUrl);
          return false;
        }
        return true;
      }
      return false;
    }
  }

  String _extractVimeoId(String videoUrl) {
    if (videoUrl.isEmpty) return '';

    // Clean the URL - remove query parameters and fragments
    String cleanUrl = videoUrl.trim();
    cleanUrl = cleanUrl.split('?').first.split('#').first;

    // Try different Vimeo URL patterns
    final patterns = [
      RegExp(
        r'(?:https?://)?(?:www\.)?player\.vimeo\.com/video/(\d+)',
        caseSensitive: false,
      ),
      RegExp(
        r'(?:https?://)?(?:www\.)?vimeo\.com/(?:channels/[^/]+/|groups/[^/]+/videos/|video/)?(\d+)',
        caseSensitive: false,
      ),
      RegExp(r'(?:https?://)?(?:www\.)?vimeo\.com/(\d+)', caseSensitive: false),
      RegExp(r'/videos?/(\d+)', caseSensitive: false),
      RegExp(r'vimeo\.com/(\d+)', caseSensitive: false),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(cleanUrl);
      if (match != null && match.group(1) != null) {
        final id = match.group(1)!.trim();
        // Validate that it's a numeric ID (at least 5 digits for Vimeo)
        if (RegExp(r'^\d{5,}$').hasMatch(id)) {
          return id;
        }
      }
    }

    // If no pattern matches, try to extract any number sequence
    final numberMatch = RegExp(r'\d{5,}').firstMatch(cleanUrl);
    if (numberMatch != null) {
      return numberMatch.group(0)!;
    }

    return '';
  }

  void _initializeControllersForRange() {
    // Only initialize controllers for videos within range of current index
    final startIndex = (currentVideoIndex - _controllerRange).clamp(
      0,
      videos.length,
    );
    final endIndex = (currentVideoIndex + _controllerRange + 1).clamp(
      0,
      videos.length,
    );

    // Pre-validate videos in range before initializing
    for (int i = startIndex; i < endIndex; i++) {
      if (i < videos.length) {
        final item = videos[i];
        var videoUrl = item.videoUrl?.toString() ?? '';

        // Normalize the URL to fix malformed URLs
        videoUrl = _normalizeVideoUrl(videoUrl);

        // Skip if video URL is in failed list
        if (_failedVideoUrls.contains(videoUrl)) {
          // Remove invalid video immediately
          _removeInvalidVideo(i);
          continue;
        }

        // For Vimeo videos, do quick validation
        if (videoUrl.toLowerCase().contains("vimeo.com")) {
          final vimeoId = _extractVimeoId(videoUrl);
          if (vimeoId.isEmpty || vimeoId.length < 5) {
            _removeInvalidVideo(i);
            continue;
          }
        }

        // Initialize controller if not already initialized
        if (!videoControllers.containsKey(i) || videoControllers[i] == null) {
          initializeVideoController(i);
        }
      }
    }
  }

  void _removeInvalidVideo(int index) {
    if (index < 0 || index >= videos.length) return;

    try {
      var videoUrl = videos[index].videoUrl?.toString() ?? '';
      debugPrint(
        '🗑️ Removing invalid video at index $index before user sees it: $videoUrl',
      );

      if (videoUrl.isNotEmpty) {
        // Normalize the URL before adding to failed list
        videoUrl = _normalizeVideoUrl(videoUrl);
        _failedVideoUrls.add(videoUrl);
      }

      // Dispose controllers
      videoControllers[index]?.dispose();
      videoControllers.remove(index);

      try {
        webViewControllers[index]?.dispose();
      } catch (e) {
        // Ignore
      }
      webViewControllers.remove(index);

      videoLoadingStates.remove(index);
      vimeoVideoErrors.remove(index);

      // Store previous index for PageView update
      final previousIndex = currentVideoIndex;

      // Remove from list
      videos.removeAt(index);

      // Adjust current index
      if (videos.isEmpty) {
        currentVideoIndex = 0;
      } else if (currentVideoIndex >= videos.length) {
        currentVideoIndex = videos.length - 1;
      } else if (currentVideoIndex > index) {
        currentVideoIndex--;
      }

      // Rebuild maps
      _rebuildControllerMapsAfterRemoval(index);

      // Update PageView controller if index changed and it's near current position
      // Only update if the removed video was before or at current position
      if (index <= previousIndex && pageController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (pageController.hasClients && currentVideoIndex != previousIndex) {
            try {
              // Animate to new position smoothly
              pageController.animateToPage(
                currentVideoIndex,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              );
            } catch (e) {
              debugPrint('Error updating PageView position after removal: $e');
            }
          }
        });
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error removing invalid video: $e');
    }
  }

  void _disposeControllersOutsideRange(int centerIndex) {
    // Dispose controllers that are outside the range around centerIndex
    final keepStart = (centerIndex - _controllerRange).clamp(0, videos.length);
    final keepEnd = (centerIndex + _controllerRange + 1).clamp(
      0,
      videos.length,
    );

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
      vimeoVideoErrors.remove(key);
    }

    // Dispose web view controllers outside range
    final webKeysToRemove = <int>[];
    for (var key in webViewControllers.keys) {
      if (key < keepStart || key >= keepEnd) {
        try {
          webViewControllers[key]?.dispose();
        } catch (e) {
          debugPrint('Error disposing web view controller at index $key: $e');
        }
        webKeysToRemove.add(key);
      }
    }
    for (var key in webKeysToRemove) {
      webViewControllers.remove(key);
    }
  }

  void _cleanupOldControllers() {
    // Always dispose controllers outside the current range
    // This manages memory by disposing video controllers for videos far from current position
    // while keeping all videos in the list for continuous scrolling
    _disposeControllersOutsideRange(currentVideoIndex);

    // Note: We no longer remove videos from the list to allow unlimited scrolling
    // Memory is managed by disposing controllers for videos outside the visible range
  }

  void initializeVideoController(int index) {
    if (index < 0 || index >= videos.length) return;

    // Skip if already initialized
    if (videoControllers[index] != null) return;

    // Don't initialize if too far from current index (memory optimization)
    final distance = (index - currentVideoIndex).abs();
    if (distance > _controllerRange) {
      return;
    }

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
                        ..setVolume(1.0);
                      videoLoadingStates[index] = false;
                      notifyListeners();
                      // Auto-play if it's the current video
                      if (index == currentVideoIndex && isPageVisible) {
                        videoControllers[index]?.play();
                        _playedVideoIndices.add(index); // Mark as played
                      }
                    }
                  })
                  .catchError((e) {
                    debugPrint('Error initializing video controller: $e');
                    if (NavigatorApp.context.mounted && index < videos.length) {
                      videoLoadingStates[index] = false;
                      notifyListeners();
                    }
                  });
      } catch (e) {
        debugPrint('Error creating video controller: $e');
        videoLoadingStates[index] = false;
        notifyListeners();
      }
    }
  }

  void onPageChanged(int index) {
    if (index < 0 || index >= videos.length + (hasMore ? 1 : 0)) return;

    try {
      // Hide flare animation when scrolling to new video
      showFlareAnimation = false;

      // Reset FlareControls to prevent artboard mismatch when switching videos
      // This ensures the new FlareActor can properly initialize with a fresh FlareControls
      if (index != currentVideoIndex) {
        flareControls = FlareControls();
      }

      notifyListeners();

      // Aggressively dispose controllers outside the new range BEFORE changing index
      _disposeControllersOutsideRange(index);

      // Pause previous video
      if (currentVideoIndex < videos.length) {
        pauseVideoAtIndex(currentVideoIndex);
      }

      // Validate current video before setting index
      if (index < videos.length) {
        final item = videos[index];
        var videoUrl = item.videoUrl?.toString() ?? '';

        // Normalize the URL to fix malformed URLs
        videoUrl = _normalizeVideoUrl(videoUrl);

        // Check if video is in failed list
        if (_failedVideoUrls.contains(videoUrl)) {
          debugPrint(
            '⏭️ Skipping failed video at index $index, moving to next',
          );
          _removeInvalidVideo(index);

          // If video was removed, adjust index
          if (index >= videos.length && videos.isNotEmpty) {
            index = videos.length - 1;
          } else if (index < videos.length) {
            // Video still exists, try next one
            if (index + 1 < videos.length) {
              index = index + 1;
            } else if (index > 0) {
              index = index - 1;
            }
          }

          // If no videos left, try to load more
          if (videos.isEmpty && hasMore && !isLoading && !isLoadingMore) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              loadVideos();
            });
            return;
          }
        }
      }

      currentVideoIndex = index;

      // Clean up controllers outside range first
      _disposeControllersOutsideRange(index);

      // Initialize controllers for new range (this will also validate videos)
      _initializeControllersForRange();

      // Play current video only if page is visible and index is valid
      if (isPageVisible && index < videos.length) {
        final item = videos[index];
        var videoUrl = item.videoUrl?.toString() ?? '';

        if (videoUrl.isNotEmpty) {
          // Normalize the URL to fix malformed URLs
          videoUrl = _normalizeVideoUrl(videoUrl);

          final isVimeo = videoUrl.contains("vimeo.com");
          final isMp4 =
              videoUrl.endsWith(".mp4") || videoUrl.contains("ltwebstatic.com");
          final isWebm = videoUrl.endsWith(".webm");

          // Check if this video has been played before - if so, restart from beginning
          final hasBeenPlayed = _playedVideoIndices.contains(index);

          if ((isMp4 || isWebm) &&
              !isVimeo &&
              videoControllers[index] != null) {
            // If video has been played before, seek to beginning before playing
            if (hasBeenPlayed) {
              try {
                videoControllers[index]?.seekTo(Duration.zero);
              } catch (e) {
                debugPrint('Error seeking video to beginning: $e');
              }
            }
            videoControllers[index]?.play();
            _playedVideoIndices.add(index); // Mark as played
            _resetAutoPauseTimer();
            // Notify listeners after a brief delay to ensure video player state is updated
            Future.delayed(const Duration(milliseconds: 100), () {
              notifyListeners();
            });
          } else if (isVimeo) {
            // For Vimeo videos, seek to beginning if played before
            if (hasBeenPlayed && webViewControllers[index] != null) {
              try {
                webViewControllers[index]?.evaluateJavascript(
                  source: '''
                  (function() {
                    try {
                      var iframe = document.querySelector('iframe');
                      if (iframe && iframe.contentWindow) {
                        iframe.contentWindow.postMessage('{"method":"seekTo","value":0}', '*');
                      }
                    } catch(e) {}
                  })();
                ''',
                );
              } catch (e) {
                debugPrint('Error seeking Vimeo video to beginning: $e');
              }
            }
            // Mark Vimeo video as playing
            vimeoVideoPlayingStates[index] = true;
            _playedVideoIndices.add(index); // Mark as played
            _resetAutoPauseTimer();
            notifyListeners();
          }
        }
      }

      // Load more videos when approaching the end (around 25 items threshold)
      if (index >= videos.length - 5 &&
          hasMore &&
          !isLoading &&
          !isLoadingMore) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (hasMore && !isLoading && !isLoadingMore) {
            loadVideos();
          }
        });
      }

      // Periodic cleanup to prevent memory buildup
      final now = DateTime.now();
      if (_lastCleanupTime == null ||
          now.difference(_lastCleanupTime!).inSeconds > 5) {
        _lastCleanupTime = now;
        _cleanupOldControllers();
      }
    } catch (e) {
      debugPrint('Error in onPageChanged: $e');
    }
  }

  void pauseVideoAtIndex(int index) {
    if (index < 0 || index >= videos.length) return;

    // Pause MP4 video
    if (videoControllers[index] != null &&
        videoControllers[index]!.value.isInitialized) {
      try {
        videoControllers[index]?.pause();
        // Immediately notify to update UI state
        notifyListeners();
      } catch (e) {
        debugPrint('Error pausing video: $e');
      }
    }

    // Pause Vimeo video
    if (webViewControllers[index] != null) {
      try {
        webViewControllers[index]?.evaluateJavascript(
          source: '''
          (function() {
            try {
              var iframe = document.querySelector('iframe');
              if (iframe && iframe.contentWindow) {
                iframe.contentWindow.postMessage('{"method":"pause"}', '*');
              }
            } catch(e) {}
          })();
        ''',
        );
        vimeoVideoPlayingStates[index] = false;
        notifyListeners();
      } catch (e) {
        // Ignore errors
      }
    }

    // If video is far from current index, dispose it to free memory
    final distance = (index - currentVideoIndex).abs();
    if (distance > _controllerRange) {
      _disposeVideoAtIndex(index);
    }
  }

  void resumeVideoAtIndex(int index) {
    if (index < 0 || index >= videos.length) return;

    final item = videos[index];
    var videoUrl = item.videoUrl?.toString() ?? '';
    if (videoUrl.isEmpty) return;

    videoUrl = _normalizeVideoUrl(videoUrl);
    final isVimeo = videoUrl.contains("vimeo.com");
    final isMp4 =
        videoUrl.endsWith(".mp4") || videoUrl.contains("ltwebstatic.com");
    final isWebm = videoUrl.endsWith(".webm");

    // Resume MP4/WebM video
    if ((isMp4 || isWebm) &&
        !isVimeo &&
        videoControllers[index] != null &&
        videoControllers[index]!.value.isInitialized) {
      try {
        videoControllers[index]?.play();
        _resetAutoPauseTimer();
        // Don't notify immediately to prevent play/pause button flicker
        // Wait for video to actually start playing
        Future.delayed(const Duration(milliseconds: 200), () {
          if (videoControllers[index]?.value.isPlaying ?? false) {
            notifyListeners();
          }
        });
      } catch (e) {
        debugPrint('Error resuming video: $e');
      }
    }

    // Resume Vimeo video
    if (isVimeo && webViewControllers[index] != null) {
      try {
        webViewControllers[index]?.evaluateJavascript(
          source: '''
          (function() {
            try {
              var iframe = document.querySelector('iframe');
              if (iframe && iframe.contentWindow) {
                iframe.contentWindow.postMessage('{"method":"play"}', '*');
              }
            } catch(e) {}
          })();
        ''',
        );
        vimeoVideoPlayingStates[index] = true;
        _resetAutoPauseTimer();
        // Delay notification for Vimeo as well
        Future.delayed(const Duration(milliseconds: 200), () {
          notifyListeners();
        });
      } catch (e) {
        debugPrint('Error resuming Vimeo video: $e');
      }
    }
  }

  void _disposeVideoAtIndex(int index) {
    if (index < 0 || index >= videos.length) return;

    try {
      // Dispose video controller
      if (videoControllers[index] != null) {
        try {
          videoControllers[index]?.dispose();
        } catch (e) {
          debugPrint('Error disposing video controller at index $index: $e');
        }
        videoControllers.remove(index);
        videoLoadingStates.remove(index);
        vimeoVideoErrors.remove(index);
      }

      // Dispose web view controller
      if (webViewControllers[index] != null) {
        try {
          webViewControllers[index]?.dispose();
        } catch (e) {
          debugPrint('Error disposing web view controller at index $index: $e');
        }
        webViewControllers.remove(index);
      }
    } catch (e) {
      debugPrint('Error in _disposeVideoAtIndex: $e');
    }
  }

  void pauseAllVideos() {
    // Cancel any auto‑pause timer when we intentionally pause everything
    _cancelAutoPauseTimer();

    // Pause all MP4 videos
    for (var entry in videoControllers.entries) {
      if (entry.value != null && entry.value!.value.isInitialized) {
        try {
          entry.value!.pause();
        } catch (e) {
          debugPrint('Error pausing video at index ${entry.key}: $e');
        }
      }
    }

    // Stop all Vimeo videos by sending pause message
    for (var entry in webViewControllers.entries) {
      final webController = entry.value;
      if (webController != null) {
        try {
          webController.evaluateJavascript(
            source: '''
            (function() {
              try {
                var iframe = document.querySelector('iframe');
                if (iframe && iframe.contentWindow) {
                  iframe.contentWindow.postMessage('{"method":"pause"}', '*');
                }
              } catch(e) {}
            })();
          ''',
          );
        } catch (e) {
          // Ignore errors - webview might be disposed
        }
      }
    }
  }

  void toggleProductInfoVisibility() {
    isProductInfoVisible = !isProductInfoVisible;
    notifyListeners();
  }

  void setPageVisibility(bool visible) {
    if (isPageVisible == visible) return;

    isPageVisible = visible;

    if (!visible) {
      _cancelAutoPauseTimer();
      // Pause all videos when page becomes invisible
      pauseAllVideos();

      // Dispose all controllers except current to free memory when page is not visible
      _disposeControllersOutsideRange(currentVideoIndex);
    } else {
      // Only play videos if page is actually visible
      // This check is done in the resume methods that follow
      
      // Initialize videos only when page becomes visible for the first time
      if (!_videosInitialized) {
        _videosInitialized = true;
        initializeVideos();
      }

      // CRITICAL: Ensure PageView is on the correct page when returning
      // This prevents audio from one video playing with a different video displayed
      if (pageController.hasClients && videos.isNotEmpty) {
        final currentPage = pageController.page?.round() ?? 0;
        if (currentPage != currentVideoIndex && currentVideoIndex < videos.length) {
          debugPrint('🔄 Syncing PageView: was on page $currentPage, jumping to $currentVideoIndex');
          try {
            pageController.jumpToPage(currentVideoIndex);
          } catch (e) {
            debugPrint('Error jumping to page: $e');
          }
        }
      }

      // Resume current video when page becomes visible
      // But only if we're actually on the reels page
      if (currentVideoIndex < videos.length) {
        final item = videos[currentVideoIndex];
        var videoUrl = item.videoUrl?.toString() ?? '';

        if (videoUrl.isNotEmpty) {
          // Normalize the URL to fix malformed URLs
          videoUrl = _normalizeVideoUrl(videoUrl);

          final isVimeo = videoUrl.contains("vimeo.com");
          final isMp4 =
              videoUrl.endsWith(".mp4") || videoUrl.contains("ltwebstatic.com");
          final isWebm = videoUrl.endsWith(".webm");

          if ((isMp4 || isWebm) &&
              !isVimeo &&
              videoControllers[currentVideoIndex] != null) {
            videoControllers[currentVideoIndex]?.play();
            _resetAutoPauseTimer();
            // Notify listeners after a brief delay to ensure video player state is updated
            Future.delayed(const Duration(milliseconds: 100), () {
              if (isPageVisible) {
                notifyListeners();
              }
            });
          } else if (isVimeo && webViewControllers[currentVideoIndex] != null) {
            // For Vimeo videos, send play message and update state
            try {
              webViewControllers[currentVideoIndex]?.evaluateJavascript(
                source: '''
                (function() {
                  try {
                    var iframe = document.querySelector('iframe');
                    if (iframe && iframe.contentWindow) {
                      iframe.contentWindow.postMessage('{"method":"play"}', '*');
                    }
                  } catch(e) {}
                })();
              ''',
              );
              vimeoVideoPlayingStates[currentVideoIndex] = true;
            } catch (e) {
              debugPrint('Error resuming Vimeo video: $e');
            }
            _resetAutoPauseTimer();
            notifyListeners();
          }
        }
      }
    }
    notifyListeners();
  }

  void toggleVideoPlayPause(int index) {
    if (index < 0 || index >= videos.length) return;

    final item = videos[index];
    var videoUrl = item.videoUrl?.toString() ?? '';
    if (videoUrl.isEmpty) return;

    videoUrl = _normalizeVideoUrl(videoUrl);
    final isVimeo = videoUrl.contains("vimeo.com");

    if (isVimeo) {
      // Toggle Vimeo video
      toggleVimeoVideoPlayPause(index);
    } else if (videoControllers[index] != null &&
        videoControllers[index]!.value.isInitialized) {
      // Toggle MP4/WebM video
      if (videoControllers[index]!.value.isPlaying) {
        videoControllers[index]?.pause();
      } else {
        videoControllers[index]?.play();
        _resetAutoPauseTimer();
      }
      notifyListeners();
    }
  }

  void toggleVimeoVideoPlayPause(int index) {
    if (webViewControllers[index] == null) return;

    final isPlaying =
        vimeoVideoPlayingStates[index] ?? true; // Default to playing

    try {
      if (isPlaying) {
        // Pause Vimeo video
        webViewControllers[index]?.evaluateJavascript(
          source: '''
          (function() {
            try {
              var iframe = document.querySelector('iframe');
              if (iframe && iframe.contentWindow) {
                iframe.contentWindow.postMessage('{"method":"pause"}', '*');
              }
            } catch(e) {}
          })();
        ''',
        );
        vimeoVideoPlayingStates[index] = false;
      } else {
        // Play Vimeo video
        webViewControllers[index]?.evaluateJavascript(
          source: '''
          (function() {
            try {
              var iframe = document.querySelector('iframe');
              if (iframe && iframe.contentWindow) {
                iframe.contentWindow.postMessage('{"method":"play"}', '*');
              }
            } catch(e) {}
          })();
        ''',
        );
        vimeoVideoPlayingStates[index] = true;
        _resetAutoPauseTimer();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling Vimeo video: $e');
    }
  }

  bool isVideoPlaying(int index) {
    if (index < 0 || index >= videos.length) return false;

    final item = videos[index];
    var videoUrl = item.videoUrl?.toString() ?? '';
    if (videoUrl.isEmpty) return false;

    videoUrl = _normalizeVideoUrl(videoUrl);
    final isVimeo = videoUrl.contains("vimeo.com");

    if (isVimeo) {
      return vimeoVideoPlayingStates[index] ??
          true; // Default to playing for Vimeo
    } else if (videoControllers[index] != null &&
        videoControllers[index]!.value.isInitialized) {
      return videoControllers[index]!.value.isPlaying;
    }
    return false;
  }

  void setVideoLoadingState(int index, bool loading) {
    videoLoadingStates[index] = loading;
    notifyListeners();
  }

  void setVimeoVideoError(int index, bool hasError) {
    if (index < 0 || index >= videos.length) return;

    // If video has error, remove it from the list immediately
    if (hasError) {
      var videoUrl = videos[index].videoUrl?.toString() ?? '';
      debugPrint('🗑️ Removing invalid video at index $index: $videoUrl');

      // Add to failed videos list to prevent re-adding
      if (videoUrl.isNotEmpty) {
        // Normalize the URL before adding to failed list
        videoUrl = _normalizeVideoUrl(videoUrl);
        _failedVideoUrls.add(videoUrl);
      }

      try {
        // Dispose controllers for this video
        try {
          videoControllers[index]?.dispose();
        } catch (e) {
          debugPrint('Error disposing video controller: $e');
        }
        videoControllers.remove(index);

        try {
          webViewControllers[index]?.dispose();
        } catch (e) {
          debugPrint('Error disposing web view controller: $e');
        }
        webViewControllers.remove(index);

        videoLoadingStates.remove(index);
        vimeoVideoErrors.remove(index);

        // Remove video from list
        videos.removeAt(index);

        debugPrint(
          '✅ Video removed successfully. Remaining videos: ${videos.length}',
        );

        // Store previous index for PageView update
        final previousIndex = currentVideoIndex;

        // Adjust current index if needed
        if (videos.isEmpty) {
          currentVideoIndex = 0;
          // Try to load more videos if available
          if (hasMore && !isLoading && !isLoadingMore) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              loadVideos();
            });
          }
        } else if (currentVideoIndex >= videos.length) {
          currentVideoIndex = videos.length - 1;
        } else if (currentVideoIndex > index) {
          currentVideoIndex--;
        }

        // Rebuild controller maps after removal
        _rebuildControllerMapsAfterRemoval(index);

        // Update PageView controller if index changed and it's near current position
        // Only update if the removed video was before or at current position
        if (index <= previousIndex && pageController.hasClients) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (pageController.hasClients &&
                currentVideoIndex != previousIndex) {
              try {
                // Animate to new position smoothly
                pageController.animateToPage(
                  currentVideoIndex,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              } catch (e) {
                debugPrint(
                  'Error updating PageView position after Vimeo error removal: $e',
                );
              }
            }
          });
        }

        notifyListeners();
      } catch (e, stack) {
        debugPrint('❌ Error removing video: $e');
        debugPrint('Stack: $stack');
        // Still mark as error even if removal failed
        vimeoVideoErrors[index] = true;
        notifyListeners();
      }
    } else {
      vimeoVideoErrors[index] = false;
      notifyListeners();
    }
  }

  void _rebuildControllerMapsAfterRemoval(int removedIndex) {
    // Shift all indices after removedIndex down by 1
    final keysToUpdate = <int>[];

    // Collect keys that need updating
    for (var key in videoControllers.keys) {
      if (key > removedIndex) {
        keysToUpdate.add(key);
      }
    }

    // Update video controllers map
    for (var oldKey in keysToUpdate) {
      final controller = videoControllers.remove(oldKey);
      if (controller != null) {
        videoControllers[oldKey - 1] = controller;
      }
    }

    // Update web view controllers map
    final webKeysToUpdate = <int>[];
    for (var key in webViewControllers.keys) {
      if (key > removedIndex) {
        webKeysToUpdate.add(key);
      }
    }

    for (var oldKey in webKeysToUpdate) {
      final controller = webViewControllers.remove(oldKey);
      if (controller != null) {
        webViewControllers[oldKey - 1] = controller;
      }
    }

    // Update loading states map
    final loadingKeysToUpdate = <int>[];
    for (var key in videoLoadingStates.keys) {
      if (key > removedIndex) {
        loadingKeysToUpdate.add(key);
      }
    }

    for (var oldKey in loadingKeysToUpdate) {
      final value = videoLoadingStates.remove(oldKey);
      if (value != null) {
        videoLoadingStates[oldKey - 1] = value;
      }
    }

    // Update error states map
    final errorKeysToUpdate = <int>[];
    for (var key in vimeoVideoErrors.keys) {
      if (key > removedIndex) {
        errorKeysToUpdate.add(key);
      }
    }

    for (var oldKey in errorKeysToUpdate) {
      final value = vimeoVideoErrors.remove(oldKey);
      if (value != null) {
        vimeoVideoErrors[oldKey - 1] = value;
      }
    }
  }

  bool hasVimeoVideoError(int index) {
    return vimeoVideoErrors[index] ?? false;
  }

  void setWebViewController(int index, InAppWebViewController controller) {
    webViewControllers[index] = controller;
  }

  // Business logic methods
  String getVimeoId(String? videoUrl) {
    if (videoUrl == null || videoUrl.isEmpty) return '';
    return _extractVimeoId(_normalizeVideoUrl(videoUrl));
  }

  String normalizeVideoUrl(String url) {
    return _normalizeVideoUrl(url);
  }

  String totalPrice(String price, int quantity) {
    String cleaned = price.replaceAll('₪', '').trim();
    double value = double.tryParse(cleaned) ?? 0.0;
    double total = value * quantity;
    return '${total.toStringAsFixed(2)} ₪';
  }

  Future<void> handleDoubleTapFavorite(Item item) async {
    try {
      final favouriteController = NavigatorApp.context
          .read<FavouriteController>();
      final isFavourite = await favouriteController.checkFavouriteItem(
        productId: item.id,
      );

      // Only add to favorites if not already favorited
      if (!isFavourite) {
        final tags = (item.tags ?? []).join(',');
        await favouriteController.insertData(
          id: item.id.toString(),
          image: item.vendorImagesLinks?.isNotEmpty == true
              ? item.vendorImagesLinks!.first
              : '',
          title: item.title ?? '',
          newPrice: item.newPrice?.toString() ?? '0 ₪',
          oldPrice: item.oldPrice?.toString() ?? '0 ₪',
          tags: tags,
          productId: item.id,
          variantId: item.variants?.isNotEmpty == true
              ? item.variants!.first.id
              : null,
        );

        // Optimistically update count immediately (before Firebase responds)
        final videoId = item.id?.toString() ?? '';
        if (videoId.isNotEmpty) {
          final currentCount = videoLikeCounts[videoId] ?? 0;
          videoLikeCounts[videoId] = currentCount + 1;
          notifyListeners(); // Update UI immediately

          // Update Firebase like count in background
          _likesService
              .incrementLike(videoId: videoId, title: item.title ?? '')
              .catchError((e) {
                // Rollback on error
                videoLikeCounts[videoId] = currentCount;
                notifyListeners();
                debugPrint('❌ Error incrementing like (double tap): $e');
              });
        } else {
          debugPrint('⚠️ Cannot increment like (double tap): videoId is empty');
        }
      }

      // Show and play flare animation
      // Since FlareActor is always in tree, it should be initialized
      // Make it visible first
      showFlareAnimation = true;
      notifyListeners();

      // Wait for next frame to ensure visibility change is rendered
      await Future.delayed(const Duration(milliseconds: 16));

      // Play animation - FlareActor should already be initialized since it's always in tree
      try {
        flareControls.play("like");
      } catch (e) {
        debugPrint('Error playing flare animation: $e');
        // If play fails, wait a bit more and retry (artboard might still be loading)
        Future.delayed(const Duration(milliseconds: 100), () {
          try {
            flareControls.play("like");
          } catch (e2) {
            debugPrint('Error playing flare animation (retry): $e2');
            // Final retry after longer delay
            Future.delayed(const Duration(milliseconds: 200), () {
              try {
                flareControls.play("like");
              } catch (e3) {
                debugPrint('Error playing flare animation (final retry): $e3');
              }
            });
          }
        });
      }

      // Hide flare after animation completes (approximately 1 second)
      Future.delayed(const Duration(milliseconds: 1000), () {
        showFlareAnimation = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error in handleDoubleTapFavorite: $e');
    }
  }

  Future<void> handleFavoriteTap(Item item) async {
    try {
      final favouriteController = NavigatorApp.context
          .read<FavouriteController>();
      final isFavourite = await favouriteController.checkFavouriteItem(
        productId: item.id,
      );
      final videoId = item.id?.toString() ?? '';

      if (isFavourite) {
        await favouriteController.deleteItem(productId: item.id);
        await showSnackBar(
          title: "تم إزالة المنتج من المفضلة",
          type: SnackBarType.success,
        );

        // Optimistically update count immediately (before Firebase responds)
        if (videoId.isNotEmpty) {
          final currentCount = videoLikeCounts[videoId] ?? 0;
          final newCount = (currentCount > 0) ? currentCount - 1 : 0;
          videoLikeCounts[videoId] = newCount;
          notifyListeners(); // Update UI immediately

          // Update Firebase like count in background
          _likesService.decrementLike(videoId: videoId).catchError((e) {
            // Rollback on error
            videoLikeCounts[videoId] = currentCount;
            notifyListeners();
            debugPrint('❌ Error decrementing like: $e');
          });
        } else {
          debugPrint('⚠️ Cannot decrement like: videoId is empty');
        }
      } else {
        final tags = (item.tags ?? []).join(',');
        await favouriteController.insertData(
          id: item.id.toString(),
          image: item.vendorImagesLinks?.isNotEmpty == true
              ? item.vendorImagesLinks!.first
              : '',
          title: item.title ?? '',
          newPrice: item.newPrice?.toString() ?? '0 ₪',
          oldPrice: item.oldPrice?.toString() ?? '0 ₪',
          tags: tags,
          productId: item.id,
          variantId: item.variants?.isNotEmpty == true
              ? item.variants!.first.id
              : null,
        );
        await showSnackBar(
          title: "تم إضافة المنتج إلى المفضلة",
          type: SnackBarType.success,
        );

        // Optimistically update count immediately (before Firebase responds)
        if (videoId.isNotEmpty) {
          final currentCount = videoLikeCounts[videoId] ?? 0;
          videoLikeCounts[videoId] = currentCount + 1;
          notifyListeners(); // Update UI immediately

          // Update Firebase like count in background
          _likesService
              .incrementLike(videoId: videoId, title: item.title ?? '')
              .catchError((e) {
                // Rollback on error
                videoLikeCounts[videoId] = currentCount;
                notifyListeners();
                debugPrint('❌ Error incrementing like: $e');
              });
        } else {
          debugPrint('⚠️ Cannot increment like: videoId is empty');
        }
      }
    } catch (e) {
      debugPrint('Error handling favorite: $e');
    }
  }

  Future<void> handleCopySku(Item item) async {
    try {
      final id = item.id?.toString() ?? '';

      if (id.isEmpty) {
        await showSnackBar(title: "id غير متوفر", type: SnackBarType.warning);
        return;
      }

      await Clipboard.setData(ClipboardData(text: id));
      await showSnackBar(title: "تم النسخ $id", type: SnackBarType.success);
    } catch (e) {
      debugPrint('Error copying id: $e');
      await showSnackBar(
        title: "حدث خطأ أثناء نسخ id",
        type: SnackBarType.error,
      );
    }
  }

  Future<void> handleRemoveFromCart(Item item) async {
    try {
      final cartItemId = "${item.id}000";
      await onPopDeleteCartItem(id: cartItemId);
    } catch (e) {
      debugPrint('Error removing from cart: $e');
      await showSnackBar(
        title: "حدث خطأ أثناء إزالة المنتج",
        type: SnackBarType.error,
      );
    }
  }

  Future<void> handleAddToCart(Item item) async {
    try {
      final cartController = NavigatorApp.context.read<CartController>();
      final fetchController = NavigatorApp.context.read<FetchController>();
      final favouriteController = NavigatorApp.context
          .read<FavouriteController>();
      final apiProductItemController = NavigatorApp.context
          .read<ApiProductItemController>();

      await apiProductItemController.resetRequests();
      dialogWaiting();

      await favouriteController.getItemData(item);

      if (favouriteController.item?.variants?[0].size == "") {
        NavigatorApp.pop();
        await showSnackBar(
          title: "للأسف!، هذه المنتج لم تعد متوفرة",
          type: SnackBarType.warning,
        );
        return;
      }

      bool check = await cartController.checkCartItemById(
        productId: favouriteController.item!.id ?? 0,
      );

      if (check == true) {
        await showSnackBar(
          title: "تم إضافة المنتج من هذا الحجم مسبقا",
          type: SnackBarType.warning,
        );
        NavigatorApp.pop();
        return;
      }

      String hasOffer1 = "false";
      String offer = await fetchController.getOffer();

      for (var i in favouriteController.item?.tags ?? []) {
        if (i.toString().trim().toString() ==
            offer.toString().trim().toString()) {
          hasOffer1 = "true";
        }
      }
      List<String> tags = (item.tags ?? []);

      await cartController.insertData(
        id: "${favouriteController.item?.id}000",
        variantId: favouriteController.item?.variants?[0].id,
        tags: '$tags',
        productId: favouriteController.item?.id,
        shopId: favouriteController.item?.shopId.toString(),
        employee: favouriteController.item?.variants?[0].employee.toString(),
        nickname: favouriteController.item?.variants?[0].nickname.toString(),
        placeInHouse: favouriteController.item?.variants?[0].placeInWarehouse
            .toString(),
        sku: favouriteController.item?.sku.toString(),
        vendorSku: favouriteController.item?.vendorSku.toString(),
        image: favouriteController.item?.vendorImagesLinks![0],
        title: favouriteController.item?.title,
        oldPrice: favouriteController.item?.oldPrice.toString(),
        size: favouriteController.item?.variants?[0].size.toString(),
        quantity: 1,
        basicQuantity: favouriteController.item?.variants?[0].quantity,
        totalPrice: totalPrice(
          favouriteController.item!.newPrice.toString(),
          1,
        ),
        indexVariants: 0,
        newPrice: favouriteController.item?.newPrice,
        favourite: "true",
        hasOffer: hasOffer1,
      );

      await showSnackBar(
        title: "تم أضافة المنتج في السلة",
        type: SnackBarType.success,
      );
      NavigatorApp.pop();
    } catch (e, stackTrace) {
      debugPrint('Error adding to cart: $e');
      debugPrint('Stack trace: $stackTrace');
      NavigatorApp.pop();
      await showSnackBar(
        title: "حدث خطأ أثناء إضافة المنتج: ${e.toString()}",
        type: SnackBarType.error,
      );
    }
  }

  /// Initialize like counts for a list of videos
  Future<void> _initializeLikeCountsForVideos(List<Item> items) async {
    debugPrint('🔥 Initializing like counts for ${items.length} videos');

    // Test Firebase connection first
    final connectionOk = await _likesService.testConnection();
    if (!connectionOk) {
      debugPrint('⚠️ Firebase connection test failed. Check security rules!');
      return;
    }

    for (final item in items) {
      final videoId = item.id?.toString() ?? '';
      if (videoId.isEmpty) {
        debugPrint('⚠️ Skipping item with empty ID');
        continue;
      }

      // Initialize video in Firebase if not exists
      await _likesService.initializeVideoLike(
        videoId: videoId,
        title: item.title ?? '',
      );

      // Get initial like count
      final initialCount = await _likesService.getLikeCount(videoId);
      videoLikeCounts[videoId] = initialCount;

      // Start watching for real-time updates
      _watchLikeCount(videoId);
    }
    notifyListeners();
  }



  /// Watch like count changes for a video in real-time
  void _watchLikeCount(String videoId) {
    // Cancel existing subscription if any
    _likeCountSubscriptions[videoId]?.cancel();

    // Create new subscription
    _likeCountSubscriptions[videoId] = _likesService
        .watchLikeCount(videoId)
        .listen(
          (count) {
            videoLikeCounts[videoId] = count;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('Error watching like count for $videoId: $error');
          },
        );
  }

  /// Get like count for a video
  int getLikeCount(Item item) {
    final videoId = item.id?.toString() ?? '';
    if (videoId.isEmpty) return 0;
    return videoLikeCounts[videoId] ?? 0;
  }

  @override
  void dispose() {
    // Cancel all like count subscriptions
    for (var subscription in _likeCountSubscriptions.values) {
      subscription.cancel();
    }
    _likeCountSubscriptions.clear();
    videoLikeCounts.clear();

    // Dispose page controller
    try {
      pageController.dispose();
    } catch (e) {
      debugPrint('Error disposing page controller: $e');
    }

    // Dispose all video controllers
    for (var entry in videoControllers.entries) {
      try {
        entry.value?.dispose();
      } catch (e) {
        debugPrint(
          'Error disposing video controller at index ${entry.key}: $e',
        );
      }
    }


    videoControllers.clear();
    videoLoadingStates.clear();
    vimeoVideoErrors.clear();
    vimeoVideoPlayingStates.clear();

    // Dispose all web view controllers
    for (var entry in webViewControllers.entries) {
      try {
        entry.value?.dispose();
      } catch (e) {
        debugPrint(
          'Error disposing web view controller at index ${entry.key}: $e',
        );
      }
    }
    webViewControllers.clear();

    super.dispose();
  }
}
