import 'package:fawri_app_refactor/salah/controllers/fetch_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/page_main_screen_controller.dart';
import 'package:fawri_app_refactor/salah/widgets/widgets_main_screen/titles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:list_wheel_scroll_view_nls/list_wheel_scroll_view_nls.dart';
import 'package:provider/provider.dart';
import '../../../../constants/constant_data_convert.dart';
import '../../../../utilities/style/colors.dart';
import '../../../../widgets/widgets_main_screen/card_best_salaller_widget.dart';

class BestSallers extends StatefulWidget {
  const BestSallers({super.key});

  @override
  State<BestSallers> createState() => _BestSallersState();
}

class _BestSallersState extends State<BestSallers> {
  bool hasReachedIndex = false;
  final FixedExtentScrollController scrollController =
      FixedExtentScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((callback) async {
      PageMainScreenController pageMainScreenController =
          context.read<PageMainScreenController>();
      await pageMainScreenController.controllerScrollBest();
      
      // Check if scroll controller is still mounted before adding listener
      if (!scrollController.hasClients) return;
      
      scrollController.jumpToItem(2);
      scrollController.addListener(() async {
        // Safety check: ensure scroll controller is still valid
        if (!scrollController.hasClients) return;
        final itemWidth = 0.2.sw;

        final index25Offset =
            (((pageMainScreenController.bestSellersProducts.length ~/ 12)) *
                    10) *
                itemWidth;

        if (scrollController.offset >= index25Offset && !hasReachedIndex) {
          hasReachedIndex = true;
          // printLog(
          //     "sasasasasasasa: ${(((pageMainScreenController.bestSellersProducts.length ~/ 12)) * 10)}");

          await pageMainScreenController.getBestSellersProducts();

          hasReachedIndex = false;
        }
      });
    });
    super.initState();
  }

  void _onScroll() {
    // Assuming each item has a fixed width (e.g., 100px or 0.2.sw)
    final itemWidth = 0.2.sw; // Replace with your widget's actual width
    final index25Offset = 12 * itemWidth;

    if (scrollController.offset >= index25Offset && !hasReachedIndex) {
      hasReachedIndex = true;
      // printLog("Arrived at index 12!");
    }
  }

  @override
  void dispose() {
    if (scrollController.hasClients) {
      scrollController.removeListener(_onScroll);
      scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PageMainScreenController pageMainScreenController =
        context.watch<PageMainScreenController>();
    FetchController fetchController = context.watch<FetchController>();
    return Column(
      children: [
        Titles(
          text: "الأكثر مبيعاً",
          flag: 1,
          showEven: fetchController.showEven,
        ),
        SizedBox(
          height: 5.h,
        ),
        if (pageMainScreenController.bestSellersProducts.isEmpty)
          CircularProgressIndicator()
        else
          Container(
            height: 0.25.sh,
            width: double.maxFinite,
            padding: EdgeInsets.zero,
            child: ListWheelScrollViewX(
                scrollDirection: Axis.horizontal,
                controller: scrollController,
                physics: FixedExtentScrollPhysics(),
                diameterRatio: 3.5,
                renderChildrenOutsideViewport: false,
                itemExtent: 0.50.sw,
                children: List.generate(
                    pageMainScreenController.bestSellersProducts.length,
                    (index) {
                  Color color = (fetchController.showEven == 1)
                      ? Colors.black
                      : (index % 2 == 0)
                          ? CustomColor.primaryColor
                          : mainColor;
                  return CardBestSallerWidget(
                    color: color,
                    index: index,
                  );
                })),
          )
      ],
    );
  }
}
