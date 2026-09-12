import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:planedriver_flame/utils/constants.dart';

/// Full-screen responsive camera. The complete 1920x1080 gameplay rectangle
/// remains visible on every landscape aspect ratio.
class CameraManager {
  static CameraComponent createCamera() {
    final camera = CameraComponent();
    camera.viewfinder
      ..anchor = Anchor.center
      ..position = GameConstants.logicalSize / 2;
    return camera;
  }

  static void fitToScreen(CameraComponent camera, Vector2 screenSize) {
    if (screenSize.x <= 0 || screenSize.y <= 0) return;
    final containZoom = math.min(
      screenSize.x / GameConstants.gameWidth,
      screenSize.y / GameConstants.gameHeight,
    ).clamp(0.01, 4.0).toDouble();
    camera.viewfinder
      ..anchor = Anchor.center
      ..position = GameConstants.logicalSize / 2
      ..zoom = containZoom;
  }

  static Rect visibleWorldRect(Vector2 screenSize) {
    if (screenSize.x <= 0 || screenSize.y <= 0) {
      return Rect.fromLTWH(
        0,
        0,
        GameConstants.gameWidth,
        GameConstants.gameHeight,
      );
    }
    final zoom = math.min(
      screenSize.x / GameConstants.gameWidth,
      screenSize.y / GameConstants.gameHeight,
    );
    return Rect.fromCenter(
      center: const Offset(
        GameConstants.gameWidth / 2,
        GameConstants.gameHeight / 2,
      ),
      width: screenSize.x / zoom,
      height: screenSize.y / zoom,
    );
  }
}
