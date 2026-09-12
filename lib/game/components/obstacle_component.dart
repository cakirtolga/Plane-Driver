import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:planedriver_flame/game/assets/aircraft_sprite_repository.dart';
import 'package:planedriver_flame/game/assets/obstacle_aircraft_sprite_repository.dart';
import 'package:planedriver_flame/game/assets/obstacle_sprite_repository.dart';
import 'package:planedriver_flame/game/models/aircraft_collision_profiles.dart';
import 'package:planedriver_flame/game/models/collision_geometry.dart';
import 'package:planedriver_flame/game/models/level_data.dart';
import 'package:planedriver_flame/game/models/obstacle_collision_profiles.dart';

class ObstacleComponent extends PositionComponent {
  ObstacleComponent({required this.definition})
      : super(
          position: definition.position,
          angle: definition.angle,
          anchor: Anchor.center,
        );

  final ObstacleDef definition;
  ui.Image? _image;
  int _planeVehicleId = 1;
  String? _spriteKey;
  bool _usesDedicatedAircraftSprite = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (definition.kind == ObstacleKind.plane) {
      _spriteKey = definition.spriteKey;
      _usesDedicatedAircraftSprite = ObstacleAircraftSpriteRepository.containsKey(_spriteKey);
      if (_usesDedicatedAircraftSprite) {
        size = ObstacleAircraftSpriteRepository.gameplaySizeForKey(_spriteKey) * definition.size;
        _image = await ObstacleAircraftSpriteRepository.imageFor(_spriteKey!);
      } else {
        size = ObstacleCollisionProfiles.baseSize(definition.kind) * definition.size;
        _planeVehicleId = AircraftSpriteRepository.obstacleVehicleId(
          definition.position.x,
          definition.position.y,
        );
        _image = await AircraftSpriteRepository.imageFor(_planeVehicleId);
      }
    } else {
      _spriteKey = definition.spriteKey ?? ObstacleSpriteRepository.defaultKeyFor(
        definition.kind,
        definition.position.x,
        definition.position.y,
      );
      size = ObstacleSpriteRepository.gameplaySizeForKey(_spriteKey) * definition.size;
      _image = await ObstacleSpriteRepository.imageFor(_spriteKey);
    }
  }

  CollisionProfile get collisionProfile {
    if (definition.kind == ObstacleKind.plane) {
      if (_usesDedicatedAircraftSprite) {
        return ObstacleAircraftSpriteRepository.collisionProfileForKey(_spriteKey);
      }
      return AircraftCollisionProfiles.forVehicle(_planeVehicleId);
    }
    return ObstacleCollisionProfiles.forKind(definition.kind);
  }

  List<List<Vector2>> get worldCollisionPolygons =>
      CollisionGeometry.worldPolygons(
        profile: collisionProfile,
        center: position,
        size: size,
        angle: angle,
        inset: definition.kind == ObstacleKind.plane ? 0.97 : 0.94,
      );

  double get collisionRadius =>
      collisionProfile.maxRadiusForSize(size) *
      (definition.kind == ObstacleKind.plane ? .98 : .95);

  @override
  void render(Canvas canvas) {
    final image = _image;
    if (image == null) {
      _renderFallback(canvas);
      return;
    }

    if (definition.kind == ObstacleKind.plane) {
      _renderPlane(canvas, image);
    } else {
      _renderTopDownObstacle(canvas, image);
    }
  }

  void _renderPlane(Canvas canvas, ui.Image image) {
    // Aircraft art is authored nose-up. Collision/gameplay longitudinal axis is
    // +X, so rotate the artwork once inside the centered component. The
    // PositionComponent angle then rotates both sprite and collision together.
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(math.pi / 2);
    final src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final dst = Rect.fromCenter(
      center: Offset.zero,
      width: size.y,
      height: size.x,
    );
    canvas.drawImageRect(
      image,
      src,
      dst.shift(const Offset(3.5, 5.0)),
      Paint()
        ..colorFilter = const ColorFilter.mode(Color(0x44000000), BlendMode.srcIn)
        ..filterQuality = FilterQuality.high,
    );
    canvas.drawImageRect(
      image,
      src,
      dst,
      Paint()
        ..colorFilter = const ColorFilter.matrix(<double>[
          0.94, 0.02, 0.02, 0, 0,
          0.02, 0.94, 0.02, 0, 0,
          0.02, 0.02, 0.94, 0, 0,
          0, 0, 0, 1, 0,
        ])
        ..filterQuality = FilterQuality.high,
    );
    canvas.restore();
  }

  void _renderTopDownObstacle(Canvas canvas, ui.Image image) {
    final src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );

    if (ObstacleSpriteRepository.quarterTurnKeys.contains(_spriteKey)) {
      canvas.save();
      canvas.translate(size.x / 2, size.y / 2);
      canvas.rotate(math.pi / 2);
      final dst = Rect.fromCenter(
        center: Offset.zero,
        width: size.y,
        height: size.x,
      );
      canvas.drawImageRect(
        image,
        src,
        dst.shift(const Offset(3, 4)),
        Paint()
          ..colorFilter = const ColorFilter.mode(Color(0x40000000), BlendMode.srcIn)
          ..filterQuality = FilterQuality.medium,
      );
      canvas.drawImageRect(
        image,
        src,
        dst,
        Paint()..filterQuality = FilterQuality.high,
      );
      canvas.restore();
      return;
    }

    final dst = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawImageRect(
      image,
      src,
      dst.shift(const Offset(3, 4)),
      Paint()
        ..colorFilter = const ColorFilter.mode(Color(0x40000000), BlendMode.srcIn)
        ..filterQuality = FilterQuality.medium,
    );
    canvas.drawImageRect(
      image,
      src,
      dst,
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  void _renderFallback(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Radius.circular(math.min(size.x, size.y) * .18),
      ),
      Paint()..color = const Color(0xFFF7B32B),
    );
  }
}
