// lib/config/cache_config.dart
//
// Cache durations and policies for Madhyamik Shokha.
// Reduces Firebase load by up to 90%.
// Developer: Sibnath Bairagi

class CacheConfig {
  CacheConfig._();

  // =====================================================================
  // CACHE KEYS (SharedPreferences)
  // =====================================================================
  static const String keySubjects = 'cache_subjects';
  static const String keyChaptersPrefix = 'cache_chapters_';
  static const String keyVideosPrefix = 'cache_videos_';
  static const String keyNotices = 'cache_notices';
  static const String keyLeaderboardPrefix = 'cache_leaderboard_';
  static const String keyUserProfilePrefix = 'cache_user_';
  static const String keyCurrentWeek = 'cache_current_week';
  static const String keyLastSyncAt = 'cache_last_sync';

  static const String tsSuffix = '_ts';

  // =====================================================================
  // CACHE DURATIONS
  // =====================================================================
  static const Duration subjects = Duration(days: 7);
  static const Duration chapters = Duration(days: 7);
  static const Duration videos = Duration(days: 3);
  static const Duration notices = Duration(days: 1);
  static const Duration leaderboard = Duration(days: 1);
  static const Duration userProfile = Duration(hours: 1);

  // =====================================================================
  // AUTO-DELETE POLICIES (Firebase)
  // =====================================================================
  static const int noticeDeleteAfterDays = 7;
  static const int oldLeaderboardDeleteAfterWeeks = 2;
  static const bool autoDeleteVideos = false;
  static const bool autoDeleteHeroes = false;

  // =====================================================================
  // LEADERBOARD RULES
  // =====================================================================
  static const int topFixedCount = 3;
  static const int leaderboardDisplayCount = 13;
  static const int leaderboardResetDay = 7;
  static const int leaderboardResetHour = 23;
  static const int leaderboardResetMinute = 59;

  // =====================================================================
  // ANTI-CHEAT
  // =====================================================================
  static const Duration cheatGracePeriod = Duration(seconds: 2);
  static const int cheatBanThreshold = 3;
  static const int cheatBanHours = 24;

  // =====================================================================
  // AD RULES
  // =====================================================================
  static const int coinsPerAd = 1;
  static const int quizEntryFee = 5;
  static const int maxAdsPerDay = 50;
  static const int welcomeBonusCoins = 5;
  static const int interstitialFrequency = 3;
  static const Duration interstitialMinInterval = Duration(seconds: 60);
}