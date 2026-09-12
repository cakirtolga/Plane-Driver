import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:planedriver_flame/utils/constants.dart';
import 'package:planedriver_flame/utils/plane_art_direction.dart';

class RunwayBackgroundComponent extends PositionComponent {
  static const double _bleedX = 1200;
  static const double _bleedY = 720;

  RunwayBackgroundComponent()
      : super(
          position: Vector2(-_bleedX, -_bleedY),
          size: Vector2(
            GameConstants.gameWidth + _bleedX * 2,
            GameConstants.gameHeight + _bleedY * 2,
          ),
          anchor: Anchor.topLeft,
          priority: -1000,
        );

  Offset _world(double x, double y) => Offset(x + _bleedX, y + _bleedY);

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = PlaneArtDirection.apronBase);

    // Large satin concrete slabs: visible enough to give depth, quiet enough
    // that aircraft remain the visual focus.
    final seam = Paint()
      ..color = PlaneArtDirection.apronSeam.withValues(alpha: .46)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    for (double x = 0; x < size.x; x += 240) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), seam);
    }
    for (double y = 0; y < size.y; y += 180) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), seam);
    }

    final highlight = Paint()
      ..color = Colors.white.withValues(alpha: .035)
      ..strokeWidth = 1.2;
    for (double y = 2; y < size.y; y += 180) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), highlight);
    }

    final rnd = Random(91);
    final speck = Paint()..color = Colors.white.withValues(alpha: .025);
    for (var i = 0; i < 520; i++) {
      canvas.drawCircle(
        Offset(rnd.nextDouble() * size.x, rnd.nextDouble() * size.y),
        rnd.nextDouble() * 1.1 + .25,
        speck,
      );
    }

    // Warm taxi centerline.
    final yellow = Paint()
      ..color = PlaneArtDirection.taxiYellow.withValues(alpha: .92)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      _world(-_bleedX, GameConstants.gameHeight * .5),
      _world(GameConstants.gameWidth + _bleedX, GameConstants.gameHeight * .5),
      yellow,
    );

    // White service lanes.
    final service = Paint()
      ..color = PlaneArtDirection.serviceWhite.withValues(alpha: .74)
      ..strokeWidth = 3.5;
    canvas.drawLine(_world(-_bleedX, 78), _world(GameConstants.gameWidth + _bleedX, 78), service);
    canvas.drawLine(_world(-_bleedX, GameConstants.gameHeight - 78), _world(GameConstants.gameWidth + _bleedX, GameConstants.gameHeight - 78), service);

    // Parking stands use the same restrained amber language as the controls.
    final bay = Paint()
      ..color = PlaneArtDirection.taxiYellow.withValues(alpha: .68)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    for (double x = 155; x < GameConstants.gameWidth; x += 310) {
      canvas.drawLine(_world(x, 122), _world(x, 258), bay);
      canvas.drawLine(_world(x - 72, 258), _world(x + 72, 258), bay);
      canvas.drawLine(_world(x, GameConstants.gameHeight - 122), _world(x, GameConstants.gameHeight - 258), bay);
      canvas.drawLine(_world(x - 72, GameConstants.gameHeight - 258), _world(x + 72, GameConstants.gameHeight - 258), bay);
    }

    // Red/yellow safety curb bands at world edges.
    final curbY = [18.0, GameConstants.gameHeight - 30.0];
    for (final y in curbY) {
      for (double x = 0; x < GameConstants.gameWidth; x += 72) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(_bleedX + x, _bleedY + y, 68, 12),
            const Radius.circular(3),
          ),
          Paint()..color = ((x ~/ 72).isEven)
              ? PlaneArtDirection.taxiYellow
              : PlaneArtDirection.dangerCoral,
        );
      }
    }
  }
}
