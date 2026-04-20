import 'package:shared_preferences/shared_preferences.dart';
import 'package:sky_climb/core/economy/wallet.dart';

final class WalletRepository {
  const WalletRepository(this._prefs);

  static const _softKey = 'wallet_soft';
  static const _hardKey = 'wallet_hard';

  final SharedPreferences _prefs;

  Wallet read() {
    return Wallet(
      soft: _prefs.getInt(_softKey) ?? 0,
      hard: _prefs.getInt(_hardKey) ?? 0,
    );
  }

  Future<void> write(Wallet wallet) async {
    await _prefs.setInt(_softKey, wallet.soft);
    await _prefs.setInt(_hardKey, wallet.hard);
  }
}
