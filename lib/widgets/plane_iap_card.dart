import 'package:flutter/material.dart';
import 'package:planedriver_flame/game/assets/aircraft_sprite_repository.dart';
import 'package:planedriver_flame/game/models/vehicle.dart';
import 'package:planedriver_flame/l10n/app_localizations.dart';
import 'package:planedriver_flame/services/iap_service.dart';
import 'package:planedriver_flame/services/save_service.dart';

class PlaneIapCard extends StatelessWidget {
  const PlaneIapCard({
    super.key,
    required this.vehicle,
    required this.onPurchased,
    this.compact = false,
  });

  final Vehicle vehicle;
  final VoidCallback onPurchased;
  final bool compact;

  String _planeName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (vehicle.id) {
      case 0:
        return l10n.planeName0;
      case 1:
        return l10n.planeName1;
      case 2:
        return l10n.planeName2;
      case 3:
        return l10n.planeName3;
      case 4:
        return l10n.planeName4;
      case 5:
        return l10n.planeName5;
      case 6:
        return l10n.planeName6;
      case 7:
        return l10n.planeName7;
      case 8:
        return l10n.planeName8;
      case 9:
        return l10n.planeName9;
      default:
        return 'Plane ${vehicle.id}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isOwned = SaveService.instance.isPlaneOwned(vehicle.id);
    final price = IAPService.instance.priceForPlane(vehicle.id);

    return Card(
      color: Colors.grey.shade900.withValues(alpha: 0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: compact ? 140 : 160,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 50 : 64,
              height: compact ? 50 : 64,
              decoration: BoxDecoration(
                color: Colors.blue.shade800,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Image(
                  image: AircraftSpriteRepository.memoryImage(vehicle.id),
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _planeName(context),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.planeHandling}: ${vehicle.turnSpeed.toStringAsFixed(0)}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),
            Text(
              '${l10n.planeAcceleration}: ${vehicle.acceleration.toStringAsFixed(vehicle.acceleration < 1 ? 2 : 0)}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 8),
            if (isOwned)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.free,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              )
            else
              ElevatedButton(
                onPressed: () async {
                  final success =
                      await IAPService.instance.purchasePlane(vehicle.id);
                  if (success) {
                    onPurchased();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  price,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
