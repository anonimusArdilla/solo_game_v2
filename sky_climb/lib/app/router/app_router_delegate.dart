import 'package:flutter/material.dart';
import 'package:sky_climb/app/router/app_route.dart';
import 'package:sky_climb/app/router/app_route_path.dart';
import 'package:sky_climb/app/router/app_router_controller.dart';
import 'package:sky_climb/ui/screens/game_screen.dart';
import 'package:sky_climb/ui/screens/home_screen.dart';
import 'package:sky_climb/ui/screens/settings_screen.dart';
import 'package:sky_climb/ui/screens/wallet_screen.dart';

final class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  AppRouterDelegate(this._controller) {
    _controller.addListener(notifyListeners);
  }

  final AppRouterController _controller;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  AppRoutePath? get currentConfiguration => AppRoutePath(_controller.route);

  @override
  Widget build(BuildContext context) {
    final route = _controller.route;

    final pages = <Page<void>>[
      const MaterialPage<void>(child: HomeScreen()),
      if (route == AppRoute.game) const MaterialPage<void>(child: GameScreen()),
      if (route == AppRoute.settings)
        const MaterialPage<void>(child: SettingsScreen()),
      if (route == AppRoute.wallet)
        const MaterialPage<void>(child: WalletScreen()),
    ];

    return Navigator(
      key: navigatorKey,
      pages: pages,
      onDidRemovePage: (page) {
        _controller.pop();
      },
    );
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) async {
    _controller.goTo(configuration.route);
  }

  @override
  void dispose() {
    _controller.removeListener(notifyListeners);
    super.dispose();
  }
}
