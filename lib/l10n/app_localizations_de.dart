// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Plane Driver';

  @override
  String get play => 'Spielen';

  @override
  String get credits => 'Credits';

  @override
  String get exit => 'Beenden';

  @override
  String get back => 'Zurück';

  @override
  String get continueText => 'Weiter';

  @override
  String get restart => 'Neustart';

  @override
  String get resume => 'Fortsetzen';

  @override
  String get levelSelect => 'Level wählen';

  @override
  String get vehicleSelect => 'Flugzeug wählen';

  @override
  String get locked => 'Gesperrt';

  @override
  String get unlock => 'Freischalten';

  @override
  String get restorePurchases => 'Käufe wiederherstellen';

  @override
  String get purchasesRestored => 'Käufe wiederhergestellt';

  @override
  String get purchaseFailed => 'Kauf fehlgeschlagen';

  @override
  String get free => 'Kostenlos';

  @override
  String get levelComplete => 'Level geschafft';

  @override
  String get gameOver => 'Spiel vorbei';

  @override
  String get levelFailed => 'Level fehlgeschlagen';

  @override
  String get tryAgain => 'Nochmal versuchen';

  @override
  String get stars => 'Sterne';

  @override
  String get time => 'Zeit';

  @override
  String get bestTime => 'Bestzeit';

  @override
  String get nextLevel => 'Nächstes Level';

  @override
  String get unlockBetterPlane => 'Besseres Flugzeug freischalten';

  @override
  String get noThanks => 'Nein danke';

  @override
  String get pause => 'Pause';

  @override
  String get settings => 'Einstellungen';

  @override
  String get creditsText => 'Plane Driver\nEntwickelt von Tarda Games';

  @override
  String level(int levelNumber) {
    return 'Level $levelNumber';
  }

  @override
  String get planeSpeed => 'Geschwindigkeit';

  @override
  String get planeHandling => 'Handling';

  @override
  String get planeAcceleration => 'Beschleunigung';

  @override
  String get planeName0 => 'Starter';

  @override
  String get planeName1 => 'Swift';

  @override
  String get planeName2 => 'Bolt';

  @override
  String get planeName3 => 'Gleiter';

  @override
  String get planeName4 => 'Rakete';

  @override
  String get planeName5 => 'Panzer';

  @override
  String get planeName6 => 'Ass';

  @override
  String get planeName7 => 'Jet';

  @override
  String get planeName8 => 'Rennflugzeug';

  @override
  String get planeName9 => 'Turbo';
}
