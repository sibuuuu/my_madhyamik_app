// lib/screens/quiz/quiz_play_screen.dart
//
// Quiz play — 20 questions, anti-cheat, no fail penalty.
// Developer: Sibnath Bairagi

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:screen_protector/screen_protector.dart';

import '../../config/cache_config.dart';
import '../../config/glass_theme.dart';
import '../../models/quiz_model.dart';
import '../../services/firebase_service.dart';
import 'quiz_result_screen.dart';

class QuizPlayScreen extends StatefulWidget {
  final QuizModel quiz;
  final String subjectName;
  final String chapterName;

  const QuizPlayScreen({
    super.key,
    required this.quiz,
    required this.subjectName,
    required this.chapterName,
  });

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen>
    with WidgetsBindingObserver {
  static const int _totalQuestions = 20;
  static const int _passThreshold = 5;

  late List<QuizQuestion> _questions;
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _answered = false;

  int _correctCount = 0;
  int _wrongCount = 0;
  final Map<String, int> _answers = {};

  DateTime? _startedAt;

  // Anti-cheat
  int _cheatCount = 0;
  Timer? _graceTimer;
  bool _graceActive = false;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    WidgetsBinding.instance.addObserver(this);

    // Prevent screenshots
    _enableScreenProtection();

    final all = List<QuizQuestion>.from(widget.quiz.questions);
    if (all.length > _totalQuestions) {
      all.shuffle();
      _questions = all.take(_totalQuestions).toList();
    } else {
      _questions = all;
    }
  }

  Future<void> _enableScreenProtection() async {
    try {
      await ScreenProtector.preventScreenshotOn();
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _onAppLeft();
    } else if (state == AppLifecycleState.resumed) {
      _onAppReturned();
    }
  }

  void _onAppLeft() {
    if (!mounted) return;
    // Start grace period
    _graceActive = true;
    _graceTimer?.cancel();
    _graceTimer = Timer(CacheConfig.cheatGracePeriod, () {
      if (!mounted) return;
      _graceActive = false;
      _cheatCount++;

      if (_cheatCount >= 2) {
        // Second time — cancel quiz
        _handleCheatBan();
      } else {
        // First time — warning
        _showCheatWarning();
      }
    });
  }

  void _onAppReturned() {
    _graceTimer?.cancel();
    if (_graceActive) {
      _graceActive = false;
    }
  }

  void _handleCheatBan() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('Quiz Cancelled'),
        content: const Text(
          'You left the app during the quiz. Your attempt has been cancelled. Entry fee will not be refunded.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pop(false);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCheatWarning() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('Warning'),
        content: const Text(
          'Do not leave the app during the quiz. If you leave again, the quiz will be cancelled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  bool get _isLast => _currentIndex == _questions.length - 1;

  void _selectOption(int index) {
    if (_answered) return;
    final q = _questions[_currentIndex];
    final correct = index == q.correctIndex;

    setState(() {
      _selectedIndex = index;
      _answered = true;
      _answers[q.questionId.isEmpty ? 'q_$_currentIndex' : q.questionId] =
          index;
      if (correct) {
        _correctCount++;
      } else {
        _wrongCount++;
      }
    });
  }

  Future<void> _next() async {
    if (_isLast) {
      await _finish();
    } else {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _answered = false;
      });
    }
  }

