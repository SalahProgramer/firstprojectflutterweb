import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_shimmer.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';

class CustomImageSponsored extends StatelessWidget {
  final String imageUrl;
  final double? borderCircle;
  final double? width;
  final double? height;
  final bool hasInk;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final BoxFit? boxFit;
  //
  // static final customCacheManager = CacheManager(Config(
  //   'customCacheKey',
  //   stalePeriod: const Duration(days: 15),
  //   maxNrOfCacheObjects: 100,
  // ));

  const CustomImageSponsored({
    super.key,
    required this.imageUrl,
    this.borderCircle,
    this.width,
    this.height,
    this.hasInk = false,
    this.borderRadius,
    this.padding,
    this.boxFit,
  });

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.sizeOf(context).height;
    // final deviceWidth = MediaQuery.sizeOf(context).width;

    return Center(
      child: InkWell(
        onTap: (hasInk == true) ? () {} : null,
        child: ClipRRect(
          borderRadius:
              borderRadius ?? BorderRadius.circular(borderCircle ?? 90.r),
          child: Container(
            margin: EdgeInsets.zero,
            padding: padding ?? EdgeInsets.only(bottom: 0.h),
            child: CachedNetworkImage(
              width: double.maxFinite,
              height: height ?? 300.w,
              key: ValueKey(imageUrl),
              imageUrl: imageUrl,
              fit: boxFit ?? BoxFit.fill,
              filterQuality: FilterQuality.high,
              alignment: Alignment.center,
              memCacheHeight: (deviceHeight).toInt(),
              placeholder: (context, url) => ShimmerImagePost(
                borderRadius: borderRadius,
                height: height ?? 300.w,
              ),
              errorWidget: (context, url, error) => Image(
                image: AssetImage(Assets.images.image.path),

                // 90% of screen width
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
