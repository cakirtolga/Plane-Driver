import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:planedriver_flame/game/models/vehicle.dart';
import 'package:planedriver_flame/game/plane_driver_game.dart';
import 'package:planedriver_flame/l10n/app_localizations.dart';
import 'package:planedriver_flame/screens/game_over_screen.dart';
import 'package:planedriver_flame/screens/level_pass_overlay.dart';
import 'package:planedriver_flame/services/ads_service.dart';
import 'package:planedriver_flame/services/analytics_service.dart';
import 'package:planedriver_flame/services/save_service.dart';
import 'package:planedriver_flame/widgets/joystick_overlay.dart';
import 'package:planedriver_flame/widgets/plane_ui.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.levelId});
  final int levelId;
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final PlaneDriverGame _game;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    AdsService.instance.loadInterstitial();
    final vehicle = Vehicle.byId(SaveService.instance.getSelectedVehicleId());
    _game = PlaneDriverGame(
      levelId: widget.levelId,
      vehicle: vehicle,
      onGameOver: _handleGameOver,
      adaptiveDifficultyBias:
          SaveService.instance.getOrCreateDifficultyBiasForLevel(widget.levelId),
      onPaused: () {
        if (mounted) setState(() => _paused = true);
      },
    );
  }

  Future<void> _handleGameOver(
    GameResult result,
    double time,
    FailReason? reason,
  ) async {
    if (result == GameResult.win) {
      final stars = _game.levelData.starsForTime(time);
      await SaveService.instance.updateLevelResult(widget.levelId, stars, time);
      await SaveService.instance.recordRun(won: true, stars: stars);
      AnalyticsService.instance.logLevelComplete(
        levelId: widget.levelId,
        stars: stars,
        time: time,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => LevelPassOverlayScreen(
          levelId: widget.levelId,
          stars: stars,
          time: time,
        ),
      ));
      return;
    }
    await SaveService.instance.recordRun(won: false);
    final failReason = reason ?? FailReason.quit;
    AnalyticsService.instance.logLevelFail(
      levelId: widget.levelId,
      reason: failReason,
      time: time,
    );
    AnalyticsService.instance.logAdInterstitialShow('game_over');
    AdsService.instance.showInterstitial(onDismissed: () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => GameOverScreen(
          levelId: widget.levelId,
          time: time,
          reason: failReason,
        ),
      ));
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF66798B),
        body: OrientationBuilder(builder: (context, orientation) {
          if (orientation != Orientation.landscape) {
            return const _RotateDeviceView();
          }
          return SafeArea(
            minimum: const EdgeInsets.all(4),
            child: LayoutBuilder(builder: (context, constraints) {
              // Flame and Flutter overlays now share the same base scale.
              final worldScale = math.min(
                constraints.maxWidth / 1920,
                constraints.maxHeight / 1080,
              );
              final controlScale = (worldScale * 1.55).clamp(.42, .82);
              final edgeGap = (12 * controlScale).clamp(6.0, 14.0);
              return Stack(fit: StackFit.expand, children: [
                Positioned.fill(child: GameWidget(game: _game)),
                Positioned(
                  left: edgeGap,
                  bottom: edgeGap,
                  child: Transform.scale(
                    scale: controlScale,
                    alignment: Alignment.bottomLeft,
                    child: HorizontalLever(onValueChanged: _game.setTurnInput),
                  ),
                ),
                Positioned(
                  right: edgeGap,
                  bottom: edgeGap,
                  child: Transform.scale(
                    scale: controlScale,
                    alignment: Alignment.bottomRight,
                    child: VerticalLever(onValueChanged: _game.setMoveInput),
                  ),
                ),
                if (_paused)
                  Container(
                    color: Colors.black.withValues(alpha: .48),
                    child: _PauseOverlay(
                      onResume: () {
                        setState(() => _paused = false);
                        _game.resumeFromPause();
                      },
                      onRestart: () {
                        setState(() => _paused = false);
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (_) => GameScreen(levelId: widget.levelId),
                        ));
                      },
                      onExit: () {
                        _game.resumeFromPause();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
              ]);
            }),
          );
        }),
      );
}

class _RotateDeviceView extends StatelessWidget {
  const _RotateDeviceView();
  @override
  Widget build(BuildContext context) => const ColoredBox(
        color: Color(0xFF17324D),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.screen_rotation_rounded, color: Colors.white, size: 58),
            SizedBox(height: 14),
            Text(
              'ROTATE YOUR DEVICE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ]),
        ),
      );
}

class _PauseOverlay extends StatelessWidget {
  const _PauseOverlay({
    required this.onResume,
    required this.onRestart,
    required this.onExit,
  });
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PlaneDialogSurface(
      maxWidth: 460,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const PlaneBadge(label: 'PLANE DRIVER', icon: Icons.flight_rounded),
        const SizedBox(height: 12),
        Text(l10n.pause.toUpperCase(),
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: PlanePrimaryButton(
            label: l10n.resume,
            icon: Icons.play_arrow_rounded,
            green: true,
            onPressed: onResume,
          ),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: PlaneSecondaryButton(
              label: l10n.restart,
              icon: Icons.replay_rounded,
              onPressed: onRestart,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: PlaneSecondaryButton(
              label: l10n.exit,
              icon: Icons.home_rounded,
              onPressed: onExit,
            ),
          ),
        ]),
      ]),
    );
  }
}
