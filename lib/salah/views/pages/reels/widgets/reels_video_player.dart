import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:video_player/video_player.dart';
import 'package:vimeo_video_player/vimeo_video_player.dart';
import 'package:vibration/vibration.dart';
import 'package:fawri_app_refactor/salah/controllers/reels_controller.dart';
import 'package:fawri_app_refactor/salah/models/items/item_model.dart';
import 'package:fawri_app_refactor/salah/widgets/custom_image.dart';
import 'package:fawri_app_refactor/salah/utilities/style/text_style.dart';
import 'reels_play_pause_button.dart';
import 'reels_image_fallback.dart';

class ReelsVideoPlayer extends StatelessWidget {
  final int index;
  final ReelsController controller;
  final Item item;

  const ReelsVideoPlayer({
    super.key,
    required this.index,
    required this.controller,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    if (index >= controller.videos.length) return const SizedBox();

    var videoUrl = item.videoUrl?.toString() ?? '';

    if (videoUrl.isEmpty) {
      return ReelsImageFallback(item: item);
    }

    videoUrl = controller.normalizeVideoUrl(videoUrl);

    final isVimeo = videoUrl.toLowerCase().contains("vimeo.com");
    final isMp4 =
        videoUrl.endsWith(".mp4") || videoUrl.contains("ltwebstatic.com");
    final isWebm = videoUrl.endsWith(".webm");
    final isLoading = controller.videoLoadingStates[index] ?? false;
    final vimeoId = isVimeo ? controller.getVimeoId(videoUrl) : '';

    if (isVimeo) {
      debugPrint('🔍 Vimeo URL: $videoUrl');
      debugPrint('🔍 Extracted Vimeo ID: $vimeoId');
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        _buildVideoContent(isVimeo, isMp4, isWebm, vimeoId, videoUrl),
        if (isLoading) _buildLoadingIndicator(),
        if (!isLoading && _shouldShowPlayPause(isVimeo, isMp4, isWebm, vimeoId))
          Center(
            child: ReelsPlayPauseButton(index: index, controller: controller),
          ),
      ],
    );
  }

  Widget _buildVideoContent(
    bool isVimeo,
    bool isMp4,
    bool isWebm,
    String vimeoId,
    String videoUrl,
  ) {
    if (isVimeo && vimeoId.isNotEmpty && vimeoId.length >= 5) {
      return GestureDetector(
        onTap: () => controller.toggleVideoPlayPause(index),
        onDoubleTap: () async {
          // Trigger vibration
          try {
            await Vibration.vibrate(duration: 100);
          } catch (e) {
            // Vibration not available, continue anyway
          }

          // Add to favorites and show flare animation
          await controller.handleDoubleTapFavorite(item);
        },
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child:
              controller.isPageVisible &&
                  (index == controller.currentVideoIndex ||
                      (index - controller.currentVideoIndex).abs() <= 1)
              ? ReelsVimeoPlayer(
                  vimeoId: vimeoId,
                  index: index,
                  controller: controller,
                  item: item,
                )
              : Container(
                  color: Colors.black,
                  child: Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 60.sp,
                    ),
                  ),
                ),
        ),
      );
    } else if ((isMp4 || isWebm) &&
        controller.videoControllers[index] != null &&
        controller.videoControllers[index]!.value.isInitialized) {
      return GestureDetector(
        onTap: () => controller.toggleVideoPlayPause(index),
        onDoubleTap: () async {
          // Trigger vibration
          try {
            await Vibration.vibrate(duration: 100);
          } catch (e) {
            // Vibration not available, continue anyway
          }

          // Add to favorites and show flare animation
          await controller.handleDoubleTapFavorite(item);
        },
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: controller.videoControllers[index]!.value.size.width,
              height: controller.videoControllers[index]!.value.size.height,
              child: VideoPlayer(controller.videoControllers[index]!),
            ),
          ),
        ),
      );
    } else {
      return ReelsImageFallback(item: item);
    }
  }

  bool _shouldShowPlayPause(
    bool isVimeo,
    bool isMp4,
    bool isWebm,
    String vimeoId,
  ) {
    if (isVimeo && vimeoId.isNotEmpty && vimeoId.length >= 5) return true;
    if ((isMp4 || isWebm) &&
        controller.videoControllers[index] != null &&
        controller.videoControllers[index]!.value.isInitialized) {
      return true;
    }
    return false;
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "قيد الإنتظار",
            style: CustomTextStyle().heading1L.copyWith(color: Colors.white),
          ),
          SizedBox(height: 20.h),
          SpinKitThreeBounce(color: Colors.white, size: 25.w),
        ],
      ),
    );
  }
}

class ReelsVimeoPlayer extends StatefulWidget {
  final String vimeoId;
  final int index;
  final ReelsController controller;
  final Item item;

