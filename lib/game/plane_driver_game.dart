import 'dart:async';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:planedriver_flame/game/components/boundary_component.dart';
import 'package:planedriver_flame/game/components/explosion_component.dart';
import 'package:planedriver_flame/game/components/finish_component.dart';
import 'package:planedriver_flame/game/components/near_miss_feedback_component.dart';
import 'package:planedriver_flame/game/components/obstacle_component.dart';
import 'package:planedriver_flame/game/components/pause_button_component.dart';
import 'package:planedriver_flame/game/components/player_component.dart';
import 'package:planedriver_flame/game/components/proximity_warning_component.dart';
import 'package:planedriver_flame/game/components/runway_background_component.dart';
import 'package:planedriver_flame/game/components/star_hud_component.dart';
import 'package:planedriver_flame/game/components/timer_hud_component.dart';
import 'package:planedriver_flame/game/camera_manager.dart';
import 'package:planedriver_flame/game/levels/level_generator.dart';
import 'package:planedriver_flame/game/levels/handcrafted_levels.dart';
import 'package:planedriver_flame/game/models/collision_geometry.dart';
import 'package:planedriver_flame/game/models/level_data.dart';
import 'package:planedriver_flame/game/models/vehicle.dart';
import 'package:planedriver_flame/services/analytics_service.dart';
import 'package:planedriver_flame/utils/constants.dart';

enum GameResult { win, lose }

