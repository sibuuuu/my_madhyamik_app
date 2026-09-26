// lib/screens/quiz/quiz_result_screen.dart
//
// Quiz result screen for Madhyamik Shokha.
// Developer: Sibnath Bairagi

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../config/glass_theme.dart';
import '../../models/quiz_model.dart';

class QuizResultScreen extends StatelessWidget {
  final int correctCount;
  final int wrongCount;
  final int totalQuestions;
  final bool passed;
  final String subjectName;
  final String chapterName;
  final List<QuizQuestion> questions;
  final Map<String, int> answers;

  const QuizResultScreen({
    super.key,
    required this.correctCount,
    required this.wrongCount,
    required this.totalQuestions,
    required this.passed,
    required this.subjectName,
    required this.chapterName,
    required this.questions,
    required this.answers,
  });

  int get _percent {
    if (totalQuestions == 0) return 0;
    return ((correctCount / totalQuestions) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (r) => false);
      },
      child: Scaffold(
        backgroundColor: GlassTheme.backgroundLight,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text('Result'),
        ),
        body: Stack(
          children: [
            const _ResultBackground(),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildScoreCircle(),
                    const SizedBox(height: 24),
                    _buildMessage(),
                    const SizedBox(height: 26),
                    _buildStats(),
                    const SizedBox(height: 26),
                    _buildRewardCard(),
                    const SizedBox(height: 30),
                    _buildActions(context),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCircle() {
    final Color accent =
        passed ? GlassTheme.accentGreen : GlassTheme.accentRed;

    return Center(
      child: Container(
        height: 180,
        width: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accent.withOpacity(0.10),
          border: Border.all(
            color: accent.withOpacity(0.55),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.25),
              blurRadius: 40,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              passed
                  ? FontAwesomeIcons.award
                  : FontAwesomeIcons.circleExclamation,
              size: 24,
              color: accent,
            ),
            const SizedBox(height: 10),
            Text(
              '$_percent%',
              style: TextStyle(
                color: GlassTheme.textPrimaryLight,
                fontSize: 42,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.0,
                fontFamily: 'PlusJakartaSans',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              passed ? 'PASSED' : 'FAILED',
              style: TextStyle(
                color: accent,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                fontFamily: 'PlusJakartaSans',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage() {
    String title;
    String sub;
    if (_percent >= 80) {
      title = 'Excellent!';
      sub = 'Outstanding performance. Keep it up.';
    } else if (_percent >= 60) {
      title = 'Good Job!';
      sub = 'You are doing well. A bit more practice.';
    } else if (_percent >= 40) {
      title = 'Getting There';
      sub = 'Review and try again for a better score.';
    } else if (passed) {
      title = 'You Passed';
      sub = 'Keep practicing to improve your score.';
    } else {
      title = 'Keep Trying';
      sub = 'Review the material and try again tomorrow.';
    }

    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: GlassTheme.textPrimaryLight,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            fontFamily: 'PlusJakartaSans',
            fontFamilyFallback: const ['HindSiliguri'],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          sub,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: GlassTheme.textSecondaryLight,
            fontSize: 14,
            height: 1.5,
            fontFamily: 'PlusJakartaSans',
            fontFamilyFallback: const ['HindSiliguri'],
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: FontAwesomeIcons.circleCheck,
            value: '$correctCount',
            label: 'Correct',
            color: GlassTheme.accentGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: FontAwesomeIcons.circleXmark,
            value: '$wrongCount',
            label: 'Wrong',
            color: GlassTheme.accentRed,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: FontAwesomeIcons.listCheck,
            value: '$totalQuestions',
            label: 'Total',
            color: GlassTheme.accentBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardCard() {
    final Color color =
        passed ? GlassTheme.accentGreen : GlassTheme.accentRed;
    final String text =
        passed ? 'You earned +10 coins!' : 'You lost 10 coins.';
    final IconData icon = passed
        ? FontAwesomeIcons.coins
        : FontAwesomeIcons.circleMinus;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.40),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
            ),
            child: Center(
              child: FaIcon(icon, size: 16, color: color),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                fontFamily: 'PlusJakartaSans',
                fontFamilyFallback: const ['HindSiliguri'],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 54,
          child: Material(
            color: GlassTheme.accentRed,
            borderRadius: BorderRadius.circular(100),
            child: InkWell(
              onTap: () => Navigator.of(context)
                  .pushNamedAndRemoveUntil('/home', (r) => false),
              borderRadius: BorderRadius.circular(100),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.house,
                      size: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Back to Home',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'PlusJakartaSans',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: GlassTheme.textPrimaryLight,
              side: BorderSide(
                color: Colors.black.withOpacity(0.10),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FaIcon(
                  FontAwesomeIcons.rotateRight,
                  size: 12,
                  color: GlassTheme.textPrimaryLight,
                ),
                const SizedBox(width: 10),
                Text(
                  'Try Another Quiz',
                  style: TextStyle(
                    color: GlassTheme.textPrimaryLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          FaIcon(icon, size: 16, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: GlassTheme.textPrimaryLight,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              fontFamily: 'PlusJakartaSans',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: GlassTheme.textTertiaryLight,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              fontFamily: 'PlusJakartaSans',
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultBackground extends StatelessWidget {
  const _ResultBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: GlassTheme.backgroundGradientLight,
        ),
        child: Stack(
          children: [
            Positioned(
              top: -140,
              right: -110,
              child: _glow(GlassTheme.accentRed, 340),
            ),
            Positioned(
              bottom: -160,
              left: -110,
              child: _glow(GlassTheme.accentBlue, 360),
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
              color.withOpacity(0.10),
              color.withOpacity(0.0),
            ],
          ),
        ),
      ),
    );
  }
}