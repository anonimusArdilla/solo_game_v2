enum AppRoute {
  home('/'),
  game('/game'),
  settings('/settings'),
  wallet('/wallet');

  const AppRoute(this.path);
  final String path;

  static AppRoute fromPath(String path) {
    for (final value in AppRoute.values) {
      if (value.path == path) return value;
    }
    return AppRoute.home;
  }
}
