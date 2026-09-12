// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Plane Driver';

  @override
  String get play => 'Jugar';

  @override
  String get credits => 'Créditos';

  @override
  String get exit => 'Salir';

  @override
  String get back => 'Atrás';

  @override
  String get continueText => 'Continuar';

  @override
  String get restart => 'Reiniciar';

  @override
  String get resume => 'Reanudar';

  @override
  String get levelSelect => 'Seleccionar nivel';

  @override
  String get vehicleSelect => 'Seleccionar avión';

  @override
  String get locked => 'Bloqueado';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get purchasesRestored => 'Compras restauradas';

  @override
  String get purchaseFailed => 'Compra fallida';

  @override
  String get free => 'Gratis';

  @override
  String get levelComplete => 'Nivel completado';

  @override
  String get gameOver => 'Juego terminado';

  @override
  String get levelFailed => 'Nivel fallido';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String get stars => 'Estrellas';

  @override
  String get time => 'Tiempo';

  @override
  String get bestTime => 'Mejor tiempo';

  @override
  String get nextLevel => 'Siguiente nivel';

  @override
  String get unlockBetterPlane => 'Desbloquear un avión mejor';

  @override
  String get noThanks => 'No, gracias';

  @override
  String get pause => 'Pausa';

  @override
  String get settings => 'Ajustes';

  @override
  String get creditsText => 'Plane Driver\nDesarrollado por Tarda Games';

  @override
  String level(int levelNumber) {
    return 'Nivel $levelNumber';
  }

  @override
  String get planeSpeed => 'Velocidad';

  @override
  String get planeHandling => 'Manejo';

  @override
  String get planeAcceleration => 'Aceleración';

  @override
  String get planeName0 => 'Inicial';

  @override
  String get planeName1 => 'Rápido';

  @override
  String get planeName2 => 'Rayo';

  @override
  String get planeName3 => 'Planeador';

  @override
  String get planeName4 => 'Cohete';

  @override
  String get planeName5 => 'Tanque';

  @override
  String get planeName6 => 'As';

  @override
  String get planeName7 => 'Jet';

  @override
  String get planeName8 => 'Corredor';

  @override
  String get planeName9 => 'Turbo';
}
