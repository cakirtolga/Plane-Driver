import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ExplosionComponent extends PositionComponent {
  ExplosionComponent({required Vector2 position})
      : super(position: position, anchor: Anchor.center);

  double _elapsed = 0;
  static const double _duration = 0.6;

  @override
  Future<void> onLoad() async {
    size = Vector2.all(120);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= _duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = _elapsed / _duration;
    const particleCount = 12;
    final radius = 50 * progress;

    for (var i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * pi;
      final offset = Offset(
        cos(angle) * radius,
        sin(angle) * radius,
      );
      final particleSize = 12 * (1 - progress);
      final color = [
        Colors.orange,
        Colors.red,
        Colors.yellow,
      ][i % 3];

      canvas.drawCircle(
        offset,
        particleSize,
        Paint()
          ..color = color.withValues(alpha: 1 - progress)
          ..style = PaintingStyle.fill,
      );
    }

    canvas.drawCircle(
      Offset.zero,
      30 * progress,
      Paint()
        ..color = Colors.orange.withValues(alpha: 0.5 * (1 - progress))
        ..style = PaintingStyle.fill,
    );
  }
}
