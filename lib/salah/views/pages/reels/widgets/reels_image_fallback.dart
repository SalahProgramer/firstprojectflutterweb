import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fawri_app_refactor/salah/models/items/item_model.dart';
import 'package:fawri_app_refactor/salah/widgets/custom_image.dart';

class ReelsImageFallback extends StatelessWidget {
  final Item item;

  const ReelsImageFallback({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final images = item.vendorImagesLinks ?? [];
    if (images.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 50.sp,
            color: Colors.grey,
          ),
        ),
      );
    }

    return CustomImageSponsored(
      boxFit: BoxFit.cover,
      imageUrl: images.first,
      borderRadius: BorderRadius.circular(0),
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.zero,
      borderCircle: 0,
    );
  }
}
