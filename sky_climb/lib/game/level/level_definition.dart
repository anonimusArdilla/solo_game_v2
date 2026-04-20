import 'package:flame/components.dart';

final class LevelDefinition {
  const LevelDefinition({
    required this.playerStart,
    required this.checkpoints,
    required this.hazards,
    required this.platforms,
  });

  factory LevelDefinition.fromJson(Map<String, dynamic> json) {
    final playerStart = json['playerStart'] as Map<String, dynamic>;
    final checkpoints =
        (json['checkpoints'] as List<dynamic>? ?? const <dynamic>[])
            .cast<num>()
            .map((e) => e.toDouble())
            .toList(growable: false);
    final hazards = (json['hazards'] as List<dynamic>? ?? const <dynamic>[])
        .cast<Map<String, dynamic>>()
        .map(HazardDefinition.fromJson)
        .toList(growable: false);
    final platforms = (json['platforms'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(PlatformDefinition.fromJson)
        .toList(growable: false);

    return LevelDefinition(
      playerStart: Vector2(
        (playerStart['x'] as num).toDouble(),
        (playerStart['y'] as num).toDouble(),
      ),
      checkpoints: checkpoints,
      hazards: hazards,
      platforms: platforms,
    );
  }

  final Vector2 playerStart;
  final List<double> checkpoints;
  final List<HazardDefinition> hazards;
  final List<PlatformDefinition> platforms;
}

final class HazardDefinition {
  const HazardDefinition({required this.position, required this.size});

  factory HazardDefinition.fromJson(Map<String, dynamic> json) {
    return HazardDefinition(
      position: Vector2(
        (json['x'] as num).toDouble(),
        (json['y'] as num).toDouble(),
      ),
      size: Vector2(
        (json['w'] as num).toDouble(),
        (json['h'] as num).toDouble(),
      ),
    );
  }

  final Vector2 position;
  final Vector2 size;
}

final class PlatformDefinition {
  const PlatformDefinition({required this.position, required this.size});

  factory PlatformDefinition.fromJson(Map<String, dynamic> json) {
    return PlatformDefinition(
      position: Vector2(
        (json['x'] as num).toDouble(),
        (json['y'] as num).toDouble(),
      ),
      size: Vector2(
        (json['w'] as num).toDouble(),
        (json['h'] as num).toDouble(),
      ),
    );
  }

  final Vector2 position;
  final Vector2 size;
}
