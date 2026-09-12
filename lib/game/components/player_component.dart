import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:planedriver_flame/game/assets/aircraft_sprite_repository.dart';
import 'package:planedriver_flame/game/models/aircraft_collision_profiles.dart';
import 'package:planedriver_flame/game/models/collision_geometry.dart';
import 'package:planedriver_flame/game/models/vehicle.dart';

class PlayerComponent extends PositionComponent with HasGameReference {
  PlayerComponent({required this.vehicle}) {
    size = Vector2(80, 60);
    anchor = Anchor.center;
    position = Vector2(100, 540);
  }

  final Vehicle vehicle;
  ui.Image? _aircraftImage;

  bool isCrashed = false;

  /// Steering wheel input: -1 = left, +1 = right.
  double turnInput = 0;

  /// Pedal input: -1 = reverse, +1 = forward.
  double moveInput = 0;

  // Original GameMaker-style ground movement. The source game does not use
  // a bicycle/wheelbase model: steering changes the sprite heading directly,
  // while forward/reverse changes one scalar speed value. Movement then always
  // follows the current body heading.
  double _speed = 0;

  // Keep the existing Flame speed envelope, but reproduce the original control
  // response: independent steering + scalar speed + friction/coast-down.
  static const double _directionChangeBrake = 1250;
  static const double _throttleDeadZone = 0.018;
  static const double _steeringDeadZone = 0.018;

