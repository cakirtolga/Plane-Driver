import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:planedriver_flame/utils/plane_art_direction.dart';

class PauseButtonComponent extends PositionComponent with TapCallbacks, HasGameReference {
  PauseButtonComponent({required this.onPaused}):super(size:Vector2.all(50),anchor:Anchor.topRight,priority:1000);
  final VoidCallback onPaused;
  @override Future<void> onLoad() async {position=Vector2(game.size.x-18,18);}
  @override void onGameResize(Vector2 size){super.onGameResize(size);position=Vector2(size.x-18,18);}
  @override void render(Canvas c){final r=RRect.fromRectAndRadius(size.toRect(),const Radius.circular(15));c.drawRRect(r,Paint()..color=PlaneArtDirection.uiNavy.withValues(alpha:.94));c.drawRRect(r,Paint()..color=PlaneArtDirection.uiEdge.withValues(alpha:.70)..style=PaintingStyle.stroke..strokeWidth=2);final p=Paint()..color=Colors.white; c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:Offset(size.x/2-6,size.y/2),width:6,height:22),const Radius.circular(2)),p);c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:Offset(size.x/2+6,size.y/2),width:6,height:22),const Radius.circular(2)),p);}
  @override void onTapDown(TapDownEvent event)=>onPaused();
}
