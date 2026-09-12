import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:planedriver_flame/utils/theme.dart';
import 'package:planedriver_flame/utils/plane_art_direction.dart';
import 'package:planedriver_flame/game/models/level_data.dart';

class StarHudComponent extends PositionComponent with HasGameReference {
  StarHudComponent({
    required this.levelData,
    required this.elapsedSeconds,
  }) : super(anchor: Anchor.topLeft, priority: 900);

  final LevelData levelData;
  final double Function() elapsedSeconds;

  @override
  Future<void> onLoad() async {
    position = Vector2(18, 18);
    size = Vector2(154, 54);
  }

  @override
  void render(Canvas canvas) {
    final shell = RRect.fromRectAndRadius(size.toRect(), const Radius.circular(18));
    canvas.drawRRect(shell.shift(const Offset(0, 4)), Paint()..color = const Color(0x33000000));
    canvas.drawRRect(shell, Paint()..color = PlaneArtDirection.uiNavy.withValues(alpha: .94));
    canvas.drawRRect(shell, Paint()..color = PlaneArtDirection.uiEdge.withValues(alpha: .60)..style = PaintingStyle.stroke..strokeWidth = 2);
    final fillStars = levelData.starsForTime(elapsedSeconds());
    for (var i = 0; i < 3; i++) {
      final center = Offset(31 + i * 46.0, 27);
      canvas.drawPath(
        _starPath(center, 18),
        Paint()
          ..color = i < fillStars ? PlaneDriverTheme.yellow : const Color(0xFF58748D)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        _starPath(center, 18),
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  Path _starPath(Offset center, double radius) {
    final path = Path();
    const points = 5;
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : radius * 0.45;
      final angle = (i * pi / points) - pi / 2;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }
}
