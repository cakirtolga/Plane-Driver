// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Plane Driver';

  @override
  String get play => 'Play';

  @override
  String get credits => 'Credits';

  @override
  String get exit => 'Exit';

  @override
  String get back => 'Back';

  @override
  String get continueText => 'Continue';

  @override
  String get restart => 'Restart';

  @override
  String get resume => 'Resume';

  @override
  String get levelSelect => 'Select Level';

  @override
  String get vehicleSelect => 'Select Plane';

  @override
  String get locked => 'Locked';

  @override
  String get unlock => 'Unlock';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get purchasesRestored => 'Purchases restored';

  @override
  String get purchaseFailed => 'Purchase failed';

  @override
  String get free => 'Free';

  @override
  String get levelComplete => 'Level Complete';

  @override
  String get gameOver => 'Game Over';

  @override
  String get levelFailed => 'Level Failed';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get stars => 'Stars';

  @override
  String get time => 'Time';

  @override
  String get bestTime => 'Best Time';

  @override
  String get nextLevel => 'Next Level';

  @override
  String get unlockBetterPlane => 'Unlock a Better Plane';

  @override
  String get noThanks => 'No Thanks';

  @override
  String get pause => 'Pause';

  @override
  String get settings => 'Settings';

  @override
  String get creditsText => 'Plane Driver\nDeveloped by Tarda Games';

  @override
  String level(int levelNumber) {
    return 'Level $levelNumber';
  }

  @override
  String get planeSpeed => 'Speed';

  @override
  String get planeHandling => 'Handling';

  @override
  String get planeAcceleration => 'Acceleration';

  @override
  String get planeName0 => 'Starter';

  @override
  String get planeName1 => 'Swift';

  @override
  String get planeName2 => 'Bolt';

  @override
  String get planeName3 => 'Glider';

  @override
  String get planeName4 => 'Rocket';

  @override
  String get planeName5 => 'Tank';

  @override
  String get planeName6 => 'Ace';

  @override
  String get planeName7 => 'Jet';

  @override
  String get planeName8 => 'Racer';

  @override
  String get planeName9 => 'Turbo';
}
