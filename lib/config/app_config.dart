// lib/config/app_config.dart
//
// Central configuration for Madhyamik Shokha.
// All constants, paths, and lists live here.
// Developer: Sibnath Bairagi

import 'package:flutter/material.dart';

class AppConfig {
  AppConfig._();

  // =====================================================================
  // APP IDENTITY
  // =====================================================================
  static const String appName = 'মাধ্যমিক শখা';
  static const String appNameEnglish = 'Madhyamik Shokha';
  static const String developerName = 'Sibnath Bairagi';
  static const String tagline = 'Class 10 Learning Companion';
  static const String version = '1.0.0';

  // =====================================================================
  // COLORS (aligned with GlassTheme)
  // =====================================================================
  static const Color background = Color(0xFFF2F2F7);
  static const Color accent = Color(0xFFEF4444);
  static const Color accentDark = Color(0xFFDC2626);
  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF2FBF71);
  static const Color warning = Color(0xFFF59E0B);

  // =====================================================================
  // ONBOARDING SLIDES (4 slides)
  // =====================================================================
  static const List<Map<String, String>> onboardingSlides = [
    {
      'image': 'assets/onboarding/slide_1.jpeg',
      'title': 'Welcome to Madhyamik Shokha',
      'subtitle':
          'Your complete learning companion for Class 10 WBBSE students.',
    },
    {
      'image': 'assets/onboarding/slide_2.jpeg',
      'title': 'Video Lessons',
      'subtitle':
          'Subject-wise video lessons with clear explanations and examples.',
    },
    {
      'image': 'assets/onboarding/slide_3.jpeg',
      'title': 'Practice Quizzes',
      'subtitle': 'Test your knowledge with quizzes and see instant feedback.',
    },
    {
      'image': 'assets/onboarding/slide_4.jpeg',
      'title': 'Ready to Begin',
      'subtitle': 'Track your progress and top the leaderboard. Let us start.',
    },
  ];

  // =====================================================================
  // MADHYAMIK EXAM COUNTDOWN
  // =====================================================================
  static DateTime get madhyamikExamDate => DateTime(2027, 2, 15, 10, 0);

  // =====================================================================
  // WEST BENGAL DISTRICTS (23)
  // =====================================================================
  static const List<String> wbDistricts = [
    'Alipurduar',
    'Bankura',
    'Birbhum',
    'Cooch Behar',
    'Dakshin Dinajpur',
    'Darjeeling',
    'Hooghly',
    'Howrah',
    'Jalpaiguri',
    'Jhargram',
    'Kalimpong',
    'Kolkata',
    'Malda',
    'Murshidabad',
    'Nadia',
    'North 24 Parganas',
    'Paschim Bardhaman',
    'Paschim Medinipur',
    'Purba Bardhaman',
    'Purba Medinipur',
    'Purulia',
    'South 24 Parganas',
    'Uttar Dinajpur',
  ];

  // =====================================================================
  // REALTIME DATABASE PATHS
  // =====================================================================
  static const String dbUsers = 'users';
  static const String dbVideos = 'videos';
  static const String dbQuizzes = 'quizzes';
  static const String dbNotices = 'notices';
  static const String dbAttempts = 'attempts';
  static const String dbSubjects = 'subjects';
  static const String dbChapters = 'chapters';
  static const String dbLeaderboard = 'leaderboard';
  static const String dbWeeklyLeaderboard = 'leaderboard/weekly';
  static const String dbConfig = 'config';

  // =====================================================================
  // BOTTOM NAVIGATION TABS
  // =====================================================================
  static const int navHome = 0;
  static const int navSubjects = 1;
  static const int navQuiz = 2;
  static const int navNotice = 3;
  static const int navSettings = 4;

  // =====================================================================
  // COIN + AD RULES
  // =====================================================================
  /// Coins given on first registration (once per user)
  static const int welcomeBonusCoins = 5;

  /// Coins required to enter a quiz
  static const int quizEntryFee = 5;

  /// Coins earned per rewarded ad watched
  static const int coinsPerAd = 1;

  /// Coins given as bonus when a quiz is passed
  static const int quizPassBonus = 0; // set >0 if you want pass bonus

  /// Max rewarded ads per day per user
  static const int maxAdsPerDay = 50;

  /// Show interstitial every N user actions
  static const int interstitialFrequency = 3;

  /// Minimum seconds between two interstitial ads
  static const int interstitialMinIntervalSeconds = 60;

  // =====================================================================
  // QUIZ TIME WINDOW (7 PM – 10 PM)
  // =====================================================================
  static const int quizStartHour = 19; // 7 PM
  static const int quizEndHour = 22; // 10 PM

  /// Set to false before Play Store release
  static const bool quizTestingMode = true;

  // =====================================================================
  // ANTI-CHEAT
  // =====================================================================
  /// Grace period (seconds) when app goes to background
  static const int cheatGracePeriodSeconds = 2;

  /// Number of cheat attempts before ban
  static const int cheatBanThreshold = 3;

  /// Ban duration (hours)
  static const int cheatBanHours = 24;

  // =====================================================================
  // EXTERNAL LINKS
  // =====================================================================
  static const String privacyPolicyUrl =
      'https://2wbky3-5wmzyk2z9-arcedawebapps1.vercel.app';
  static const String instagramUrl =
      'https://www.instagram.com/madhyamik_sokha';
  static const String whatsappUrl =
      'https://whatsapp.com/channel/0029VbDajBJDZ4LezgieUS41';
  static const String youtubeUrl =
      'https://youtube.com/@madhyamik_sokha';
}