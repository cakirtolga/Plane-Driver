import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:planedriver_flame/utils/plane_art_direction.dart';

class TimerHudComponent extends PositionComponent with HasGameReference {
  TimerHudComponent() : super(size: Vector2(154, 54), anchor: Anchor.topRight, priority: 950);
  double elapsedTime = 0;

  @override
  Future<void> onLoad() async { position = Vector2(game.size.x - 82, 18); }

  @override
  void update(double dt) { super.update(dt); elapsedTime += dt; }

  @override
  void onGameResize(Vector2 size) { super.onGameResize(size); position = Vector2(size.x - 82, 18); }

  @override
  void render(Canvas canvas) {
    final r = RRect.fromRectAndRadius(size.toRect(), const Radius.circular(18));
    canvas.drawRRect(r.shift(const Offset(0, 4)), Paint()..color = const Color(0x33000000));
    canvas.drawRRect(r, Paint()..color = PlaneArtDirection.uiNavy.withValues(alpha: .94));
    canvas.drawRRect(r, Paint()..color = PlaneArtDirection.uiEdge.withValues(alpha: .60)..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawCircle(const Offset(27, 27), 13, Paint()..color = Colors.white.withValues(alpha: .12));
    canvas.drawCircle(const Offset(27, 27), 10, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2.4);
    canvas.drawLine(const Offset(27, 27), const Offset(27, 20), Paint()..color = Colors.white..strokeWidth = 2.4..strokeCap = StrokeCap.round);
    canvas.drawLine(const Offset(27, 27), const Offset(33, 30), Paint()..color = Colors.white..strokeWidth = 2.4..strokeCap = StrokeCap.round);
    final tp = TextPainter(text: TextSpan(text: '${elapsedTime.toStringAsFixed(1)}s', style: const TextStyle(color: Colors.white,fontSize:22,fontWeight:FontWeight.w900)),textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(49, (size.y - tp.height)/2));
  }
}
