import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:planedriver_flame/game/assets/aircraft_sprite_repository.dart';
import 'package:planedriver_flame/game/models/level_state.dart';
import 'package:planedriver_flame/game/models/vehicle.dart';
import 'package:planedriver_flame/l10n/app_localizations.dart';
import 'package:planedriver_flame/screens/credits_screen.dart';
import 'package:planedriver_flame/screens/game_screen.dart';
import 'package:planedriver_flame/screens/vehicle_select_screen.dart';
import 'package:planedriver_flame/services/analytics_service.dart';
import 'package:planedriver_flame/services/save_service.dart';
import 'package:planedriver_flame/utils/theme.dart';
import 'package:planedriver_flame/widgets/plane_ui.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  int _currentLevel = 1;
  int _selectedPlaneId = 0;
  List<LevelState> _visibleLevels = const [];

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
      lowerBound: 0,
      upperBound: 1,
    )..repeat(reverse: true);
    _refresh();
    AnalyticsService.instance.logScreenView('menu_progression');
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _refresh() {
    final all = SaveService.instance.getAllLevelStates();
    var current = 1;
    for (final level in all) {
      if (level.unlocked && level.stars == 0) {
        current = level.id;
        break;
      }
      if (level.stars > 0) current = level.id + 1;
    }

    final start = math.max(1, current - 3);
    final end = start + 8;
    final states = <LevelState>[];
    for (var id = start; id <= end; id++) {
      states.add(SaveService.instance.getLevelState(id));
    }

    if (!mounted) {
      _currentLevel = current;
      _selectedPlaneId = SaveService.instance.getSelectedVehicleId();
      _visibleLevels = states;
      return;
    }
    setState(() {
      _currentLevel = current;
      _selectedPlaneId = SaveService.instance.getSelectedVehicleId();
      _visibleLevels = states;
    });
  }

  Future<void> _openPlaneSelect() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const VehicleSelectScreen()),
    );
    if (mounted) _refresh();
  }

  Future<void> _play() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GameScreen(levelId: _currentLevel)),
    );
    if (mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [PlaneDriverTheme.sky, Color(0xFFBDEBFA), Color(0xFF85C989)],
            stops: [0, .62, 1],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _AirportBackdropPainter(),
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                        child: Row(
                          children: [
                            _GlassPill(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded, color: PlaneDriverTheme.yellow, size: 22),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${_totalStars()}',
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            PlaneIconButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const CreditsScreen()),
                                );
                              },
                              icon: Icons.settings_rounded,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: _ProgressRoad(
                            levels: _visibleLevels,
                            currentLevel: _currentLevel,
                            pulse: _pulse,
                          ),
                        ),
                      ),
                      _PlaneDock(
                        vehicle: Vehicle.byId(_selectedPlaneId),
                        currentLevel: _currentLevel,
                        onPlaneTap: _openPlaneSelect,
                        onPlay: _play,
                        playLabel: l10n.play,
                        levelLabel: l10n.level(_currentLevel),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  int _totalStars() {
    return SaveService.instance
        .getAllLevelStates()
        .fold<int>(0, (sum, level) => sum + level.stars);
  }
}

class _ProgressRoad extends StatelessWidget {
  const _ProgressRoad({
    required this.levels,
    required this.currentLevel,
    required this.pulse,
  });

