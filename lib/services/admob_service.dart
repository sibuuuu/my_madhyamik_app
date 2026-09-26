// lib/services/admob_service.dart
//
// AdMob service layer for Madhyamik Shokha.
// Handles rewarded + interstitial ads.
// Developer: Sibnath Bairagi

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/ad_config.dart';
import 'firebase_service.dart';

/// Result of an ad attempt
enum AdResult {
  rewarded,    // User watched full ad — reward
  dismissed,   // User closed early — no reward
  failed,      // Ad failed to load — no reward
  notAvailable // Ads not supported on this platform (web)
}

class AdMobService {
  AdMobService._();

  static bool _initialized = false;

  // Rewarded ad
  static RewardedAd? _rewardedAd;
  static bool _isLoadingRewarded = false;
  static int _lastRewardTime = 0;

  // Interstitial ad
  static InterstitialAd? _interstitialAd;
  static bool _isLoadingInterstitial = false;
  static int _lastInterstitialTime = 0;
  static int _interstitialCounter = 0;

  // =====================================================================
  // INIT
  // =====================================================================
  static Future<void> initialize() async {
    if (_initialized) return;
    if (kIsWeb) return; // No ads on web

    try {
      await MobileAds.instance.initialize();
      _initialized = true;

      // Pre-load ads
      _loadRewardedAd();
      _loadInterstitialAd();
    } catch (e) {
      debugPrint('AdMob init failed: $e');
    }
  }

  // =====================================================================
  // REWARDED AD
  // =====================================================================
  static bool get isRewardedSupported {
    if (kIsWeb) return false;
    return AdConfig.rewardedAdUnitId.isNotEmpty;
  }

  static bool get isRewardedReady => _rewardedAd != null;

  static void _loadRewardedAd() {
    if (kIsWeb) return;
    if (_isLoadingRewarded || _rewardedAd != null) return;

    final unitId = AdConfig.rewardedAdUnitId;
    if (unitId.isEmpty) return;

    _isLoadingRewarded = true;

    RewardedAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoadingRewarded = false;
          debugPrint('Rewarded ad loaded.');
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isLoadingRewarded = false;
          debugPrint('Rewarded ad failed: ${error.message}');
        },
      ),
    );
  }

  /// Show rewarded ad. Returns AdResult.
  /// The reward is only given when onUserEarnedReward fires.
  static Future<AdResult> showRewardedAd({
    required String uid,
    required Function(int newCoins) onRewarded,
  }) async {
    if (kIsWeb) return AdResult.notAvailable;

    // Rate limit
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastRewardTime < AdConfig.minSecondsBetweenAds * 1000) {
      return AdResult.failed;
    }

    // Check daily limit
    final canWatch = await FirebaseService.canWatchAdToday(uid);
    if (!canWatch) return AdResult.failed;

    // Not loaded yet?
    if (_rewardedAd == null) {
      _loadRewardedAd();
      return AdResult.failed;
    }

    final ad = _rewardedAd!;
    _rewardedAd = null;
    bool rewardEarned = false;

    final completer = Completer<AdResult>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('Rewarded ad shown.');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Rewarded ad failed to show: ${error.message}');
        ad.dispose();
        if (!completer.isCompleted) {
          completer.complete(AdResult.failed);
        }
        _loadRewardedAd();
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('Rewarded ad dismissed. Reward earned: $rewardEarned');
        ad.dispose();
        if (!completer.isCompleted) {
          completer.complete(
            rewardEarned ? AdResult.rewarded : AdResult.dismissed,
          );
        }
        _loadRewardedAd();
      },
      onAdImpression: (ad) {
        debugPrint('Rewarded ad impression.');
      },
    );

    try {
      await ad.show(
        onUserEarnedReward: (ad, reward) async {
          rewardEarned = true;
          _lastRewardTime = DateTime.now().millisecondsSinceEpoch;

          // CREDIT COINS ONLY HERE
          final newCoins = await FirebaseService.trackAdWatched(uid);
          onRewarded(newCoins);
        },
      );
    } catch (e) {
      debugPrint('Rewarded ad show error: $e');
      if (!completer.isCompleted) {
        completer.complete(AdResult.failed);
      }
      _loadRewardedAd();
    }

    return completer.future;
  }

  // =====================================================================
  // INTERSTITIAL AD
  // =====================================================================
  static bool get isInterstitialSupported {
    if (kIsWeb) return false;
    return AdConfig.interstitialAdUnitId.isNotEmpty;
  }

  static void _loadInterstitialAd() {
    if (kIsWeb) return;
    if (_isLoadingInterstitial || _interstitialAd != null) return;

    final unitId = AdConfig.interstitialAdUnitId;
    if (unitId.isEmpty) return;

    _isLoadingInterstitial = true;

    InterstitialAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoadingInterstitial = false;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isLoadingInterstitial = false;
        },
      ),
    );
  }

  /// Call on every "natural break" action.
  /// Shows interstitial every N times, respecting min interval.
  static void maybeShowInterstitial() {
    if (kIsWeb) return;
    if (!isInterstitialSupported) return;

    _interstitialCounter++;

    if (_interstitialCounter % AdConfig.interstitialFrequency != 0) {
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastInterstitialTime <
        AdConfig.interstitialMinIntervalSeconds * 1000) {
      return;
    }

    if (_interstitialAd == null) {
      _loadInterstitialAd();
      return;
    }

    final ad = _interstitialAd!;
    _interstitialAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadInterstitialAd();
      },
    );

    ad.show();
    _lastInterstitialTime = now;
  }

  // =====================================================================
  // DISPOSE
  // =====================================================================
  static void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}