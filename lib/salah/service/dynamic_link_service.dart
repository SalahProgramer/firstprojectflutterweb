import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:fawri_app_refactor/salah/utilities/sentry_service.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../server/functions/functions.dart';
import '../controllers/page_main_screen_controller.dart';
import '../controllers/product_item_controller.dart';
import '../views/pages/home/main_screen/product_item_view.dart';

class DynamicLinkService {
  static Uri? initialUri;

  Future<void> buildDynamicLink(
    String title,
    String image,
    String docId,
  ) async {
    try {
      String url = "https://fawri.page.link"; //prefix Url
      final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: url,
        link: Uri.parse(
          'https://mobileappservice-production.up.railway.app/$docId',
        ),
        androidParameters: AndroidParameters(
          packageName: "fawri.app.shop",
          minimumVersion: 1,
        ),
        iosParameters: IOSParameters(
          bundleId: "co.fawri.fawri",
          minimumVersion: '1.0.0',
        ),
        socialMetaTagParameters: SocialMetaTagParameters(
          description: "",
          imageUrl: Uri.parse(image),
          title: title,
        ),
      );
      final ShortDynamicLink shortDynamicLink = await FirebaseDynamicLinks
          .instance
          .buildShortLink(parameters);

      String? dec = shortDynamicLink.shortUrl.toString();
      await Share.share(dec, subject: title);
      NavigatorApp.pop();
    } catch (e, stack) {
      NavigatorApp.pop();

      printLog("errorr");
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'buildDynamicLink',
        fileName: 'dynamic_link_service.dart',
        lineNumber: 30,
      );
    }
  }

  Future<void> initDynamicLink() async {
    try {
      final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks
          .instance
          .getInitialLink();

      if (initialLink?.link != null) {
        initialUri = initialLink!.link;
      }

      FirebaseDynamicLinks.instance.onLink
          .listen((dynamicLinkData) async {
            handleDynamicLink(uri: dynamicLinkData.link);
          })
          .onError((error) {
            printLog('Dynamic Link Failed: $error');
          });
    } catch (error, stack) {
      await SentryService.captureError(
        exception: error,
        stackTrace: stack,
        functionName: 'initDynamicLink',
        fileName: 'dynamic_link_service.dart',
        lineNumber: 50,
      );
      printLog('Dynamic Link Init Error: $error');
    }
  }

  static Future<void> handleInitialUriIfNeeded() async {
    try {
      if (initialUri != null) {
        await handleDynamicLink(uri: initialUri!);
        initialUri = null; // بعد الاستخدام يتم إزالتها
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'handleInitialUriIfNeeded',
        fileName: 'dynamic_link_service.dart',
        lineNumber: 60,
      );
    }
  }
}

Future<void> handleDynamicLink({required Uri uri}) async {
  try {
    List<String> sepeatedLink = [];
    sepeatedLink.addAll(uri.path.split("/"));

    printLog('Dynamic Link success: ${sepeatedLink[1]}');

    WidgetsBinding.instance.addPostFrameCallback((callback) async {
      ProductItemController productItemController = NavigatorApp.context
          .read<ProductItemController>();
      PageMainScreenController pageMainScreenController = NavigatorApp.context
          .read<PageMainScreenController>();

      await pageMainScreenController.changePositionScroll(sepeatedLink[1], 0);
      await productItemController.clearItemsData();
      await productItemController.getSpecificProduct(sepeatedLink[1]);

      NavigatorApp.push(
        ProductItemView(
          item: productItemController.specificItemData!,
          sizes: "",
        ),
      );
    });

    // NavigatorApp.push(SplashLink(
    //   id: sepeatedLink[1],
    // ));
  } catch (e, stack) {
    await SentryService.captureError(
      exception: e,
      stackTrace: stack,
      functionName: 'handleDynamicLink',
      fileName: 'dynamic_link_service.dart',
      lineNumber: 85,
    );
    //messageError('$e');
  }
}
