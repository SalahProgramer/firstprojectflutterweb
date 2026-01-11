import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../models/order/order_detail_model.dart';
import '../../../../widgets/widgets_item_view/widget_spacific_order_in_home.dart';

class NewestOrderInHome extends StatefulWidget {
  final String userId;
  final List<OrderDetailModel> newOrders;

  const NewestOrderInHome({
    super.key,
    required this.userId,
    required this.newOrders,
  });

  @override
  State<NewestOrderInHome> createState() => _NewestOrderInHomeState();
}

class _NewestOrderInHomeState extends State<NewestOrderInHome>
    with TickerProviderStateMixin {
  late FixedExtentScrollController scrollController;
  Timer? timer;
  int currentIndex = 0;
  late AnimationController animationController;
  late Animation<double> animation;
  final double itemHeight = 0.24.sh;

  @override
  void initState() {
    super.initState();

    scrollController = FixedExtentScrollController();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    if (widget.newOrders[0].orderId != -1) {
      timer = Timer.periodic(Duration(seconds: 3), (timer) {
        if (widget.newOrders[0].orderId != -1) {
          int nextIndex = (currentIndex + 1) % widget.newOrders.length;

          // Animate without setState
          scrollController.animateToItem(
            nextIndex,
            duration: Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
          );

          currentIndex = nextIndex;
        }
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      width: 0.63.sw,
      child: AnimatedOpacity(
        opacity: 1,
        duration: Duration(milliseconds: 300),
        child: ListWheelScrollView.useDelegate(
          controller: scrollController,

          physics: FixedExtentScrollPhysics(),
          itemExtent: itemHeight,
          diameterRatio: 1, // Adjust for visibility
          overAndUnderCenterOpacity: 0.5,
          clipBehavior: Clip.hardEdge,
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: widget.newOrders.length,
            builder: (context, index) {
              return WidgetSpacificOrderInHome(
                userId: widget.userId,
                index: index,
                newestOrder: widget.newOrders[index],
              );
            },
          ),
        ),
      ),
    );
  }
}
