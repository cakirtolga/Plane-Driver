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

    final widthZoom = screenSize.x / GameConstants.gameWidth;
    final heightZoom = screenSize.y / GameConstants.gameHeight;
    final containZoom = math.min(widthZoom, heightZoom);
    final responsiveZoom = screenSize.x / screenSize.y > 1.82
        ? math.min(widthZoom, containZoom * 1.25)
        : containZoom;

    camera.viewfinder
      ..anchor = Anchor.center
      ..position = GameConstants.logicalSize / 2
      ..zoom = responsiveZoom.clamp(0.01, 4.0).toDouble();
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
    final widthZoom = screenSize.x / GameConstants.gameWidth;
    final heightZoom = screenSize.y / GameConstants.gameHeight;
    final containZoom = math.min(widthZoom, heightZoom);
    final zoom = screenSize.x / screenSize.y > 1.82
        ? math.min(widthZoom, containZoom * 1.25)
        : containZoom;
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