  // Original GameMaker default: global.donus = 2 degrees per Step. At the
  // conventional 60 Steps/s this is 120 degrees/s. Analog input scales it, so
  // tiny lever movements still give tiny heading changes.
  static const double _stoppedSpeedEpsilon = 0.12;


  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _aircraftImage = await AircraftSpriteRepository.imageFor(vehicle.id);
  }

  double get speed => _speed;

  CollisionProfile get collisionProfile =>
      AircraftCollisionProfiles.forVehicle(vehicle.id);

  /// World-space wing/body/tail polygons used by collision, proximity and
  /// procedural-level validation. Keeping one source of truth avoids invisible
  /// collisions or a warning light that disagrees with gameplay.
  List<List<Vector2>> get worldCollisionPolygons =>
      CollisionGeometry.worldPolygons(
        profile: collisionProfile,
        center: position,
        size: size,
        angle: angle,
        inset: 0.96,
      );

  double get collisionRotationRadius => collisionProfile.maxRadiusForSize(size) * 0.96;

  @override
  void update(double dt) {
    super.update(dt);
    if (isCrashed) return;

    final step = dt.clamp(0.0, 1 / 30).toDouble();

    _updateOriginalSteering(step);
    _updateOriginalSpeed(step);
    _moveAlongBodyHeading(step);
  }

  void _updateOriginalSteering(double dt) {
    // Steering is deliberately independent of _speed: the original game
    // allows the plane to rotate in place around its center.
    final rawSteering = turnInput.clamp(-1.0, 1.0).toDouble();
    if (rawSteering.abs() < _steeringDeadZone) return;

    // GameMaker source:
    //   left  -> image_angle += global.donus
    //   right -> image_angle -= global.donus
    // Flame's screen-space angle convention is opposite to GameMaker's
    // image_angle convention, so +turnInput (right) increases Flame angle.
    angle += rawSteering * vehicle.handling.turnRateDegrees * pi / 180 * dt;
  }

  void _updateOriginalSpeed(double dt) {
    final rawThrottle = moveInput.clamp(-1.0, 1.0).toDouble();
    final magnitude = rawThrottle.abs();

    // GameMaker's built-in `friction = .1` continuously pulls speed toward 0.
    // In the Flame port we apply the same coast-down behavior when the pedal is
    // released so short taps remain short, controllable movements.
    if (magnitude < _throttleDeadZone) {
      _speed = _moveToward(_speed, 0, vehicle.handling.coastFriction * dt);
      if (_speed.abs() <= _stoppedSpeedEpsilon) _speed = 0;
      return;
    }

    final direction = rawThrottle.sign;
    final oppositeDirection =
        (_speed > 0 && direction < 0) || (_speed < 0 && direction > 0);

    if (oppositeDirection) {
      _speed = _moveToward(_speed, 0, _directionChangeBrake * dt);
      if (_speed.abs() <= _stoppedSpeedEpsilon) _speed = 0;
      return;
    }

    // Unlike the bicycle version, throttle does not alter steering geometry.
    // Keep the analog precision curve so small lever movements reproduce the
    // tiny incremental forward/reverse motion the original game is known for.
    final precisionMagnitude = pow(magnitude, 2.25).toDouble();
    final maxSpeed = direction > 0
        ? vehicle.handling.maxForwardSpeed
        : vehicle.handling.maxReverseSpeed;
    final targetSpeed = direction * maxSpeed * precisionMagnitude;

    final responseMultiplier =
        (0.92 + vehicle.acceleration * 0.10).clamp(0.88, 1.25).toDouble();
    _speed = _moveToward(
      _speed,
      targetSpeed,
      vehicle.handling.driveResponse * responseMultiplier * dt,
    );
  }

  void _moveAlongBodyHeading(double dt) {
    if (_speed.abs() <= _stoppedSpeedEpsilon) {
      _speed = 0;
      return;
    }

    // Exact structural equivalent of GameMaker: `direction = image_angle`.
    // There is no slip angle, wheelbase, front/rear axle or lateral velocity.
    position += Vector2(cos(angle), sin(angle)) * (_speed * dt);
  }

  double _moveToward(double current, double target, double maxDelta) {
    if ((target - current).abs() <= maxDelta) return target;
    return current + (target > current ? maxDelta : -maxDelta);
  }

  @override
  void render(Canvas canvas) {
    final image = _aircraftImage;
    if (image == null) {
      _renderPlaceholder(canvas);
      return;
    }

    // Source sprites face up. The movement model uses +X as the aircraft nose
    // at angle == 0, so rotate the artwork 90° clockwise around the exact
    // component center. Anchor.center therefore remains the true visual pivot.
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(pi / 2);

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

    // Soft contact shadow belongs to the shared Soft-Toy 3D language.
    final shadowDst = dst.shift(const Offset(3.5, 5.0));
    canvas.drawImageRect(
      image,
      src,
      shadowDst,
      Paint()
        ..colorFilter = const ColorFilter.mode(Color(0x55000000), BlendMode.srcIn)
        ..filterQuality = FilterQuality.high,
    );

    if (isCrashed) {
      canvas.drawImageRect(
        image,
        src,
        dst,
        Paint()
          ..colorFilter = const ColorFilter.mode(Color(0xFF777777), BlendMode.modulate)
          ..filterQuality = FilterQuality.high,
      );
    } else {
      // Hero treatment: slightly stronger saturation/contrast than structural
      // obstacle aircraft, without changing the authored palette.
      canvas.drawImageRect(
        image,
        src,
        dst,
        Paint()
          ..colorFilter = const ColorFilter.matrix(<double>[
            1.10, -0.03, -0.03, 0, 0,
            -0.03, 1.10, -0.03, 0, 0,
            -0.03, -0.03, 1.10, 0, 0,
            0, 0, 0, 1, 0,
          ])
          ..filterQuality = FilterQuality.high,
      );
    }
    canvas.restore();
  }

  void _renderPlaceholder(Canvas canvas) {
    final paint = Paint()..color = isCrashed ? const Color(0xFF777777) : const Color(0xFF33A8FF);
    final shadow = Paint()..color = const Color(0x44000000);
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(size.x / 2, size.y / 2), width: size.x * .82, height: size.y * .24),
      const Radius.circular(10),
    );
    final wings = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(size.x * .48, size.y / 2), width: size.x * .24, height: size.y * .86),
      const Radius.circular(8),
    );
    canvas.save();
    canvas.translate(3, 4);
    canvas.drawRRect(wings, shadow);
    canvas.drawRRect(body, shadow);
    canvas.restore();
    canvas.drawRRect(wings, paint);
    canvas.drawRRect(body, paint);
    canvas.drawCircle(Offset(size.x * .86, size.y / 2), size.y * .11, paint);
  }

  void crash() {
    isCrashed = true;
    _speed = 0;
  }
}
