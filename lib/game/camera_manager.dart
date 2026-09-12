import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:planedriver_flame/utils/constants.dart';

/// Full-screen responsive camera.
///
/// The 1920x1080 gameplay rectangle is always fully visible. Devices with a
/// wider/taller landscape aspect simply reveal extra apron around it instead
/// of stretching sprites or changing gameplay scale.
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

  /// Visible world rectangle at the current device aspect ratio. Useful for
  /// backgrounds/decorations only; gameplay remains inside the base bounds.
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
    final visibleW = screenSize.x / zoom;
    final visibleH = screenSize.y / zoom;
    return Rect.fromCenter(
      center: const Offset(
        GameConstants.gameWidth / 2,
        GameConstants.gameHeight / 2,
      ),
      width: visibleW,
      height: visibleH,
    );
  }
}
