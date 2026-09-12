// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Plane Driver';

  @override
  String get play => 'Играть';

  @override
  String get credits => 'Титры';

  @override
  String get exit => 'Выход';

  @override
  String get back => 'Назад';

  @override
  String get continueText => 'Продолжить';

  @override
  String get restart => 'Заново';

  @override
  String get resume => 'Продолжить';

  @override
  String get levelSelect => 'Выбор уровня';

  @override
  String get vehicleSelect => 'Выбор самолёта';

  @override
  String get locked => 'Заблокировано';

  @override
  String get unlock => 'Разблокировать';

  @override
  String get restorePurchases => 'Восстановить покупки';

  @override
  String get purchasesRestored => 'Покупки восстановлены';

  @override
  String get purchaseFailed => 'Покупка не удалась';

  @override
  String get free => 'Бесплатно';

  @override
  String get levelComplete => 'Уровень пройден';

  @override
  String get gameOver => 'Игра окончена';

  @override
  String get levelFailed => 'Уровень не пройден';

  @override
  String get tryAgain => 'Попробовать снова';

  @override
  String get stars => 'Звёзды';

  @override
  String get time => 'Время';

  @override
  String get bestTime => 'Лучшее время';

  @override
  String get nextLevel => 'Следующий уровень';

  @override
  String get unlockBetterPlane => 'Разблокировать лучший самолёт';

  @override
  String get noThanks => 'Нет, спасибо';

  @override
  String get pause => 'Пауза';

  @override
  String get settings => 'Настройки';

  @override
  String get creditsText => 'Plane Driver\nРазработано Tarda Games';

  @override
  String level(int levelNumber) {
    return 'Уровень $levelNumber';
  }

  @override
  String get planeSpeed => 'Скорость';

  @override
  String get planeHandling => 'Управляемость';

  @override
  String get planeAcceleration => 'Ускорение';

  @override
  String get planeName0 => 'Стартовый';

  @override
  String get planeName1 => 'Стриж';

  @override
  String get planeName2 => 'Молния';

  @override
  String get planeName3 => 'Планер';

  @override
  String get planeName4 => 'Ракета';

  @override
  String get planeName5 => 'Танк';

  @override
  String get planeName6 => 'Туз';

  @override
  String get planeName7 => 'Реактивный';

  @override
  String get planeName8 => 'Гонщик';

  @override
  String get planeName9 => 'Турбо';
}