class PlaneDriverGame extends FlameGame
    with
        HasCollisionDetection,
        KeyboardEvents,
        HasElapsedTime {
  PlaneDriverGame({
    required this.levelId,
    required this.vehicle,
    required this.onGameOver,
    required this.onPaused,
    this.adaptiveDifficultyBias = 0,
  }) : super(camera: CameraManager.createCamera());

  final int levelId;
  final Vehicle vehicle;
  final void Function(GameResult result, double time, FailReason? reason)
      onGameOver;
  final VoidCallback onPaused;
  final double adaptiveDifficultyBias;

  late PlayerComponent _player;
  late TimerHudComponent _timerHud;
  late LevelData _levelData;
  late ProximityWarningComponent _proximityWarning;
  late NearMissFeedbackComponent _nearMissFeedback;

  bool _isGameOver = false;
  bool _keyTurnLeft = false;
  bool _keyTurnRight = false;
  bool _keyForward = false;
  bool _keyBackward = false;
  ObstacleComponent? _nearMissCandidate;
  double _candidateMinimumClearance = double.infinity;
  double _nearMissCooldown = 0;

  @override
  double get elapsedTime => _timerHud.elapsedTime;

  LevelData get levelData => _levelData;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _levelData = levelId <= 10
        ? HandcraftedLevelGenerator(vehicle: vehicle).generate(levelId)
        : ProceduralLevelGenerator(
            vehicle: vehicle,
            adaptiveBias: adaptiveDifficultyBias,
          ).generate(levelId);

    CameraManager.fitToScreen(camera, size);

    await add(RunwayBackgroundComponent());

    _player = PlayerComponent(vehicle: vehicle);
    _player.position = _levelData.playerStart;
    await add(_player);

    for (final obstacle in _levelData.obstacles) {
      await add(ObstacleComponent(definition: obstacle));
    }

    await add(FinishComponent(position: _levelData.finishPosition));
    await add(BoundaryComponent.left(x: GameConstants.boundaryX));
    await add(BoundaryComponent.top());
    await add(BoundaryComponent.bottom());

    // HUD lives in the viewport (screen space), not in the world. It therefore
    // remains pinned to device edges on every landscape aspect ratio.
    _timerHud = TimerHudComponent();
    await camera.viewport.add(_timerHud);

    await camera.viewport.add(StarHudComponent(
      levelData: _levelData,
      elapsedSeconds: () => _timerHud.elapsedTime,
    ));
    _proximityWarning = ProximityWarningComponent();
    await camera.viewport.add(_proximityWarning);
    _nearMissFeedback = NearMissFeedbackComponent();
    await camera.viewport.add(_nearMissFeedback);
    await camera.viewport.add(PauseButtonComponent(onPaused: _pauseGame));

    await AnalyticsService.instance.logLevelStart(levelId);
  }

  void setTurnInput(double value) {
    _player.turnInput = value;
  }

  void setMoveInput(double value) {
    _player.moveInput = value;
  }

  void _updateInputsFromKeys() {
    var turn = 0.0;
    if (_keyTurnLeft) turn -= 1.0;
    if (_keyTurnRight) turn += 1.0;

    var move = 0.0;
    if (_keyForward) move += 1.0;
    if (_keyBackward) move -= 1.0;

    _player.turnInput = turn;
    _player.moveInput = move;
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isKeyDown = event is KeyDownEvent || event is KeyRepeatEvent;

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _keyTurnLeft = isKeyDown;
      _updateInputsFromKeys();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _keyTurnRight = isKeyDown;
      _updateInputsFromKeys();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _keyForward = isKeyDown;
      _updateInputsFromKeys();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _keyBackward = isKeyDown;
      _updateInputsFromKeys();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    CameraManager.fitToScreen(camera, canvasSize);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _nearMissCooldown = math.max(0, _nearMissCooldown - dt);

    if (_isGameOver) return;

    _checkBoundaryCollision();
    _checkObstacleCollisionAndProximity();
    _checkFinishCollision();
  }

  void _checkBoundaryCollision() {
    if (_player.position.x < GameConstants.boundaryX + 50) {
      _triggerLose(FailReason.boundary);
      return;
    }

    if (_player.position.y < 40 ||
        _player.position.y > GameConstants.gameHeight - 40) {
      _triggerLose(FailReason.boundary);
      return;
    }

    // The right edge is closed everywhere except the EXIT opening.
    // This prevents bypassing the level by simply driving off-screen.
    const exitHalfHeight = 135.0;
    final insideExitOpening =
        (_player.position.y - _levelData.finishPosition.y).abs() <=
            exitHalfHeight;
    if (_player.position.x > GameConstants.gameWidth - 20 &&
        !insideExitOpening) {
      _triggerLose(FailReason.boundary);
    }
  }

  void _checkFinishCollision() {
    // The exit sits on the right edge. Requiring the player's center to enter
    // the gate prevents a wing tip from completing the level accidentally.
    final finishRect = Rect.fromCenter(
      center: _levelData.finishPosition.toOffset(),
      width: 92,
      height: 270,
    );
    if (finishRect.contains(_player.position.toOffset())) {
      _triggerWin();
    }
  }

  void _checkObstacleCollisionAndProximity() {
    final playerPolygons = _player.worldCollisionPolygons;
    var nearestDistance = double.infinity;
    ObstacleComponent? nearestObstacle;

    for (final obstacle in children.query<ObstacleComponent>()) {
      final obstaclePolygons = obstacle.worldCollisionPolygons;
      if (CollisionGeometry.profilesOverlap(playerPolygons, obstaclePolygons)) {
        _proximityWarning.setProximity(normalizedRisk: 1, relativeDirection: 0);
        _triggerLose(FailReason.obstacle);
        return;
      }

      final distance = CollisionGeometry.distanceBetweenProfiles(
        playerPolygons,
        obstaclePolygons,
      );
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestObstacle = obstacle;
      }
    }

    if (nearestObstacle == null) {
      _proximityWarning.setProximity(normalizedRisk: 0, relativeDirection: 0);
      _completeNearMissIfNeeded();
      return;
    }

    // Thresholds scale with the selected aircraft's actual collision envelope.
    final warningDistance = _player.collisionRotationRadius * 2.25 + 42;
    final risk = (1 - nearestDistance / warningDistance).clamp(0.0, 1.0).toDouble();
    final delta = nearestObstacle.position - _player.position;
    final obstacleBearing = math.atan2(delta.y, delta.x);
    final relative = _normalizeAngle(obstacleBearing - _player.angle);
    final side = math.sin(relative).clamp(-1.0, 1.0).toDouble();
    _proximityWarning.setProximity(
      normalizedRisk: risk,
      relativeDirection: side,
    );

    _updateNearMissCandidate(nearestObstacle, nearestDistance, risk);
  }

  void _updateNearMissCandidate(
    ObstacleComponent obstacle,
    double distance,
    double risk,
  ) {
    if (risk >= .80 && distance > 0 && _nearMissCooldown <= 0) {
      if (!identical(_nearMissCandidate, obstacle)) {
        _nearMissCandidate = obstacle;
        _candidateMinimumClearance = distance;
      } else {
        _candidateMinimumClearance = math.min(_candidateMinimumClearance, distance);
      }
      return;
    }

    // Reward only after the aircraft safely leaves the danger zone. Entering
    // it is tension; exiting it without a collision is the achievement.
    if (_nearMissCandidate != null && risk < .48) {
      _completeNearMissIfNeeded();
    }
  }

  void _completeNearMissIfNeeded() {
    if (_nearMissCandidate == null) return;
    final clearance = _candidateMinimumClearance;
    _nearMissCandidate = null;
    _candidateMinimumClearance = double.infinity;
    _nearMissCooldown = .9;
    _nearMissFeedback.show(clearance: clearance);
    HapticFeedback.lightImpact();
    AnalyticsService.instance.logNearMiss(
      levelId: levelId,
      clearance: clearance,
    );
  }

  double _normalizeAngle(double value) {
    var result = value;
    while (result > math.pi) result -= math.pi * 2;
    while (result < -math.pi) result += math.pi * 2;
    return result;
  }


  void _triggerWin() {
    if (_isGameOver) return;
    _isGameOver = true;
    pauseEngine();
    onGameOver(GameResult.win, _timerHud.elapsedTime, null);
  }

  void _triggerLose(FailReason reason) {
    if (_isGameOver) return;
    _isGameOver = true;
    _player.crash();
    add(ExplosionComponent(position: _player.position));

    Future.delayed(const Duration(milliseconds: 700), () {
      pauseEngine();
      onGameOver(GameResult.lose, _timerHud.elapsedTime, reason);
    });
  }

  void _pauseGame() {
    pauseEngine();
    onPaused();
  }

  void resumeFromPause() {
    resumeEngine();
  }
}

mixin HasElapsedTime on Component {
  double get elapsedTime;
}
