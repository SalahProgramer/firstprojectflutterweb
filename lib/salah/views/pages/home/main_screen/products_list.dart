import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../models/products_view_config.dart';
import '../../../../widgets/styles_product_list/style_five/widget_style_five.dart';
import '../../../../widgets/styles_product_list/style_four/widget_style_four.dart';
import '../../../../widgets/styles_product_list/style_one/widget_style_one.dart';
import '../../../../widgets/styles_product_list/style_seven/widget_style_seven.dart';
import '../../../../widgets/styles_product_list/style_three/widget_style_three.dart';
import '../../../../widgets/styles_product_list/style_two/widget_style_two.dart';
import '../../../../widgets/styles_product_list/syle_six/widget_style_six.dart';

class ProductsViewInList extends StatefulWidget {
  final ProductsViewConfigModel configModel;

  const ProductsViewInList({super.key, required this.configModel});

  @override
  State<ProductsViewInList> createState() => _ProductsViewInListState();
}

class _ProductsViewInListState extends State<ProductsViewInList> {
  @override
  Widget build(BuildContext context) {
    return buildStyleWidget(widget.configModel);
  }

  Widget buildStyleWidget(ProductsViewConfigModel config) {
    switch (config.numberStyle) {
      case 1:
        return WidgetStyleOne(config: config);

      case 2:
        return WidgetStyleTwo(
          config: config.copyWith(height: 0.45.sh, width: 145.w),
        );

      case 3:
        return WidgetStyleThree(config: config.copyWith(height: 0.25.sh));

      case 4:
        return WidgetStyleFour(
          config: config.copyWith(width: 0.85.sw, height: 0.23.sh),
        );

      case 5:
        return WidgetStyleFive(config: config.copyWith(height: 0.40.sh));

      case 6:
        return WidgetStyleSix(config: config.copyWith(height: 0.40.sh));

      case 7:
        return WidgetStyleSeven(config: config.copyWith(height: 0.40.sh));

      default:
        return WidgetStyleOne(config: config);
    }
  }
}
