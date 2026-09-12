import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:planedriver_flame/utils/plane_art_direction.dart';

class FinishComponent extends PositionComponent {
  FinishComponent({required Vector2 position})
      : super(position: position, size: Vector2(108, 286), anchor: Anchor.center);

  @override
  Future<void> onLoad() async => add(RectangleHitbox());

  @override
  void render(Canvas canvas) {
    final outer = RRect.fromRectAndRadius(size.toRect(), const Radius.circular(22));
    canvas.drawRRect(outer.shift(const Offset(0, 6)), Paint()..color = const Color(0x44000000));
    canvas.drawRRect(outer, Paint()..color = PlaneArtDirection.uiNavyDeep);
    canvas.drawRRect(
      outer.deflate(4),
      Paint()
        ..color = PlaneArtDirection.uiEdge.withValues(alpha: .78)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(13, 13, size.x - 26, size.y - 26),
      const Radius.circular(15),
    );
    canvas.drawRRect(inner, Paint()..color = const Color(0xFF376E18));
    canvas.drawRRect(
      inner,
      Paint()
        ..color = PlaneArtDirection.exitGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );

    // Four restrained runway-style goal lamps.
    for (final p in <Offset>[
      const Offset(20, 22),
      Offset(size.x - 20, 22),
      Offset(20, size.y - 22),
      Offset(size.x - 20, size.y - 22),
    ]) {
      canvas.drawCircle(p, 7, Paint()..color = PlaneArtDirection.exitGreen.withValues(alpha: .20));
      canvas.drawCircle(p, 3.5, Paint()..color = PlaneArtDirection.exitGreen);
    }

    final chevron = Paint()
      ..color = PlaneArtDirection.exitGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (var i = 0; i < 3; i++) {
      final y = 78.0 + i * 40;
      final p = Path()
        ..moveTo(size.x * .31, y - 15)
        ..lineTo(size.x * .61, y)
        ..lineTo(size.x * .31, y + 15);
      canvas.drawPath(p, chevron);
    }

    final tp = TextPainter(
      text: const TextSpan(
        text: 'EXIT',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.8,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(size.x / 2, size.y - 47);
    canvas.rotate(-1.5708);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }
}
