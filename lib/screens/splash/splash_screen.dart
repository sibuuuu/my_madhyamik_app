// lib/screens/splash/splash_screen.dart
//
// Premium splash screen for Madhyamik Shokha.
// Checks auth state and routes to the right screen.
// Developer: Sibnath Bairagi

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../config/glass_theme.dart';
import '../../services/firebase_service.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoSlide;

  late final AnimationController _textController;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  late final AnimationController _glowController;
  late final Animation<double> _glowScale;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _logoFade = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 35),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 30,
      ),
    ]).animate(_mainController);

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.92, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 35),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.08)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 30,
      ),
    ]).animate(_mainController);

    _logoSlide = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 12.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 35),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -6.0)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 30,
      ),
    ]).animate(_mainController);

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _textFade = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _glowScale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    _mainController.forward();
    _glowController.repeat(reverse: true);

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _textController.forward();

    // Wait for animation
    await Future.delayed(const Duration(milliseconds: 2300));
    if (!mounted) return;

    // Route based on auth state
    await _routeNext();
  }

  Future<void> _routeNext() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Not signed in → onboarding
      if (!mounted) return;
      Navigator.of(context)
          .pushReplacementNamed(OnboardingScreen.routeName);
      return;
    }

    // Signed in — check profile and give welcome bonus if needed
    try {
      final profile = await FirebaseService.getUserProfile(
        user.uid,
        forceRefresh: true,
      );

      if (profile == null) {
        // No profile in DB → send to onboarding (safety)
        if (!mounted) return;
        Navigator.of(context)
            .pushReplacementNamed(OnboardingScreen.routeName);
        return;
      }

      // Safe welcome bonus — runs once
      await FirebaseService.giveWelcomeBonusIfNotGiven(user.uid);
    } catch (_) {
      // Silent fail — don't block user
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _textController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlassTheme.backgroundLight,
      body: Stack(
        children: [
          const _SplashBackground(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoFade.value,
                      child: Transform.translate(
                        offset: Offset(0, _logoSlide.value),
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: _buildLogo(),
                ),
                const SizedBox(height: 40),
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: _buildText(),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 44,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _textFade,
              child: _buildFooter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: _glowScale.value,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        GlassTheme.accentBlue.withOpacity(0.18),
                        GlassTheme.accentBlue.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              child!,
            ],
          ),
        );
      },
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: GlassTheme.accentBlue.withOpacity(0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: GlassTheme.accentBlue.withOpacity(0.15),
              blurRadius: 30,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipOval(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Image.asset(
              'assets/logo/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Center(
                child: FaIcon(
                  FontAwesomeIcons.graduationCap,
                  size: 44,
                  color: GlassTheme.accentBlue,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildText() {
    return Column(
      children: const [
        Text(
          'মাধ্যমিক শখা',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: GlassTheme.textPrimaryLight,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            height: 1.2,
            fontFamilyFallback: ['HindSiliguri'],
          ),
        ),
        SizedBox(height: 10),
        _SplashDivider(),
        SizedBox(height: 12),
        Text(
          'CLASS 10  •  WBBSE',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: GlassTheme.textTertiaryLight,
            fontSize: 11,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Developed by Sibnath Bairagi',
          style: TextStyle(
            color: GlassTheme.textTertiaryLight,
            fontSize: 11,
            letterSpacing: 0.4,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'v1.0.0',
          style: TextStyle(
            color: GlassTheme.textHintLight,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// Small divider below the app name
class _SplashDivider extends StatelessWidget {
  const _SplashDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      width: 32,
      decoration: BoxDecoration(
        color: GlassTheme.accentBlue,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFAFAFC),
              Color(0xFFF2F2F7),
              Color(0xFFEAEAF0),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -100,
              child: _glow(GlassTheme.accentBlue, 320),
            ),
            Positioned(
              bottom: -140,
              left: -100,
              child: _glow(GlassTheme.accentRed, 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glow(Color color, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(0.08),
              color.withOpacity(0.0),
            ],
          ),
        ),
      ),
    );
  }
}