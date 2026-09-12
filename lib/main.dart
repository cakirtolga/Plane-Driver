import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:planedriver_flame/app.dart';
import 'package:planedriver_flame/firebase_options.dart';
import 'package:planedriver_flame/services/ads_service.dart';
import 'package:planedriver_flame/services/analytics_service.dart';
import 'package:planedriver_flame/services/iap_service.dart';
import 'package:planedriver_flame/services/save_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Landscape-only, edge-to-edge immersive gameplay on phones and tablets.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init failed (placeholder): $e');
  }

  await SaveService.instance.init();
  await AdsService.instance.initialize();
  IAPService.instance.initialize();
  await AnalyticsService.instance.init();

  runApp(const PlaneDriverApp());
}
