import 'package:fawri_app_refactor/salah/controllers/game_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/showcase_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import '../../../../dialog/dialogs/dialog_waiting/dialog_waiting.dart';
import '../../../../server/functions/functions.dart';
import '../../../games/games_cubit.dart';
import '../../../games/widget_game.dart';
import '../../../utilities/global/app_global.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomGameWidget extends StatefulWidget {
  final bool? haveSort;

  const CustomGameWidget({super.key, required this.haveSort});

  @override
  State<CustomGameWidget> createState() => _CustomGameWidgetState();
}

class _CustomGameWidgetState extends State<CustomGameWidget> {
  GlobalKey three = GlobalKey();

  Future<void> startShowCaseThree() async {

  ShowcaseController showcaseController = context.read<ShowcaseController>();
    // منع عرض الـ showcase إذا تم تهيئته بالفعل من instance آخر
    if (showcaseController.showcaseInitialized || !mounted) return;
    
    try {
      ShowcaseController showcaseController = context.read<ShowcaseController>();

      if (!showcaseController.showcaseGameShown) {

        
        // تعيين الـ flag أولاً قبل أي عملية أخرى لمنع race condition
        showcaseController.showcaseInitialized = true;
        
        // Mark the showcase as shown via provider
        await showcaseController.markGameShowcaseShown();
        
        // عرض الـ showcase بعد frame واحد
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            try {
              ShowCaseWidget.of(context).startShowCase([three]);
            } catch (e) {
              printLog("Error showing showcase three: $e");
            }
          }
        });
      }
    } catch (e) {
      printLog("Error in startShowCaseThree: $e");
    }
  }

  @override
  void initState() {
    super.initState();
WidgetsBinding.instance.addPostFrameCallback((_) {

  ShowcaseController showcaseController = context.read<ShowcaseController>();

      // إضافة delay صغير للتأكد من أن أول instance فقط يبدأ الـ showcase
  Future.delayed(Duration(milliseconds: 150), () {
      if (mounted && !showcaseController.showcaseInitialized) {
        printLog("Starting showcase from CustomGameWidget");
        startShowCaseThree();
      }
    });

  });

  }

  @override
  Widget build(BuildContext context) {
    GameController gameController = context.watch<GameController>();
    return Expanded(
      child: BlocConsumer<GamesCubit, GamesState>(
        listener: (context, state) {},
        builder: (context, state) {
          // التحقق من وجود ShowCaseWidget context قبل استخدام Showcase
          Widget gameWidget = Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
            child: InkWell(
                onTap: () async {
                  dialogWaiting();
                  await gameController.doInit();

                  await gameController.set(state.currentPlayingState);
                  NavigatorApp.pop();
                  NavigatorApp.push(WidgetGame());
                },
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Image(
                    image: AssetImage(
                      Assets.images.gameImages.dash.path,
                    ),
                  ),
                )),
          );
          
          // محاولة استخدام Showcase فقط إذا كان ShowCaseWidget موجود
          if (!mounted) return gameWidget;
          
          try {
            // This will throw if ShowCaseWidget is not found in the widget tree
            ShowCaseWidget.of(context);
            return Showcase(
              key: three,
              title: 'انطلق وطر! 🕊️',
              description: 'حلّق بداش وتجاوز الحواجز… 🚀',
              child: gameWidget,
            );
          } catch (e) {
            // إذا لم يكن هناك ShowCaseWidget context، نرجع الـ widget بدون showcase
            printLog("ShowCaseWidget context not found: $e");
            return gameWidget;
          }
        },
      ),
    );
  }
}
