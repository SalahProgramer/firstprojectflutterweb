import 'package:flutter/material.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';

/// Stub implementation for non-web platforms
class WebImageWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // This should never be called on non-web platforms
    // as kIsWeb check prevents it
    return Image(
      image: AssetImage(
        Assets.images.image.path,
      ),
      fit: BoxFit.contain,
    );
  }
}

