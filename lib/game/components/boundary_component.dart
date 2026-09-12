import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum BoundaryEdge { left, top, bottom }

class BoundaryComponent extends PositionComponent {
  BoundaryComponent.left({required double x})
      : edge = BoundaryEdge.left,
        super(
          position: Vector2(x, 540),
          size: Vector2(10, 1080),
          anchor: Anchor.center,
        );

  BoundaryComponent.top()
      : edge = BoundaryEdge.top,
        super(
          position: Vector2(960, 0),
          size: Vector2(1920, 40),
          anchor: Anchor.center,
        );

  BoundaryComponent.bottom()
      : edge = BoundaryEdge.bottom,
        super(
          position: Vector2(960, 1080),
          size: Vector2(1920, 40),
          anchor: Anchor.center,
        );

  final BoundaryEdge edge;

  @override
  Future<void> onLoad() async {
    await add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    if (edge == BoundaryEdge.left) return;

    final isTop = edge == BoundaryEdge.top;
    final gradient = LinearGradient(
      begin: isTop ? Alignment.topCenter : Alignment.bottomCenter,
      end: isTop ? Alignment.bottomCenter : Alignment.topCenter,
      colors: [
        Colors.red.shade700,
        Colors.red.withValues(alpha: 0.3),
      ],
    );

    canvas.drawRect(
      size.toRect(),
      Paint()
        ..shader = gradient.createShader(size.toRect())
        ..style = PaintingStyle.fill,
    );

    // Striped warning pattern
    final stripeWidth = 40.0;
    for (var x = 0.0; x < size.x; x += stripeWidth * 2) {
      canvas.drawRect(
        Rect.fromLTWH(x, 0, stripeWidth, size.y),
        Paint()
          ..color = Colors.yellow.withValues(alpha: 0.6)
          ..style = PaintingStyle.fill,
      );
    }
  }
}
