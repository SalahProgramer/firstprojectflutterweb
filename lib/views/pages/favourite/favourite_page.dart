import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../controllers/favourite_controller.dart';
import '../../../core/utilities/style/colors.dart';
import '../../../core/utilities/style/text_style.dart';
import '../../../core/widgets/empty_widget.dart';
import '../../../core/widgets/widget_favourite/widget_favourite_card.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    FavouriteController favouriteController =
        context.watch<FavouriteController>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: (favouriteController.favouriteItems.isEmpty)
          ? Center(
              child: EmptyWidget(
                text: "لا يوجد منتجات بالمفضلة",
                hasButton: false,
                iconName: Assets.icons.heart,
              ),
            )
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                            child: Text("عدد المنتجات بالمفضلة :",
                                textDirection: TextDirection.rtl,
                                style: CustomTextStyle().heading1L.copyWith(
                                    color: Colors.black, fontSize: 14.sp)),
                          ),
                        ),
                        Flexible(
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: EdgeInsets.only(top: 2.h),
                              child: Text(
                                  "${favouriteController.favouriteItems.length}",
                                  textDirection: TextDirection.rtl,
                                  style: CustomTextStyle().heading1L.copyWith(
                                      color: CustomColor.blueColor,
                                      fontSize: 15.sp)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Expanded(
                      child: ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: favouriteController.favouriteItems.length,
                        itemBuilder: (context, index) {
                          final reversedIndex =
                              favouriteController.favouriteItems.length -
                                  1 -
                                  index;
                          return WidgetFavouriteCard(
                            index: reversedIndex,
                            favouriteItem: favouriteController
                                .favouriteItems[reversedIndex],
                            checkInCart:
                                favouriteController.checkInCart[reversedIndex],
                            // checkInCart: check,
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