  const ReelsVimeoPlayer({
    super.key,
    required this.vimeoId,
    required this.index,
    required this.controller,
    required this.item,
  });

  @override
  State<ReelsVimeoPlayer> createState() => _ReelsVimeoPlayerState();
}

class _ReelsVimeoPlayerState extends State<ReelsVimeoPlayer> {
  @override
  Widget build(BuildContext context) {
    if (widget.controller.hasVimeoVideoError(widget.index)) {
      return ReelsImageFallback(item: widget.item);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        VimeoVideoPlayer(
          videoId: widget.vimeoId,
          isAutoPlay: true,
          backgroundColor: Colors.transparent,
          showByline: false,
          showTitle: false,
          showControls: false,
          isLooping: true,
          onInAppWebViewCreated: (webController) {
            widget.controller.setWebViewController(widget.index, webController);
          },
          onInAppWebViewLoadStart: (webController, url) {
            widget.controller.setVideoLoadingState(widget.index, true);
            widget.controller.setVimeoVideoError(widget.index, false);
          },
          onInAppWebViewLoadStop: (webController, url) {
            widget.controller.setVideoLoadingState(widget.index, false);

            _checkVideoError(webController, widget.vimeoId);
          },
        ),
        if (widget.item.vendorImagesLinks != null &&
            widget.item.vendorImagesLinks!.isNotEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.2,
                child: CustomImageSponsored(
                  boxFit: BoxFit.cover,
                  imageUrl: widget.item.vendorImagesLinks!.first,
                  borderRadius: BorderRadius.circular(0),
                  width: double.infinity,
                  height: double.infinity,
                  padding: EdgeInsets.zero,
                  borderCircle: 0,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _checkVideoError(InAppWebViewController webController, String vimeoId) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && widget.index < widget.controller.videos.length) {
        _performErrorCheck(webController, vimeoId);
      }
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted && widget.index < widget.controller.videos.length) {
        _performErrorCheck(webController, vimeoId);
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && widget.index < widget.controller.videos.length) {
        _performErrorCheck(webController, vimeoId);
      }
    });
  }

  void _performErrorCheck(
    InAppWebViewController webController,
    String vimeoId,
  ) {
    if (!mounted || widget.index >= widget.controller.videos.length) return;
    if (widget.controller.hasVimeoVideoError(widget.index)) return;

    webController
        .evaluateJavascript(
          source: '''
      (function() {
        try {
          var bodyText = (document.body.innerText || document.body.textContent || '').toLowerCase();
          var htmlContent = (document.body.innerHTML || '').toLowerCase();
          var allText = bodyText + ' ' + htmlContent;
          
          var errorPatterns = [
            /sorry.*video.*does not exist/i,
            /sorry.*this video does not exist/i,
            /this video does not exist/i,
            /video does not exist/i,
            /video not found/i,
            /video unavailable/i,
            /private video/i,
            /this video is private/i,
            /video cannot be played/i,
            /error loading video/i,
            /unable to load video/i,
            /sorry.*does not exist/i
          ];
          
          for (var i = 0; i < errorPatterns.length; i++) {
            if (errorPatterns[i].test(allText)) {
              return 'error';
            }
          }
          
          if ((allText.includes('sorry') || allText.includes('error')) && 
              (allText.includes('does not exist') || allText.includes('not exist') || allText.includes('not found'))) {
            return 'error';
          }
  
          var iframe = document.querySelector('iframe');
          if (!iframe) {
            return 'error';
          }
          
          var iframeSrc = iframe.getAttribute('src') || '';
          if (!iframeSrc.includes('vimeo.com') && !iframeSrc.includes('player.vimeo.com')) {
            return 'error';
          }
          
          try {
            var iframeDoc = iframe.contentDocument || iframe.contentWindow.document;
            if (iframeDoc) {
              var iframeBody = iframeDoc.body;
              if (iframeBody) {
                var iframeText = (iframeBody.innerText || iframeBody.textContent || '').toLowerCase();
                if (iframeText.includes('sorry') || iframeText.includes('does not exist') || iframeText.includes('not found')) {
                  return 'error';
                }
              }
            }
          } catch(e) {
            // Cross-origin, can't access iframe content
          }
          
          return 'ok';
        } catch(e) {
          return 'error';
        }
      })();
    ''',
        )
        .then((result) {
          if (!mounted) return;

          final resultStr = result.toString().toLowerCase();
          if (resultStr.contains('error')) {
            debugPrint('❌ Vimeo video error detected for ID: $vimeoId');
            widget.controller.setVimeoVideoError(widget.index, true);
          } else if (resultStr.contains('ok')) {
            debugPrint('✅ Vimeo video loaded successfully for ID: $vimeoId');
          }
        })
        .catchError((e) {
          debugPrint('⚠️ Error checking Vimeo video status: $e');
        });
  }
}
