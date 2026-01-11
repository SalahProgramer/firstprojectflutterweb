import 'package:fawri_app_refactor/salah/controllers/product_item_controller.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../controllers/APIS/api_product_item.dart';
import '../../controllers/page_main_screen_controller.dart';
import '../../utilities/style/text_style.dart';
import '../../views/pages/home/main_screen/product_item_view.dart';
import '../custom_image.dart';

class CardBestSallerWidget extends StatefulWidget {
  final int index;
  final Color color;

  const CardBestSallerWidget({
    super.key,
    required this.index,
    required this.color,
  });

  @override
  State<CardBestSallerWidget> createState() => _CardBestSallerWidgetState();
}

class _CardBestSallerWidgetState extends State<CardBestSallerWidget> {
  @override
  Widget build(BuildContext context) {
    PageMainScreenController pageMainScreenController = context
        .watch<PageMainScreenController>();

    ProductItemController productItemController = context
        .watch<ProductItemController>();
    ApiProductItemController apiProductItemController = context
        .watch<ApiProductItemController>();

    return InkWell(
      highlightColor: Colors.transparent,
      overlayColor: WidgetStateColor.transparent,
      focusColor: WidgetStateColor.transparent,
      hoverColor: Colors.transparent,
      onTap: () async {
        await pageMainScreenController.changePositionScroll(
          pageMainScreenController.bestSellersProducts[widget.index].id
              .toString(),
          0,
        );
        await productItemController.clearItemsData();
        await apiProductItemController.cancelRequests();
        NavigatorApp.push(
          ProductItemView(
            item: pageMainScreenController.bestSellersProducts[widget.index],
            isFlashOrBest: true,
            sizes: "",
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(4.w),
        padding: EdgeInsets.zero,
        alignment: AlignmentDirectional.centerStart,
        decoration: BoxDecoration(
          // color: widget.,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: CustomImageSponsored(
                imageUrl:
                    pageMainScreenController
                        .bestSellersProducts[widget.index]
                        .vendorImagesLinks?[0]
                        .toString() ??
                    "",
                boxFit: BoxFit.cover,
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.all(Radius.circular(15.r)),
                // borderCircle: 10.r,
              ),
            ),
            SizedBox(height: 5.h),
            Expanded(
              flex: 1,
              child: Container(
                width: double.maxFinite,
                padding: EdgeInsets.only(left: 2.w, right: 2.w),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(height: 2.h),
                    Flexible(
                      child: Text(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        pageMainScreenController
                            .bestSellersProducts[widget.index]
                            .title
                            .toString(),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: CustomTextStyle().heading1L.copyWith(
                          height: 0.8.h,
                          fontSize: 11.sp,
                          color: Colors.white,
                        ),
                        // textDecoration: TextDecoration.none,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,

                        pageMainScreenController
                            .bestSellersProducts[widget.index]
                            .newPrice
                            .toString(),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: CustomTextStyle().heading1L.copyWith(
                          height: 1.5.h,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                        // textDecoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // OpenContainer(
    //   closedElevation: 0,
    //   openElevation: 0,
    //   closedColor: Colors.transparent,
    //   openShape:
    //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
    //   transitionDuration: Duration(milliseconds: 700),
    //   tappable: true,
    //   closedShape:
    //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
    //   middleColor: Colors.transparent,
    //   openColor: Colors.transparent,
    //   transitionType: ContainerTransitionType.fadeThrough,
    //   onClosed: (data) async {
    //
    //
    //   },
    //   closedBuilder: (context, action) => ,
    //   openBuilder: (context, action) => );
  }
}
