import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:planedriver_flame/utils/theme.dart';

/// Compact peripheral-vision proximity light. It stays quiet when the nearest
/// obstacle is comfortably far away, then shifts yellow -> orange -> red and
/// pulses only in the critical zone.
class ProximityWarningComponent extends PositionComponent with HasGameReference {
  ProximityWarningComponent() : super(anchor: Anchor.topCenter, priority: 1000);

  double _normalizedRisk = 0;
  double _relativeDirection = 0;
  double _pulseTime = 0;

  void setProximity({required double normalizedRisk, required double relativeDirection}) {
    _normalizedRisk = normalizedRisk.clamp(0.0, 1.0).toDouble();
    _relativeDirection = relativeDirection.clamp(-1.0, 1.0).toDouble();
  }

  @override
  Future<void> onLoad() async {
    size = Vector2(190, 42);
    position = Vector2(game.size.x / 2, 18);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position = Vector2(size.x / 2, 18);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTime += dt;
  }

  @override
  void render(Canvas canvas) {
    if (_normalizedRisk < .08) return;

    final critical = _normalizedRisk > .82;
    final pulse = critical ? .82 + math.sin(_pulseTime * 10) * .18 : 1.0;
    final opacity = (.34 + _normalizedRisk * .66) * pulse;

    final panel = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(21),
    );
    canvas.drawRRect(
      panel,
      Paint()..color = PlaneDriverTheme.navyDeep.withValues(alpha: .62 * opacity),
    );

    final riskColor = _riskColor(_normalizedRisk);
    final center = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(
      center,
      11 + _normalizedRisk * 3,
      Paint()..color = riskColor.withValues(alpha: opacity),
    );
    canvas.drawCircle(
      center,
      17,
      Paint()
        ..color = riskColor.withValues(alpha: .30 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );

    // Directional side bars show which wing/tail side is closest without
    // forcing the player to read text during a precision maneuver.
    final leftStrength = _relativeDirection < 0 ? _relativeDirection.abs() : .15;
    final rightStrength = _relativeDirection > 0 ? _relativeDirection.abs() : .15;
    _drawSideBar(canvas, 20, leftStrength, riskColor, opacity);
    _drawSideBar(canvas, size.x - 20, rightStrength, riskColor, opacity);
  }

  void _drawSideBar(
    Canvas canvas,
    double x,
    double directionStrength,
    Color color,
    double opacity,
  ) {
    final strength = (.18 + directionStrength * .82) * _normalizedRisk;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, size.y / 2),
          width: 9,
          height: 10 + 18 * strength,
        ),
        const Radius.circular(5),
      ),
      Paint()..color = color.withValues(alpha: opacity * strength),
    );
  }

  Color _riskColor(double risk) {
    if (risk >= .72) return PlaneDriverTheme.coral;
    if (risk >= .42) return PlaneDriverTheme.orange;
    return PlaneDriverTheme.yellow;
  }
}
