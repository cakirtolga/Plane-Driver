import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:planedriver_flame/game/assets/obstacle_aircraft_sprite_repository.dart';
import 'package:planedriver_flame/game/models/aircraft_collision_profiles.dart';
import 'package:planedriver_flame/game/models/collision_geometry.dart';
import 'package:planedriver_flame/game/models/level_data.dart';
import 'package:planedriver_flame/game/models/obstacle_collision_profiles.dart';
import 'package:planedriver_flame/game/models/vehicle.dart';
import 'package:planedriver_flame/utils/constants.dart';

abstract class LevelGenerator {
  LevelData generate(int levelId);
}

enum EncounterPattern {
  wideGate,
  offsetGate,
  slalom,
  planeNoseGap,
  serviceLane,
  chicane,
  precisionPocket,
  mixedApron,
  heavyAircraftGate,
  staggeredAirliners,
}

/// Infinite deterministic level generator. It first creates a hidden solvable
/// route, then places designed encounter patterns around that route, and only
/// accepts the level after aircraft-aware validation succeeds.
class ProceduralLevelGenerator implements LevelGenerator {
  ProceduralLevelGenerator({
    required this.vehicle,
    this.adaptiveBias = 0,
  });

  final Vehicle vehicle;

  /// -0.18..+0.12. Negative values quietly soften a run after repeated fails;
  /// positive values gently challenge a player consistently earning 3 stars.
  final double adaptiveBias;

  static const double _topPlayable = 120;
  static const double _bottomPlayable = 960;
  static const double _startSafeX = 300;
  static const double _finishSafeX = 1690;

  @override
  LevelData generate(int levelId) {
    final level = levelId < 1 ? 1 : levelId;
    final aircraftSize = Vector2(80, 60);
    final profile = AircraftCollisionProfiles.forVehicle(vehicle.id);
    final rotationRadius = profile.maxRadiusForSize(aircraftSize) * .96;
    final difficulty = _difficultyFor(level);

    // Deterministic: retrying the same level with the same aircraft always
    // presents the same authored-feeling layout.
    final baseSeed = level * 73856093 ^ vehicle.id * 19349663;

    for (var attempt = 0; attempt < 18; attempt++) {
      final random = math.Random(baseSeed + attempt * 83492791);
      final route = _buildSafeRoute(random, difficulty, rotationRadius);
      final build = _buildEncounters(
        random: random,
        route: route,
        difficulty: difficulty,
        rotationRadius: rotationRadius,
      );

      final candidate = _toLevelData(
        level: level,
        route: route,
        obstacles: build.obstacles,
        encounterNames: build.names,
        difficulty: difficulty,
      );

      if (LevelSolvabilityValidator(
        vehicle: vehicle,
        minClearance: _validationClearance(difficulty),
      ).validate(candidate)) {
        return candidate;
      }
    }

    // Fail-safe layout: even if an extreme random combination is rejected,
    // gameplay never receives an impossible level.
    final fallbackRoute = <Vector2>[
      GameConstants.playerStart.clone(),
      Vector2(650, 540),
      Vector2(1150, 540),
      Vector2(1600, 540),
      GameConstants.finishPosition.clone(),
    ];
    return _toLevelData(
      level: level,
      route: fallbackRoute,
      obstacles: [
        ObstacleDef(
          position: Vector2(760, 260),
          kind: ObstacleKind.pushbackTug,
          angle: math.pi / 2,
        ),
        ObstacleDef(
          position: Vector2(1110, 810),
          kind: ObstacleKind.plane,
          size: 1.05,
          angle: -.12,
          spriteKey: 'olive_transport',
        ),
        ObstacleDef(
          position: Vector2(1470, 270),
          kind: ObstacleKind.baggageCart,
          angle: math.pi / 2,
        ),
      ],
      encounterNames: const ['fallback_wide_lane'],
      difficulty: difficulty,
    );
  }

