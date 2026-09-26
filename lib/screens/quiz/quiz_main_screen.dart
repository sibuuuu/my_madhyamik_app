// lib/screens/quiz/quiz_main_screen.dart
//
// Quiz main entry - coin card + REAL AdMob rewarded ad + subject select.
// Developer: Sibnath Bairagi

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../config/ad_config.dart';
import '../../config/app_config.dart';
import '../../config/glass_theme.dart';
import '../../models/quiz_model.dart';
import '../../services/admob_service.dart';
import '../../services/firebase_service.dart';
import 'quiz_play_screen.dart';

class QuizMainScreen extends StatefulWidget {
  static const String routeName = '/quiz';
  const QuizMainScreen({super.key});

  @override
  State<QuizMainScreen> createState() => _QuizMainScreenState();
}

enum _Stage { subjectSelect, chapterSelect }

class _QuizMainScreenState extends State<QuizMainScreen> {
  static const int _entryFee = AppConfig.quizEntryFee;

  _Stage _stage = _Stage.subjectSelect;
  String? _selectedSubjectId;
  String? _selectedSubjectName;

  int _coins = 0;
  bool _loadingCoins = true;
  bool _showingAd = false;

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    final uid = FirebaseService.currentUid;
    if (uid == null) {
      if (mounted) setState(() => _loadingCoins = false);
      return;
    }
    final coins = await FirebaseService.getCoins(uid, forceRefresh: true);
    if (!mounted) return;
    setState(() {
      _coins = coins;
      _loadingCoins = false;
    });
  }

  Future<void> _watchAd() async {
    final uid = FirebaseService.currentUid;
    if (uid == null) return;

    // Web: no ads
    if (!AdMobService.isRewardedSupported) {
      _showInfo('Ads are not available on web. Use the mobile app.');
      return;
    }

    if (_showingAd) return;
    setState(() => _showingAd = true);

    final result = await AdMobService.showRewardedAd(
      uid: uid,
      onRewarded: (newCoins) {
        if (!mounted) return;
        setState(() => _coins = newCoins);
      },
    );

    if (!mounted) return;
    setState(() => _showingAd = false);

    switch (result) {
      case AdResult.rewarded:
        _showInfo('+${AdConfig.coinsPerAd} coin added!');
        break;
      case AdResult.dismissed:
        _showInfo('Ad was closed early. No reward.');
        break;
      case AdResult.failed:
        _showInfo('Ad could not load. Try again later.');
        break;
      case AdResult.notAvailable:
        _showInfo('Ads not available on this platform.');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlassTheme.backgroundLight,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.arrowLeft,
            size: 15,
            color: GlassTheme.textPrimaryLight,
          ),
          onPressed: () {
            if (_stage == _Stage.chapterSelect) {
              setState(() {
                _stage = _Stage.subjectSelect;
                _selectedSubjectId = null;
                _selectedSubjectName = null;
              });
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: Text(
          _stage == _Stage.chapterSelect
              ? (_selectedSubjectName ?? 'Chapters')
              : 'Quiz',
        ),
      ),
      body: Stack(
        children: [
          const _QuizBackground(),
          SafeArea(
            child: _isQuizTime()
                ? (_stage == _Stage.subjectSelect
                    ? _buildSubjectSelect()
                    : _buildChapterSelect())
                : _buildLockedScreen(),
          ),
        ],
      ),
    );
  }

  bool _isQuizTime() {
    if (AppConfig.quizTestingMode) return true;
    final h = DateTime.now().hour;
    return h >= AppConfig.quizStartHour && h < AppConfig.quizEndHour;
  }

  Duration _timeUntilQuiz() {
    final now = DateTime.now();
    DateTime target;
    if (now.hour < AppConfig.quizStartHour) {
      target = DateTime(
        now.year, now.month, now.day, AppConfig.quizStartHour,
      );
    } else {
      target = DateTime(
        now.year, now.month, now.day + 1, AppConfig.quizStartHour,
      );
    }
    return target.difference(now);
  }

  Widget _buildLockedScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: GlassTheme.accentRed.withOpacity(0.10),
                border: Border.all(
                  color: GlassTheme.accentRed.withOpacity(0.25),
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.lock,
                  size: 30,
                  color: GlassTheme.accentRed,
                ),
              ),
            ),
            const SizedBox(height: 26),
            const Text(
              'Quiz Not Live',
              style: TextStyle(
                color: GlassTheme.textPrimaryLight,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                fontFamily: 'PlusJakartaSans',
                fontFamilyFallback: ['HindSiliguri'],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Quizzes open every day from 7:00 PM to 10:00 PM.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: GlassTheme.textSecondaryLight,
                fontSize: 14,
                height: 1.5,
                fontFamily: 'PlusJakartaSans',
                fontFamilyFallback: ['HindSiliguri'],
              ),
            ),
            const SizedBox(height: 30),
            _LockedCountdown(targetProvider: _timeUntilQuiz),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectSelect() {
    const subjects = [
      {'id': 'bengali', 'name': 'বাংলা', 'icon': FontAwesomeIcons.bookOpen},
      {
        'id': 'english', 'name': 'English',
        'icon': FontAwesomeIcons.bookOpenReader
      },
      {
        'id': 'mathematics', 'name': 'গণিত',
        'icon': FontAwesomeIcons.squareRootVariable
      },
      {
        'id': 'physical_science', 'name': 'ভৌতবিজ্ঞান',
        'icon': FontAwesomeIcons.atom
      },
      {
        'id': 'life_science', 'name': 'জীবন বিজ্ঞান',
        'icon': FontAwesomeIcons.dna
      },
      {
        'id': 'history', 'name': 'ইতিহাস',
        'icon': FontAwesomeIcons.landmark
      },
      {
        'id': 'geography', 'name': 'ভূগোল',
        'icon': FontAwesomeIcons.earthAsia
      },
    ];

    final bool canAfford = _coins >= _entryFee;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Quiz',
            style: TextStyle(
              color: GlassTheme.textPrimaryLight,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              height: 1.15,
              fontFamily: 'PlusJakartaSans',
              fontFamilyFallback: ['HindSiliguri'],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Entry fee: $_entryFee coins per quiz.',
            style: const TextStyle(
              color: GlassTheme.textSecondaryLight,
              fontSize: 14,
              fontFamily: 'PlusJakartaSans',
              fontFamilyFallback: ['HindSiliguri'],
            ),
          ),
          const SizedBox(height: 20),
          _buildCoinCard(),
          const SizedBox(height: 12),
          _buildWatchAdButton(),
          const SizedBox(height: 22),
          if (!_loadingCoins && !canAfford) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: GlassTheme.accentRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: GlassTheme.accentRed.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const FaIcon(
                    FontAwesomeIcons.circleExclamation,
                    size: 14,
                    color: GlassTheme.accentRed,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You need $_entryFee coins. Watch ads to earn more.',
                      style: const TextStyle(
                        color: GlassTheme.accentRed,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'PlusJakartaSans',
                        fontFamilyFallback: ['HindSiliguri'],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
          ...subjects.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SubjectTile(
                name: s['name'] as String,
                icon: s['icon'] as IconData,
                enabled: canAfford && !_loadingCoins,
                onTap: () {
                  setState(() {
                    _selectedSubjectId = s['id'] as String;
                    _selectedSubjectName = s['name'] as String;
                    _stage = _Stage.chapterSelect;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD770), Color(0xFFE5B85C)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE5B85C).withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.30),
              border: Border.all(
                color: Colors.white.withOpacity(0.50),
                width: 1.5,
              ),
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.coins,
                size: 22,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Coins',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.90),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _loadingCoins ? '...' : '$_coins',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                    height: 1.0,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _loadCoins,
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.50),
                  width: 1,
                ),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.rotateRight,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchAdButton() {
    final bool supported = AdMobService.isRewardedSupported;

    return GestureDetector(
      onTap: (_showingAd || !supported) ? null : _watchAd,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: supported ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: GlassTheme.accentRed.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _showingAd
                    ? const Center(
                        child: SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(
                              GlassTheme.accentRed,
                            ),
                          ),
                        ),
                      )
                    : const Center(
                        child: FaIcon(
                          FontAwesomeIcons.circlePlay,
                          size: 14,
                          color: GlassTheme.accentRed,
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supported
                          ? 'Watch Ad to Earn Coin'
                          : 'Ads Unavailable on Web',
                      style: const TextStyle(
                        color: GlassTheme.textPrimaryLight,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        fontFamily: 'PlusJakartaSans',
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      supported
                          ? 'Get 1 coin per ad watched'
                          : 'Use the mobile app to earn coins',
                      style: const TextStyle(
                        color: GlassTheme.textTertiaryLight,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'PlusJakartaSans',
                      ),
                    ),
                  ],
                ),
              ),
              const FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 12,
                color: GlassTheme.textTertiaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChapterSelect() {
    final subjectId = _selectedSubjectId ?? '';
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Choose a Chapter',
            style: TextStyle(
              color: GlassTheme.textPrimaryLight,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              fontFamily: 'PlusJakartaSans',
              fontFamilyFallback: ['HindSiliguri'],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Entry fee: $_entryFee coins  •  You have: $_coins',
            style: const TextStyle(
              color: GlassTheme.textSecondaryLight,
              fontSize: 13.5,
              fontFamily: 'PlusJakartaSans',
              fontFamilyFallback: ['HindSiliguri'],
            ),
          ),
          const SizedBox(height: 22),
          StreamBuilder<DatabaseEvent>(
            stream: FirebaseDatabase.instance
                .ref('chapters')
                .orderByChild('subjectId')
                .equalTo(subjectId)
                .onValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        GlassTheme.accentRed,
                      ),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData ||
                  !snapshot.data!.snapshot.exists ||
                  snapshot.data!.snapshot.value == null) {
                return _emptyChapters();
              }

              final raw = Map<String, dynamic>.from(
                snapshot.data!.snapshot.value as Map,
              );
              final chapters = <Map<String, dynamic>>[];
              raw.forEach((key, value) {
                if (value is! Map) return;
                final data = Map<String, dynamic>.from(value);
                if ((data['isActive'] ?? true) == true) {
                  data['id'] = key;
                  chapters.add(data);
                }
              });

              chapters.sort((a, b) {
                final ao = _asInt(a['order']);
                final bo = _asInt(b['order']);
                return ao.compareTo(bo);
              });

              return Column(
                children: chapters
                    .map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ChapterTile(
                          title: (c['title'] ?? '').toString(),
                          description:
                              (c['description'] ?? '').toString(),
                          onTap: () => _startQuiz(
                            (c['id'] ?? '').toString(),
                            (c['title'] ?? '').toString(),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _emptyChapters() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 60,
        horizontal: 20,
      ),
      child: Column(
        children: [
          FaIcon(
            FontAwesomeIcons.bookOpen,
            size: 36,
            color: GlassTheme.textHintLight,
          ),
          const SizedBox(height: 16),
          const Text(
            'No chapters yet',
            style: TextStyle(
              color: GlassTheme.textPrimaryLight,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'PlusJakartaSans',
              fontFamilyFallback: ['HindSiliguri'],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Chapters will be added from Admin Panel.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: GlassTheme.textTertiaryLight,
              fontSize: 13,
              fontFamily: 'PlusJakartaSans',
              fontFamilyFallback: ['HindSiliguri'],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startQuiz(
    String chapterId,
    String chapterTitle,
  ) async {
    final uid = FirebaseService.currentUid;
    if (uid == null) {
      _showInfo('Please sign in first.');
      return;
    }

    final coins = await FirebaseService.getCoins(
      uid,
      forceRefresh: true,
    );
    if (!mounted) return;
    setState(() => _coins = coins);

    if (coins < _entryFee) {
      _showInfo('You need $_entryFee coins. You have $coins.');
      return;
    }

    final subjectId = _selectedSubjectId ?? '';
    final subjectName = _selectedSubjectName ?? '';

    List<QuizModel> matched = [];

    try {
      final snap =
          await FirebaseDatabase.instance.ref('quizzes').get();

      if (snap.exists && snap.value != null) {
        final raw = Map<String, dynamic>.from(snap.value as Map);
        final all = <QuizModel>[];

        raw.forEach((key, value) {
          if (value is! Map) return;
          final data = Map<String, dynamic>.from(value);
          data['quizId'] = key;
          final q = QuizModel.fromMap(data);
          if (q.isActive) all.add(q);
        });

        matched = all.where((q) {
          final subMatch =
              q.subject == subjectId || q.subject == subjectName;
          final chMatch = q.chapter == chapterId ||
              q.chapterTitle == chapterTitle;
          return subMatch && chMatch;
        }).toList();

        if (matched.isEmpty) {
          matched = all.where((q) {
            return q.subject == subjectId ||
                q.subject == subjectName;
          }).toList();
        }

        if (matched.isEmpty && all.isNotEmpty) {
          matched = all;
        }
      }
    } catch (_) {
      _showInfo('Could not load quiz. Check connection.');
      return;
    }

    if (matched.isEmpty) {
      _showInfo('No quiz available for this chapter yet.');
      return;
    }

    if (!mounted) return;

    await FirebaseService.updateCoins(uid, coins - _entryFee);
    if (!mounted) return;
    setState(() => _coins = coins - _entryFee);

    final quiz = matched.first;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => QuizPlayScreen(
          quiz: quiz,
          subjectName: subjectName,
          chapterName: chapterTitle,
        ),
      ),
    );

    if (result == true && mounted) {
      _loadCoins();
      // Show interstitial after quiz completion
      AdMobService.maybeShowInterstitial();
    }
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.circleInfo,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}

// =====================================================================
// SUBJECT TILE
// =====================================================================
class _SubjectTile extends StatelessWidget {
  final String name;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _SubjectTile({
    required this.name,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.45,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.black.withOpacity(0.05),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: GlassTheme.accentRed.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: FaIcon(
                    icon,
                    size: 16,
                    color: GlassTheme.accentRed,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: GlassTheme.textPrimaryLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    fontFamily: 'PlusJakartaSans',
                    fontFamilyFallback: ['HindSiliguri'],
                  ),
                ),
              ),
              const FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 12,
                color: GlassTheme.textTertiaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// CHAPTER TILE
// =====================================================================
class _ChapterTile extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ChapterTile({
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.black.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: GlassTheme.accentBlue.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.listCheck,
                  size: 16,
                  color: GlassTheme.accentBlue,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isEmpty ? 'Untitled' : title,
                    style: const TextStyle(
                      color: GlassTheme.textPrimaryLight,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      fontFamily: 'PlusJakartaSans',
                      fontFamilyFallback: ['HindSiliguri'],
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: GlassTheme.textTertiaryLight,
                        fontSize: 12.5,
                        fontFamily: 'PlusJakartaSans',
                        fontFamilyFallback: ['HindSiliguri'],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: GlassTheme.accentRed,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.play,
                    size: 9,
                    color: Colors.white,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'START',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// LOCKED COUNTDOWN
// =====================================================================
class _LockedCountdown extends StatefulWidget {
  final Duration Function() targetProvider;

  const _LockedCountdown({required this.targetProvider});

  @override
  State<_LockedCountdown> createState() => _LockedCountdownState();
}

class _LockedCountdownState extends State<_LockedCountdown>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      if (mounted) setState(() {});
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  String _pad(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final diff = widget.targetProvider();
    final hours = diff.inHours;
    final mins = diff.inMinutes % 60;
    final secs = diff.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FaIcon(
            FontAwesomeIcons.clock,
            size: 12,
            color: GlassTheme.accentRed,
          ),
          const SizedBox(width: 10),
          Text(
            'Opens in ${_pad(hours)}:${_pad(mins)}:${_pad(secs)}',
            style: const TextStyle(
              color: GlassTheme.textPrimaryLight,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              fontFamily: 'PlusJakartaSans',
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// BACKGROUND
// =====================================================================
class _QuizBackground extends StatelessWidget {
  const _QuizBackground();

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