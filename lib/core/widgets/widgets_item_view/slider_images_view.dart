import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import '../../utilities/functions.dart';
import '../../utilities/style/colors.dart';
import '../custom_image.dart';
import 'package:vimeo_video_player/vimeo_video_player.dart';

class SliderImagesView extends StatefulWidget {
  final double? width;
  final double? height;
  final String? videoUrl; // Vimeo or MP4 URL
  final List<String> images;
  final String id;
  final Function(int, CarouselPageChangedReason)? onPageChange;

  const SliderImagesView({
    super.key,
    this.width,
    this.height,
    required this.images,
    required this.onPageChange,
    required this.id,
    required this.videoUrl,
  });

  @override
  State<SliderImagesView> createState() => _SliderImagesViewState();
}

class _SliderImagesViewState extends State<SliderImagesView> {
  String get vimeoId {
    final regex = RegExp(r'vimeo\.com/(?:video/)?(\d+)');
    final match = regex.firstMatch(widget.videoUrl ?? '');
    return match != null ? match.group(1)! : '';
  }

  bool get isVimeo =>
      widget.videoUrl != null && widget.videoUrl!.contains("vimeo.com");

  bool get isMp4 =>
      widget.videoUrl != null &&
      (widget.videoUrl!.endsWith(".mp4") ||
          widget.videoUrl!.contains("ltwebstatic.com"));

  bool isVideoLoading = true;
  InAppWebViewController? webViewController;
  VideoPlayerController? videoPlayerController;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isMp4 && widget.videoUrl?.isNotEmpty == true) {
        videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl!),
        )..initialize().then((_) {
            videoPlayerController!
              ..setLooping(true)
              ..setVolume(1.0)
              ..play();
            setState(() {
              isVideoLoading = false;
            });
          }).catchError((e) {});
      }
    });
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    webViewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double sliderHeight = widget.height ?? 0.55.sh;
    final bool hasVideo =
        widget.videoUrl != null && widget.videoUrl!.isNotEmpty;
    printLog("${widget.videoUrl}ffffffffffff");
    return SizedBox(
      height: sliderHeight,
      width: widget.width ?? double.infinity,
      child: CarouselSlider.builder(
        itemCount: hasVideo ? widget.images.length + 1 : widget.images.length,
        itemBuilder: (context, index, realIndex) {
          final bool isVideoItem = hasVideo && index == 0;

          return Container(
            margin: EdgeInsets.symmetric(vertical: 3.h),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 8,
                  blurStyle: BlurStyle.outer,
                ),
              ],
            ),
            child: isVideoItem
                ? SizedBox(
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isVimeo)
                          VimeoVideoPlayer(
                            videoId: vimeoId,
                            isAutoPlay: true,
                            backgroundColor: Colors.white,
                            showByline: false,
                            showTitle: false,
                            showControls: false,
                            isLooping: true,
                            onInAppWebViewCreated: (controller) {
                              webViewController = controller;
                            },
                            onInAppWebViewLoadStart: (controller, url) {
                              setState(() {
                                isVideoLoading = true;
                              });
                            },
                            onInAppWebViewLoadStop: (controller, url) {
                              setState(() {
                                isVideoLoading = false;
                              });
                            },
                          )
                        else if (videoPlayerController != null &&
                            videoPlayerController!.value.isInitialized)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (videoPlayerController!.value.isPlaying) {
                                  videoPlayerController!.pause();
                                } else {
                                  videoPlayerController!.play();
                                }
                              });
                            },
                            child: AspectRatio(
                              aspectRatio:
                                  videoPlayerController!.value.aspectRatio,
                              child: VideoPlayer(videoPlayerController!),
                            ),
                          )
                        else
                          const SizedBox(),

                        // Loading Indicator
                        if (isVideoLoading)
                          Center(
                            child: SizedBox(
                              width: 25.w,
                              height: 25.w,
                              child: CircularProgressIndicator(
                                color: CustomColor.blueColor,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : CustomImageSponsored(
                    boxFit: BoxFit.cover,
                    imageUrl: hasVideo
                        ? widget.images[index - 1]
                        : widget.images[index],
                    borderRadius: BorderRadius.circular(0),
                    width: double.infinity,
                    height: sliderHeight,
                    padding: EdgeInsets.zero,
                    borderCircle: 0,
                  ),
          );
        },
        options: CarouselOptions(
          initialPage: 0,
          scrollDirection: Axis.vertical,
          height: sliderHeight,
          enlargeCenterPage: true,
          enlargeStrategy: CenterPageEnlargeStrategy.zoom,
          viewportFraction: 0.94,
          autoPlay: !hasVideo,
          autoPlayAnimationDuration: const Duration(milliseconds: 3000),
          scrollPhysics: const ClampingScrollPhysics(),
          onPageChanged: widget.onPageChange,
        ),
      ),
    );
  }
}
