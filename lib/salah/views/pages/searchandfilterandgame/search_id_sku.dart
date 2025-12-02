import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../dialog/dialogs/dialog_waiting/dialog_waiting.dart';
import '../../../controllers/APIS/api_product_item.dart';
import '../../../controllers/page_main_screen_controller.dart';
import '../../../controllers/product_item_controller.dart';
import '../../../controllers/search_controller.dart';
import '../../../utilities/global/app_global.dart';
import '../../../utilities/style/text_style.dart';
import '../../../widgets/lottie_widget.dart';
import '../../../widgets/widget_text_field/can_custom_text_field.dart';
import '../../../widgets/widgets_item_view/button_done.dart';
import '../home/main_screen/product_item_view.dart';

class SearchIdSku extends StatefulWidget {
  const SearchIdSku({super.key});

  @override
  State<SearchIdSku> createState() => _SearchIdSkuState();
}

class _SearchIdSkuState extends State<SearchIdSku> {
  @override
  Widget build(BuildContext context) {
    SearchItemController searchItemController =
        context.watch<SearchItemController>();
    PageMainScreenController pageMainScreenController =
        context.watch<PageMainScreenController>();
    ProductItemController productItemController =
        context.watch<ProductItemController>();
    ApiProductItemController apiProductItemController =
        context.watch<ApiProductItemController>();
    AnalyticsService analyticsService = AnalyticsService();

    return Container(
      decoration: BoxDecoration(
          color: Colors.grey, borderRadius: BorderRadius.circular(12.r)),
      margin: EdgeInsets.all(5.w),
      padding: EdgeInsets.all(6.w),
      child: Column(
        children: [
          Text(
            "رقم المنتج أو SKU",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CustomTextStyle().heading1L.copyWith(
                  color: Colors.black,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 15.sp,

                  fontWeight: FontWeight.bold,
                  // decorationThickness: 1.5,
                ),
          ),
          SizedBox(
            height: 5.h,
          ),
          Row(
            children: [
              Expanded(
                child: CanCustomTextFormField(
                  hintText: ' ادخل رقم المنتج أو ال sku',
                  hasFill: true,
                  hasTap: false,
                  textStyle: CustomTextStyle()
                      .heading1L
                      .copyWith(color: Colors.black, fontSize: 12.sp),
                  hasFocusBorder: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(2.w),
                    child: LottieWidget(
                      name: Assets.lottie.search1,
                      width: 18.w,
                      height: 18.w,
                    ),
                  ),
                  alignLabelWithHint: true,
                  inputType: TextInputType.text,
                  controller: searchItemController.idAndSkuSearch,
                  controlPage: searchItemController,
                  maxLines: 1,
                  onChanged: (p0) async {
                    await searchItemController.setSkuAndIdSearch(p0);
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5.h,
          ),
          ButtonDone(
            text: "تأكيد   ",
            haveBouncingWidget: false,
            iconName: Assets.icons.yes,
            onPressed: (searchItemController.idAndSkuSearch.text == "")
                ? null
                : () async {
                    await analyticsService.logEvent(
                      eventName: "search_id_sku_confirm",
                      parameters: {
                        "class_name": "SearchIdSku",
                        "button_name": "تأكيد id sku search",
                        "search_text": searchItemController.idAndSkuSearch.text,
                        "time": DateTime.now().toString(),
                      },
                    );

                    FocusScope.of(context).unfocus();
                    dialogWaiting();
                    await pageMainScreenController.changePositionScroll(
                        searchItemController.idAndSkuSearch.text, 0);
                    await productItemController.clearItemsData();
                    await productItemController.getSpecificProduct(
                        searchItemController.idAndSkuSearch.text);

                    NavigatorApp.pop();
                    if (productItemController.isTrue == true) {
                      await productItemController.clearItemsData();
                      await apiProductItemController.cancelRequests();
                      NavigatorApp.push(ProductItemView(
                        item: productItemController.specificItemData!,
                        sizes: '',
                      ));
                    }
                  },
          ),
        ],
      ),
    );
  }
}
