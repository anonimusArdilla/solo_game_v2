import 'dart:async';

import 'package:sky_climb/game/bridge/game_command.dart';
import 'package:sky_climb/game/bridge/game_event.dart';

final class GameBridge {
  final StreamController<GameCommand> _commandController =
      StreamController.broadcast();
  final StreamController<GameEvent> _eventController =
      StreamController.broadcast();

  Stream<GameCommand> get commands => _commandController.stream;
  Stream<GameEvent> get events => _eventController.stream;

  void send(GameCommand command) => _commandController.add(command);
  void emit(GameEvent event) => _eventController.add(event);

  Future<void> dispose() async {
    await _commandController.close();
    await _eventController.close();
  }
}
