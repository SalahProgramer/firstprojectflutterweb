import 'package:flutter/material.dart';

import '../../../../core/dialogs/dialogs_hny/dialog_hny.dart';
import '../../../../core/widgets/app_bar_widgets/app_bar_custom.dart';
import '../../../../core/widgets/grid_items_screen/sub_items.dart';


class HomeScreen extends StatefulWidget {
  final bool slider;
  final bool productsKinds;
  final bool hasAppBar;
  final String url, title, endDate, bannerTitle;
  final ScrollController scrollController;
  final dynamic type;
  final int i;
  final bool haveScaffold;

  const HomeScreen({
    super.key,
    this.type = "normal",
    this.bannerTitle = "",
    this.endDate = "",
    this.productsKinds = false,
    this.url = "",
    this.title = "",
    this.slider = false,
    required this.scrollController,
    this.hasAppBar = false,
    this.i = 0,
    this.haveScaffold = true,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  PageController pageController = PageController();

  bool colorful = false;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.type == "2025") {
        dialogHNY();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return (widget.haveScaffold)
        ? PopScope(
            canPop: true,
            onPopInvokedWithResult: (didPop, result) {
              if (Navigator.canPop(context)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                });
              }
            },
            child: Scaffold(
              extendBody: true,
              backgroundColor: Colors.white,
              resizeToAvoidBottomInset: false,
              appBar: (widget.hasAppBar)
                  ? CustomAppBar(
                      title: "الرئيسية",
                      textButton: "رجوع",
                      onPressed: () async {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      colorWidgets: Colors.black,
                    )
                  : null,
              body: body(),
            ),
          )
        : body();
  }

  Widget body() {
    return SafeArea(
      child: SubItems(
        scrollController: widget.scrollController,
        bannerTitle: widget.bannerTitle,
        hasAPI: widget.productsKinds,
        type: widget.type,
        hasAppBar: widget.hasAppBar,
        url: widget.url,
        title: widget.title,
        index: widget.i,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
