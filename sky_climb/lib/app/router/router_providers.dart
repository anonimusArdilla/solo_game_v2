import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sky_climb/app/router/app_route_information_parser.dart';
import 'package:sky_climb/app/router/app_router_controller.dart';
import 'package:sky_climb/app/router/app_router_delegate.dart';

final appRouterControllerProvider = Provider<AppRouterController>((ref) {
  final controller = AppRouterController();
  ref.onDispose(controller.dispose);
  return controller;
});

final appRouterDelegateProvider = Provider<AppRouterDelegate>((ref) {
  final delegate = AppRouterDelegate(ref.watch(appRouterControllerProvider));
  ref.onDispose(delegate.dispose);
  return delegate;
});

final appRouteInformationParserProvider = Provider<AppRouteInformationParser>(
  (ref) => AppRouteInformationParser(),
);
