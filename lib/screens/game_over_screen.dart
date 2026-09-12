import 'package:flutter/material.dart';
import 'package:planedriver_flame/l10n/app_localizations.dart';
import 'package:planedriver_flame/screens/game_screen.dart';
import 'package:planedriver_flame/screens/vehicle_select_screen.dart';
import 'package:planedriver_flame/services/ads_service.dart';
import 'package:planedriver_flame/services/analytics_service.dart';
import 'package:planedriver_flame/utils/theme.dart';
import 'package:planedriver_flame/widgets/plane_ui.dart';

class GameOverScreen extends StatefulWidget {
  const GameOverScreen({
    super.key,
    required this.levelId,
    required this.time,
    required this.reason,
  });

  final int levelId;
  final double time;
  final FailReason reason;

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView('game_over');
  }

  String _reason(AppLocalizations l10n) {
    switch (widget.reason) {
      case FailReason.obstacle:
        return 'WATCH THE WINGS!';
      case FailReason.boundary:
        return 'STAY ON THE APRON!';
      case FailReason.quit:
        return l10n.levelFailed.toUpperCase();
    }
  }

  String _detail() {
    switch (widget.reason) {
      case FailReason.obstacle:
        return 'Your aircraft touched an obstacle.';
      case FailReason.boundary:
        return 'The aircraft left the safe driving area.';
      case FailReason.quit:
        return '';
    }
  }

  void _retry() {
    AnalyticsService.instance.logAdInterstitialShow('restart');
    AdsService.instance.showInterstitial(
      onDismissed: () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => GameScreen(levelId: widget.levelId),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: PlaneScreenBackground(
        child: SafeArea(
          child: Center(
            child: PlaneDialogSurface(
              maxWidth: 620,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 150,
                    height: 190,
                    decoration: BoxDecoration(
                      color: PlaneDriverTheme.coral.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(PlaneDriverTheme.rLg),
                    ),
                    child: const Icon(
                      Icons.airplanemode_inactive_rounded,
                      color: PlaneDriverTheme.coral,
                      size: 94,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PlaneBadge(
                          label: l10n.level(widget.levelId).toUpperCase(),
                          color: PlaneDriverTheme.coral,
                          icon: Icons.warning_rounded,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _reason(l10n),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 7),
                        Text(
                          _detail(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${l10n.time}: ${widget.time.toStringAsFixed(1)}s',
                          style: const TextStyle(
                            color: PlaneDriverTheme.yellow,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 18),
                        PlanePrimaryButton(
                          label: l10n.tryAgain,
                          icon: Icons.replay_rounded,
                          onPressed: _retry,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: PlaneSecondaryButton(
                                label: l10n.vehicleSelect,
                                icon: Icons.flight_rounded,
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const VehicleSelectScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: PlaneSecondaryButton(
                                label: l10n.appTitle,
                                icon: Icons.home_rounded,
                                onPressed: () {
                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
