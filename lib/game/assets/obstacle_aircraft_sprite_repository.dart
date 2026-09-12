import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:planedriver_flame/game/assets/obstacle_aircraft_sprite_data.dart';
import 'package:planedriver_flame/game/models/collision_geometry.dart';

/// Obstacle aircraft catalogue built from the user's approved top-down set.
/// Source sprites are authored nose-up and isolated one-aircraft-per-PNG.
class ObstacleAircraftSpriteRepository {
  ObstacleAircraftSpriteRepository._();

  static final Map<String, Uint8List> _bytes = {};
  static final Map<String, ui.Image> _images = {};

  /// Large aircraft are the primary level-shaping obstacles.
  static const List<String> largeKeys = <String>[
    'white_shuttle',
    'lavender_jet',
    'cyan_airliner',
    'olive_transport',
  ];

  /// Medium aircraft vary the silhouette and tighten the main corridors.
  static const List<String> mediumKeys = <String>[
    'mint_glider',
    'olive_vintage',
    'red_helicopter',
    'cream_twin',
    'coral_biplane',
  ];

  /// Small aircraft are secondary precision obstacles, never the main wall.
  static const List<String> smallKeys = <String>[
    'violet_light',
    'violet_drone',
  ];

  static List<String> get allKeys => <String>[
        ...largeKeys,
        ...mediumKeys,
        ...smallKeys,
      ];

  static bool containsKey(String? key) =>
      key != null && kObstacleAircraftSpriteBase64.containsKey(key);

  static Uint8List bytesFor(String key) {
    final safe = kObstacleAircraftSpriteBase64.containsKey(key)
        ? key
        : largeKeys.first;
    return _bytes.putIfAbsent(
      safe,
      () => base64Decode(kObstacleAircraftSpriteBase64[safe]!),
    );
  }

  static Future<ui.Image> imageFor(String key) async {
    final safe = kObstacleAircraftSpriteBase64.containsKey(key)
        ? key
        : largeKeys.first;
    final cached = _images[safe];
    if (cached != null) return cached;
    final codec = await ui.instantiateImageCodec(bytesFor(safe));
    final frame = await codec.getNextFrame();
    _images[safe] = frame.image;
    codec.dispose();
    return frame.image;
  }

  /// Gameplay size uses game axes: X = nose-to-tail length, Y = wingspan/rotor span.
  /// The 80x60 player is treated as a small trainer/light aircraft.\n  /// Obstacle sizes preserve believable class-relative proportions.
  static Vector2 gameplaySizeForKey(String? key) {
    switch (key) {
      case 'violet_drone': return Vector2(58, 68);
      case 'violet_light': return Vector2(82, 104);
      case 'coral_biplane': return Vector2(96, 136);
      case 'olive_vintage': return Vector2(104, 138);
      case 'red_helicopter': return Vector2(108, 142);
      case 'mint_glider': return Vector2(106, 224);
      case 'cream_twin': return Vector2(118, 154);
      case 'lavender_jet': return Vector2(166, 142);
      case 'cyan_airliner': return Vector2(178, 154);
      case 'olive_transport': return Vector2(176, 224);
      case 'white_shuttle': return Vector2(196, 132);
      default: return Vector2(104, 138);
    }
  }

  static CollisionProfile collisionProfileForKey(String? key) {
    switch (key) {
      case 'mint_glider':
        return _glider;
      case 'shuttle_white':
        return _shuttle;
      case 'quad_drone':
        return _drone;
      case 'lavender_jet':
        return _sweptJet;
      case 'olive_vintage':
        return _vintage;
      case 'cyan_airliner':
        return _airliner;
      case 'red_helicopter':
        return _helicopter;
      case 'cream_twin':
        return _twin;
      case 'lavender_light':
        return _lightAircraft;
      case 'olive_transport':
        return _transport;
      case 'coral_biplane':
        return _biplane;
      default:
        return _airliner;
    }
  }

  static CollisionProfile _aircraft({
    required double bodyHalf,
    required double wingSpan,
    required double wingForward,
    required double wingBack,
    required double tailSpan,
  }) =>
      CollisionProfile(polygons: <List<Vector2>>[
        <Vector2>[
          Vector2(.49, 0),
          Vector2(.42, -bodyHalf * .72),
          Vector2(.12, -bodyHalf),
          Vector2(-.34, -bodyHalf * .95),
          Vector2(-.48, -.025),
          Vector2(-.49, 0),
          Vector2(-.48, .025),
          Vector2(-.34, bodyHalf * .95),
          Vector2(.12, bodyHalf),
          Vector2(.42, bodyHalf * .72),
        ],
        <Vector2>[
          Vector2(wingForward, -bodyHalf * .7),
          Vector2(.02, -wingSpan),
          Vector2(-.10, -wingSpan),
          Vector2(wingBack, -bodyHalf),
        ],
        <Vector2>[
          Vector2(wingForward, bodyHalf * .7),
          Vector2(wingBack, bodyHalf),
          Vector2(-.10, wingSpan),
          Vector2(.02, wingSpan),
        ],
        <Vector2>[
          Vector2(-.30, -bodyHalf * .55),
          Vector2(-.39, -tailSpan),
          Vector2(-.47, -tailSpan * .72),
          Vector2(-.42, -bodyHalf * .45),
        ],
        <Vector2>[
          Vector2(-.30, bodyHalf * .55),
          Vector2(-.42, bodyHalf * .45),
          Vector2(-.47, tailSpan * .72),
          Vector2(-.39, tailSpan),
        ],
      ]);

  static final CollisionProfile _airliner = _aircraft(
    bodyHalf: .070,
    wingSpan: .46,
    wingForward: .13,
    wingBack: -.17,
    tailSpan: .20,
  );

