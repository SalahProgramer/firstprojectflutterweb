import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/items/item_model.dart';
import '../models/sections/style_model.dart';

/// Configuration model for ProductsViewInList widget
/// This model centralizes all the shared properties used across different widget styles
class ProductsViewConfigModel {
  // Core properties
  final List<Item> listItems;
  final ScrollController scrollController;
  final int numberStyle;
  final Color bgColor;
  final int i;
  final int flag;

  // Loading and state properties
  final dynamic changeLoadingProduct;
  final dynamic isLoadingProduct;

  // UI properties
  final double? height;
  final double? width;
  final bool hasAnimatedBorder;
  final bool doSwipeAuto;
  final bool reverse;
  final bool hasBellChristmas;
  final List<Color>? colorsGradient;

  // Background properties
  final String bgImage;
  final double heightBGImage;

  // Style properties
  final StyleModel styleModel;

  ProductsViewConfigModel({
    required this.listItems,
    required this.scrollController,
    required this.numberStyle,
    required this.bgColor,
    required this.changeLoadingProduct,
    required this.isLoadingProduct,
    required this.hasAnimatedBorder,
    required this.flag,
    this.height,
    this.width,
    this.doSwipeAuto = false,
    this.reverse = false,
    this.hasBellChristmas = false,
    this.colorsGradient,
    this.bgImage = "",
    this.heightBGImage = 250,
    this.i = 0,
    StyleModel? styleModel,
  }) : styleModel = styleModel ?? StyleModel(styleId: "1", bGColor: "");

  /// Creates a copy of this configuration with the given fields replaced with new values
  ProductsViewConfigModel copyWith({
    List<Item>? listItems,
    ScrollController? scrollController,
    int? numberStyle,
    Color? bgColor,
    int? i,
    int? flag,
    dynamic changeLoadingProduct,
    dynamic isLoadingProduct,
    double? height,
    double? width,
    bool? hasAnimatedBorder,
    bool? doSwipeAuto,
    bool? reverse,
    bool? hasBellChristmas,
    List<Color>? colorsGradient,
    String? bgImage,
    double? heightBGImage,
    StyleModel? styleModel,
  }) {
    return ProductsViewConfigModel(
      listItems: listItems ?? this.listItems,
      scrollController: scrollController ?? this.scrollController,
      numberStyle: numberStyle ?? this.numberStyle,
      bgColor: bgColor ?? this.bgColor,
      i: i ?? this.i,
      flag: flag ?? this.flag,
      changeLoadingProduct: changeLoadingProduct ?? this.changeLoadingProduct,
      isLoadingProduct: isLoadingProduct ?? this.isLoadingProduct,
      height: height ?? effectiveHeight,
      width: width ?? effectiveWidth,
      hasAnimatedBorder: hasAnimatedBorder ?? this.hasAnimatedBorder,
      doSwipeAuto: doSwipeAuto ?? this.doSwipeAuto,
      reverse: reverse ?? this.reverse,
      hasBellChristmas: hasBellChristmas ?? this.hasBellChristmas,
      colorsGradient: colorsGradient ?? this.colorsGradient,
      bgImage: bgImage ?? this.bgImage,
      heightBGImage: heightBGImage ?? this.heightBGImage,
      styleModel: styleModel ?? this.styleModel,
    );
  }

  /// Gets the effective height with default fallback
  double get effectiveHeight => height ?? 0.27.sh;

  /// Gets the effective width with default fallback
  double get effectiveWidth => width ?? 120.w;
  //
  // /// Factory constructor for style 5, 6, 7 with background image support
  // factory ProductsViewConfigModel.withBackgroundImage({
  //   required List<Item> listItems,
  //   required ScrollController scrollController,
  //   required int numberStyle,
  //   required Color bgColor,
  //   required dynamic changeLoadingProduct,
  //   required dynamic isLoadingProduct,
  //   required bool hasAnimatedBorder,
  //   required int flag,
  //   required String bgImage,
  //   required double heightBGImage,
  //   required StyleModel styleModel,
  // }) {
  //   return ProductsViewConfigModel(
  //     listItems: listItems,
  //     scrollController: scrollController,
  //     numberStyle: numberStyle,
  //     bgColor: bgColor,
  //     changeLoadingProduct: changeLoadingProduct,
  //     isLoadingProduct: isLoadingProduct,
  //     hasAnimatedBorder: hasAnimatedBorder,
  //     flag: flag,
  //     bgImage: bgImage,
  //     heightBGImage: heightBGImage,
  //     styleModel: styleModel,
  //   );
  // }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductsViewConfigModel &&
        other.listItems == listItems &&
        other.scrollController == scrollController &&
        other.numberStyle == numberStyle &&
        other.bgColor == bgColor &&
        other.i == i &&
        other.flag == flag &&
        other.changeLoadingProduct == changeLoadingProduct &&
        other.isLoadingProduct == isLoadingProduct &&
        other.height == height &&
        other.width == width &&
        other.hasAnimatedBorder == hasAnimatedBorder &&
        other.doSwipeAuto == doSwipeAuto &&
        other.reverse == reverse &&
        other.hasBellChristmas == hasBellChristmas &&
        other.colorsGradient == colorsGradient &&
        other.bgImage == bgImage &&
        other.heightBGImage == heightBGImage &&
        other.styleModel == styleModel;
  }

  @override
  int get hashCode {
    return Object.hash(
      listItems,
      scrollController,
      numberStyle,
      bgColor,
      i,
      flag,
      changeLoadingProduct,
      isLoadingProduct,
      height,
      width,
      hasAnimatedBorder,
      doSwipeAuto,
      reverse,
      hasBellChristmas,
      colorsGradient,
      bgImage,
      heightBGImage,
      styleModel,
    );
  }

  @override
  String toString() {
    return 'ProductsViewConfig('
        'listItems: $listItems, '
        'scrollController: $scrollController, '
        'numberStyle: $numberStyle, '
        'bgColor: $bgColor, '
        'i: $i, '
        'flag: $flag, '
        'changeLoadingProduct: $changeLoadingProduct, '
        'isLoadingProduct: $isLoadingProduct, '
        'height: $height, '
        'width: $width, '
        'hasAnimatedBorder: $hasAnimatedBorder, '
        'doSwipeAuto: $doSwipeAuto, '
        'reverse: $reverse, '
        'hasBellChristmas: $hasBellChristmas, '
        'colorsGradient: $colorsGradient, '
        'bgImage: $bgImage, '
        'heightBGImage: $heightBGImage, '
        'styleModel: $styleModel'
        ')';
  }
}
