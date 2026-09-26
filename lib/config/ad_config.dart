// lib/config/ad_config.dart
//
// AdMob configuration for Madhyamik Shokha.
// Developer: Sibnath Bairagi

import 'package:flutter/foundation.dart';

class AdConfig {
  AdConfig._();

  // =====================================================================
  // PRODUCTION IDs (replace with your real AdMob IDs)
  // =====================================================================
  static const String _prodRewardedAndroid =
      'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _prodRewardedIOS =
      'ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ';
  static const String _prodInterstitialAndroid =
      'ca-app-pub-XXXXXXXXXXXXXXXX/AAAAAAAAAA';
  static const String _prodInterstitialIOS =
      'ca-app-pub-XXXXXXXXXXXXXXXX/BBBBBBBBBB';

  // =====================================================================
  // TEST IDs (Google-provided, safe during development)
  // =====================================================================
  static const String _testRewardedAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedIOS =
      'ca-app-pub-3940256099942544/1712485313';
  static const String _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIOS =
      'ca-app-pub-3940256099942544/4411468910';

  // =====================================================================
  // TOGGLE
  // =====================================================================
  /// Set to false before Play Store release
  static const bool useTestAds = true;

  // =====================================================================
  // GETTERS
  // =====================================================================
  static String get rewardedAdUnitId {
    if (kIsWeb) return ''; // Ads not supported on web
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return useTestAds ? _testRewardedIOS : _prodRewardedIOS;
    }
    return useTestAds ? _testRewardedAndroid : _prodRewardedAndroid;
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return useTestAds ? _testInterstitialIOS : _prodInterstitialIOS;
    }
    return useTestAds ? _testInterstitialAndroid : _prodInterstitialAndroid;
  }

  // =====================================================================
  // RULES
  // =====================================================================
  /// Coins per rewarded ad (as per user's strategy: 1 ad = 1 coin)
  static const int coinsPerAd = 1;

  /// Max ads per day per user
  static const int maxAdsPerDay = 50;

  /// Minimum seconds between two ads
  static const int minSecondsBetweenAds = 5;

  /// Show interstitial every N user actions
  static const int interstitialFrequency = 3;

  /// Minimum seconds between two interstitial ads
  static const int interstitialMinIntervalSeconds = 60;
}