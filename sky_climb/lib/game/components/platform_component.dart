import 'dart:ui';

import 'package:flame/components.dart';

final class PlatformComponent extends RectangleComponent {
  PlatformComponent({required super.position, required super.size})
    : super(paint: Paint()..color = const Color(0xFF1B1E2A));

  Rect get rect => Rect.fromLTWH(position.x, position.y, size.x, size.y);
}
