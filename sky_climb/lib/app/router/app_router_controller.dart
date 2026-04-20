import 'package:flutter/foundation.dart';
import 'package:sky_climb/app/router/app_route.dart';

final class AppRouterController extends ChangeNotifier {
  AppRoute get route => _route;
  AppRoute _route = AppRoute.home;

  void goTo(AppRoute route) {
    if (_route == route) return;
    _route = route;
    notifyListeners();
  }

  void pop() => goTo(AppRoute.home);
}
