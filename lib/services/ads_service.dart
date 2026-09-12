import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:planedriver_flame/services/save_service.dart';

class AdsService {
  AdsService._();

  static final AdsService instance = AdsService._();

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    return '';
  }

  InterstitialAd? _interstitialAd;
  bool _isLoading = false;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  bool get areAdsRemoved => SaveService.instance.getAdsRemoved();

  void loadInterstitial() {
    if (areAdsRemoved) return;
    if (_isLoading || _interstitialAd != null) return;

    _isLoading = true;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isLoading = false;
        },
      ),
    );
  }

  Future<void> showInterstitial({VoidCallback? onDismissed}) async {
    if (areAdsRemoved) {
      onDismissed?.call();
      return;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      onDismissed?.call();
      loadInterstitial();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        onDismissed?.call();
        loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        onDismissed?.call();
        loadInterstitial();
      },
    );

    await ad.show();
  }

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
