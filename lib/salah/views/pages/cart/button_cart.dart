import 'package:fawri_app_refactor/salah/controllers/fetch_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/points_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:vibration/vibration.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../server/functions/functions.dart';
import '../../../../dialog/dialogs/dialog_waiting/dialog_waiting.dart';
import '../../../../dialog/dialogs/dialogs_cart/dialogs_cart_delete_and_check_available.dart';
import '../../../../dialog/dialogs/dialogs_cart/dialogs_no_tawseel_free.dart';
import '../../../../pages/checkout/first-screen/first_screen.dart';
import '../../../../services/remote_config_firebase/remote_config_firebase.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/page_main_screen_controller.dart';
import '../../../utilities/global/app_global.dart';

import '../../../widgets/widgets_item_view/button_done.dart';

class ButtonCart extends StatelessWidget {
  final ItemScrollController scrollController;
  final ItemScrollController scrollController1;

  const ButtonCart({
    super.key,
    required this.scrollController,
    required this.scrollController1,
  });

  Future<void> _handlePurchaseProcess(
    CartController cartController,
    FetchController fetchController,
    PointsController pointsController,
    PageMainScreenController pageMainScreenController,
  ) async {
    try {
      Vibration.vibrate(duration: 100);
      await cartController.changeLoading(true);
      dialogWaiting();

      // Check product availability
      List<Map<String, dynamic>> jsonList = cartController.cartItems
          .map((cart) => cart.toJsonCart())
          .toList();

      await cartController.checkProductAvailability(jsonList);

      // Handle availability results

      // First check if there are items with availability true but have warning messages
      bool hasWarningMessages = false;
      for (int i = 0; i < cartController.availability.length; i++) {
        var availabilityItem = cartController.availability[i];
        if (availabilityItem.availability == "true" &&
            availabilityItem.message != null &&
            availabilityItem.message!.isNotEmpty) {
          hasWarningMessages = true;
          break;
        }
      }

      // If there are warning messages, scroll to show them and stop the process
      if (hasWarningMessages) {
        await cartController.changeLoading(false);
        NavigatorApp.pop(); // Close waiting dialog

        // Vibrate to alert user about warning messages
        Vibration.vibrate(duration: 500, amplitude: 200);

        // Find first item with warning message and scroll to it
        for (int i = 0; i < cartController.availability.length; i++) {
          var availabilityItem = cartController.availability[i];
          if (availabilityItem.availability == "true" &&
              availabilityItem.message != null &&
              availabilityItem.message!.isNotEmpty) {
            // Convert to reversed index for UI display
            int reversedIndex = cartController.cartItems.length - 1 - i;
            await scrollController.scrollTo(
              index: reversedIndex,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            break;
          }
        }
        printLog(
          "Stopping checkout due to warning messages - user alerted with vibration",
        );
        return; // Stop the checkout process
      }

      if (cartController.notAvailabilityItems.isEmpty &&
          cartController.availabilityItems.length ==
              cartController.cartItems.length) {
        // All items are available, check free shipping
        var freeShipValue = await FirebaseRemoteConfigClass().fetchFreeShip();

        if (int.parse(freeShipValue.toString()) == 0 ||
            (double.parse(cartController.totalItemsPrice.toString()) >
                double.parse(freeShipValue.toString()))) {
          // No free shipping threshold, proceed directly to checkout
          await cartController.changeLoading(false);
          NavigatorApp.pop(); // Close waiting dialog

          // Set points controller values
          await pointsController.changeTotal(
            double.parse(cartController.totalItemsPrice.toString()),
          );
          await pointsController.changeTotalItems(
            double.parse(cartController.totalItemsPrice.toString()),
          );

          // Navigate to checkout
          NavigatorApp.push(
            CheckoutFirstScreen(
              freeShipValue: freeShipValue,
              items: cartController.cartItems,
            ),
          );
        } else {
          // Cart total is below threshold, show waiting dialog and no tawseel dialog
          await cartController.changeLoading(false);
          // Calculate remainder needed for free shipping
          double remainder =
              double.parse(freeShipValue.toString()) -
              double.parse(cartController.totalItemsPrice.toString());
          if (remainder < 0) remainder = 0;

          // Clear and get offer tawseel items
          pageMainScreenController.getOfferTawseelClear();
          await pageMainScreenController.getOfferTawseelItems();

          // Close waiting dialog
          NavigatorApp.pop();

          // Initialize calculate item offer tawseel
          cartController.initCalculateItemOfferTawseel(remainder.toInt());
          await cartController.changeLoading(false);

          // Show no tawseel dialog
          dialogGetNoTawseel(remainder, scrollController);

          // Set points controller values
          await pointsController.changeTotal(
            double.parse(cartController.totalItemsPrice.toString()),
          );
          await pointsController.changeTotalItems(
            double.parse(cartController.totalItemsPrice.toString()),
          );
        }
      } else if (cartController.notAvailabilityItems.isNotEmpty) {
        // Some items are not available
        await cartController.changeLoading(false);
        NavigatorApp.pop(); // Close waiting dialog
        await dialogCheckItemsAvailable();
      } else {
        // Some items have false availability status
        await cartController.changeLoading(false);
        NavigatorApp.pop();

        Vibration.vibrate(duration: 500, amplitude: 200);
        // Close waiting dialog
        await scrollController.scrollTo(
          index: cartController.availabilityWithFalseItems.indexOf(
            cartController.availabilityWithFalseItems.first,
          ),
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      printLog("Error in purchase process: $e");
      await cartController.changeLoading(false);
      NavigatorApp.pop(); // Close waiting dialog in case of error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<
      CartController,
      FetchController,
      PointsController,
      PageMainScreenController
    >(
      builder:
          (
            context,
            cartController,
            fetchController,
            pointsController,
            pageMainScreenController,
            child,
          ) {
            return (cartController.cartItems.isNotEmpty &&
                    cartController.haveButton)
                ? ButtonDone(
                    text: "تأكيد عمليه الشراء",
                    heightIcon: 28.h,
                    iconName: Assets.icons.yes,
                    onPressed: () => _handlePurchaseProcess(
                      cartController,
                      fetchController,
                      pointsController,
                      pageMainScreenController,
                    ),
                    isLoading: cartController.isLoading,
                  )
                : const SizedBox();
          },
    );
  }
}
