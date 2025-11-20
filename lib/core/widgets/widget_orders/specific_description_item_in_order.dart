import 'package:fawri_app_refactor/core/widgets/widget_orders/specific_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/APIS/api_product_item.dart';
import '../../../controllers/product_item_controller.dart';
import '../../../models/items/item_model.dart';
import '../../../models/order/order.dart';
import '../../utilities/global/app_global.dart';
import '../../utilities/print_looger.dart';
import '../app_bar_widgets/app_bar_custom.dart';

class SpecificDescriptionItemInOrder extends StatefulWidget {
  final Item item;
  final SpecificOrder specificOrder;
  final int indexVariants;
  final bool isFavourite;

  const SpecificDescriptionItemInOrder(
      {super.key,
      required this.item,
      required this.isFavourite,
      required this.indexVariants,
      required this.specificOrder});

  @override
  State<SpecificDescriptionItemInOrder> createState() =>
      _SpecificDescriptionItemInOrderState();
}

class _SpecificDescriptionItemInOrderState
    extends State<SpecificDescriptionItemInOrder> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        ProductItemController productItemController =
            context.read<ProductItemController>();
        ApiProductItemController apiProductItemController =
            context.read<ApiProductItemController>();

        await productItemController.clearItemsData();
        await apiProductItemController.resetRequests();

        await productItemController.getItemDataSpecificInOrder(
            widget.item, "", widget.specificOrder);
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ProductItemController productItemController =
        context.watch<ProductItemController>();
    ApiProductItemController apiProductItemController =
        context.watch<ApiProductItemController>();

    return Scaffold(
      extendBody: ((widget.item.variants?[0].size == "") ||
              widget.item.subCategoris == "")
          ? true
          : false,
      appBar: CustomAppBar(
        title: "فوري",
        textButton: "رجوع",
        onPressed: () async {
          printLog("Canceling requests and disposing resources");
          await apiProductItemController
              .cancelRequests(); // Directly cancel requests
          await productItemController.clearItemsData();
          NavigatorApp.pop();
        },
        actions: [],
        colorWidgets: Colors.white,
      ),
      body: SpecificItem(
          item: (productItemController.allItems.isEmpty)
              ? widget.item
              : productItemController.allItems[0],
          isFavourite: widget.isFavourite,
          indexVariants: widget.indexVariants,
          specificOrder: widget.specificOrder),
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
