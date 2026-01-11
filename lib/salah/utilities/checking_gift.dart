import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fawri_app_refactor/salah/controllers/free_gift_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/product_item_controller.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import '../../dialog/dialogs/dialogs_home/dialog_free_gift.dart';
import '../../services/remote_config_firebase/remote_config_firebase.dart';
import 'audio_player_extensions.dart';
import 'sentry_service.dart';

Future<void> checkForSurpriseGift(
  BuildContext context,
  FreeGiftController freeGiftController,
) async {
  try {
    ProductItemController productItemController = context
        .read<ProductItemController>();

    const int giftThreshold = 400; // 7 دقيقة (410 ثانية)
    String itemId = await FirebaseRemoteConfigClass().fetchItemIdFreeGift();

    if (itemId.isNotEmpty && (freeGiftController.theTime == giftThreshold)) {
      if (await freeGiftController.canUse() && freeGiftController.repeatShow) {
        await freeGiftController.changeShow(check: false);
        await freeGiftController.getItemsViewedData(id: itemId);
        await Future.delayed(Duration(seconds: 1));
        if ((freeGiftController.theItemFree.variants?[0].size != "") &&
            (productItemController.inCart[freeGiftController.theItemFree.id
                    .toString()] !=
                true)) {
          final player = AudioPlayer();

          // Play audio when the dialog opens
          player.playAsset(Assets.audios.iDidItMessageTone);
          // Stop the audio after 5 seconds
          Future.delayed(const Duration(seconds: 3), () async {
            try {
              await player.stop();
            } catch (e, stack) {
              await SentryService.captureError(
                exception: e,
                stackTrace: stack,
                functionName: 'checkForSurpriseGift',
                fileName: 'checking_gift.dart',
                lineNumber: 35,
              );
            }
          });

          await dialogFreeGift(); // عرض النافذة المنبثقة لاستلام الهدية
        } else {}
      }
    }
  } catch (e, stack) {
    await SentryService.captureError(
      exception: e,
      stackTrace: stack,
      functionName: 'checkForSurpriseGift',
      fileName: 'checking_gift.dart',
      lineNumber: 15,
    );
  }
}
