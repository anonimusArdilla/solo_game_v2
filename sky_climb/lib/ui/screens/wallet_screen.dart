import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sky_climb/app/router/router_providers.dart';
import 'package:sky_climb/l10n/app_localizations.dart';
import 'package:sky_climb/ui/state/wallet_provider.dart';

final class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.read(appRouterControllerProvider);
    final l10n = AppLocalizations.of(context)!;
    final wallet = ref.watch(walletProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wallet),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: router.pop,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              title: Text(l10n.softCurrency),
              trailing: Text('${wallet.soft}'),
            ),
            ListTile(
              title: Text(l10n.hardCurrency),
              trailing: Text('${wallet.hard}'),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.tonal(
                  onPressed: () =>
                      ref.read(walletProvider.notifier).addSoft(50),
                  child: Text('${l10n.add} +50'),
                ),
                FilledButton.tonal(
                  onPressed: () async {
                    final ok = await ref
                        .read(walletProvider.notifier)
                        .spendSoft(50);
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.insufficientFunds)),
                      );
                    }
                  },
                  child: Text('${l10n.spend} -50'),
                ),
                FilledButton.tonal(
                  onPressed: () => ref.read(walletProvider.notifier).addHard(5),
                  child: Text('${l10n.add} +5'),
                ),
                FilledButton.tonal(
                  onPressed: () async {
                    final ok = await ref
                        .read(walletProvider.notifier)
                        .spendHard(1);
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.insufficientFunds)),
                      );
                    }
                  },
                  child: Text('${l10n.spend} -1'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
