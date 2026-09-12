import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class NearMissFeedbackComponent extends PositionComponent
    with HasGameReference {
  NearMissFeedbackComponent() : super(anchor: Anchor.topCenter, priority: 1100);

  double _remaining = 0;
  double _duration = 0;
  String _label = '';
  Color _color = const Color(0xFFFFD54F);

  @override
  Future<void> onLoad() async {
    size = Vector2(360, 82);
    position = Vector2(game.size.x / 2, 72);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position = Vector2(size.x / 2, 72);
  }

  void show({required double clearance}) {
    final perfect = clearance <= 12;
    _label = perfect ? 'PERFECT!' : 'CLOSE CALL!';
    _color = perfect ? const Color(0xFF69F0AE) : const Color(0xFFFFD54F);
    _duration = perfect ? 1.05 : .85;
    _remaining = _duration;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _remaining = math.max(0, _remaining - dt);
  }

  @override
  void render(Canvas canvas) {
    if (_remaining <= 0 || _duration <= 0) return;
    final progress = 1 - _remaining / _duration;
    final alpha = progress < .18
        ? (progress / .18).clamp(0.0, 1.0)
        : (1 - (progress - .62).clamp(0.0, .38) / .38);
    final scale = 1 + math.sin(progress * math.pi) * .08;
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.scale(scale, scale);
    final painter = TextPainter(
      text: TextSpan(
        text: _label,
        style: TextStyle(
          color: _color.withValues(alpha: alpha),
          fontSize: 34,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.4,
          shadows: [
            Shadow(color: Colors.black.withValues(alpha: .55 * alpha), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
    canvas.restore();
  }
}
