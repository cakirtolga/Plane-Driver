import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:planedriver_flame/l10n/app_localizations.dart';
import 'package:planedriver_flame/screens/game_screen.dart';
import 'package:planedriver_flame/services/analytics_service.dart';
import 'package:planedriver_flame/utils/theme.dart';
import 'package:planedriver_flame/widgets/plane_ui.dart';

class LevelPassOverlayScreen extends StatefulWidget {
  const LevelPassOverlayScreen({
    super.key,
    required this.levelId,
    required this.stars,
    required this.time,
  });

  final int levelId;
  final int stars;
  final double time;

  @override
  State<LevelPassOverlayScreen> createState() => _LevelPassOverlayScreenState();
}

class _LevelPassOverlayScreenState extends State<LevelPassOverlayScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entry;
  late final List<AnimationController> _starControllers;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView('level_pass');
    _entry = AnimationController(
      vsync: this,
      duration: PlaneDriverTheme.celebration,
    );
    _starControllers = List.generate(
      3,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 340),
      ),
    );
    _playCelebration();
  }

  Future<void> _playCelebration() async {
    await _entry.forward();
    for (var i = 0; i < widget.stars.clamp(0, 3); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 110));
      if (!mounted) return;
      await _starControllers[i].forward();
    }
  }

  @override
  void dispose() {
    _entry.dispose();
    for (final controller in _starControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: PlaneScreenBackground(
        child: SafeArea(
          child: Stack(
            children: [
              const Positioned.fill(child: _Confetti()),
              Center(
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _entry,
                    curve: Curves.easeOutBack,
                  ),
                  child: PlaneDialogSurface(
                    maxWidth: 560,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PlaneBadge(
                          label: l10n.level(widget.levelId).toUpperCase(),
                          color: PlaneDriverTheme.green,
                          icon: Icons.flag_rounded,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.levelComplete.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            3,
                            (i) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: _ResultStar(
                                earned: i < widget.stars,
                                controller: _starControllers[i],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            color: const Color(0x1FFFFFFF),
                            borderRadius: BorderRadius.circular(PlaneDriverTheme.rMd),
                          ),
                          child: Text(
                            '${l10n.time}: ${widget.time.toStringAsFixed(1)}s',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: PlanePrimaryButton(
                            label: l10n.nextLevel,
                            icon: Icons.arrow_forward_rounded,
                            green: true,
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => GameScreen(
                                    levelId: widget.levelId + 1,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: PlaneSecondaryButton(
                                label: l10n.restart,
                                icon: Icons.replay_rounded,
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => GameScreen(
                                        levelId: widget.levelId,
                                      ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultStar extends StatelessWidget {
  const _ResultStar({required this.earned, required this.controller});
  final bool earned;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    if (!earned) {
      return const Icon(
        Icons.star_rounded,
        color: Color(0x556A86A1),
        size: 70,
      );
    }

    final animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.25, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
    ]).animate(controller);

    return ScaleTransition(
      scale: animation,
      child: Transform.rotate(
        angle: -math.pi / 40,
        child: const Icon(
          Icons.star_rounded,
          color: PlaneDriverTheme.yellow,
          size: 70,
          shadows: [
            Shadow(
              color: Color(0x66000000),
              blurRadius: 7,
              offset: Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }
}

class _Confetti extends StatelessWidget {
  const _Confetti();
  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: CustomPaint(painter: _ConfettiPainter()),
      );
}

class _ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const points = [
      Offset(.08, .15),
      Offset(.18, .30),
      Offset(.31, .12),
      Offset(.73, .14),
      Offset(.88, .29),
      Offset(.94, .12),
      Offset(.12, .78),
      Offset(.28, .88),
      Offset(.76, .82),
      Offset(.90, .72),
    ];
    const colors = [
      PlaneDriverTheme.yellow,
      PlaneDriverTheme.cyan,
      PlaneDriverTheme.coral,
      PlaneDriverTheme.green,
      PlaneDriverTheme.purple,
    ];
    final paint = Paint();
    for (var i = 0; i < points.length; i++) {
      paint.color = colors[i % colors.length].withValues(alpha: .85);
      final offset = Offset(
        size.width * points[i].dx,
        size.height * points[i].dy,
      );
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.rotate(i * .44);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-5, -10, 10, 20),
          const Radius.circular(3),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
