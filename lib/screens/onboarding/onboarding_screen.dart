// lib/screens/onboarding/onboarding_screen.dart
//
// Fullscreen onboarding slides for Madhyamik Shokha.
// First 3 slides: image only (no text)
// Last slide: image + "Ready to Begin" + Get Started
// Developer: Sibnath Bairagi

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../config/app_config.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  static const String routeName = '/onboarding';
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < AppConfig.onboardingSlides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final slides = AppConfig.onboardingSlides;
    final bool isLast = _currentPage == slides.length - 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // =============================================================
          // FULLSCREEN PAGES
          // =============================================================
          PageView.builder(
            controller: _controller,
            itemCount: slides.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => _buildSlide(slides[i], i == slides.length - 1),
          ),

          // =============================================================
          // SKIP — top right (Apple style, minimal)
          // =============================================================
          SafeArea(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isLast ? 0.0 : 1.0,
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 16, 0),
                  child: IgnorePointer(
                    ignoring: isLast,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Material(
                          color: Colors.white.withOpacity(0.14),
                          child: InkWell(
                            onTap: _goToLogin,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.28),
                                  width: 0.8,
                                ),
                              ),
                              child: const Text(
                                'Skip',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // =============================================================
          // BOTTOM CONTROLS — dots + next/get started
          // =============================================================
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 34),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDots(slides.length),
                    const SizedBox(height: 28),
                    _buildNextButton(isLast),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // SLIDE
  // First 3 slides: image only
  // Last slide   : image + "Ready to Begin"
  // =====================================================================
  Widget _buildSlide(Map<String, String> slide, bool isLast) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Fullscreen image
        Image.asset(
          slide['image'] ?? '',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _imageFallback(),
        ),

        // Only on last slide — bottom gradient + title
        if (isLast) ...[
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.48,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.45),
                    Colors.black.withOpacity(0.82),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            left: 28,
            right: 28,
            bottom: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Ready to Begin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Your journey to Madhyamik success starts now.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // =====================================================================
  // FALLBACK — when image missing
  // =====================================================================
  Widget _imageFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF5B8DEF),
            Color(0xFF1E2A47),
          ],
        ),
      ),
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.image,
          size: 60,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }

  // =====================================================================
  // DOTS — Apple style
  // =====================================================================
  Widget _buildDots(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final bool active = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: active ? 24 : 6,
          decoration: BoxDecoration(
            color: active
                ? Colors.white
                : Colors.white.withOpacity(0.42),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  // =====================================================================
  // NEXT / GET STARTED — Apple style glass button
  // =====================================================================
  Widget _buildNextButton(bool isLast) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Material(
          color: isLast
              ? Colors.white
              : Colors.white.withOpacity(0.16),
          child: InkWell(
            onTap: _nextPage,
            child: Container(
              height: 58,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isLast
                      ? Colors.white
                      : Colors.white.withOpacity(0.30),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLast ? 'Get Started' : 'Next',
                    style: TextStyle(
                      color: isLast
                          ? Colors.black
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  FaIcon(
                    isLast
                        ? FontAwesomeIcons.arrowRight
                        : FontAwesomeIcons.chevronRight,
                    size: 12,
                    color: isLast ? Colors.black : Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}