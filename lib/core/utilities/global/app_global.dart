import 'package:flutter/material.dart';
import '../../../animation/animation.dart';
import '../routes.dart';

class NavigatorApp {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static BuildContext context = navigatorKey.currentState!.context;

  static ScaffoldMessengerState scaffoldMessenger =
      ScaffoldMessenger.of(context);

  static pop([Object? result]) {
    if (navigatorKey.currentState!.canPop()) {
      return navigatorKey.currentState!.pop(result);
    }
  }

  static pushName(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  static pushHaveArguments({required String routeName, Object? arguments}) {
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  // Deprecated: Use pushName instead
  @Deprecated('Use pushName with route name instead')
  static push(Widget widget) {
    return navigatorKey.currentState!
        .push(MaterialPageRoute(builder: (context) => widget));
  }

  static pushAnimation(String routeName, {Object? arguments}) {
    final builder = listRoute[routeName];
    if (builder != null) {
      return navigatorKey.currentState!.push(
        Animations(
          page: builder(
            navigatorKey.currentState!.context,
            arguments,
          ),
        ),
      );
    }
    throw Exception('Route $routeName not found');
  }

  static pushReplacment(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  static navigateToRemoveUntil(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
}
