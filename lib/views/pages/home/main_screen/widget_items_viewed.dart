import 'package:fawri_app_refactor/views/pages/home/main_screen/products_list.dart';

import '../../../../core/utilities/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/widgets_main_screen/titles.dart';
import '../../../../models/products_view_config.dart';
import '../../../../controllers/fetch_controller.dart';
import '../../../../controllers/page_main_screen_controller.dart';

class WidgetItemsViewed extends StatelessWidget {
  const WidgetItemsViewed({super.key});

  @override
  Widget build(BuildContext context) {
    PageMainScreenController pageMainScreenController =
        context.watch<PageMainScreenController>();
    FetchController fetchController = context.watch<FetchController>();

    return Column(
      children: [
        Titles(
          text: "شوهد مؤخراً",
          showEven: fetchController.showEven,
          flag: 1,
        ),
        SizedBox(
          height: 2.h,
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.only(right: 4.w),
          child: ProductsViewInList(
            configModel: ProductsViewConfigModel(
              hasAnimatedBorder: true,
              bgColor: Colors.transparent,
              colorsGradient: [CustomColor.chrismasColor],
              numberStyle: 1,
              flag: 0,
              reverse: false,
              changeLoadingProduct:
                  pageMainScreenController.changeLoadingViewedItems,
              scrollController: pageMainScreenController.scrollViewedItems,
              listItems: pageMainScreenController.viewedItemsData,
              isLoadingProduct:
                  pageMainScreenController.isLoadingItemViewedProducts,
            ),
          ),
        ),
      ],
    );
  }
}
