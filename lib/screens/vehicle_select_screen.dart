import 'package:flutter/material.dart';
import 'package:planedriver_flame/game/assets/aircraft_sprite_repository.dart';
import 'package:planedriver_flame/game/models/vehicle.dart';
import 'package:planedriver_flame/l10n/app_localizations.dart';
import 'package:planedriver_flame/services/analytics_service.dart';
import 'package:planedriver_flame/services/iap_service.dart';
import 'package:planedriver_flame/services/save_service.dart';
import 'package:planedriver_flame/utils/theme.dart';
import 'package:planedriver_flame/widgets/plane_ui.dart';

class VehicleSelectScreen extends StatefulWidget {
  const VehicleSelectScreen({super.key});
  @override
  State<VehicleSelectScreen> createState() => _VehicleSelectScreenState();
}

class _VehicleSelectScreenState extends State<VehicleSelectScreen> {
  int _selectedPlaneId = 0;
  bool _restoring = false;
  @override
  void initState() { super.initState(); _selectedPlaneId = SaveService.instance.getSelectedVehicleId(); IAPService.instance.loadProducts(); AnalyticsService.instance.logScreenView('vehicle_select'); }

  String _name(BuildContext context, Vehicle v) {
    final l = AppLocalizations.of(context);
    return [l.planeName0,l.planeName1,l.planeName2,l.planeName3,l.planeName4,l.planeName5,l.planeName6,l.planeName7,l.planeName8,l.planeName9][v.id < 0 ? 0 : (v.id > 9 ? 9 : v.id)];
  }

  Future<void> _select(Vehicle v) async {
    if (!SaveService.instance.isPlaneOwned(v.id) && !await IAPService.instance.purchasePlane(v.id)) return;
    await SaveService.instance.setSelectedVehicleId(v.id);
    await AnalyticsService.instance.logPlaneSelected(v.id);
    if (mounted) setState(() => _selectedPlaneId = v.id);
  }

  Future<void> _restore() async {
    setState(() => _restoring = true);
    final ok = await IAPService.instance.restorePurchases();
    await AnalyticsService.instance.logPurchaseRestore(success: ok);
    if (!mounted) return;
    setState(() => _restoring = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? AppLocalizations.of(context).purchasesRestored : AppLocalizations.of(context).purchaseFailed)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final selected = Vehicle.byId(_selectedPlaneId);
    return Scaffold(
      body: PlaneScreenBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(flex: 4, child: PlanePanel(child: Column(children: [
                Row(children: [PlaneIconButton(icon: Icons.arrow_back_rounded, onPressed: () => Navigator.pop(context)), const SizedBox(width: 12), Text(l.vehicleSelect.toUpperCase(), style: Theme.of(context).textTheme.headlineMedium), const Spacer(), TextButton.icon(onPressed: _restoring ? null : _restore, icon: _restoring ? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)) : const Icon(Icons.restore_rounded), label: Text(l.restorePurchases))]),
                const SizedBox(height: 8),
                Expanded(child: Container(decoration: BoxDecoration(color: PlaneDriverTheme.skyDeep.withValues(alpha:.5), borderRadius: BorderRadius.circular(PlaneDriverTheme.rLg)), child: Center(child: Image(image: AircraftSpriteRepository.memoryImage(selected.id), fit: BoxFit.contain, filterQuality: FilterQuality.high)))),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [PlaneBadge(label: _name(context, selected).toUpperCase(), color: PlaneDriverTheme.green, icon: Icons.check_rounded)]),
                const SizedBox(height: 12),
                Row(children: [Expanded(child: _Stat(label:l.planeHandling, value:selected.turnSpeed.toStringAsFixed(0))), const SizedBox(width:8), Expanded(child:_Stat(label:l.planeAcceleration,value:selected.acceleration.toStringAsFixed(selected.acceleration < 1 ? 2 : 0)))]),
                const SizedBox(height: 14),
                SizedBox(width: 220, child: PlanePrimaryButton(label: l.continueText, icon: Icons.check_rounded, green: true, onPressed: () => Navigator.pop(context))),
              ]))),
              const SizedBox(width: 16),
              Expanded(flex: 6, child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, childAspectRatio: .78, crossAxisSpacing: 10, mainAxisSpacing: 10),
                itemCount: Vehicle.all.length,
                itemBuilder: (_, i) {
                  final v = Vehicle.all[i]; final sel = v.id == _selectedPlaneId; final owned = SaveService.instance.isPlaneOwned(v.id);
                  return InkWell(onTap: () => _select(v), borderRadius: BorderRadius.circular(PlaneDriverTheme.rMd), child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(color: sel ? PlaneDriverTheme.panelLight : PlaneDriverTheme.panel, borderRadius: BorderRadius.circular(PlaneDriverTheme.rMd), border: Border.all(color: sel ? PlaneDriverTheme.yellow : const Color(0x35FFFFFF), width: sel ? 3 : 1.5), boxShadow: sel ? PlaneDriverTheme.softShadow : null),
                    child: Column(children: [Expanded(child: Image(image: AircraftSpriteRepository.memoryImage(v.id), fit: BoxFit.contain, filterQuality: FilterQuality.high)), const SizedBox(height:4), Text(_name(context,v), maxLines:1, overflow:TextOverflow.ellipsis, style: const TextStyle(fontWeight:FontWeight.w900,color:Colors.white)), const SizedBox(height:5), PlaneBadge(label: owned ? (v.isFree ? l.free.toUpperCase() : 'OWNED') : IAPService.instance.priceForPlane(v.id), color: sel ? PlaneDriverTheme.green : (owned ? PlaneDriverTheme.skyDeep : PlaneDriverTheme.purple))]),
                  ));
                },
              )),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value}); final String label; final String value;
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal:12,vertical:10), decoration: BoxDecoration(color: const Color(0x22000000), borderRadius: BorderRadius.circular(14)), child: Row(children:[Expanded(child:Text(label,style:const TextStyle(color:Colors.white70,fontWeight:FontWeight.w800))),Text(value,style:const TextStyle(color:PlaneDriverTheme.yellow,fontWeight:FontWeight.w900))]));
}
