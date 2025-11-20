import 'package:fawri_app_refactor/core/widgets/widget_orders/quantity_widget.dart';
import 'package:fawri_app_refactor/core/widgets/widget_orders/specific_view_image_item_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../controllers/favourite_controller.dart';
import '../../../models/items/item_model.dart';
import '../../../models/order/order.dart';
import '../widgets_item_view/description_specafic_item.dart';

class SpecificItem extends StatefulWidget {
  final Item item;
  final int indexVariants;
  final bool isFavourite;
  final SpecificOrder specificOrder;

  const SpecificItem(
      {super.key,
      required this.item,
      required this.indexVariants,
      required this.isFavourite,
      required this.specificOrder});

  @override
  State<SpecificItem> createState() => _SpecificItemState();
}

class _SpecificItemState extends State<SpecificItem> {
  @override
  Widget build(BuildContext context) {
    FavouriteController favouriteController =
        context.watch<FavouriteController>();

    bool favourite = favouriteController.checkFavouriteItemProductId(
        productId: (widget.item.id!.toInt()));
    return Scaffold(
      extendBody: ((widget.item.variants?[0].size == "") ||
              widget.item.subCategoris == "")
          ? true
          : false,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SpecificViewImageItemOrder(
                      item: widget.item,
                      favourite: favourite,
                      indexVariants: widget.indexVariants,
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    DescriptionSpecaficItem(
                      item: widget.item,
                      isFeature: false,
                      favourite: favourite,
                      indexVariants: widget.indexVariants,
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    QuantityWidget(
                      specificOrder: widget.specificOrder,
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String totalPrice1(String price, int quantity) {
    double total;

    String cleaned = price.replaceAll('₪', '');
    double value = double.parse(cleaned);
    total = value * quantity;
    String f = total.toStringAsFixed(2);
    total = double.parse(f);
    return "$total ₪";
  }
}
