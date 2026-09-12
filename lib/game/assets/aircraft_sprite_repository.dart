import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:planedriver_flame/game/assets/aircraft_sprite_data.dart';

/// Single source of truth for all playable/obstacle aircraft art.
/// Sprites are embedded in lib so replacing the lib folder is enough; no
/// pubspec asset registration is required.
class AircraftSpriteRepository {
  AircraftSpriteRepository._();

  static final Map<int, Uint8List> _bytes = {};
  static final Map<int, ui.Image> _images = {};
  static final Map<int, MemoryImage> _providers = {};

  static Uint8List bytesFor(int vehicleId) {
    final id = kAircraftSpriteBase64.containsKey(vehicleId) ? vehicleId : 0;
    return _bytes.putIfAbsent(id, () => base64Decode(kAircraftSpriteBase64[id]!));
  }

  static MemoryImage memoryImage(int vehicleId) {
    final id = kAircraftSpriteBase64.containsKey(vehicleId) ? vehicleId : 0;
    return _providers.putIfAbsent(id, () => MemoryImage(bytesFor(id)));
  }

  static Future<ui.Image> imageFor(int vehicleId) async {
    final id = kAircraftSpriteBase64.containsKey(vehicleId) ? vehicleId : 0;
    final cached = _images[id];
    if (cached != null) return cached;

    final codec = await ui.instantiateImageCodec(bytesFor(id));
    final frame = await codec.getNextFrame();
    _images[id] = frame.image;
    codec.dispose();
    return frame.image;
  }

  /// Deterministic civil-aircraft variation for parked obstacle planes.
  /// Avoids the special/neon aircraft so environmental traffic stays neutral.
  static int obstacleVehicleId(double x, double y) {
    const ids = <int>[0, 1, 2, 3, 4, 5];
    final hash = (x.round() * 31 + y.round() * 17).abs();
    return ids[hash % ids.length];
  }
}