  static final CollisionProfile _transport = _aircraft(
    bodyHalf: .085,
    wingSpan: .48,
    wingForward: .08,
    wingBack: -.18,
    tailSpan: .21,
  );

  static final CollisionProfile _twin = _aircraft(
    bodyHalf: .075,
    wingSpan: .46,
    wingForward: .10,
    wingBack: -.14,
    tailSpan: .22,
  );

  static final CollisionProfile _vintage = _aircraft(
    bodyHalf: .070,
    wingSpan: .47,
    wingForward: .04,
    wingBack: -.08,
    tailSpan: .23,
  );

  static final CollisionProfile _lightAircraft = _aircraft(
    bodyHalf: .060,
    wingSpan: .46,
    wingForward: .08,
    wingBack: -.12,
    tailSpan: .22,
  );

  static final CollisionProfile _biplane = CollisionProfile(
    polygons: <List<Vector2>>[
      <Vector2>[
        Vector2(.48, 0),
        Vector2(.37, -.07),
        Vector2(-.40, -.075),
        Vector2(-.48, 0),
        Vector2(-.40, .075),
        Vector2(.37, .07),
      ],
      <Vector2>[
        Vector2(.16, -.06),
        Vector2(.04, -.48),
        Vector2(-.10, -.48),
        Vector2(-.18, -.06),
      ],
      <Vector2>[
        Vector2(.16, .06),
        Vector2(-.18, .06),
        Vector2(-.10, .48),
        Vector2(.04, .48),
      ],
      <Vector2>[
        Vector2(-.32, -.05),
        Vector2(-.40, -.24),
        Vector2(-.47, -.20),
        Vector2(-.42, -.04),
      ],
      <Vector2>[
        Vector2(-.32, .05),
        Vector2(-.42, .04),
        Vector2(-.47, .20),
        Vector2(-.40, .24),
      ],
    ],
  );

  static final CollisionProfile _glider = CollisionProfile(
    polygons: <List<Vector2>>[
      <Vector2>[
        Vector2(.48, 0),
        Vector2(.36, -.025),
        Vector2(-.45, -.035),
        Vector2(-.48, 0),
        Vector2(-.45, .035),
        Vector2(.36, .025),
      ],
      <Vector2>[
        Vector2(.10, -.025),
        Vector2(-.01, -.49),
        Vector2(-.14, -.49),
        Vector2(-.11, -.03),
      ],
      <Vector2>[
        Vector2(.10, .025),
        Vector2(-.11, .03),
        Vector2(-.14, .49),
        Vector2(-.01, .49),
      ],
      <Vector2>[
        Vector2(-.35, -.025),
        Vector2(-.42, -.15),
        Vector2(-.47, -.12),
        Vector2(-.42, -.02),
      ],
      <Vector2>[
        Vector2(-.35, .025),
        Vector2(-.42, .02),
        Vector2(-.47, .12),
        Vector2(-.42, .15),
      ],
    ],
  );

  static final CollisionProfile _shuttle = CollisionProfile(
    polygons: <List<Vector2>>[
      <Vector2>[
        Vector2(.49, 0),
        Vector2(.33, -.10),
        Vector2(-.22, -.13),
        Vector2(-.46, -.08),
        Vector2(-.49, 0),
        Vector2(-.46, .08),
        Vector2(-.22, .13),
        Vector2(.33, .10),
      ],
      <Vector2>[
        Vector2(.02, -.08),
        Vector2(-.17, -.49),
        Vector2(-.33, -.46),
        Vector2(-.24, -.12),
      ],
      <Vector2>[
        Vector2(.02, .08),
        Vector2(-.24, .12),
        Vector2(-.33, .46),
        Vector2(-.17, .49),
      ],
    ],
  );

  static final CollisionProfile _sweptJet = _aircraft(
    bodyHalf: .065,
    wingSpan: .47,
    wingForward: .12,
    wingBack: -.25,
    tailSpan: .19,
  );

  static final CollisionProfile _helicopter = CollisionProfile(
    polygons: <List<Vector2>>[
      <Vector2>[
        Vector2(.39, 0),
        Vector2(.24, -.11),
        Vector2(-.29, -.09),
        Vector2(-.48, -.035),
        Vector2(-.49, 0),
        Vector2(-.48, .035),
        Vector2(-.29, .09),
        Vector2(.24, .11),
      ],
      <Vector2>[
        Vector2(.28, 0),
        Vector2(0, -.48),
        Vector2(-.28, 0),
        Vector2(0, .48),
      ],
    ],
  );

  static final CollisionProfile _drone = CollisionProfile(
    polygons: <List<Vector2>>[
      <Vector2>[
        Vector2(.34, 0),
        Vector2(.24, -.24),
        Vector2(0, -.34),
        Vector2(-.24, -.24),
        Vector2(-.34, 0),
        Vector2(-.24, .24),
        Vector2(0, .34),
        Vector2(.24, .24),
      ],
      <Vector2>[
        Vector2(.42, -.42),
        Vector2(.20, -.42),
        Vector2(.20, -.20),
        Vector2(.42, -.20),
      ],
      <Vector2>[
        Vector2(.42, .20),
        Vector2(.20, .20),
        Vector2(.20, .42),
        Vector2(.42, .42),
      ],
      <Vector2>[
        Vector2(-.20, -.42),
        Vector2(-.42, -.42),
        Vector2(-.42, -.20),
        Vector2(-.20, -.20),
      ],
      <Vector2>[
        Vector2(-.20, .20),
        Vector2(-.42, .20),
        Vector2(-.42, .42),
        Vector2(-.20, .42),
      ],
    ],
  );
}