  double _difficultyFor(int level) {
    // Fast early mastery, then a long tail. Every 5th level is a deliberate
    // relief beat so endless play breathes instead of becoming a linear wall.
    final progression = (1 - math.exp(-(level - 1) / 24)).clamp(0.0, 1.0);
    final wave = math.sin(level * .82) * .045;
    final relief = level % 5 == 0 ? -.10 : 0.0;
    final earlyProtection = level <= 3 ? -.14 + (level - 1) * .04 : 0.0;
    return (progression + wave + relief + earlyProtection + adaptiveBias)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  List<Vector2> _buildSafeRoute(
    math.Random random,
    double difficulty,
    double rotationRadius,
  ) {
    final segmentCount = 4 + (difficulty * 3).round();
    final points = <Vector2>[GameConstants.playerStart.clone()];
    var previousY = GameConstants.playerStartY;
    final maxShift = 110 + difficulty * 145;
    final edgeMargin = math.max(135.0, rotationRadius + 48);
    final minY = _topPlayable + edgeMargin;
    final maxY = _bottomPlayable - edgeMargin;

    for (var i = 1; i <= segmentCount; i++) {
      final t = i / (segmentCount + 1);
      final x = _startSafeX + (_finishSafeX - _startSafeX) * t;
      var targetY = previousY + (random.nextDouble() * 2 - 1) * maxShift;

      // Early levels deliberately teach one idea at a time.
      if (difficulty < .12) targetY = 540 + (i.isEven ? 70 : -70);
      targetY = targetY.clamp(minY, maxY).toDouble();
      points.add(Vector2(x, targetY));
      previousY = targetY;
    }
    points.add(GameConstants.finishPosition.clone());
    return points;
  }

  _EncounterBuild _buildEncounters({
    required math.Random random,
    required List<Vector2> route,
    required double difficulty,
    required double rotationRadius,
  }) {
    final obstacles = <ObstacleDef>[];
    final names = <String>[];

    // The previous generator left a huge empty ribbon around the safe route.
    // In this parking-puzzle game large parked aircraft should define the
    // macro shape of the lane. Keep just enough room for the selected aircraft
    // to rotate at authored waypoints, then use small airport equipment to
    // shave the remaining clearance into precision challenges.
    final baseGapHalf = rotationRadius + (34 - difficulty * 10);

    for (var i = 1; i < route.length - 1; i++) {
      final p = route[i];
      final pattern = _pickPattern(random, difficulty, i);
      names.add(pattern.name);

      final localGapHalf = baseGapHalf + random.nextDouble() * 30;
      final next = route[math.min(i + 1, route.length - 1)];
      final routeAngle = math.atan2(next.y - p.y, next.x - p.x);

      switch (pattern) {
        case EncounterPattern.wideGate:
          _addGate(obstacles, p, localGapHalf + 38, random, routeAngle, light: true);
          break;
        case EncounterPattern.offsetGate:
          _addGate(obstacles, p, localGapHalf + 15, random, routeAngle, offset: 35);
          break;
        case EncounterPattern.slalom:
          final upper = i.isEven;
          obstacles.add(_singleSideObstacle(
            random,
            p,
            localGapHalf + 70,
            upper: upper,
            preferPlane: difficulty > .34,
          ));
          break;
        case EncounterPattern.planeNoseGap:
          _addGate(
            obstacles,
            p,
            localGapHalf + 18,
            random,
            routeAngle,
            forcePlaneSide: true,
          );
          break;
        case EncounterPattern.serviceLane:
          _addGate(
            obstacles,
            p,
            localGapHalf + 5,
            random,
            routeAngle,
            groundOnly: true,
          );
          break;
        case EncounterPattern.chicane:
          obstacles.add(_singleSideObstacle(
            random,
            p + Vector2(-45, 0),
            localGapHalf + 42,
            upper: i.isOdd,
            preferPlane: false,
          ));
          obstacles.add(_singleSideObstacle(
            random,
            p + Vector2(65, 0),
            localGapHalf + 42,
            upper: i.isEven,
            preferPlane: difficulty > .55,
          ));
          break;
        case EncounterPattern.precisionPocket:
          _addGate(obstacles, p, localGapHalf, random, routeAngle, groundOnly: true);
          if (difficulty > .62) {
            obstacles.add(_singleSideObstacle(
              random,
              p + Vector2(95, 0),
              localGapHalf + 82,
              upper: i.isOdd,
              preferPlane: false,
            ));
          }
          break;
        case EncounterPattern.mixedApron:
          _addHeavyAircraftGate(
            obstacles,
            p,
            localGapHalf + 4,
            random,
            routeAngle,
            addMicroBlocker: true,
          );
          break;
        case EncounterPattern.heavyAircraftGate:
          _addHeavyAircraftGate(
            obstacles,
            p,
            localGapHalf,
            random,
            routeAngle,
            addMicroBlocker: difficulty > .20,
          );
          break;
        case EncounterPattern.staggeredAirliners:
          _addStaggeredAirliners(
            obstacles,
            p,
            localGapHalf,
            random,
            routeAngle,
            difficulty,
          );
          break;
      }
    }

    // Keep start and final resolution zone visually calm.
    obstacles.removeWhere((o) =>
        o.position.x < _startSafeX || o.position.x > _finishSafeX);

    return _EncounterBuild(obstacles: obstacles, names: names);
  }

  EncounterPattern _pickPattern(math.Random random, double difficulty, int index) {
    final pool = <EncounterPattern>[
      // Large aircraft dominate the spatial composition. Duplicating these
      // entries intentionally gives them a much higher selection weight.
      EncounterPattern.heavyAircraftGate,
      EncounterPattern.heavyAircraftGate,
      EncounterPattern.staggeredAirliners,
      EncounterPattern.staggeredAirliners,
      EncounterPattern.planeNoseGap,
      EncounterPattern.offsetGate,
      if (difficulty > .16) EncounterPattern.slalom,
      if (difficulty > .28) EncounterPattern.mixedApron,
      if (difficulty > .44) EncounterPattern.chicane,
      if (difficulty > .58) EncounterPattern.serviceLane,
      if (difficulty > .72) EncounterPattern.precisionPocket,
    ];
    // First encounter remains readable, but it is still framed by a large
    // parked aircraft so the level immediately communicates its challenge.
    if (index == 1 && random.nextDouble() < .78) {
      return EncounterPattern.heavyAircraftGate;
    }
    return pool[random.nextInt(pool.length)];
  }

  void _addGate(
    List<ObstacleDef> obstacles,
    Vector2 center,
    double gapHalf,
    math.Random random,
    double routeAngle, {
    double offset = 0,
    bool light = false,
    bool forcePlaneSide = false,
    bool groundOnly = false,
  }) {
    final upperKind = forcePlaneSide || (!groundOnly && !light && random.nextDouble() < .72)
        ? ObstacleKind.plane
        : _randomKind(random, groundOnly: groundOnly, light: light);
    final lowerKind = !groundOnly && !light && random.nextDouble() < .58
        ? ObstacleKind.plane
        : _randomKind(random, groundOnly: groundOnly, light: light);
    final upperAircraftKey = upperKind == ObstacleKind.plane
        ? _randomAircraftKey(random, preferLarge: true)
        : null;
    final lowerAircraftKey = lowerKind == ObstacleKind.plane
        ? _randomAircraftKey(random, preferLarge: true)
        : null;
    final upperSize = upperKind == ObstacleKind.plane
        ? ObstacleAircraftSpriteRepository.gameplaySizeForKey(upperAircraftKey)
        : ObstacleCollisionProfiles.baseSize(upperKind);
    final lowerSize = lowerKind == ObstacleKind.plane
        ? ObstacleAircraftSpriteRepository.gameplaySizeForKey(lowerAircraftKey)
        : ObstacleCollisionProfiles.baseSize(lowerKind);
    final upperRadius = math.max(upperSize.x, upperSize.y) * .52;
    final lowerRadius = math.max(lowerSize.x, lowerSize.y) * .52;

    final yShift = offset * (random.nextBool() ? 1 : -1);
    final upperY = center.y + yShift - gapHalf - upperRadius;
    final lowerY = center.y + yShift + gapHalf + lowerRadius;

    if (upperY > _topPlayable + 40) {
      obstacles.add(ObstacleDef(
        position: Vector2(center.x + random.nextDouble() * 28 - 14, upperY),
        kind: upperKind,
        size: upperKind == ObstacleKind.plane
            ? 1.08 + random.nextDouble() * .22
            : (light ? .88 : .94 + random.nextDouble() * .16),
        angle: upperKind == ObstacleKind.plane
            ? routeAngle + (random.nextDouble() * .25 - .125)
            : (random.nextBool() ? 0 : math.pi / 2),
        spriteKey: upperAircraftKey,
      ));
    }
    if (lowerY < _bottomPlayable - 40) {
      obstacles.add(ObstacleDef(
        position: Vector2(center.x + random.nextDouble() * 28 - 14, lowerY),
        kind: lowerKind,
        size: lowerKind == ObstacleKind.plane
            ? 1.08 + random.nextDouble() * .22
            : (light ? .88 : .94 + random.nextDouble() * .16),
        angle: lowerKind == ObstacleKind.plane
            ? routeAngle + (random.nextDouble() * .25 - .125)
            : (random.nextBool() ? 0 : math.pi / 2),
        spriteKey: lowerAircraftKey,
      ));
    }
  }

  ObstacleDef _singleSideObstacle(
    math.Random random,
    Vector2 routePoint,
    double clearance, {
    required bool upper,
    required bool preferPlane,
  }) {
    final kind = preferPlane && random.nextDouble() < .62
        ? ObstacleKind.plane
        : _randomKind(random);
    final aircraftKey = kind == ObstacleKind.plane
        ? _randomAircraftKey(random, preferLarge: preferPlane)
        : null;
    final base = kind == ObstacleKind.plane
        ? ObstacleAircraftSpriteRepository.gameplaySizeForKey(aircraftKey)
        : ObstacleCollisionProfiles.baseSize(kind);
    final radius = math.max(base.x, base.y) * .52;
    return ObstacleDef(
      position: Vector2(
        routePoint.x,
        routePoint.y + (upper ? -1 : 1) * (clearance + radius),
      ),
      kind: kind,
      size: kind == ObstacleKind.plane
          ? 1.08 + random.nextDouble() * .22
          : .94 + random.nextDouble() * .14,
      angle: kind == ObstacleKind.plane
          ? (random.nextDouble() * .35 - .175)
          : (random.nextBool() ? 0 : math.pi / 2),
      spriteKey: aircraftKey,
    );
  }

  void _addHeavyAircraftGate(
    List<ObstacleDef> obstacles,
    Vector2 center,
    double gapHalf,
    math.Random random,
    double routeAngle, {
    bool addMicroBlocker = false,
  }) {
    final topKey = _randomAircraftKey(random, preferLarge: true);
    final bottomKey = _randomAircraftKey(random, preferLarge: true);
    final topScale = 1.04 + random.nextDouble() * .16;
    final bottomScale = 1.04 + random.nextDouble() * .16;
    final topBase = ObstacleAircraftSpriteRepository.gameplaySizeForKey(topKey);
    final bottomBase = ObstacleAircraftSpriteRepository.gameplaySizeForKey(bottomKey);
    final topRadius = math.max(topBase.x, topBase.y) * topScale * .52;
    final bottomRadius = math.max(bottomBase.x, bottomBase.y) * bottomScale * .52;
    final stagger = 24 + random.nextDouble() * 38;

    final topY = center.y - gapHalf - topRadius;
    final bottomY = center.y + gapHalf + bottomRadius;

    if (topY > _topPlayable + 48) {
      obstacles.add(ObstacleDef(
        position: Vector2(center.x - stagger, topY),
        kind: ObstacleKind.plane,
        size: topScale,
        angle: routeAngle + (random.nextDouble() * .12 - .06),
        spriteKey: topKey,
      ));
    }
    if (bottomY < _bottomPlayable - 48) {
      obstacles.add(ObstacleDef(
        position: Vector2(center.x + stagger, bottomY),
        kind: ObstacleKind.plane,
        size: bottomScale,
        angle: routeAngle + (random.nextDouble() * .12 - .06),
        spriteKey: bottomKey,
      ));
    }

    if (addMicroBlocker) {
      // Small props do not replace the large-aircraft challenge; they trim one
      // side of the opening so the player has to make a deliberate correction.
      final upper = random.nextBool();
      final kind = random.nextDouble() < .55
          ? ObstacleKind.serviceTruck
          : (random.nextBool()
              ? ObstacleKind.environmentLong
              : ObstacleKind.environmentMedium);
      final base = ObstacleCollisionProfiles.baseSize(kind);
      final radius = math.max(base.x, base.y) * .5;
      final microClearance = gapHalf + 16 + radius;
      obstacles.add(ObstacleDef(
        position: Vector2(
          center.x + 75 + random.nextDouble() * 55,
          center.y + (upper ? -microClearance : microClearance),
        ),
        kind: kind,
        size: .96 + random.nextDouble() * .12,
        angle: random.nextBool() ? 0 : math.pi / 2,
      ));
    }
  }

  void _addStaggeredAirliners(
    List<ObstacleDef> obstacles,
    Vector2 center,
    double gapHalf,
    math.Random random,
    double routeAngle,
    double difficulty,
  ) {
    final firstUpper = random.nextBool();
    final longitudinal = 100 + difficulty * 38;

    obstacles.add(_largePlaneSide(
      random,
      center + Vector2(-longitudinal * .55, 0),
      gapHalf + 8,
      upper: firstUpper,
      routeAngle: routeAngle,
    ));
    obstacles.add(_largePlaneSide(
      random,
      center + Vector2(longitudinal * .55, 0),
      gapHalf + 4,
      upper: !firstUpper,
      routeAngle: routeAngle,
    ));

    if (difficulty > .34) {
      // A small vehicle on the outside of the second turn prevents the
      // stagger from reading as a giant empty S-shaped highway.
      final kind = random.nextBool()
          ? ObstacleKind.pushbackTug
          : ObstacleKind.baggageCart;
      final base = ObstacleCollisionProfiles.baseSize(kind);
      final radius = math.max(base.x, base.y) * .5;
      obstacles.add(ObstacleDef(
        position: Vector2(
          center.x + longitudinal * .9,
          center.y + (firstUpper ? 1 : -1) * (gapHalf + 45 + radius),
        ),
        kind: kind,
        size: 1.0,
        angle: routeAngle,
      ));
    }
  }

  ObstacleDef _largePlaneSide(
    math.Random random,
    Vector2 routePoint,
    double clearance, {
    required bool upper,
    required double routeAngle,
  }) {
    final aircraftKey = _randomAircraftKey(random, preferLarge: true);
    final scale = 1.04 + random.nextDouble() * .18;
    final base = ObstacleAircraftSpriteRepository.gameplaySizeForKey(aircraftKey);
    final radius = math.max(base.x, base.y) * scale * .52;
    return ObstacleDef(
      position: Vector2(
        routePoint.x,
        routePoint.y + (upper ? -1 : 1) * (clearance + radius),
      ),
      kind: ObstacleKind.plane,
      size: scale,
      angle: routeAngle + (random.nextDouble() * .14 - .07),
      spriteKey: aircraftKey,
    );
  }

  String _randomAircraftKey(math.Random random, {bool preferLarge = false}) {
    if (preferLarge || random.nextDouble() < .58) {
      final pool = ObstacleAircraftSpriteRepository.largeKeys;
      return pool[random.nextInt(pool.length)];
    }
    if (random.nextDouble() < .68) {
      final pool = ObstacleAircraftSpriteRepository.mediumKeys;
      return pool[random.nextInt(pool.length)];
    }
    final pool = ObstacleAircraftSpriteRepository.smallKeys;
    return pool[random.nextInt(pool.length)];
  }

  ObstacleKind _randomKind(
    math.Random random, {
    bool groundOnly = false,
    bool light = false,
  }) {
    if (!groundOnly && !light && random.nextDouble() < .46) {
      return ObstacleKind.plane;
    }
    // Weighted airport obstacle pool. Vehicles remain the majority so the
    // apron reads naturally, while cones/barriers/equipment create the small
    // precision beats that make endless levels visually and mechanically vary.
    const ground = [
      ObstacleKind.pushbackTug,
      ObstacleKind.pushbackTug,
      ObstacleKind.baggageCart,
      ObstacleKind.baggageCart,
      ObstacleKind.serviceTruck,
      ObstacleKind.serviceTruck,
      ObstacleKind.serviceTruck,
      ObstacleKind.environmentSmall,
      ObstacleKind.environmentMedium,
      ObstacleKind.environmentLong,
      ObstacleKind.lightPole,
    ];
    return ground[random.nextInt(ground.length)];
  }

  double _validationClearance(double difficulty) => 28 - difficulty * 10;

  LevelData _toLevelData({
    required int level,
    required List<Vector2> route,
    required List<ObstacleDef> obstacles,
    required List<String> encounterNames,
    required double difficulty,
  }) {
    var routeLength = 0.0;
    var headingChange = 0.0;
    for (var i = 1; i < route.length; i++) {
      routeLength += route[i].distanceTo(route[i - 1]);
      if (i >= 2) {
        final a = math.atan2(
          route[i - 1].y - route[i - 2].y,
          route[i - 1].x - route[i - 2].x,
        );
        final b = math.atan2(
          route[i].y - route[i - 1].y,
          route[i].x - route[i - 1].x,
        );
        headingChange += _angleDelta(a, b).abs();
      }
    }

    // Targets scale from ideal-route travel time + maneuver complexity rather
    // than imposing the same timer on every generated layout.
    final idealTravel = routeLength / 205;
    final maneuverTime = headingChange * (2.6 + difficulty * .7);
    final three = math.max(12.0, idealTravel + maneuverTime + 5.5);
    final two = three * 1.65 + 3;
    final one = three * 2.65 + 7;

    return LevelData(
      id: level,
      playerStart: GameConstants.playerStart.clone(),
      finishPosition: GameConstants.finishPosition.clone(),
      obstacles: obstacles,
      safeRoute: route,
      difficulty: difficulty,
      encounterNames: encounterNames,
      threeStarTime: three,
      twoStarTime: two,
      oneStarTime: one,
    );
  }

  double _angleDelta(double a, double b) {
    var delta = b - a;
    while (delta > math.pi) delta -= math.pi * 2;
    while (delta < -math.pi) delta += math.pi * 2;
    return delta;
  }
}

/// Compatibility name retained for existing screens. Unlike the old class,
/// this generator is infinite and aircraft-aware.
class ManualLevelGenerator extends ProceduralLevelGenerator {
  ManualLevelGenerator({Vehicle? vehicle, double adaptiveBias = 0})
      : super(vehicle: vehicle ?? Vehicle.all.first, adaptiveBias: adaptiveBias);
}

class LevelSolvabilityValidator {
  LevelSolvabilityValidator({
    required this.vehicle,
    required this.minClearance,
  });

