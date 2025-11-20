import '../../../controllers/search_controller.dart';
import '../../utilities/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utilities/style/text_style.dart';
import '../widgets_main_screen/titles.dart';

class WidgetPriceFilter extends StatefulWidget {
  const WidgetPriceFilter({super.key});

  @override
  State<WidgetPriceFilter> createState() => _WidgetPriceFilterState();
}

class _WidgetPriceFilterState extends State<WidgetPriceFilter> {
  @override
  Widget build(BuildContext context) {
    SearchItemController searchItemController =
        context.watch<SearchItemController>();
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.w),
          child: Align(
            alignment: Alignment.centerRight,
            child: Titles(
              text: "السعر",
              flag: 0,
              showEven: 0,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8.w),
          child: Row(
            children: [
              Text(
                "${searchItemController.rangePrice.start.toString()} ₪",
                style: CustomTextStyle()
                    .heading1L
                    .copyWith(color: Colors.black, fontSize: 12.sp),
              ),
              Expanded(
                child: RangeSlider(
                  values: searchItemController.rangePrice,
                  min: 0,
                  max: 1000,
                  activeColor: CustomColor.blueColor,
                  divisions: (1000 / 5).round(),
                  labels: RangeLabels(
                    searchItemController.rangePrice.start.toString(),
                    searchItemController.rangePrice.end.toString(),
                  ),
                  onChanged: (RangeValues newValue) async {
                    await searchItemController.changePrice(newValue);
                  },
                ),
              ),
              Text(
                "${searchItemController.rangePrice.end.toString()} ₪",
                style: CustomTextStyle()
                    .heading1L
                    .copyWith(color: Colors.black, fontSize: 12.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
