import 'package:flame/components.dart';
import 'package:planedriver_flame/game/models/collision_geometry.dart';

/// Sprite-matched composite collision masks for every playable aircraft.
///
/// Coordinates are normalized around the aircraft center. +X is the nose,
/// +/-Y are the wings. Each aircraft uses separate convex pieces for fuselage,
/// left/right wing and left/right tailplane; there is deliberately no single
/// rectangle/triangle standing in for the visible silhouette.
class AircraftCollisionProfiles {
  AircraftCollisionProfiles._();

  static CollisionProfile forVehicle(int vehicleId) =>
      _profiles[vehicleId] ?? _profiles[0]!;

  static final Map<int, CollisionProfile> _profiles = {
    // Starter: short fuselage, broad straight wings, compact tail.
    0: _make(
      nose: .46, tailX: -.43, bodyHalf: .070,
      wingRootFront: .09, wingRootBack: -.16,
      wingTipX: -.03, wingHalfSpan: .43, wingTipChord: .095,
      tailRootX: -.29, tailHalfSpan: .20, tailTipX: -.39,
    ),
    // Commuter: longer civil fuselage and wide, slightly swept wing.
    1: _make(
      nose: .48, tailX: -.46, bodyHalf: .062,
      wingRootFront: .08, wingRootBack: -.17,
      wingTipX: -.10, wingHalfSpan: .46, wingTipChord: .075,
      tailRootX: -.30, tailHalfSpan: .22, tailTipX: -.42,
    ),
    // Mini prop: visibly compact body with almost rectangular wing.
    2: _make(
      nose: .42, tailX: -.40, bodyHalf: .073,
      wingRootFront: .08, wingRootBack: -.13,
      wingTipX: -.03, wingHalfSpan: .40, wingTipChord: .115,
      tailRootX: -.27, tailHalfSpan: .19, tailTipX: -.36,
    ),
    // Business jet: long slim fuselage, pronounced swept wing.
    3: _make(
      nose: .49, tailX: -.47, bodyHalf: .052,
      wingRootFront: .06, wingRootBack: -.18,
      wingTipX: -.20, wingHalfSpan: .40, wingTipChord: .065,
      tailRootX: -.32, tailHalfSpan: .18, tailTipX: -.43,
    ),
    // Retro prop: chunky center section and broad prop-airliner wing.
    4: _make(
      nose: .45, tailX: -.44, bodyHalf: .072,
      wingRootFront: .10, wingRootBack: -.17,
      wingTipX: -.07, wingHalfSpan: .47, wingTipChord: .105,
      tailRootX: -.29, tailHalfSpan: .23, tailTipX: -.40,
    ),
    // Regional airliner: balanced narrow-body silhouette.
    5: _make(
      nose: .49, tailX: -.47, bodyHalf: .058,
      wingRootFront: .07, wingRootBack: -.18,
      wingTipX: -.14, wingHalfSpan: .44, wingTipChord: .072,
      tailRootX: -.31, tailHalfSpan: .21, tailTipX: -.43,
    ),
    // Cargo: fuller fuselage and stronger shoulder wing.
    6: _make(
      nose: .47, tailX: -.45, bodyHalf: .076,
      wingRootFront: .09, wingRootBack: -.18,
      wingTipX: -.12, wingHalfSpan: .45, wingTipChord: .082,
      tailRootX: -.30, tailHalfSpan: .22, tailTipX: -.41,
    ),
    // Widebody: wide fuselage and large swept wing.
    7: _make(
      nose: .48, tailX: -.46, bodyHalf: .082,
      wingRootFront: .10, wingRootBack: -.20,
      wingTipX: -.17, wingHalfSpan: .48, wingTipChord: .075,
      tailRootX: -.31, tailHalfSpan: .24, tailTipX: -.43,
    ),
    // Jumbo: largest wing envelope and broad body.
    8: _make(
      nose: .49, tailX: -.47, bodyHalf: .086,
      wingRootFront: .11, wingRootBack: -.21,
      wingTipX: -.19, wingHalfSpan: .49, wingTipChord: .080,
      tailRootX: -.32, tailHalfSpan: .25, tailTipX: -.44,
    ),
    // Special civil livery: sporty but still civilian, swept silhouette.
    9: _make(
      nose: .48, tailX: -.45, bodyHalf: .060,
      wingRootFront: .08, wingRootBack: -.18,
      wingTipX: -.18, wingHalfSpan: .43, wingTipChord: .070,
      tailRootX: -.30, tailHalfSpan: .20, tailTipX: -.41,
    ),
  };

  static CollisionProfile _make({
    required double nose,
    required double tailX,
    required double bodyHalf,
    required double wingRootFront,
    required double wingRootBack,
    required double wingTipX,
    required double wingHalfSpan,
    required double wingTipChord,
    required double tailRootX,
    required double tailHalfSpan,
    required double tailTipX,
  }) {
    // 3-5% visual forgiveness is applied by CollisionGeometry callers, so the
    // polygons can track the actual sprite silhouette without feeling unfair.
    final body = <Vector2>[
      Vector2(nose, 0),
      Vector2(nose - .07, -bodyHalf * .72),
      Vector2(.18, -bodyHalf),
      Vector2(-.25, -bodyHalf * 1.08),
      Vector2(tailX, -bodyHalf * .58),
      Vector2(tailX - .015, 0),
      Vector2(tailX, bodyHalf * .58),
      Vector2(-.25, bodyHalf * 1.08),
      Vector2(.18, bodyHalf),
      Vector2(nose - .07, bodyHalf * .72),
    ];

    List<Vector2> wing(double sign) => <Vector2>[
      Vector2(wingRootFront, sign * bodyHalf * .72),
      Vector2(wingTipX + wingTipChord / 2, sign * wingHalfSpan),
      Vector2(wingTipX - wingTipChord / 2, sign * wingHalfSpan),
      Vector2(wingRootBack, sign * bodyHalf * .92),
    ];

    List<Vector2> tail(double sign) => <Vector2>[
      Vector2(tailRootX + .035, sign * bodyHalf * .58),
      Vector2(tailTipX + .03, sign * tailHalfSpan),
      Vector2(tailTipX - .035, sign * tailHalfSpan),
      Vector2(tailRootX - .07, sign * bodyHalf * .52),
    ];

    return CollisionProfile(polygons: <List<Vector2>>[
      body,
      wing(-1),
      wing(1),
      tail(-1),
      tail(1),
    ]);
  }
}
