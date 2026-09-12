import 'package:flutter/material.dart';
import 'package:planedriver_flame/utils/theme.dart';
import 'package:planedriver_flame/utils/plane_art_direction.dart';

class _ControlShell extends StatelessWidget {
  const _ControlShell({required this.child, required this.width, required this.height});
  final Widget child;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: PlaneArtDirection.uiNavy.withValues(alpha: .95),
          borderRadius: BorderRadius.circular(PlaneDriverTheme.rLg),
          border: Border.all(color: PlaneArtDirection.uiEdge.withValues(alpha: .72), width: 2.5),
          boxShadow: PlaneDriverTheme.softShadow,
        ),
        child: child,
      );
}

class _OrangeKnob extends StatelessWidget {
  const _OrangeKnob({required this.icon, required this.pressed});
  final IconData icon;
  final bool pressed;
  @override
  Widget build(BuildContext context) => AnimatedScale(
        duration: PlaneDriverTheme.fast,
        scale: pressed ? .94 : 1,
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: PlaneArtDirection.interactionAmber,
            border: Border.all(color: const Color(0xFFFFE8A3), width: 3),
            boxShadow: const [BoxShadow(color: Color(0x55052D5D), blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: Icon(icon, color: PlaneArtDirection.uiNavyDeep, size: 28),
        ),
      );
}

class VerticalLever extends StatefulWidget {
  const VerticalLever({super.key, required this.onValueChanged});
  final ValueChanged<double> onValueChanged;
  @override
  State<VerticalLever> createState() => _VerticalLeverState();
}

class _VerticalLeverState extends State<VerticalLever> {
  double _knobY = .5;
  bool _dragging = false;
  void _update(double y) {
    final n = ((y - 30) / 200).clamp(0.0, 1.0);
    setState(() => _knobY = n);
    widget.onValueChanged(1 - n * 2);
  }
  void _reset() { setState(() { _dragging = false; _knobY = .5; }); widget.onValueChanged(0); }

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown: (e) { setState(() => _dragging = true); _update(e.localPosition.dy); },
        onPointerMove: (e) => _update(e.localPosition.dy),
        onPointerUp: (_) => _reset(),
        onPointerCancel: (_) => _reset(),
        child: _ControlShell(
          width: 94,
          height: 276,
          child: Stack(alignment: Alignment.center, children: [
            Container(width: 12, height: 196, decoration: BoxDecoration(color: PlaneArtDirection.uiNavyDeep.withValues(alpha: .72), borderRadius: BorderRadius.circular(99), border: Border.all(color: const Color(0x44FFFFFF)))),
            const Positioned(top: 12, child: Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white, size: 30)),
            const Positioned(bottom: 12, child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 30)),
            Positioned(top: 200 * _knobY + 27, child: _OrangeKnob(icon: _dragging ? Icons.touch_app_rounded : Icons.flight_takeoff_rounded, pressed: _dragging)),
          ]),
        ),
      );
}

class HorizontalLever extends StatefulWidget {
  const HorizontalLever({super.key, required this.onValueChanged});
  final ValueChanged<double> onValueChanged;
  @override
  State<HorizontalLever> createState() => _HorizontalLeverState();
}

class _HorizontalLeverState extends State<HorizontalLever> {
  double _knobX = .5;
  bool _dragging = false;
  void _update(double x) {
    final n = ((x - 30) / 200).clamp(0.0, 1.0);
    setState(() => _knobX = n);
    widget.onValueChanged(n * 2 - 1);
  }
  void _reset() { setState(() { _dragging = false; _knobX = .5; }); widget.onValueChanged(0); }

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown: (e) { setState(() => _dragging = true); _update(e.localPosition.dx); },
        onPointerMove: (e) => _update(e.localPosition.dx),
        onPointerUp: (_) => _reset(),
        onPointerCancel: (_) => _reset(),
        child: _ControlShell(
          width: 276,
          height: 94,
          child: Stack(alignment: Alignment.center, children: [
            Container(width: 196, height: 12, decoration: BoxDecoration(color: PlaneArtDirection.uiNavyDeep.withValues(alpha: .72), borderRadius: BorderRadius.circular(99), border: Border.all(color: const Color(0x44FFFFFF)))),
            const Positioned(left: 12, child: Icon(Icons.keyboard_arrow_left_rounded, color: Colors.white, size: 30)),
            const Positioned(right: 12, child: Icon(Icons.keyboard_arrow_right_rounded, color: Colors.white, size: 30)),
            Positioned(left: 200 * _knobX + 27, child: _OrangeKnob(icon: _dragging ? Icons.touch_app_rounded : Icons.swap_horiz_rounded, pressed: _dragging)),
          ]),
        ),
      );
}
