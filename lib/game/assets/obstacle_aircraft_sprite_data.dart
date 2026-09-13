/// Dedicated obstacle-aircraft artwork will be added in the sprite pass.
///
/// Keeping the catalogue empty is intentional: ObstacleComponent falls back
/// to the playable-aircraft repository and its procedural placeholder art,
/// while collision geometry and level generation continue to work normally.
const Map<String, String> kObstacleAircraftSpriteBase64 = <String, String>{};
