import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Animations extends PageRouteBuilder {
  final dynamic page;

  Animations({this.page})
    : super(
        pageBuilder: (context, animation2, animationTwo) => page,
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation1, animationTwo, child) {
          var begin = const Offset(0, 1);
          var end = const Offset(0, 0);

          var tween = Tween(begin: begin, end: end);
          var curveAnimation = CurvedAnimation(
            parent: animation1,
            curve: Curves.ease,
            reverseCurve: Curves.ease,
          );
          return SlideTransition(
            position: tween.animate(curveAnimation),
            child: child,
          );
          // var begin= 0.0;
          // var end =1.0;
          // var tween= Tween(begin:  begin,end:  end);
          // var offsetanimation= animation.drive(tween);
          // var curvanimation= CurvedAnimation(parent: animation, curve: Curves.easeInCirc);
          // return ScaleTransition(scale: tween.animate(curvanimation),child: child,);
          // var begin= 0.0;
          // var end =1.0;
          //
          //
          //
          //
          // var tween= Tween(begin:  begin,end:  end);
          // // var offsetanimation= animation.drive(tween);
          // var curvanimation= CurvedAnimation(parent: animation, curve: Curves.easeInOutCubicEmphasized);
          // return RotationTransition(turns: tween.animate(curvanimation),child: child,);
          // return Align(
          //     alignment: Alignment.center,
          //     child: SizeTransition(
          //       sizeFactor: animation,
          //       child: child,
          //     ));
          // var begin= 0.0;
          // var end =1.0;
          // var tween= Tween(begin:  begin,end:  end);
          // var offsetanimation= animation.drive(tween);
          // var curvanimation= CurvedAnimation(parent: animation, curve: Curves.easeInOutCubicEmphasized);
          // return FadeTransition(opacity: animation,child: RotationTransition(turns: tween.animate(curvanimation),child: child,),);
        },
      );
}

class AnimationTween extends StatefulWidget {
  const AnimationTween({super.key, required this.widget});

  final Widget widget;

  @override
  State<AnimationTween> createState() => _AnimationTweenState();
}

class _AnimationTweenState extends State<AnimationTween> {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(seconds: 2),
      child: widget.widget,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Padding(
            padding: EdgeInsets.only(right: value * 8.w),
            child: child,
          ),
        );
      },
    );
  }
}
