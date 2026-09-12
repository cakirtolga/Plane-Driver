import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:planedriver_flame/game/assets/obstacle_sprite_data.dart';
import 'package:planedriver_flame/game/models/level_data.dart';

class ObstacleSpriteRepository {
  ObstacleSpriteRepository._();

  static final Map<String, ui.Image> _cache = {};

  static const List<String> vehicleKeys = [
    'pushback_tug',
    'baggage_cart',
    'fuel_truck',
    'catering_truck',
    'stair_truck',
    'bus',
    'cargo_loader',
    'service_van',
    'follow_me',
    'maintenance_van',
  ];

  static const List<String> smallPropKeys = [
    'cone',
    'barrel',
    'waste_bin',
    'taxi_light',
  ];

  static const List<String> mediumPropKeys = [
    'crate',
    'cargo_pallet',
    'dollies',
    'luggage_cart',
    'ground_power',
    'aircon_unit',
    'sign',
  ];

  static const List<String> longPropKeys = [
    'barrier',
    'water_barrier',
  ];

  static const List<String> poleKeys = [
    'light_pole',
    'flood_light',
  ];

  /// Sprites authored vertically on the atlas are quarter-turned internally so
  /// their longitudinal axis matches the game's +X collision axis. This keeps
  /// every obstacle truly bird's-eye while preserving procedural rotation.
  static const Set<String> quarterTurnKeys = {
    'pushback_tug',
    'fuel_truck',
    'catering_truck',
    'stair_truck',
    'bus',
    'cargo_loader',
    'service_van',
    'follow_me',
    'maintenance_van',
    'taxi_light',
  };

  static Future<ui.Image?> imageFor(String? key) async {
    if (key == null) return null;
    final cached = _cache[key];
    if (cached != null) return cached;
    final encoded = obstacleSpriteBase64[key];
    if (encoded == null) return null;
    try {
      final bytes = base64Decode(encoded);
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      _cache[key] = frame.image;
      codec.dispose();
      return frame.image;
    } catch (error) {
      debugPrint('Obstacle sprite decode failed for $key: $error');
      return null;
    }
  }

  /// Gameplay dimensions are normalized against the 80x60 player aircraft.
  /// Vehicles remain clearly readable without consuming unrealistic amounts
  /// of apron space; small props can create precision beats without becoming
  /// invisible collision traps.
  static Vector2 gameplaySizeForKey(String? key) {
    switch (key) {
      case 'pushback_tug': return Vector2(42, 30);
      case 'baggage_cart': return Vector2(58, 22);
      case 'fuel_truck': return Vector2(54, 28);
      case 'catering_truck': return Vector2(50, 27);
      case 'stair_truck': return Vector2(48, 28);
      case 'bus': return Vector2(58, 25);
      case 'cargo_loader': return Vector2(46, 34);
      case 'service_van': return Vector2(40, 23);
      case 'follow_me': return Vector2(36, 22);
      case 'maintenance_van': return Vector2(42, 24);
      case 'cone': return Vector2(14, 14);
      case 'barrel': return Vector2(16, 16);
      case 'barrier': return Vector2(48, 16);
      case 'water_barrier': return Vector2(54, 18);
      case 'crate': return Vector2(24, 22);
      case 'cargo_pallet': return Vector2(32, 30);
      case 'dollies': return Vector2(32, 28);
      case 'luggage_cart': return Vector2(34, 26);
      case 'ground_power': return Vector2(30, 24);
      case 'aircon_unit': return Vector2(28, 26);
      case 'waste_bin': return Vector2(16, 16);
      case 'light_pole': return Vector2(18, 18);
      case 'flood_light': return Vector2(20, 20);
      case 'sign': return Vector2(30, 18);
      case 'taxi_light': return Vector2(14, 14);
      default: return Vector2(40, 28);
    }
  }

  static String defaultKeyFor(ObstacleKind kind, double x, double y) {
    final seed = (x.round() * 73856093) ^ (y.round() * 19349663);
    switch (kind) {
      case ObstacleKind.plane:
        return '';
      case ObstacleKind.pushbackTug:
        return 'pushback_tug';
      case ObstacleKind.baggageCart:
        return 'baggage_cart';
      case ObstacleKind.serviceTruck:
        const keys = [
          'fuel_truck', 'catering_truck', 'stair_truck', 'bus',
          'service_van', 'follow_me', 'maintenance_van', 'cargo_loader',
        ];
        return keys[seed.abs() % keys.length];
      case ObstacleKind.environmentSmall:
        return smallPropKeys[seed.abs() % smallPropKeys.length];
      case ObstacleKind.environmentMedium:
        return mediumPropKeys[seed.abs() % mediumPropKeys.length];
      case ObstacleKind.environmentLong:
        return longPropKeys[seed.abs() % longPropKeys.length];
      case ObstacleKind.lightPole:
        return poleKeys[seed.abs() % poleKeys.length];
    }
  }
}
