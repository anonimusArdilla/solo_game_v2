import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sky_climb/game/bridge/game_bridge.dart';
import 'package:sky_climb/game/sky_climb_game.dart';

final gameBridgeProvider = Provider<GameBridge>((ref) {
  final bridge = GameBridge();
  ref.onDispose(bridge.dispose);
  return bridge;
});

final skyClimbGameProvider = Provider<SkyClimbGame>((ref) {
  return SkyClimbGame(bridge: ref.watch(gameBridgeProvider));
});