  final List<LevelState> levels;
  final int currentLevel;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    if (levels.isEmpty) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, _) {
        return CustomPaint(
          painter: _RoadPainter(levels: levels, currentLevel: currentLevel),
          child: LayoutBuilder(
            builder: (context, c) {
              final points = _roadPoints(c.maxWidth, c.maxHeight, levels.length);
              return Stack(
                children: [
                  for (var i = 0; i < levels.length; i++)
                    Positioned(
                      left: points[i].dx - 30,
                      top: points[i].dy - 30,
                      child: _LevelNode(
                        state: levels[i],
                        isCurrent: levels[i].id == currentLevel,
                        pulse: pulse.value,
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

List<Offset> _roadPoints(double width, double height, int count) {
  if (count <= 1) return [Offset(width / 2, height / 2)];
  final usableH = math.max(1.0, height - 55);
  return List.generate(count, (i) {
    final t = i / (count - 1);
    final y = usableH - t * usableH + 24;
    final wave = math.sin(t * math.pi * 3.2);
    final x = width / 2 + wave * math.min(width * .30, 110);
    return Offset(x, y);
  });
}

class _RoadPainter extends CustomPainter {
  const _RoadPainter({required this.levels, required this.currentLevel});
  final List<LevelState> levels;
  final int currentLevel;

  @override
  void paint(Canvas canvas, Size size) {
    final points = _roadPoints(size.width, size.height, levels.length);
    if (points.length < 2) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final p = points[i];
      final midY = (prev.dy + p.dy) / 2;
      path.cubicTo(prev.dx, midY, p.dx, midY, p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFFFFF).withValues(alpha: .86)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF6E9B75).withValues(alpha: .24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RoadPainter oldDelegate) =>
      oldDelegate.currentLevel != currentLevel || oldDelegate.levels != levels;
}

class _LevelNode extends StatelessWidget {
  const _LevelNode({required this.state, required this.isCurrent, required this.pulse});
  final LevelState state;
  final bool isCurrent;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    final locked = !state.unlocked;
    final scale = isCurrent ? 1.05 + pulse * .08 : 1.0;
    return Transform.scale(
      scale: scale,
      child: SizedBox(
        width: 60,
        height: 60,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (isCurrent)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PlaneDriverTheme.yellow.withValues(alpha: .22 + pulse * .15),
                ),
              ),
            Container(
              width: isCurrent ? 48 : 42,
              height: isCurrent ? 48 : 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: locked
                    ? const Color(0xFF7891A6)
                    : state.stars > 0
                        ? PlaneDriverTheme.green
                        : PlaneDriverTheme.orange,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 3))],
              ),
              alignment: Alignment.center,
              child: locked
                  ? const Icon(Icons.lock_rounded, color: Colors.white, size: 18)
                  : Text(
                      '${state.id}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                    ),
            ),
            if (state.stars > 0)
              Positioned(
                bottom: -5,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) => Icon(
                    Icons.star_rounded,
                    size: 12,
                    color: i < state.stars ? PlaneDriverTheme.yellow : const Color(0xFFB7C5C1),
                  )),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlaneDock extends StatelessWidget {
  const _PlaneDock({required this.vehicle,required this.currentLevel,required this.onPlaneTap,required this.onPlay,required this.playLabel,required this.levelLabel});
  final Vehicle vehicle; final int currentLevel; final VoidCallback onPlaneTap,onPlay; final String playLabel,levelLabel;
  @override Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(14,4,14,14),
    child: PlanePanel(
      color: PlaneDriverTheme.navy.withValues(alpha:.94),
      padding: const EdgeInsets.fromLTRB(14,10,14,12),
      child: Row(children:[
        InkWell(onTap:onPlaneTap,borderRadius:BorderRadius.circular(PlaneDriverTheme.rLg),child:Container(width:104,height:82,decoration:BoxDecoration(color:PlaneDriverTheme.skyDeep,borderRadius:BorderRadius.circular(PlaneDriverTheme.rLg),border:Border.all(color:const Color(0x55FFFFFF),width:2)),child:Stack(children:[Positioned.fill(child:Padding(padding:const EdgeInsets.all(6),child:Image(image:AircraftSpriteRepository.memoryImage(vehicle.id),fit:BoxFit.contain,filterQuality:FilterQuality.high))),const Positioned(right:5,top:5,child:CircleAvatar(radius:13,backgroundColor:PlaneDriverTheme.yellow,child:Icon(Icons.swap_horiz_rounded,size:17,color:PlaneDriverTheme.navy)))]))),
        const SizedBox(width:14),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[PlaneBadge(label:levelLabel.toUpperCase(),color:PlaneDriverTheme.skyDeep,icon:Icons.route_rounded),const SizedBox(height:6),Text('PLANE DRIVER',style:Theme.of(context).textTheme.titleLarge)])),
        const SizedBox(width:12),
        SizedBox(width:190,child:PlanePrimaryButton(label:playLabel,icon:Icons.play_arrow_rounded,green:false,onPressed:onPlay)),
      ]),
    ),
  );
}

class _AirportBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: .16);
    for (var i = 0; i < 7; i++) {
      final x = (i * 113.0) % size.width;
      final y = (i * 167.0) % math.max(1.0, size.height * .75);
      canvas.drawCircle(Offset(x, y), 24 + (i % 3) * 9, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: PlaneDriverTheme.navy.withValues(alpha: .90),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}
