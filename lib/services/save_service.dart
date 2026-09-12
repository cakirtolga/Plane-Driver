import 'dart:convert';
import 'dart:math' as math;

import 'package:planedriver_flame/game/models/level_state.dart';
import 'package:planedriver_flame/game/models/vehicle.dart';
import 'package:planedriver_flame/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveService {
  SaveService._();

  static final SaveService instance = SaveService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _requirePrefs {
    if (_prefs == null) {
      throw StateError('SaveService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  static const String _selectedVehicleKey = 'selected_vehicle';
  static const String _ownedPlanesKey = 'owned_planes';
  static const String _levelStarsKey = 'level_stars';
  static const String _levelBestTimesKey = 'level_best_times';
  static const String _adsRemovedKey = 'ads_removed';
  static const String _recentRunsKey = 'recent_runs';
  static const String _levelDifficultyBiasKey = 'level_difficulty_bias';

  int getSelectedVehicleId() {
    return _requirePrefs.getInt(_selectedVehicleKey) ?? 0;
  }

  Future<void> setSelectedVehicleId(int id) async {
    await _requirePrefs.setInt(_selectedVehicleKey, id);
  }

  List<int> getOwnedPlaneIds() {
    final jsonStr = _requirePrefs.getString(_ownedPlanesKey);
    if (jsonStr == null) return [0];
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list.cast<int>();
  }

  Future<void> addOwnedPlaneId(int id) async {
    final owned = getOwnedPlaneIds();
    if (!owned.contains(id)) {
      owned.add(id);
      owned.sort();
      await _requirePrefs.setString(_ownedPlanesKey, jsonEncode(owned));
    }
  }

  Future<void> restoreAllPlanes() async {
    final allIds = Vehicle.all.map((v) => v.id).toList();
    await _requirePrefs.setString(_ownedPlanesKey, jsonEncode(allIds));
  }

  bool isPlaneOwned(int id) {
    if (Vehicle.byId(id).isFree) return true;
    return getOwnedPlaneIds().contains(id);
  }

  List<LevelState> getAllLevelStates() {
    final starsMap = _getLevelStarsMap();
    final bestTimesMap = _getLevelBestTimesMap();
    var highestCompleted = 0;
    for (final key in starsMap.keys) {
      final id = int.tryParse(key) ?? 0;
      if ((starsMap[key] ?? 0) > 0 && id > highestCompleted) highestCompleted = id;
    }

    // Infinite generation, finite browsing window. The selector grows as the
    // player progresses so returning from level 80 never loses that progress.
    final visibleCount = math.max(
      GameConstants.minimumLevelSelectCount,
      highestCompleted + 10,
    ).toInt();

    return List.generate(visibleCount, (index) {
      final id = index + 1;
      final stars = starsMap[id.toString()] ?? 0;
      final unlocked = id == 1 || (starsMap[(id - 1).toString()] ?? 0) > 0;
      final bestTime = bestTimesMap[id.toString()];

      return LevelState(
        id: id,
        stars: stars,
        unlocked: unlocked,
        bestTime: bestTime,
      );
    });
  }

  LevelState getLevelState(int id) {
    final starsMap = _getLevelStarsMap();
    final bestTimesMap = _getLevelBestTimesMap();
    return LevelState(
      id: id,
      stars: starsMap[id.toString()] ?? 0,
      unlocked: id == 1 || (starsMap[(id - 1).toString()] ?? 0) > 0,
      bestTime: bestTimesMap[id.toString()],
    );
  }

  /// Retention director input. It only nudges generation; it never changes the
  /// player's controls. Two poor runs soften upcoming layouts, while repeated
  /// 3-star clears add a small challenge bump.
  double getOrCreateDifficultyBiasForLevel(int levelId) {
    final raw = _requirePrefs.getString(_levelDifficultyBiasKey);
    final map = raw == null
        ? <String, dynamic>{}
        : jsonDecode(raw) as Map<String, dynamic>;
    final key = levelId.toString();
    final existing = map[key];
    if (existing is num) return existing.toDouble();

    final bias = getAdaptiveDifficultyBias();
    map[key] = bias;
    // SharedPreferences updates memory immediately; persistence completes
    // asynchronously. This keeps retries of the same level layout-stable.
    _requirePrefs.setString(_levelDifficultyBiasKey, jsonEncode(map));
    return bias;
  }

  double getAdaptiveDifficultyBias() {
    final raw = _requirePrefs.getString(_recentRunsKey);
    if (raw == null) return 0;
    final runs = (jsonDecode(raw) as List<dynamic>).cast<num>();
    if (runs.isEmpty) return 0;
    final recent = runs.length > 6 ? runs.sublist(runs.length - 6) : runs;
    final average = recent.fold<double>(0, (sum, v) => sum + v.toDouble()) / recent.length;
    if (average < .34) return -.16;
    if (average < .50) return -.09;
    if (average > .88) return .10;
    if (average > .74) return .05;
    return 0;
  }

  Future<void> recordRun({required bool won, int stars = 0}) async {
    final raw = _requirePrefs.getString(_recentRunsKey);
    final runs = raw == null
        ? <double>[]
        : (jsonDecode(raw) as List<dynamic>).map((v) => (v as num).toDouble()).toList();
    final score = won ? (stars / 3).clamp(0.0, 1.0).toDouble() : 0.0;
    runs.add(score);
    if (runs.length > 12) runs.removeRange(0, runs.length - 12);
    await _requirePrefs.setString(_recentRunsKey, jsonEncode(runs));
  }

  Future<void> updateLevelResult(int id, int stars, double time) async {
    final starsMap = _getLevelStarsMap();
    final currentStars = starsMap[id.toString()] ?? 0;
    if (stars > currentStars) {
      starsMap[id.toString()] = stars;
      await _requirePrefs.setString(_levelStarsKey, jsonEncode(starsMap));
    }

    final bestTimesMap = _getLevelBestTimesMap();
    final currentBest = bestTimesMap[id.toString()];
    if (currentBest == null || time < currentBest) {
      bestTimesMap[id.toString()] = time;
      await _requirePrefs.setString(
        _levelBestTimesKey,
        jsonEncode(bestTimesMap),
      );
    }
  }

  Map<String, int> _getLevelStarsMap() {
    final jsonStr = _requirePrefs.getString(_levelStarsKey);
    if (jsonStr == null) return {};
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, v as int));
  }

  Map<String, double> _getLevelBestTimesMap() {
    final jsonStr = _requirePrefs.getString(_levelBestTimesKey);
    if (jsonStr == null) return {};
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }

  bool getAdsRemoved() => _requirePrefs.getBool(_adsRemovedKey) ?? false;

  Future<void> setAdsRemoved(bool value) async {
    await _requirePrefs.setBool(_adsRemovedKey, value);
  }

  Future<void> clearAll() async {
    await _requirePrefs.clear();
  }
}
