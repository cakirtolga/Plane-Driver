import 'package:flame/game.dart';

class GameConstants {
  GameConstants._();

  static const double gameWidth = 1920;
  static const double gameHeight = 1080;

  static final Vector2 logicalSize = Vector2(gameWidth, gameHeight);

  static const double playerStartX = 100;
  static const double playerStartY = 540;

  static final Vector2 playerStart = Vector2(playerStartX, playerStartY);
  static final Vector2 finishPosition = Vector2(1868, 540);

  static const double boundaryX = -150;

  static const double defaultFriction = 0.95;

  static const double threeStarTime = 20.0;
  static const double twoStarTime = 40.0;
  static const double oneStarTime = 90.0;

  // Levels are generated indefinitely. This is only the minimum amount shown
  // in Level Select before the list grows with player progress.
  static const int minimumLevelSelectCount = 30;
  static const int totalLevels = minimumLevelSelectCount;
  static const int totalPlanes = 10;

  static const String freePlaneProductId =
      'com.tardagames.planedriver.plane_0';

  static String planeProductId(int index) {
    return 'com.tardagames.planedriver.plane_$index';
  }
}
