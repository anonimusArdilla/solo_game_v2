import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sky_climb/core/di/service_locator.dart';

final appStartupProvider = FutureProvider<void>((ref) async {
  await configureDependencies();
});
