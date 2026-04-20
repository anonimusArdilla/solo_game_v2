import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sky_climb/core/di/service_locator.dart';
import 'package:sky_climb/core/economy/wallet.dart';
import 'package:sky_climb/core/economy/wallet_repository.dart';
import 'package:sky_climb/ui/startup/app_startup_provider.dart';

final walletProvider = NotifierProvider<WalletNotifier, Wallet>(
  WalletNotifier.new,
);

final class WalletNotifier extends Notifier<Wallet> {
  @override
  Wallet build() {
    ref.watch(appStartupProvider);
    return sl<WalletRepository>().read();
  }

  Future<void> addSoft(int amount) async {
    if (amount <= 0) return;
    final next = state.copyWith(soft: state.soft + amount);
    state = next;
    unawaited(sl<WalletRepository>().write(next));
  }

  Future<void> addHard(int amount) async {
    if (amount <= 0) return;
    final next = state.copyWith(hard: state.hard + amount);
    state = next;
    unawaited(sl<WalletRepository>().write(next));
  }

  Future<bool> spendSoft(int amount) async {
    if (amount <= 0) return true;
    if (state.soft < amount) return false;
    final next = state.copyWith(soft: state.soft - amount);
    state = next;
    unawaited(sl<WalletRepository>().write(next));
    return true;
  }

  Future<bool> spendHard(int amount) async {
    if (amount <= 0) return true;
    if (state.hard < amount) return false;
    final next = state.copyWith(hard: state.hard - amount);
    state = next;
    unawaited(sl<WalletRepository>().write(next));
    return true;
  }
}
