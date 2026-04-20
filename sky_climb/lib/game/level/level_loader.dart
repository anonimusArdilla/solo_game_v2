import 'package:flame/cache.dart';
import 'package:sky_climb/game/level/level_definition.dart';

final class LevelLoader {
  const LevelLoader();

  Future<LevelDefinition> load(
    AssetsCache assets, {
    required String fileName,
  }) async {
    final json = await assets.readJson(fileName);
    return LevelDefinition.fromJson(json);
  }
}
