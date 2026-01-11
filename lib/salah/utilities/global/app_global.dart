import 'package:flutter/material.dart';

import '../../animation/animation.dart';

class NavigatorApp {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext get context {
    final currentState = navigatorKey.currentState;
    if (currentState == null) {
      throw FlutterError(
        'NavigatorApp.context accessed before the navigator is ready. '
        'Make sure the MaterialApp with navigatorKey: NavigatorApp.navigatorKey '
        'has been built before accessing the context.',
      );
    }
    return currentState.context;
  }

  static ScaffoldMessengerState get scaffoldMessenger {
    return ScaffoldMessenger.of(context);
  }

  static pop() {
    if (navigatorKey.currentState!.canPop()) {
      return navigatorKey.currentState!.pop();
    }
  }

  static pushName(String routeName) {
    return navigatorKey.currentState!.pushNamed(routeName);
  }

  static pushHaveArguments({required String routeName, Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  static push(Widget widget) {
    return navigatorKey.currentState!.push(
      MaterialPageRoute(builder: (context) => widget),
    );
  }

  static pushAnimation(Widget widget) {
    return navigatorKey.currentState!.push(Animations(page: widget));
  }

  static pushReplacment(Widget widget) {
    return navigatorKey.currentState!.pushReplacement(
      MaterialPageRoute(builder: (context) => widget),
    );
  }

  static navigateToRemoveUntil(Widget widget) {
    return navigatorKey.currentState!.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => widget),
      (route) => false,
    );
  }
}