  final Vehicle vehicle;
  final double minClearance;

  bool validate(LevelData level) {
    if (level.safeRoute.length < 2) return false;
    final aircraftProfile = AircraftCollisionProfiles.forVehicle(vehicle.id);
    final aircraftSize = Vector2(80, 60);

    for (var segment = 0; segment < level.safeRoute.length - 1; segment++) {
      final from = level.safeRoute[segment];
      final to = level.safeRoute[segment + 1];
      final length = from.distanceTo(to);
      final samples = math.max(2, (length / 34).ceil());
      final heading = math.atan2(to.y - from.y, to.x - from.x);

      for (var sample = 0; sample <= samples; sample++) {
        final t = sample / samples;
        final position = from + (to - from) * t;
        if (position.y < 95 || position.y > 985) return false;

        final playerPolygons = CollisionGeometry.worldPolygons(
          profile: aircraftProfile,
          center: position,
          size: aircraftSize,
          angle: heading,
          inset: .96,
        );

        for (final obstacle in level.obstacles) {
          final obstacleSize = _obstacleSize(obstacle);
          final obstaclePolygons = CollisionGeometry.worldPolygons(
            profile: _obstacleProfile(obstacle),
            center: obstacle.position,
            size: obstacleSize,
            angle: obstacle.angle,
            inset: obstacle.kind == ObstacleKind.plane ? .97 : .98,
          );
          final distance = CollisionGeometry.distanceBetweenProfiles(
            playerPolygons,
            obstaclePolygons,
          );
          if (distance < minClearance) return false;
        }
      }
    }

    // Because the original game can rotate in place, every route corner that
    // may ask for a heading correction must also fit the entire aircraft while
    // rotating. Test a full turn in 30-degree increments around each waypoint.
    for (var i = 1; i < level.safeRoute.length - 1; i++) {
      final pivot = level.safeRoute[i];
      for (var step = 0; step < 12; step++) {
        final angle = step * math.pi / 6;
        final playerPolygons = CollisionGeometry.worldPolygons(
          profile: aircraftProfile,
          center: pivot,
          size: aircraftSize,
          angle: angle,
          inset: .96,
        );
        for (final obstacle in level.obstacles) {
          final obstacleSize = _obstacleSize(obstacle);
          final obstaclePolygons = CollisionGeometry.worldPolygons(
            profile: _obstacleProfile(obstacle),
            center: obstacle.position,
            size: obstacleSize,
            angle: obstacle.angle,
            inset: obstacle.kind == ObstacleKind.plane ? .97 : .98,
          );
          if (CollisionGeometry.distanceBetweenProfiles(
                playerPolygons,
                obstaclePolygons,
              ) < minClearance) {
            return false;
          }
        }
      }
    }
    return true;
  }

  Vector2 _obstacleSize(ObstacleDef obstacle) {
    if (obstacle.kind == ObstacleKind.plane &&
        ObstacleAircraftSpriteRepository.containsKey(obstacle.spriteKey)) {
      return ObstacleAircraftSpriteRepository.gameplaySizeForKey(obstacle.spriteKey) * obstacle.size;
    }
    return ObstacleCollisionProfiles.baseSize(obstacle.kind) * obstacle.size;
  }

  CollisionProfile _obstacleProfile(ObstacleDef obstacle) {
    if (obstacle.kind == ObstacleKind.plane &&
        ObstacleAircraftSpriteRepository.containsKey(obstacle.spriteKey)) {
      return ObstacleAircraftSpriteRepository.collisionProfileForKey(obstacle.spriteKey);
    }
    return ObstacleCollisionProfiles.forKind(obstacle.kind);
  }
}

class _EncounterBuild {
  const _EncounterBuild({required this.obstacles, required this.names});
  final List<ObstacleDef> obstacles;
  final List<String> names;
}
