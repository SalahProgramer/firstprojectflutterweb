import 'package:fawri_app_refactor/salah/utilities/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../server/functions/functions.dart';
import '../../../../controllers/fetch_controller.dart';
import '../../../../controllers/page_main_screen_controller.dart';
import '../../../../widgets/widgets_main_screen/marguee_visibality.dart';
import '../../departments/basic_departments.dart';
import '../../searchandfilterandgame/widget_search_filter.dart';

class PageCategory extends StatefulWidget {
  const PageCategory({super.key});

  @override
  State<PageCategory> createState() => _PageCategoryState();
}

class _PageCategoryState extends State<PageCategory>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    PageMainScreenController pageMainScreenController = context
        .watch<PageMainScreenController>();
    FetchController fetchController = context.watch<FetchController>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        children: [
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                try {
                  await pageMainScreenController.getAllSliders();
                } catch (e) {
                  printLog(e.toString());
                }
              },
              strokeWidth: 2,
              color: CustomColor.blueColor,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                      children: [
                        WidgetSearchFilter(),
                        MargueeVisibality(),
                        BasicDepartments(
                          alwaysChangeBig: false,
                          discountCategories:
                              fetchController.discountCategories,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // if (fetchController.showEven == 1)
          //   IgnorePointer(
          //     ignoring: true,
          //     child: SnowfallWidget(
          //       gravity: 1,
          //       numberOfSnowflakes: 60,
          //       windIntensity: 1,
          //       size: Size(
          //         MediaQuery.of(context).size.width,
          //         MediaQuery.of(context).size.height,
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