  Future<void> _finish() async {
    final uid = FirebaseService.currentUid;
    if (uid == null) {
      if (mounted) Navigator.of(context).pop(true);
      return;
    }

    final bool passed = _correctCount >= _passThreshold;

    final attempt = QuizAttempt(
      attemptId: '',
      uid: uid,
      quizId: widget.quiz.quizId,
      subject: widget.subjectName,
      chapter: widget.chapterName,
      score: _correctCount,
      totalMarks: _questions.length,
      correctCount: _correctCount,
      wrongCount: _wrongCount,
      skippedCount: _questions.length - _correctCount - _wrongCount,
      answers: _answers,
      startedAt: _startedAt,
      submittedAt: DateTime.now(),
      timeSpentSeconds: DateTime.now()
          .difference(_startedAt ?? DateTime.now())
          .inSeconds,
    );

    // Save attempt (also updates weekly leaderboard)
    await FirebaseService.saveAttempt(attempt);

    // ❌ NO EXTRA COIN DEDUCTION ON FAIL — entry fee already taken
    // ❌ NO BONUS ON PASS (change if needed)

    try {
      await ScreenProtector.preventScreenshotOff();
    } catch (_) {}

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizResultScreen(
          correctCount: _correctCount,
          wrongCount: _wrongCount,
          totalQuestions: _questions.length,
          passed: passed,
          subjectName: widget.subjectName,
          chapterName: widget.chapterName,
          questions: _questions,
          answers: _answers,
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _graceTimer?.cancel();
    try {
      ScreenProtector.preventScreenshotOff();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) return _emptyState();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _confirmQuit();
      },
      child: Scaffold(
        backgroundColor: GlassTheme.backgroundLight,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.xmark,
              size: 16,
              color: GlassTheme.textPrimaryLight,
            ),
            onPressed: _confirmQuit,
          ),
          title: Text('${_currentIndex + 1} / ${_questions.length}'),
        ),
        body: Stack(
          children: [
            const _PlayBackground(),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProgress(),
                    const SizedBox(height: 20),
                    _buildQuestionCard(),
                    const SizedBox(height: 16),
                    ...List.generate(
                      _questions[_currentIndex].options.length,
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _OptionTile(
                          index: i,
                          label: _questions[_currentIndex].options[i],
                          selected: _selectedIndex == i,
                          answered: _answered,
                          isCorrect: i ==
                              _questions[_currentIndex].correctIndex,
                          onTap: () => _selectOption(i),
                        ),
                      ),
                    ),
                    if (_answered) ...[
                      const SizedBox(height: 10),
                      _buildExplanation(),
                      const SizedBox(height: 18),
                      _buildNextButton(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    final double ratio = _questions.isEmpty
        ? 0
        : (_currentIndex + 1) / _questions.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Score: $_correctCount',
              style: const TextStyle(
                color: GlassTheme.accentGreen,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                fontFamily: 'PlusJakartaSans',
              ),
            ),
            const Spacer(),
            Text(
              '$_wrongCount wrong',
              style: const TextStyle(
                color: GlassTheme.accentRed,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                fontFamily: 'PlusJakartaSans',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Container(
                height: 6,
                color: Colors.black.withOpacity(0.06),
              ),
              FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  height: 6,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        GlassTheme.accentRed,
                        GlassTheme.accentRedDark,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        _questions[_currentIndex].question,
        style: const TextStyle(
          color: GlassTheme.textPrimaryLight,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          height: 1.5,
          letterSpacing: -0.2,
          fontFamily: 'PlusJakartaSans',
          fontFamilyFallback: ['HindSiliguri'],
        ),
      ),
    );
  }

  Widget _buildExplanation() {
    final q = _questions[_currentIndex];
    final bool correct = _selectedIndex == q.correctIndex;

    final Color accent =
        correct ? GlassTheme.accentGreen : GlassTheme.accentRed;
    final String symbol = correct ? '✅' : '❌';
    final String label = correct ? 'Correct' : 'Incorrect';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent.withOpacity(0.40),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(symbol, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: accent,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'PlusJakartaSans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            q.explanation.isEmpty
                ? 'No explanation provided.'
                : q.explanation,
            style: const TextStyle(
              color: GlassTheme.textPrimaryLight,
              fontSize: 13.5,
              height: 1.6,
              fontFamily: 'PlusJakartaSans',
              fontFamilyFallback: ['HindSiliguri'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      height: 54,
      child: Material(
        color: GlassTheme.accentRed,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          onTap: _next,
          borderRadius: BorderRadius.circular(100),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isLast ? 'See Result' : 'Next Question',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
                const SizedBox(width: 10),
                FaIcon(
                  _isLast
                      ? FontAwesomeIcons.flagCheckered
                      : FontAwesomeIcons.arrowRight,
                  size: 13,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Scaffold(
      backgroundColor: GlassTheme.backgroundLight,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FaIcon(
                FontAwesomeIcons.circleInfo,
                size: 40,
                color: GlassTheme.textHintLight,
              ),
              const SizedBox(height: 16),
              const Text(
                'No questions available',
                style: TextStyle(
                  color: GlassTheme.textPrimaryLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'PlusJakartaSans',
                  fontFamilyFallback: ['HindSiliguri'],
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmQuit() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('Leave quiz?'),
        content: const Text(
          'Your progress on this quiz will be lost. Your entry fee will not be refunded.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pop(false);
            },
            child: const Text(
              'Leave',
              style: TextStyle(color: GlassTheme.accentRed),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// OPTION TILE
// =====================================================================
class _OptionTile extends StatelessWidget {
  final int index;
  final String label;
  final bool selected;
  final bool answered;
  final bool isCorrect;
  final VoidCallback onTap;

  const _OptionTile({
    required this.index,
    required this.label,
    required this.selected,
    required this.answered,
    required this.isCorrect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.black.withOpacity(0.06);
    Color fillColor = Colors.white;
    Color textColor = GlassTheme.textPrimaryLight;
    String? badge;
    Color? badgeColor;
    IconData? leadingIcon;
    Color leadingColor = GlassTheme.textTertiaryLight;

    if (!answered) {
      if (selected) {
        borderColor = GlassTheme.accentRed.withOpacity(0.60);
        fillColor = GlassTheme.accentRed.withOpacity(0.06);
      }
    } else {
      if (isCorrect) {
        borderColor = GlassTheme.accentGreen.withOpacity(0.70);
        fillColor = GlassTheme.accentGreen.withOpacity(0.10);
        badge = '✅';
        badgeColor = GlassTheme.accentGreen;
        leadingIcon = FontAwesomeIcons.check;
        leadingColor = GlassTheme.accentGreen;
      } else if (selected && !isCorrect) {
        borderColor = GlassTheme.accentRed.withOpacity(0.70);
        fillColor = GlassTheme.accentRed.withOpacity(0.10);
        badge = '❌';
        badgeColor = GlassTheme.accentRed;
        leadingIcon = FontAwesomeIcons.xmark;
        leadingColor = GlassTheme.accentRed;
      } else {
        textColor = GlassTheme.textTertiaryLight;
      }
    }

    return GestureDetector(
      onTap: answered ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: leadingIcon == null
                    ? Colors.black.withOpacity(0.04)
                    : leadingColor.withOpacity(0.15),
              ),
              child: Center(
                child: leadingIcon == null
                    ? Text(
                        String.fromCharCode(65 + index),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      )
                    : FaIcon(
                        leadingIcon,
                        size: 12,
                        color: leadingColor,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'PlusJakartaSans',
                  fontFamilyFallback: ['HindSiliguri'],
                ),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeColor!.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// BACKGROUND
// =====================================================================
class _PlayBackground extends StatelessWidget {
  const _PlayBackground();

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