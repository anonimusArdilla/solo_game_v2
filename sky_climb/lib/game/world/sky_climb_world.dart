import 'package:flame/components.dart';
import 'package:sky_climb/game/components/hazard_component.dart';
import 'package:sky_climb/game/components/platform_component.dart';
import 'package:sky_climb/game/components/player_component.dart';
import 'package:sky_climb/game/level/level_definition.dart';

final class SkyClimbWorld extends World {
  PlayerComponent? player;
  Vector2? playerStart;
  final List<PlatformComponent> platforms = [];
  final List<HazardComponent> hazards = [];

  Future<void> loadLevel(LevelDefinition level) async {
    playerStart = level.playerStart.clone();

    _syncPool<PlatformComponent>(
      pool: platforms,
      desired: level.platforms.length,
      create: () =>
          PlatformComponent(position: Vector2.zero(), size: Vector2.zero()),
    );
    for (var i = 0; i < level.platforms.length; i++) {
      final def = level.platforms[i];
      final platform = platforms[i];
      platform.position.setFrom(def.position);
      platform.size.setFrom(def.size);
      if (platform.parent == null) add(platform);
    }
    for (var i = level.platforms.length; i < platforms.length; i++) {
      platforms[i].removeFromParent();
    }

    _syncPool<HazardComponent>(
      pool: hazards,
      desired: level.hazards.length,
      create: () =>
          HazardComponent(position: Vector2.zero(), size: Vector2.zero()),
    );
    for (var i = 0; i < level.hazards.length; i++) {
      final def = level.hazards[i];
      final hazard = hazards[i];
      hazard.position.setFrom(def.position);
      hazard.size.setFrom(def.size);
      if (hazard.parent == null) add(hazard);
    }
    for (var i = level.hazards.length; i < hazards.length; i++) {
      hazards[i].removeFromParent();
    }

    final newPlayer =
        player ??
        PlayerComponent(
          position: level.playerStart.clone(),
          platforms: platforms,
          hazards: hazards,
        );
    if (newPlayer.parent == null) add(newPlayer);
    newPlayer.reset(position: level.playerStart.clone());
    player = newPlayer;
  }

  void _syncPool<T extends Component>({
    required List<T> pool,
    required int desired,
    required T Function() create,
  }) {
    while (pool.length < desired) {
      pool.add(create());
    }
  }
}
