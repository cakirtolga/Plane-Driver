// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Plane Driver';

  @override
  String get play => '开始';

  @override
  String get credits => '制作人员';

  @override
  String get exit => '退出';

  @override
  String get back => '返回';

  @override
  String get continueText => '继续';

  @override
  String get restart => '重新开始';

  @override
  String get resume => '继续游戏';

  @override
  String get levelSelect => '选择关卡';

  @override
  String get vehicleSelect => '选择飞机';

  @override
  String get locked => '已锁定';

  @override
  String get unlock => '解锁';

  @override
  String get restorePurchases => '恢复购买';

  @override
  String get purchasesRestored => '购买已恢复';

  @override
  String get purchaseFailed => '购买失败';

  @override
  String get free => '免费';

  @override
  String get levelComplete => '关卡完成';

  @override
  String get gameOver => '游戏结束';

  @override
  String get levelFailed => '关卡失败';

  @override
  String get tryAgain => '再试一次';

  @override
  String get stars => '星星';

  @override
  String get time => '时间';

  @override
  String get bestTime => '最佳时间';

  @override
  String get nextLevel => '下一关';

  @override
  String get unlockBetterPlane => '解锁更好的飞机';

  @override
  String get noThanks => '不用了';

  @override
  String get pause => '暂停';

  @override
  String get settings => '设置';

  @override
  String get creditsText => 'Plane Driver\n由 Tarda Games 开发';

  @override
  String level(int levelNumber) {
    return '第 $levelNumber 关';
  }

  @override
  String get planeSpeed => '速度';

  @override
  String get planeHandling => '操控';

  @override
  String get planeAcceleration => '加速';

  @override
  String get planeName0 => '新手';

  @override
  String get planeName1 => '迅捷';

  @override
  String get planeName2 => '闪电';

  @override
  String get planeName3 => '滑翔机';

  @override
  String get planeName4 => '火箭';

  @override
  String get planeName5 => '坦克';

  @override
  String get planeName6 => '王牌';

  @override
  String get planeName7 => '喷气';

  @override
  String get planeName8 => '赛车';

  @override
  String get planeName9 => '涡轮';
}
