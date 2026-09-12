import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:planedriver_flame/game/models/level_data.dart';
import 'package:planedriver_flame/game/models/vehicle.dart';
import 'package:planedriver_flame/utils/constants.dart';

/// The opening curriculum is authored, deterministic and sprite-agnostic.
/// Sprites can be replaced later without changing these puzzle layouts.
class HandcraftedLevelGenerator {
  const HandcraftedLevelGenerator({required this.vehicle});

  final Vehicle vehicle;

  LevelData generate(int levelId) {
    final id = levelId.clamp(1, 10).toInt();
    final routes = <List<Vector2>>[
      _route([const [650, 540], const [1250, 540], const [1700, 540]]),
      _route([const [600, 540], const [980, 420], const [1370, 540], const [1700, 540]]),
      _route([const [590, 540], const [900, 360], const [1250, 360], const [1510, 540]]),
      _route([const [560, 540], const [820, 300], const [1190, 300], const [1450, 540]]),
      _route([const [560, 540], const [820, 700], const [1120, 700], const [1380, 420], const [1650, 540]]),
      _route([const [620, 540], const [850, 540], const [700, 360], const [1050, 360], const [1450, 540]]),
      _route([const [600, 540], const [830, 700], const [720, 430], const [1110, 330], const [1510, 540]]),
      _route([const [570, 540], const [820, 330], const [1110, 330], const [1380, 650], const [1650, 540]]),
      _route([const [560, 540], const [800, 730], const [1050, 430], const [1300, 690], const [1630, 540]]),
      _route([const [540, 540], const [760, 280], const [1040, 720], const [1320, 300], const [1650, 540]]),
    ];
    final route = routes[id - 1];
    final obstacles = <ObstacleDef>[];
    for (var i = 1; i < route.length - 1; i++) {
      final point = route[i];
      final previous = route[i - 1];
      final next = route[i + 1];
      final heading = math.atan2(next.y - previous.y, next.x - previous.x);
      final normal = Vector2(-math.sin(heading), math.cos(heading));
      final gap = id <= 2 ? 155.0 : math.max(100.0, 150 - id * 5.0);
      final kind = id >= 8 ? ObstacleKind.plane : ObstacleKind.serviceTruck;
      obstacles
        ..add(ObstacleDef(position: point + normal * gap, kind: kind, angle: heading, size: kind == ObstacleKind.plane ? .88 : 1))
        ..add(ObstacleDef(position: point - normal * gap, kind: kind, angle: heading, size: kind == ObstacleKind.plane ? .88 : 1));
    }

    final idealSeconds = 10.5 + id * 1.8;
    return LevelData(
      id: id,
      obstacles: obstacles,
      playerStart: GameConstants.playerStart.clone(),
      finishPosition: GameConstants.finishPosition.clone(),
      threeStarTime: idealSeconds,
      twoStarTime: idealSeconds * 1.65,
      oneStarTime: idealSeconds * 2.6,
      safeRoute: route,
      difficulty: (id - 1) / 12,
      encounterNames: [_lessonNames[id - 1]],
    );
  }

  List<Vector2> _route(List<List<num>> middle) => <Vector2>[
        GameConstants.playerStart.clone(),
        ...middle.map((p) => Vector2(p[0].toDouble(), p[1].toDouble())),
        GameConstants.finishPosition.clone(),
      ];

  static const _lessonNames = <String>[
    'forward',
    'steering',
    'wing_clearance',
    'tight_turn',
    'impossible_gap',
    'reverse',
    'reverse_turn',
    'parked_aircraft',
    'double_precision',
    'first_skill_test',
  ];
}
