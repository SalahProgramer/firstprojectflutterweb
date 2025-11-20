import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glowy_borders/glowy_borders.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/APIS/api_product_item.dart';
import '../../../../controllers/page_main_screen_controller.dart';
import '../../../../controllers/product_item_controller.dart';
import '../../../../models/items/item_model.dart';
import '../../../utilities/global/app_global.dart';
import '../../../utilities/style/colors.dart';
import '../../../utilities/style/text_style.dart';
import '../../../../views/pages/home/main_screen/product_item_view.dart';
import '../../custom_image.dart';

class SpecificItemStyleSeven extends StatelessWidget {
  final int i;
  final bool hasAnimatedBorder;
  final Item item;
  final String image;
  final Color bGColor;
  final Map<String, bool> isLoadingProduct;

  final List<Color>? colorsGradient;
  final bool isFeature;

  const SpecificItemStyleSeven({
    super.key,
    this.hasAnimatedBorder = false,
    required this.i,
    required this.item,
    required this.image,
    this.colorsGradient,
    required this.isFeature,
    required this.isLoadingProduct,
    this.bGColor = Colors.greenAccent,
  });

  @override
  Widget build(BuildContext context) {
    return (hasAnimatedBorder)
        ? AnimatedGradientBorder(
            glowSize: 0,
            borderSize: 2,
            gradientColors: [CustomColor.blueColor, Colors.transparent],
            borderRadius: BorderRadius.circular(5.r),
            child: body(context: context))
        : body(context: context);
  }

  Widget body({required BuildContext context}) {
    ProductItemController productItemController =
        context.watch<ProductItemController>();
    PageMainScreenController pageMainScreenController =
        context.watch<PageMainScreenController>();
    ApiProductItemController apiProductItemController =
        context.watch<ApiProductItemController>();
    return InkWell(
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      overlayColor: WidgetStatePropertyAll(Colors.transparent),
      onTap: () async {
        await pageMainScreenController.changePositionScroll(
            item.id.toString(), 0);
        await productItemController.clearItemsData();
        await apiProductItemController.cancelRequests();

        NavigatorApp.push(ProductItemView(
          item: item,
          isFeature: isFeature,
          sizes: '',
          isFlashOrBest:
              (isLoadingProduct == pageMainScreenController.isLoadingFlashItems)
                  ? true
                  : false,
        ));
      },
      child: Container(
          padding: EdgeInsets.all(3.5.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r),
            color: bGColor,
          ),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CustomImageSponsored(
                      imageUrl: image.isEmpty
                          ? "https://www.fawri.co/assets/about_us/fawri_logo.jpg"
                          : image,
                      boxFit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.only(topLeft: Radius.circular(5.r)),
                          color: bGColor),
                      child: Text(
                        item.newPrice ?? "0",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        strutStyle: StrutStyle(
                          fontSize: 9.sp,
                          fontFamily: 'rubik',
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.end,
                        style: CustomTextStyle().rubik.copyWith(
                              fontSize: 9.sp,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
