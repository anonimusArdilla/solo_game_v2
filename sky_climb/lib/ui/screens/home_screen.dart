import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sky_climb/app/router/app_route.dart';
import 'package:sky_climb/app/router/router_providers.dart';
import 'package:sky_climb/l10n/app_localizations.dart';

final class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.read(appRouterControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.appTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => router.goTo(AppRoute.game),
                    child: Text(l10n.play),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => router.goTo(AppRoute.wallet),
                    child: Text(l10n.wallet),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => router.goTo(AppRoute.settings),
                    child: Text(l10n.settings),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
