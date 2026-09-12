// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Plane Driver';

  @override
  String get play => 'プレイ';

  @override
  String get credits => 'クレジット';

  @override
  String get exit => '終了';

  @override
  String get back => '戻る';

  @override
  String get continueText => '続ける';

  @override
  String get restart => 'リスタート';

  @override
  String get resume => '再開';

  @override
  String get levelSelect => 'レベル選択';

  @override
  String get vehicleSelect => '機体選択';

  @override
  String get locked => 'ロック中';

  @override
  String get unlock => 'アンロック';

  @override
  String get restorePurchases => '購入を復元';

  @override
  String get purchasesRestored => '購入を復元しました';

  @override
  String get purchaseFailed => '購入に失敗しました';

  @override
  String get free => '無料';

  @override
  String get levelComplete => 'レベルクリア';

  @override
  String get gameOver => 'ゲームオーバー';

  @override
  String get levelFailed => 'レベル失敗';

  @override
  String get tryAgain => 'もう一度';

  @override
  String get stars => 'スター';

  @override
  String get time => 'タイム';

  @override
  String get bestTime => 'ベストタイム';

  @override
  String get nextLevel => '次のレベル';

  @override
  String get unlockBetterPlane => 'より良い機体をアンロック';

  @override
  String get noThanks => '結構です';

  @override
  String get pause => 'ポーズ';

  @override
  String get settings => '設定';

  @override
  String get creditsText => 'Plane Driver\nTarda Games 開発';

  @override
  String level(int levelNumber) {
    return 'レベル $levelNumber';
  }

  @override
  String get planeSpeed => 'スピード';

  @override
  String get planeHandling => 'ハンドリング';

  @override
  String get planeAcceleration => '加速';

  @override
  String get planeName0 => 'スターター';

  @override
  String get planeName1 => 'スウィフト';

  @override
  String get planeName2 => 'ボルト';

  @override
  String get planeName3 => 'グライダー';

  @override
  String get planeName4 => 'ロケット';

  @override
  String get planeName5 => 'タンク';

  @override
  String get planeName6 => 'エース';

  @override
  String get planeName7 => 'ジェット';

  @override
  String get planeName8 => 'レーサー';

  @override
  String get planeName9 => 'ターボ';
}
