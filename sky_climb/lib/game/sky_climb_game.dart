import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sky_climb/game/bridge/game_bridge.dart';
import 'package:sky_climb/game/bridge/game_command.dart';
import 'package:sky_climb/game/bridge/game_event.dart';
import 'package:sky_climb/game/level/level_definition.dart';
import 'package:sky_climb/game/level/level_loader.dart';
import 'package:sky_climb/game/world/sky_climb_world.dart';

final class SkyClimbGame extends FlameGame<SkyClimbWorld>
    with MultiTouchTapDetector, KeyboardEvents {
  SkyClimbGame({required this.bridge}) : super(world: SkyClimbWorld());

  static const double _fixedDt = 1 / 60;
  static const int _maxStepsPerFrame = 5;
  static const double _maxJumpChargeSeconds = 0.45;
  static const double _fallOutDistance = 900;
  static const int _maxLives = 3;
  static const double _respawnYOffset = 80;

  final GameBridge bridge;
  final LevelLoader _levelLoader = const LevelLoader();
  StreamSubscription<GameCommand>? _commandSub;
  double _accumulator = 0;

  double _moveAxis = 0;
  bool _isChargingJump = false;
  double _jumpChargeSeconds = 0;
  double? _pendingJumpStrength;

  double _runStartY = 0;
  double _minY = 0;
  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;
  int _lives = _maxLives;
  bool _isGameOver = false;

  LevelDefinition? _level;
  double? _activeCheckpointY;

  @override
  Future<void> onLoad() async {
    _commandSub = bridge.commands.listen(_onCommand);
    await super.onLoad();

    camera.viewfinder.anchor = Anchor.center;

    try {
      await _startNewRun();
      bridge.emit(const GameReadyEvent());
    } on Exception catch (e) {
      bridge.emit(GameErrorEvent(e.toString()));
    }
  }

  void _onCommand(GameCommand command) {
    switch (command) {
      case PauseCommand():
        pauseEngine();
      case ResumeCommand():
        resumeEngine();
      case JumpCommand():
        _queueJump(strength: 0);
      case SetMoveAxisCommand():
        _moveAxis = command.axis.clamp(-1.0, 1.0);
      case RestartCommand():
        unawaited(_startNewRun());
    }
  }

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    _startChargingJump();
  }

  @override
  void onTapUp(int pointerId, TapUpInfo info) {
    _releaseJump();
  }

  @override
  void onTapCancel(int pointerId) {
    _cancelJumpCharge();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final left =
        keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA);
    final right =
        keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD);
    _moveAxis = (right ? 1.0 : 0.0) + (left ? -1.0 : 0.0);

    final isJumpKey =
        event.logicalKey == LogicalKeyboardKey.space ||
        event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.keyW;
    if (isJumpKey) {
      if (event is KeyDownEvent) {
        _startChargingJump();
      } else if (event is KeyUpEvent) {
        _releaseJump();
      }
    }

    return KeyEventResult.handled;
  }

  @override
  void update(double dt) {
    _accumulator += dt;
    var steps = 0;
    while (_accumulator >= _fixedDt && steps < _maxStepsPerFrame) {
      _step(_fixedDt);
      _accumulator -= _fixedDt;
      steps += 1;
    }
    super.update(0);
  }

  void _step(double dt) {
    if (world.player == null) return;

    if (_isGameOver) {
      super.update(dt);
      return;
    }

    final player = world.player!..moveAxis = _moveAxis;
    if (_isChargingJump) {
      _jumpChargeSeconds = (_jumpChargeSeconds + dt).clamp(
        0.0,
        _maxJumpChargeSeconds,
      );
    }
    final pendingStrength = _pendingJumpStrength;
    if (pendingStrength != null) {
      player.queueJump(strength: pendingStrength);
      _pendingJumpStrength = null;
    }

    super.update(dt);

    final viewfinder = camera.viewfinder;
    viewfinder.position.setFrom(player.centerPoint);

    if (player.isDead) {
      _handleFail();
      return;
    }

    final playerY = player.position.y;
    _updateCheckpoint(playerY);

    if (player.isGrounded && _combo != 0) {
      _combo = 0;
      _emitHud();
    }

    if (player.position.y < _minY) {
      _minY = player.position.y;
      final newScore = (_runStartY - _minY).floor();
      if (newScore != _score) {
        if (!player.isGrounded) {
          _combo += 1;
          if (_combo > _maxCombo) _maxCombo = _combo;
        }
        _score = newScore;
        _emitHud();
      }
    }

    if (player.position.y > _minY + _fallOutDistance) {
      _handleFail();
    }
  }

  Future<void> _startNewRun() async {
    _isGameOver = false;
    _moveAxis = 0;
    _cancelJumpCharge();
    _pendingJumpStrength = null;
    _score = 0;
    _combo = 0;
    _maxCombo = 0;
    _lives = _maxLives;
    _activeCheckpointY = null;

    final level = await _levelLoader.load(
      assets,
      fileName: 'levels/level_001.json',
    );
    _level = level;
    await world.loadLevel(level);

    final player = world.player!;
    _runStartY = player.position.y;
    _minY = _runStartY;
    final viewfinder = camera.viewfinder;
    viewfinder.position.setFrom(player.centerPoint);
    _emitHud();
  }

  void _startChargingJump() {
    if (_isGameOver) return;
    if (_isChargingJump) return;
    _isChargingJump = true;
    _jumpChargeSeconds = 0;
  }

  void _releaseJump() {
    if (!_isChargingJump) return;
    final strength = (_jumpChargeSeconds / _maxJumpChargeSeconds).clamp(
      0.0,
      1.0,
    );
    _cancelJumpCharge();
    _queueJump(strength: strength);
  }

  void _cancelJumpCharge() {
    _isChargingJump = false;
    _jumpChargeSeconds = 0;
  }

  void _queueJump({required double strength}) {
    _pendingJumpStrength = strength.clamp(0.0, 1.0);
  }

  void _updateCheckpoint(double playerY) {
    final checkpoints = _level?.checkpoints;
    if (checkpoints == null || checkpoints.isEmpty) return;

    for (final cpY in checkpoints) {
      if (playerY <= cpY) {
        final current = _activeCheckpointY;
        if (current == null || cpY < current) {
          _activeCheckpointY = cpY;
        }
      }
    }
  }

  void _handleFail() {
    if (_isGameOver) return;
    _lives -= 1;
    _combo = 0;

    final checkpointY = _activeCheckpointY;
    final start = world.playerStart;
    if (_lives > 0 && checkpointY != null && start != null) {
      world.player?.reset(
        position: Vector2(start.x, checkpointY - _respawnYOffset),
      );
      _emitHud();
      return;
    }

    _isGameOver = true;
    bridge.emit(GameOverEvent(score: _score, maxCombo: _maxCombo));
  }

  void _emitHud() {
    bridge.emit(
      ScoreChangedEvent(
        score: _score,
        combo: _combo,
        maxCombo: _maxCombo,
        lives: _lives,
      ),
    );
  }

  @override
  Color backgroundColor() => const Color(0xFF05060A);

  @override
  void onRemove() {
    unawaited(_commandSub?.cancel());
    super.onRemove();
  }
}
