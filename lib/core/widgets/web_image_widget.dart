import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_shimmer.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';

/// Web-specific image widget that uses HTML ImageElement to bypass CORS
class WebImageWidget extends StatefulWidget {
  final String imageUrl;
  final double? height;
  final BoxFit? boxFit;
  final BorderRadius? borderRadius;

  const WebImageWidget({
    super.key,
    required this.imageUrl,
    this.height,
    this.boxFit,
    this.borderRadius,
  });

  @override
  State<WebImageWidget> createState() => _WebImageWidgetState();
}

class _WebImageWidgetState extends State<WebImageWidget> {
  bool _isLoading = true;
  bool _hasError = false;
  static int _counter = 0;
  late String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'web_image_${_counter++}';
    _loadImage();
  }

  void _loadImage() {
    final img = html.ImageElement()
      ..src = widget.imageUrl
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = _getObjectFit(widget.boxFit ?? BoxFit.fill)
      ..style.pointerEvents = 'none'; // Allow clicks to pass through

    img.onLoad.listen((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });

    img.onError.listen((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    });

    // Register the view
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) {
        final container = html.DivElement()
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.overflow = 'hidden'
          ..style.pointerEvents = 'none'; // Allow clicks to pass through
        
        if (widget.borderRadius != null) {
          final radius = widget.borderRadius!;
          container.style.borderRadius = 
              '${radius.topLeft.x}px ${radius.topRight.x}px ${radius.bottomRight.x}px ${radius.bottomLeft.x}px';
        }
        
        container.append(img);
        return container;
      },
    );
  }

  String _getObjectFit(BoxFit fit) {
    switch (fit) {
      case BoxFit.cover:
        return 'cover';
      case BoxFit.contain:
        return 'contain';
      case BoxFit.fill:
        return 'fill';
      case BoxFit.fitWidth:
        return 'scale-down';
      case BoxFit.fitHeight:
        return 'scale-down';
      case BoxFit.none:
        return 'none';
      case BoxFit.scaleDown:
        return 'scale-down';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Image(
        image: AssetImage(
          Assets.images.image.path,
        ),
        fit: BoxFit.contain,
      );
    }

    if (_isLoading) {
      return ShimmerImagePost(
        borderRadius: widget.borderRadius,
        height: widget.height ?? 300.w,
      );
    }

    return SizedBox(
      width: double.maxFinite,
      height: widget.height ?? 300.w,
      child: HtmlElementView(
        key: ValueKey(_viewId),
        viewType: _viewId,
      ),
    );
  }
}

