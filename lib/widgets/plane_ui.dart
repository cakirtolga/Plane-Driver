import 'package:flutter/material.dart';
import 'package:planedriver_flame/utils/theme.dart';

class PlanePanel extends StatelessWidget {
  const PlanePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color = PlaneDriverTheme.panel,
    this.borderColor = const Color(0x40FFFFFF),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(PlaneDriverTheme.rLg),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: PlaneDriverTheme.softShadow,
      ),
      child: child,
    );
  }
}

class PlanePrimaryButton extends StatefulWidget {
  const PlanePrimaryButton({super.key, required this.label, required this.onPressed, this.icon, this.green = false});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool green;

  @override
  State<PlanePrimaryButton> createState() => _PlanePrimaryButtonState();
}

class _PlanePrimaryButtonState extends State<PlanePrimaryButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? .96 : 1,
      duration: PlaneDriverTheme.fast,
      child: GestureDetector(
        onTapDown: widget.onPressed == null ? null : (_) => setState(() => _pressed = true),
        onTapCancel: widget.onPressed == null ? null : () => setState(() => _pressed = false),
        onTapUp: widget.onPressed == null ? null : (_) => setState(() => _pressed = false),
        child: SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: widget.onPressed,
            icon: Icon(widget.icon ?? Icons.play_arrow_rounded, size: 25),
            label: Text(widget.label.toUpperCase()),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.green ? PlaneDriverTheme.green : PlaneDriverTheme.yellow,
              foregroundColor: widget.green ? Colors.white : PlaneDriverTheme.navy,
              shadowColor: PlaneDriverTheme.navyDeep,
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PlaneDriverTheme.rMd)),
            ),
          ),
        ),
      ),
    );
  }
}

class PlaneSecondaryButton extends StatelessWidget {
  const PlaneSecondaryButton({super.key, required this.label, required this.onPressed, required this.icon});
  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 50,
        child: OutlinedButton.icon(onPressed: onPressed, icon: Icon(icon), label: Text(label.toUpperCase())),
      );
}

class PlaneIconButton extends StatelessWidget {
  const PlaneIconButton({super.key, required this.icon, required this.onPressed, this.tooltip});
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: PlaneDriverTheme.panel,
        foregroundColor: PlaneDriverTheme.white,
        minimumSize: const Size(48, 48),
        side: const BorderSide(color: Color(0x40FFFFFF), width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PlaneDriverTheme.rMd)),
      ),
      icon: Icon(icon),
    );
  }
}

class PlaneBadge extends StatelessWidget {
  const PlaneBadge({super.key, required this.label, this.color = PlaneDriverTheme.skyDeep, this.icon});
  final String label;
  final Color color;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999), border: Border.all(color: const Color(0x66FFFFFF))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 5)],
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: .4)),
        ]),
      );
}

class PlaneDialogSurface extends StatelessWidget {
  const PlaneDialogSurface({super.key, required this.child, this.maxWidth = 520});
  final Widget child;
  final double maxWidth;
  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: PlanePanel(
            color: PlaneDriverTheme.navy,
            borderColor: const Color(0x66FFFFFF),
            padding: const EdgeInsets.all(26),
            child: child,
          ),
        ),
      );
}

class PlaneScreenBackground extends StatelessWidget {
  const PlaneScreenBackground({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF70CEF4), Color(0xFF29A5DF), Color(0xFF0E68AC)],
          ),
        ),
        child: child,
      );
}
