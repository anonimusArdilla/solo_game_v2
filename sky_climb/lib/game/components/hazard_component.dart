import 'dart:ui';

import 'package:flame/components.dart';

final class HazardComponent extends RectangleComponent {
  HazardComponent({required super.position, required super.size})
    : super(paint: Paint()..color = const Color(0xFFFF2D55));

  Rect get rect => Rect.fromLTWH(position.x, position.y, size.x, size.y);
}
