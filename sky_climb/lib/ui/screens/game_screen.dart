import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sky_climb/app/router/router_providers.dart';
import 'package:sky_climb/game/bridge/game_command.dart';
import 'package:sky_climb/game/bridge/game_event.dart';
import 'package:sky_climb/l10n/app_localizations.dart';
import 'package:sky_climb/ui/state/game_providers.dart';

final class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(skyClimbGameProvider);
    final bridge = ref.watch(gameBridgeProvider);
    final router = ref.read(appRouterControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: game)),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: StreamBuilder<ScoreChangedEvent?>(
                  stream: bridge.events
                      .where((event) => event is ScoreChangedEvent)
                      .cast<ScoreChangedEvent>(),
                  builder: (context, snapshot) {
                    final hud = snapshot.data;
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: DefaultTextStyle(
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${hud?.score ?? 0}'),
                              if (hud != null) ...[
                                const SizedBox(height: 2),
                                Text('${l10n.lives}: ${hud.lives}'),
                                if (hud.combo > 0) ...[
                                  const SizedBox(height: 2),
                                  Text('${l10n.combo}: ${hud.combo}'),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: StreamBuilder<GameOverEvent?>(
              stream: bridge.events.map(
                (event) => event is GameOverEvent ? event : null,
              ),
              builder: (context, snapshot) {
                final gameOver = snapshot.data;
                if (gameOver == null) return const SizedBox();

                return ColoredBox(
                  color: Colors.black.withValues(alpha: 0.55),
                  child: SafeArea(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surface.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${gameOver.score}',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${l10n.maxCombo}: ${gameOver.maxCombo}',
                                  ),
                                  const SizedBox(height: 16),
                                  FilledButton(
                                    onPressed: () =>
                                        bridge.send(const RestartCommand()),
                                    child: Text(l10n.retry),
                                  ),
                                  const SizedBox(height: 4),
                                  TextButton(
                                    onPressed: router.pop,
                                    child: Text(l10n.exit),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: IconButton.filledTonal(
                  onPressed: router.pop,
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
