// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Plane Driver';

  @override
  String get play => '플레이';

  @override
  String get credits => '크레딧';

  @override
  String get exit => '종료';

  @override
  String get back => '뒤로';

  @override
  String get continueText => '계속';

  @override
  String get restart => '다시 시작';

  @override
  String get resume => '이어서 하기';

  @override
  String get levelSelect => '레벨 선택';

  @override
  String get vehicleSelect => '비행기 선택';

  @override
  String get locked => '잠김';

  @override
  String get unlock => '잠금 해제';

  @override
  String get restorePurchases => '구매 복원';

  @override
  String get purchasesRestored => '구매가 복원되었습니다';

  @override
  String get purchaseFailed => '구매 실패';

  @override
  String get free => '묣';

  @override
  String get levelComplete => '레벨 완료';

  @override
  String get gameOver => '게임 오버';

  @override
  String get levelFailed => '레벨 실패';

  @override
  String get tryAgain => '다시 시도';

  @override
  String get stars => '별';

  @override
  String get time => '시간';

  @override
  String get bestTime => '최고 기록';

  @override
  String get nextLevel => '다음 레벨';

  @override
  String get unlockBetterPlane => '더 좋은 비행기 잠금 해제';

  @override
  String get noThanks => '괜찮습니다';

  @override
  String get pause => '일시정지';

  @override
  String get settings => '설정';

  @override
  String get creditsText => 'Plane Driver\nTarda Games 개발';

  @override
  String level(int levelNumber) {
    return '레벨 $levelNumber';
  }

  @override
  String get planeSpeed => '속도';

  @override
  String get planeHandling => '조작';

  @override
  String get planeAcceleration => '가속';

  @override
  String get planeName0 => '스타터';

  @override
  String get planeName1 => '스위프트';

  @override
  String get planeName2 => '볼트';

  @override
  String get planeName3 => '글라이더';

  @override
  String get planeName4 => '로켓';

  @override
  String get planeName5 => '탱크';

  @override
  String get planeName6 => '에이스';

  @override
  String get planeName7 => '제트';

  @override
  String get planeName8 => '레이서';

  @override
  String get planeName9 => '터보';
}
