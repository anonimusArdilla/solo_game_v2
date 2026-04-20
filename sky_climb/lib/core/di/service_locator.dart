import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sky_climb/core/economy/wallet_repository.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  if (!sl.isRegistered<SharedPreferences>()) {
    sl.registerSingletonAsync<SharedPreferences>(SharedPreferences.getInstance);
  }
  await sl.isReady<SharedPreferences>();

  if (!sl.isRegistered<WalletRepository>()) {
    sl.registerLazySingleton<WalletRepository>(
      () => WalletRepository(sl<SharedPreferences>()),
    );
  }
}
