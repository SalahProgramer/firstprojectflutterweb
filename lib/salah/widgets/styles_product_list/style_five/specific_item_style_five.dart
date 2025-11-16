import 'package:fawri_app_refactor/salah/utilities/style/colors.dart';
import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glowy_borders/glowy_borders.dart';
import 'package:provider/provider.dart';
import '../../../controllers/APIS/api_product_item.dart';
import '../../../controllers/page_main_screen_controller.dart';
import '../../../controllers/product_item_controller.dart';
import '../../../models/items/item_model.dart';
import '../../../utilities/global/app_global.dart';
import '../../../utilities/style/text_style.dart';
import '../../../views/pages/home/main_screen/product_item_view.dart';
import '../../custom_image.dart';

class SpecificItemStyleFive extends StatelessWidget {
  final int i;
  final bool hasAnimatedBorder;
  final Item item;
  final String image;
  final Map<String, bool> isLoadingProduct;

  final List<Color>? colorsGradient;
  final bool isFeature;

  const SpecificItemStyleFive({
    super.key,
    this.hasAnimatedBorder = false,
    required this.i,
    required this.item,
    required this.image,
    this.colorsGradient,
    required this.isFeature,
    required this.isLoadingProduct,
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
    AnalyticsService analyticsService = AnalyticsService();
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
        await analyticsService.logEvent(
          eventName: "specific_item_style_five_click",
          parameters: {
            "class_name": "SpecificItemStyleFive",
            "button_name": "scroll item $i clicked",
            "product_id": item.id?.toString() ?? "",
            "product_title": item.title ?? "",
            "time": DateTime.now().toString(),
          },
        );
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Text(
                item.newPrice ?? "0",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                strutStyle: StrutStyle(
                  fontSize: 10.sp,
                  fontFamily: 'rubik',
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.end,
                style: CustomTextStyle().rubik.copyWith(
                      fontSize: 10.sp,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Expanded(
                flex: 1,
                child: CustomImageSponsored(
                  imageUrl: image.isEmpty
                      ? "https://www.fawri.co/assets/about_us/fawri_logo.jpg"
                      : image,
                  boxFit: BoxFit.contain,
                  borderRadius: BorderRadius.circular(0.r),
                ),
              ),
              Text(
                item.title ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                strutStyle: StrutStyle(
                  fontSize: 10.sp,
                  height: 1.5.h,
                  fontFamily: 'CrimsonText',
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.end,
                style: CustomTextStyle().crimson.copyWith(
                      fontSize: 10.sp,
                      height: 1.5.h,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          )),
    );
  }
}
