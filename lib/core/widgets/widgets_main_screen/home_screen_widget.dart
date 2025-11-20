import 'package:flutter/cupertino.dart';

import '../../../views/pages/home/home_screen/home_screen.dart';

Widget homeScreenWidget(
    {required String bannerTitle,
    required String type,
    String? url,
    required ScrollController scroll}) {
  return HomeScreen(
    bannerTitle: bannerTitle,
    hasAppBar: true,
    endDate: "",
    type: type,
    url: "",
    title: "",
    slider: false,
    productsKinds: true,
    scrollController: scroll,
  );
}
