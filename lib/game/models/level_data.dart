import 'package:flame/components.dart';

enum ObstacleKind {
  plane,
  pushbackTug,
  baggageCart,
  serviceTruck,
  environmentSmall,
  environmentMedium,
  environmentLong,
  lightPole,
}

class ObstacleDef {
  const ObstacleDef({
    required this.position,
    required this.kind,
    this.size = 1.0,
    this.angle = 0.0,
    this.spriteKey,
  });

  final Vector2 position;
  final ObstacleKind kind;
  final double size;
  final double angle;
  final String? spriteKey;
}

class LevelData {
  const LevelData({
    required this.id,
    required this.obstacles,
    required this.playerStart,
    required this.finishPosition,
    required this.threeStarTime,
    required this.twoStarTime,
    required this.oneStarTime,
    required this.safeRoute,
    required this.difficulty,
    required this.encounterNames,
  });

  final int id;
  final List<ObstacleDef> obstacles;
  final Vector2 playerStart;
  final Vector2 finishPosition;
  final double threeStarTime;
  final double twoStarTime;
  final double oneStarTime;

  /// Invisible route used only during generation/validation. Gameplay never
  /// forces the player onto it; it guarantees that a fair solution exists.
  final List<Vector2> safeRoute;

  /// 0..1 procedural difficulty after pacing + adaptive retention adjustment.
  final double difficulty;
  final List<String> encounterNames;

  int starsForTime(double time) {
    if (time <= threeStarTime) return 3;
    if (time <= twoStarTime) return 2;
    return 1;
  }
}
