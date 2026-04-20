import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sky_climb/app/router/router_providers.dart';
import 'package:sky_climb/l10n/app_localizations.dart';
import 'package:sky_climb/ui/startup/app_startup_provider.dart';

final class SkyClimbApp extends ConsumerWidget {
  const SkyClimbApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startup = ref.watch(appStartupProvider);
    final routerDelegate = ref.watch(appRouterDelegateProvider);
    final parser = ref.watch(appRouteInformationParserProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerDelegate: routerDelegate,
      routeInformationParser: parser,
      builder: (context, child) {
        return startup.when(
          data: (_) => child ?? const SizedBox(),
          loading: () => const ColoredBox(
            color: Color(0xFF05060A),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => ColoredBox(
            color: const Color(0xFF05060A),
            child: Center(
              child: Text(
                e.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}
