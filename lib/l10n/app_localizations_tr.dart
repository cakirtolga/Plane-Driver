// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Plane Driver';

  @override
  String get play => 'Oyna';

  @override
  String get credits => 'Kredi';

  @override
  String get exit => 'Çıkış';

  @override
  String get back => 'Geri';

  @override
  String get continueText => 'Devam';

  @override
  String get restart => 'Yeniden Başla';

  @override
  String get resume => 'Devam Et';

  @override
  String get levelSelect => 'Bölüm Seç';

  @override
  String get vehicleSelect => 'Uçak Seç';

  @override
  String get locked => 'Kilitli';

  @override
  String get unlock => 'Aç';

  @override
  String get restorePurchases => 'Satın Alımları Geri Yükle';

  @override
  String get purchasesRestored => 'Satın alımlar geri yüklendi';

  @override
  String get purchaseFailed => 'Satın alma başarısız';

  @override
  String get free => 'Ücretsiz';

  @override
  String get levelComplete => 'Bölüm Tamamlandı';

  @override
  String get gameOver => 'Oyun Bitti';

  @override
  String get levelFailed => 'Bölüm Başarısız';

  @override
  String get tryAgain => 'Tekrar Dene';

  @override
  String get stars => 'Yıldız';

  @override
  String get time => 'Süre';

  @override
  String get bestTime => 'En İyi Süre';

  @override
  String get nextLevel => 'Sonraki Bölüm';

  @override
  String get unlockBetterPlane => 'Daha İyi Uçak Aç';

  @override
  String get noThanks => 'Hayır Teşekkürler';

  @override
  String get pause => 'Duraklat';

  @override
  String get settings => 'Ayarlar';

  @override
  String get creditsText =>
      'Plane Driver\nTarda Games tarafından geliştirilmiştir';

  @override
  String level(int levelNumber) {
    return 'Bölüm $levelNumber';
  }

  @override
  String get planeSpeed => 'Hız';

  @override
  String get planeHandling => 'Dönüş';

  @override
  String get planeAcceleration => 'İvme';

  @override
  String get planeName0 => 'Başlangıç';

  @override
  String get planeName1 => 'Çevik';

  @override
  String get planeName2 => 'Yıldırım';

  @override
  String get planeName3 => 'Planör';

  @override
  String get planeName4 => 'Roket';

  @override
  String get planeName5 => 'Tank';

  @override
  String get planeName6 => 'As';

  @override
  String get planeName7 => 'Jet';

  @override
  String get planeName8 => 'Yarışçı';

  @override
  String get planeName9 => 'Turbo';
}
