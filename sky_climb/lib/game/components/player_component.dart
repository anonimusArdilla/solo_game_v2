import 'dart:ui';

import 'package:flame/components.dart';
import 'package:sky_climb/game/components/hazard_component.dart';
import 'package:sky_climb/game/components/platform_component.dart';

final class PlayerComponent extends RectangleComponent {
  PlayerComponent({
    required super.position,
    required this.platforms,
    required this.hazards,
  }) : super(
         size: Vector2.all(28),
         paint: Paint()..color = const Color(0xFF00E5FF),
       );

  static const double _gravity = 2200;
  static const double _jumpVelocity = 760;
  static const double _extraJumpVelocity = 520;
  static const double _moveSpeed = 240;
  static const double _groundAccel = 2200;
  static const double _airAccel = 1400;
  static const double _groundFriction = 2600;
  static const double _maxFallSpeed = 1400;
  static const double _coyoteTimeSeconds = 0.08;
  static const double _jumpBufferSeconds = 0.10;

  final List<PlatformComponent> platforms;
  final List<HazardComponent> hazards;

  final Vector2 velocity = Vector2.zero();

  double moveAxis = 0;
  bool _jumpQueued = false;
  double _jumpStrength = 0;
  double _jumpBufferTimer = 0;
  double _coyoteTimer = 0;
  bool _isGrounded = false;
  bool _isDead = false;

  bool get isDead => _isDead;
  bool get isGrounded => _isGrounded;

  void reset({required Vector2 position}) {
    this.position.setFrom(position);
    velocity.setZero();
    _jumpQueued = false;
    _jumpStrength = 0;
    _jumpBufferTimer = 0;
    _coyoteTimer = 0;
    _isGrounded = false;
    _isDead = false;
  }

  void queueJump({double strength = 0}) {
    _jumpQueued = true;
    _jumpStrength = strength.clamp(0.0, 1.0);
    _jumpBufferTimer = _jumpBufferSeconds;
  }

  Vector2 get centerPoint =>
      Vector2(position.x + size.x / 2, position.y + size.y / 2);

  @override
  void update(double dt) {
    super.update(dt);

    _jumpBufferTimer = (_jumpBufferTimer - dt).clamp(0.0, _jumpBufferSeconds);
    if (_isGrounded) {
      _coyoteTimer = _coyoteTimeSeconds;
    } else {
      _coyoteTimer = (_coyoteTimer - dt).clamp(0.0, _coyoteTimeSeconds);
    }

    final canJump = _isGrounded || _coyoteTimer > 0;
    if (_jumpQueued && _jumpBufferTimer > 0 && canJump) {
      velocity.y = -(_jumpVelocity + _extraJumpVelocity * _jumpStrength);
      _isGrounded = false;
      _coyoteTimer = 0;
      _jumpBufferTimer = 0;
    }
    _jumpQueued = false;
    _jumpStrength = 0;

    final targetX = moveAxis.clamp(-1.0, 1.0) * _moveSpeed;
    if (_isGrounded) {
      if (targetX == 0) {
        velocity.x = _moveTowards(velocity.x, 0, _groundFriction * dt);
      } else {
        velocity.x = _moveTowards(velocity.x, targetX, _groundAccel * dt);
      }
    } else {
      velocity.x = _moveTowards(velocity.x, targetX, _airAccel * dt);
    }
    velocity.y = (velocity.y + _gravity * dt).clamp(
      -(_jumpVelocity + _extraJumpVelocity),
      _maxFallSpeed,
    );

    final previousPosition = position.clone();
    position.add(velocity * dt);

    _resolveCollisions(previousPosition);
  }

  double _moveTowards(double current, double target, double maxDelta) {
    final delta = target - current;
    if (delta.abs() <= maxDelta) return target;
    return current + delta.sign * maxDelta;
  }

  void _resolveCollisions(Vector2 previousPosition) {
    _isGrounded = false;

    final playerRect = Rect.fromLTWH(position.x, position.y, size.x, size.y);
    final previousBottom = previousPosition.y + size.y;

    for (final platform in platforms) {
      final platformRect = platform.rect;
      if (!playerRect.overlaps(platformRect)) continue;

      final landingFromAbove =
          velocity.y >= 0 && previousBottom <= platformRect.top + 1;
      if (landingFromAbove) {
        position.y = platformRect.top - size.y;
        velocity.y = 0;
        _isGrounded = true;
      }
    }

    for (final hazard in hazards) {
      if (!playerRect.overlaps(hazard.rect)) continue;
      _isDead = true;
      break;
    }
  }
}
