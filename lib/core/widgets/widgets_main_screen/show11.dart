import '../../../core/utilities/global/app_global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../controllers/fetch_controller.dart';
import '../../../controllers/sub_main_categories_conrtroller.dart';
import '../../../views/pages/home/home_screen/home_screen.dart';
import '../custom_image.dart';

class Show11 extends StatefulWidget {
  const Show11({super.key});

  @override
  State<Show11> createState() => _Show11State();
}

class _Show11State extends State<Show11> {
  @override
  Widget build(BuildContext context) {
    FetchController fetchController = context.watch<FetchController>();
    SubMainCategoriesController subMainCategoriesController =
        context.watch<SubMainCategoriesController>();
    return Visibility(
      visible: (fetchController.setShow11 == "false") ? false : true,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 7.w),
        child: Column(
          children: [
            InkWell(
                onTap: () async {
                  await subMainCategoriesController.clear();

                  NavigatorApp.push(
                    HomeScreen(
                      bannerTitle: "🎊 ${fetchController.setShow11.trim()} 🎊",
                      endDate: "",
                      type: fetchController.setShow11.trim(),
                      url: "",
                      title: "",
                      slider: false,
                      hasAppBar: true,
                      scrollController:
                          subMainCategoriesController.scrollDynamicItems,
                      productsKinds: false,
                    ),
                  );
                },
                child: CustomImageSponsored(
                  imageUrl: fetchController.url_11,
                  width: double.maxFinite,
                  height: 170.h,
                  borderRadius: BorderRadius.circular(12.r),
                  borderCircle: 12.r,
                )),
            SizedBox(
              height: 7.h,
            )
          ],
        ),
      ),
    );
  }
}
