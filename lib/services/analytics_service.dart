import 'package:firebase_analytics/firebase_analytics.dart';

enum FailReason { obstacle, boundary, quit }

class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? _analytics;
  bool _enabled = false;

  Future<void> init() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      _enabled = true;
    } catch (e) {
      _analytics = null;
      _enabled = false;
    }
  }

  Future<void> logScreenView(String screenName) async {
    if (!_enabled) return;
    try {
      await _analytics?.logScreenView(screenName: screenName);
    } catch (_) {}
  }

  Future<void> logLevelStart(int levelId) async {
    if (!_enabled) return;
    try {
      await _analytics?.logEvent(
        name: 'level_start',
        parameters: {'level_id': levelId},
      );
    } catch (_) {}
  }

  Future<void> logLevelComplete({
    required int levelId,
    required int stars,
    required double time,
  }) async {
    if (!_enabled) return;
    try {
      await _analytics?.logEvent(
        name: 'level_complete',
        parameters: {
          'level_id': levelId,
          'stars': stars,
          'time': time,
        },
      );
    } catch (_) {}
  }

  Future<void> logLevelFail({
    required int levelId,
    required FailReason reason,
    required double time,
  }) async {
    if (!_enabled) return;
    try {
      await _analytics?.logEvent(
        name: 'level_fail',
        parameters: {
          'level_id': levelId,
          'reason': reason.name,
          'time': time,
        },
      );
    } catch (_) {}
  }

  Future<void> logPlaneSelected(int planeId) async {
    if (!_enabled) return;
    try {
      await _analytics?.logEvent(
        name: 'plane_selected',
        parameters: {'plane_id': planeId},
      );
    } catch (_) {}
  }

  Future<void> logPurchaseAttempt({
    required int planeId,
    required String price,
  }) async {
    if (!_enabled) return;
    try {
      await _analytics?.logEvent(
        name: 'purchase_attempt',
        parameters: {
          'plane_id': planeId,
          'price': price,
        },
      );
    } catch (_) {}
  }

  Future<void> logPurchaseSuccess({
    required int planeId,
    required String price,
  }) async {
    if (!_enabled) return;
    try {
      await _analytics?.logEvent(
        name: 'purchase_success',
        parameters: {
          'plane_id': planeId,
          'price': price,
        },
      );
    } catch (_) {}
  }

  Future<void> logPurchaseRestore({required bool success}) async {
    if (!_enabled) return;
    try {
      await _analytics?.logEvent(
        name: 'purchase_restore',
        parameters: {'success': success},
      );
    } catch (_) {}
  }

  Future<void> logAdInterstitialShow(String location) async {
    if (!_enabled) return;
    try {
      await _analytics?.logEvent(
        name: 'ad_interstitial_show',
        parameters: {'location': location},
      );
    } catch (_) {}
  }
  Future<void> logNearMiss({
    required int levelId,
    required double clearance,
  }) async {
    if (!_enabled) return;
    try {
      await _analytics?.logEvent(
        name: 'near_miss',
        parameters: {
          'level_id': levelId,
          'clearance': clearance,
        },
      );
    } catch (_) {}
  }

}
