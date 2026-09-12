// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Plane Driver';

  @override
  String get play => 'Jouer';

  @override
  String get credits => 'Crédits';

  @override
  String get exit => 'Quitter';

  @override
  String get back => 'Retour';

  @override
  String get continueText => 'Continuer';

  @override
  String get restart => 'Recommencer';

  @override
  String get resume => 'Reprendre';

  @override
  String get levelSelect => 'Choisir un niveau';

  @override
  String get vehicleSelect => 'Choisir un avion';

  @override
  String get locked => 'Verrouillé';

  @override
  String get unlock => 'Déverrouiller';

  @override
  String get restorePurchases => 'Restaurer les achats';

  @override
  String get purchasesRestored => 'Achats restaurés';

  @override
  String get purchaseFailed => 'Achat échoué';

  @override
  String get free => 'Gratuit';

  @override
  String get levelComplete => 'Niveau terminé';

  @override
  String get gameOver => 'Partie terminée';

  @override
  String get levelFailed => 'Niveau échoué';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get stars => 'Étoiles';

  @override
  String get time => 'Temps';

  @override
  String get bestTime => 'Meilleur temps';

  @override
  String get nextLevel => 'Niveau suivant';

  @override
  String get unlockBetterPlane => 'Déverrouiller un meilleur avion';

  @override
  String get noThanks => 'Non merci';

  @override
  String get pause => 'Pause';

  @override
  String get settings => 'Paramètres';

  @override
  String get creditsText => 'Plane Driver\nDéveloppé par Tarda Games';

  @override
  String level(int levelNumber) {
    return 'Niveau $levelNumber';
  }

  @override
  String get planeSpeed => 'Vitesse';

  @override
  String get planeHandling => 'Maniabilité';

  @override
  String get planeAcceleration => 'Accélération';

  @override
  String get planeName0 => 'Débutant';

  @override
  String get planeName1 => 'Rapide';

  @override
  String get planeName2 => 'Éclair';

  @override
  String get planeName3 => 'Planeur';

  @override
  String get planeName4 => 'Fusée';

  @override
  String get planeName5 => 'Tank';

  @override
  String get planeName6 => 'As';

  @override
  String get planeName7 => 'Jet';

  @override
  String get planeName8 => 'Course';

  @override
  String get planeName9 => 'Turbo';
}
