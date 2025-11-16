import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/controllers/product_item_controller.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../utilities/style/colors.dart';

class FavouriteIconDouble extends StatelessWidget {
  const FavouriteIconDouble({super.key});

  @override
  Widget build(BuildContext context) {
    ProductItemController productItemController =
        context.watch<ProductItemController>();
    return SizedBox(
      width: double.infinity,
      height: 1.sh / 4,
      child: Center(
        child: SizedBox(
          width: 80.w,
          height: 80.w,
          child: FlareActor(
            Assets.images.instagramLike,
            controller: productItemController.flareControls,
            color: CustomColor.primaryColor,
            animation: 'idle',
          ),
        ),
      ),
    );
  }
}
