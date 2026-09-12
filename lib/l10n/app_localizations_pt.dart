// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Plane Driver';

  @override
  String get play => 'Jogar';

  @override
  String get credits => 'Créditos';

  @override
  String get exit => 'Sair';

  @override
  String get back => 'Voltar';

  @override
  String get continueText => 'Continuar';

  @override
  String get restart => 'Reiniciar';

  @override
  String get resume => 'Continuar';

  @override
  String get levelSelect => 'Selecionar fase';

  @override
  String get vehicleSelect => 'Selecionar avião';

  @override
  String get locked => 'Bloqueado';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get purchasesRestored => 'Compras restauradas';

  @override
  String get purchaseFailed => 'Compra falhou';

  @override
  String get free => 'Grátis';

  @override
  String get levelComplete => 'Fase concluída';

  @override
  String get gameOver => 'Fim de jogo';

  @override
  String get levelFailed => 'Fase falhou';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get stars => 'Estrelas';

  @override
  String get time => 'Tempo';

  @override
  String get bestTime => 'Melhor tempo';

  @override
  String get nextLevel => 'Próxima fase';

  @override
  String get unlockBetterPlane => 'Desbloquear um avião melhor';

  @override
  String get noThanks => 'Não, obrigado';

  @override
  String get pause => 'Pausa';

  @override
  String get settings => 'Configurações';

  @override
  String get creditsText => 'Plane Driver\nDesenvolvido por Tarda Games';

  @override
  String level(int levelNumber) {
    return 'Fase $levelNumber';
  }

  @override
  String get planeSpeed => 'Velocidade';

  @override
  String get planeHandling => 'Manobra';

  @override
  String get planeAcceleration => 'Aceleração';

  @override
  String get planeName0 => 'Inicial';

  @override
  String get planeName1 => 'Ágil';

  @override
  String get planeName2 => 'Relâmpago';

  @override
  String get planeName3 => 'Planador';

  @override
  String get planeName4 => 'Foguete';

  @override
  String get planeName5 => 'Tanque';

  @override
  String get planeName6 => 'Ás';

  @override
  String get planeName7 => 'Jato';

  @override
  String get planeName8 => 'Corredor';

  @override
  String get planeName9 => 'Turbo';
}
