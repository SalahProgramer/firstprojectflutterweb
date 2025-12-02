import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:fawri_app_refactor/salah/widgets/app_bar_widgets/app_bar_custom.dart';
import 'package:fawri_app_refactor/salah/widgets/widget_search/widget_drop_down_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../controllers/search_controller.dart';

import '../../../widgets/lottie_widget.dart';
import '../../../widgets/snackBarWidgets/snack_bar_style.dart';
import '../../../widgets/snackBarWidgets/snackbar_widget.dart';

class MainSearch extends StatefulWidget {
  final ScrollController scrollController;

  const MainSearch({super.key, required this.scrollController});

  @override
  State<MainSearch> createState() => _MainSearchState();
}

class _MainSearchState extends State<MainSearch> {
  bool hasReachedIndex = false;

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SearchItemController searchItemController =
          context.read<SearchItemController>();
      
      // Check if scroll controller is still mounted before adding listener
      if (!scrollController.hasClients) return;
      
      scrollController.addListener(() async {
        // Safety check: ensure scroll controller is still valid
        if (!scrollController.hasClients) return;
        final itemWidth = 0.3.sw;
        final itemHeight =
            itemWidth / 0.40.h; // Calculated from childAspectRatio
        final rowHeight = itemHeight + 10; // Add mainAxisSpacing if applicable

        final index25Offset =
            (((searchItemController.subCategories.length ~/ 12)) * 3) *
                rowHeight;
        if (scrollController.offset >= index25Offset && !hasReachedIndex) {
          hasReachedIndex = true;
          if ((scrollController.position.pixels >=
              scrollController.position.maxScrollExtent)) {
            await searchItemController.changeSpinHaveMoreData(true);
          }
          if (widget.scrollController ==
              searchItemController.scrollSearchItems) {
            await searchItemController.getSearch();
          }
          hasReachedIndex = false;
        }
        if ((scrollController.position.extentAfter == 0.0)) {
          if ((searchItemController.haveMoreData == false)) {
            await searchItemController.changeSpinHaveMoreData(false);
            await showSnackBar(
              title: "لقد وصلت إلى النهاية ",
              description: 'لا توجد منتجات إضافية من هذا القسم ',
              type: SnackBarType.info,
            );
          }
        }
      });
    });
  }

  @override
  void dispose() {
    // scrollController.removeListener(_onScroll);
    // scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(
          title: "البحث ",
          textButton: "رجوع",
          onPressed: () async {
            FocusScope.of(context).unfocus();

            NavigatorApp.pop();
          },
          colorWidgets: Colors.black,
        ),
        body: Column(
          children: [
            LottieWidget(
              name: Assets.lottie.search1,
              width: 60.w,
              height: 60.w,
            ),
            WidgetDropDownSearch(scrollController: scrollController),
          ],
        ),
      ),
    );
  }
}
