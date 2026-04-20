import 'package:flutter/material.dart';
import 'package:sky_climb/app/router/app_route.dart';
import 'package:sky_climb/app/router/app_route_path.dart';

final class AppRouteInformationParser
    extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final location = routeInformation.uri.path;
    return AppRoutePath(AppRoute.fromPath(location));
  }

  @override
  RouteInformation? restoreRouteInformation(AppRoutePath configuration) {
    return RouteInformation(uri: Uri.parse(configuration.route.path));
  }
}
