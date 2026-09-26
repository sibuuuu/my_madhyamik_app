// lib/main.dart
//
// Madhyamik Shokha - Entry Point
// Developer: Sibnath Bairagi

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'services/cache_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/profile_setup.dart';
import 'screens/home/home_screen.dart';
import 'screens/notice/notice_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/quiz/leaderboard_screen.dart';
import 'screens/quiz/quiz_main_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/subjects/subject_list_screen.dart';
import 'screens/subjects/video_player_screen.dart';
import 'services/admob_service.dart';
import 'screens/settings/edit_profile_screen.dart';
import 'screens/settings/change_password_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI style first
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFFF2F2F7),
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize local cache (shared_preferences)
  await CacheService.init();

  runApp(const MadhyamikShokhaApp());
}

class MadhyamikShokhaApp extends StatelessWidget {
  const MadhyamikShokhaApp({super.key});

  // Static constants used by other screens
  static const String kAppName = AppConfig.appName;
  static const String kAppNameEnglish = AppConfig.appNameEnglish;
  static const String kDeveloperName = AppConfig.developerName;
  static const String kTagline = AppConfig.tagline;
  static const String kVersion = AppConfig.version;

  static const Color kBackground = Color(0xFFF2F2F7);
  static const Color kSurfaceGlass = Color(0x99FFFFFF);
  static const Color kBorderGlass = Color(0x4DFFFFFF);
  static const Color kAccent = Color(0xFFEF4444);
  static const Color kDanger = Color(0xFFEF4444);
  static const Color kSuccess = Color(0xFF2FBF71);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MaterialApp(
        title: kAppName,
        debugShowCheckedModeBanner: false,
        initialRoute: SplashScreen.routeName,
        routes: {
          SplashScreen.routeName: (_) => const SplashScreen(),
          OnboardingScreen.routeName: (_) => const OnboardingScreen(),
          LoginScreen.routeName: (_) => const LoginScreen(),
          ProfileSetupScreen.routeName: (_) => const ProfileSetupScreen(),
          HomeScreen.routeName: (_) => const HomeScreen(),
          SubjectListScreen.routeName: (_) => const SubjectListScreen(),
          VideoPlayerScreen.routeName: (_) => const VideoPlayerScreen(),
          QuizMainScreen.routeName: (_) => const QuizMainScreen(),
          LeaderboardScreen.routeName: (_) => const LeaderboardScreen(),
          NoticeScreen.routeName: (_) => const NoticeScreen(),
          SettingsScreen.routeName: (_) => const SettingsScreen(),
          SearchScreen.routeName: (_) => const SearchScreen(),
          EditProfileScreen.routeName: (_) => const EditProfileScreen(),
          ChangePasswordScreen.routeName: (_) => const ChangePasswordScreen(),
        },
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: kBackground,
          canvasColor: kBackground,
          splashFactory: InkRipple.splashFactory,
          fontFamily: 'PlusJakartaSans',
          fontFamilyFallback: const ['HindSiliguri'],
          colorScheme: const ColorScheme.light(
            primary: kAccent,
            secondary: kAccent,
            surface: Colors.white,
            error: kDanger,
            onPrimary: Colors.white,
            onSurface: Color(0xFF1C1C1E),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            scrolledUnderElevation: 0,
            iconTheme: IconThemeData(color: Color(0xFF1C1C1E)),
            titleTextStyle: TextStyle(
              color: Color(0xFF1C1C1E),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              fontFamily: 'PlusJakartaSans',
              fontFamilyFallback: ['HindSiliguri'],
            ),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(
              color: Color(0xFF1C1C1E),
              fontSize: 15,
              fontFamily: 'PlusJakartaSans',
              fontFamilyFallback: ['HindSiliguri'],
            ),
            bodyMedium: TextStyle(
              color: Color(0xFF4A4A4F),
              fontSize: 14,
              fontFamily: 'PlusJakartaSans',
              fontFamilyFallback: ['HindSiliguri'],
            ),
            bodySmall: TextStyle(
              color: Color(0xFF7A7A80),
              fontSize: 12.5,
              fontFamily: 'PlusJakartaSans',
              fontFamilyFallback: ['HindSiliguri'],
            ),
            titleLarge: TextStyle(
              color: Color(0xFF1C1C1E),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'PlusJakartaSans',
              fontFamilyFallback: ['HindSiliguri'],
            ),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF1C1C1E)),
          dividerTheme: const DividerThemeData(
            color: Color(0x1A000000),
            thickness: 1,
            space: 1,
          ),
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: Color(0xFF1C1C1E),
            contentTextStyle: TextStyle(color: Colors.white),
            behavior: SnackBarBehavior.floating,
          ),
          dialogTheme: const DialogTheme(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
          ),
        ),
        builder: (context, child) {
          return DefaultTextStyle(
            style: const TextStyle(
              decoration: TextDecoration.none,
              color: Color(0xFF1C1C1E),
              fontFamily: 'PlusJakartaSans',
              fontFamilyFallback: ['HindSiliguri'],
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}