import 'package:flame/components.dart';
import 'package:planedriver_flame/game/models/collision_geometry.dart';
import 'package:planedriver_flame/game/models/level_data.dart';

class ObstacleCollisionProfiles {
  ObstacleCollisionProfiles._();

  static CollisionProfile forKind(ObstacleKind kind) {
    switch (kind) {
      case ObstacleKind.plane:
        return plane;
      case ObstacleKind.pushbackTug:
        return compactVehicle;
      case ObstacleKind.baggageCart:
        return longVehicle;
      case ObstacleKind.serviceTruck:
        return serviceVehicle;
      case ObstacleKind.environmentSmall:
        return smallProp;
      case ObstacleKind.environmentMedium:
        return mediumProp;
      case ObstacleKind.environmentLong:
        return longProp;
      case ObstacleKind.lightPole:
        return poleProp;
    }
  }

  static final CollisionProfile plane = CollisionProfile(polygons: [
    [
      Vector2(.46, 0), Vector2(.34, -.075), Vector2(-.30, -.085),
      Vector2(-.46, -.04), Vector2(-.49, 0), Vector2(-.46, .04),
      Vector2(-.30, .085), Vector2(.34, .075),
    ],
    [Vector2(.10, -.055), Vector2(-.07, -.46), Vector2(-.24, -.46), Vector2(-.20, -.075), Vector2(-.02, -.055)],
    [Vector2(.10, .055), Vector2(-.02, .055), Vector2(-.20, .075), Vector2(-.24, .46), Vector2(-.07, .46)],
    [Vector2(-.28, -.045), Vector2(-.37, -.22), Vector2(-.47, -.22), Vector2(-.41, -.035)],
    [Vector2(-.28, .045), Vector2(-.41, .035), Vector2(-.47, .22), Vector2(-.37, .22)],
  ]);

  static final CollisionProfile compactVehicle = CollisionProfile(polygons: [
    [Vector2(.44,-.31), Vector2(.48,-.18), Vector2(.48,.18), Vector2(.40,.32), Vector2(-.36,.32), Vector2(-.46,.20), Vector2(-.46,-.20), Vector2(-.36,-.32)],
  ]);

  static final CollisionProfile longVehicle = CollisionProfile(polygons: [
    [Vector2(.47,-.27), Vector2(.49,-.17), Vector2(.49,.17), Vector2(.44,.28), Vector2(-.44,.28), Vector2(-.49,.17), Vector2(-.49,-.17), Vector2(-.44,-.28)],
  ]);

  static final CollisionProfile serviceVehicle = CollisionProfile(polygons: [
    [Vector2(.46,-.29), Vector2(.49,-.18), Vector2(.49,.18), Vector2(.42,.31), Vector2(-.42,.31), Vector2(-.49,.18), Vector2(-.49,-.18), Vector2(-.42,-.31)],
  ]);

  static final CollisionProfile smallProp = CollisionProfile(polygons: [
    [Vector2(.34,-.34), Vector2(.42,-.20), Vector2(.42,.20), Vector2(.34,.34), Vector2(-.34,.34), Vector2(-.42,.20), Vector2(-.42,-.20), Vector2(-.34,-.34)],
  ]);

  static final CollisionProfile mediumProp = CollisionProfile(polygons: [
    [Vector2(.42,-.36), Vector2(.48,-.20), Vector2(.48,.20), Vector2(.42,.36), Vector2(-.42,.36), Vector2(-.48,.20), Vector2(-.48,-.20), Vector2(-.42,-.36)],
  ]);

  static final CollisionProfile longProp = CollisionProfile(polygons: [
    [Vector2(.48,-.24), Vector2(.49,.24), Vector2(-.49,.24), Vector2(-.49,-.24)],
  ]);

  static final CollisionProfile poleProp = CollisionProfile(polygons: [
    [Vector2(.28,-.28), Vector2(.36,-.12), Vector2(.36,.12), Vector2(.28,.28), Vector2(-.28,.28), Vector2(-.36,.12), Vector2(-.36,-.12), Vector2(-.28,-.28)],
  ]);

  static Vector2 baseSize(ObstacleKind kind) {
    switch (kind) {
      case ObstacleKind.plane:
        return Vector2(150, 100);
      case ObstacleKind.pushbackTug:
        return Vector2(44, 32);
      case ObstacleKind.baggageCart:
        return Vector2(60, 24);
      case ObstacleKind.serviceTruck:
        return Vector2(60, 34);
      case ObstacleKind.environmentSmall:
        return Vector2(18, 18);
      case ObstacleKind.environmentMedium:
        return Vector2(34, 30);
      case ObstacleKind.environmentLong:
        return Vector2(56, 20);
      case ObstacleKind.lightPole:
        return Vector2(22, 22);
    }
  }
}
