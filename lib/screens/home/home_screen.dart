// lib/screens/home/home_screen.dart
//
// Apple-style home screen with small coin badge + profile pic.
// Developer: Sibnath Bairagi

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../config/app_config.dart';
import '../../config/glass_theme.dart';
import '../../services/firebase_service.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../subjects/video_player_screen.dart';
import '../subjects/subject_list_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _heroIndex = 0;
  final PageController _heroController = PageController();

  String _studentName = 'Student';
  String _avatarUrl = '';
  int _coins = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseService.currentUid;
    if (uid == null) return;

    try {
      final profile = await FirebaseService.getUserProfile(
        uid,
        forceRefresh: true,
      );

      if (profile == null) {
        await FirebaseService.giveWelcomeBonusIfNotGiven(uid);
        final coins = await FirebaseService.getCoins(
          uid,
          forceRefresh: true,
        );
        if (!mounted) return;
        setState(() {
          _studentName = 'Student';
          _avatarUrl = '';
          _coins = coins;
        });
        return;
      }

      await FirebaseService.giveWelcomeBonusIfNotGiven(uid);

      final freshCoins = await FirebaseService.getCoins(
        uid,
        forceRefresh: true,
      );

      if (!mounted) return;
      setState(() {
        _studentName = profile.displayName;
        _avatarUrl = profile.profileImageUrl;
        _coins = freshCoins;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlassTheme.backgroundLight,
      extendBody: true,
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          const _HomeBackground(),
          SafeArea(
            bottom: false,
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _buildHomeTab(context),
                const SubjectListScreen(),
                _buildQuizTab(context),
                _buildNoticeTab(),
                const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i == 4) {
            Navigator.of(context).pushNamed('/settings');
          } else {
            setState(() => _currentIndex = i);
          }
        },
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTopBar(context),
          const SizedBox(height: 18),
          _buildSearchBar(context),
          const SizedBox(height: 20),
          _buildHeroCarousel(),
          const SizedBox(height: 12),
          _buildHeroDots(),
          const SizedBox(height: 20),
          _buildCountdownCard(),
          const SizedBox(height: 22),
          _buildSectionHeader(
              context, 'Trending Now', FontAwesomeIcons.fire),
          const SizedBox(height: 14),
          _buildTrendingList(context),
          const SizedBox(height: 24),
          _buildSectionHeader(
              context, 'Quick Subjects', FontAwesomeIcons.book),
          const SizedBox(height: 14),
          _buildSubjectsGrid(context),
          const SizedBox(height: 24),
          _buildSectionHeader(
              context, 'Latest Notice', FontAwesomeIcons.bullhorn),
          const SizedBox(height: 14),
          _buildNoticePreview(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // =====================================================================
  // TOP BAR — name + coin badge + avatar with DP
  // =====================================================================
  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(),
                style: const TextStyle(
                  color: GlassTheme.textSecondaryLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'PlusJakartaSans',
                  fontFamilyFallback: ['HindSiliguri'],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _studentName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: GlassTheme.textPrimaryLight,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  height: 1.15,
                  fontFamily: 'PlusJakartaSans',
                  fontFamilyFallback: ['HindSiliguri'],
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => _currentIndex = 2),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFD770), Color(0xFFE5B85C)],
              ),
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE5B85C).withOpacity(0.30),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FaIcon(
                  FontAwesomeIcons.coins,
                  size: 11,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  '$_coins',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed('/settings'),
          child: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: GlassTheme.accentRed.withOpacity(0.10),
              border: Border.all(
                color: GlassTheme.accentRed.withOpacity(0.25),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: _avatarUrl.isNotEmpty
                  ? Image.network(
                      _avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _avatarFallback(),
                    )
                  : _avatarFallback(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: GlassTheme.accentRed.withOpacity(0.08),
      child: const Center(
        child: FaIcon(
          FontAwesomeIcons.user,
          size: 15,
          color: GlassTheme.accentRed,
        ),
      ),
    );
  }

  String _greeting() {
    final int h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/search'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const FaIcon(
              FontAwesomeIcons.magnifyingGlass,
              size: 14,
              color: GlassTheme.textTertiaryLight,
            ),
            const SizedBox(width: 14),
            Text(
              'Search videos, chapters, quizzes...',
              style: TextStyle(
                color: GlassTheme.textHintLight,
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                fontFamily: 'PlusJakartaSans',
                fontFamilyFallback: const ['HindSiliguri'],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCarousel() {
    final banners = <Map<String, Object>>[
      {
        'tag': 'NEW',
        'title': 'Madhyamik 2026',
        'sub': 'Complete preparation package',
        'colors': <Color>[
          const Color(0xFF5B8DEF),
          const Color(0xFF1E2A47)
        ],
      },
      {
        'tag': 'VIDEO',
        'title': 'Physics Lessons',
        'sub': 'Chapter-wise video library',
        'colors': <Color>[
          const Color(0xFFEF4444),
          const Color(0xFF7F1D1D)
        ],
      },
      {
        'tag': 'QUIZ',
        'title': 'Daily Practice',
        'sub': 'Sharpen your skills every evening',
        'colors': <Color>[
          const Color(0xFF2FBF71),
          const Color(0xFF145A34)
        ],
      },
    ];

    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _heroController,
        itemCount: banners.length,
        onPageChanged: (i) => setState(() => _heroIndex = i),
        itemBuilder: (_, i) {
          final b = banners[i];
          final colors = b['colors'] as List<Color>;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 110,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.40),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: GlassTheme.accentRed,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              b['tag'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                fontFamily: 'PlusJakartaSans',
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            b['title'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              height: 1.2,
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            b['sub'] as String,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'PlusJakartaSans',
                              fontFamilyFallback: const ['HindSiliguri'],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = i == _heroIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 6,
          width: active ? 20 : 6,
          decoration: BoxDecoration(
            color:
                active ? GlassTheme.accentRed : GlassTheme.textHintLight,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildCountdownCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: GlassTheme.accentRed.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.clock,
                    size: 12,
                    color: GlassTheme.accentRed,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Madhyamik Exam Countdown',
                  style: TextStyle(
                    color: GlassTheme.textPrimaryLight,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    fontFamily: 'PlusJakartaSans',
                    fontFamilyFallback: ['HindSiliguri'],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _CountdownTimer(targetDate: AppConfig.madhyamikExamDate),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              '15 February 2027  |  10:00 AM',
              style: TextStyle(
                color: GlassTheme.textTertiaryLight,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'PlusJakartaSans',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        FaIcon(icon, size: 12, color: GlassTheme.accentRed),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: GlassTheme.textPrimaryLight,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            fontFamily: 'PlusJakartaSans',
            fontFamilyFallback: ['HindSiliguri'],
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => setState(() => _currentIndex = 1),
          child: const Text(
            'See all',
            style: TextStyle(
              color: GlassTheme.accentRed,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'PlusJakartaSans',
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================================
  // TRENDING — reads all videos, filters client-side
  // =====================================================================
  Widget _buildTrendingList(BuildContext context) {
    return SizedBox(
      height: 172,
      child: StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance.ref('videos').onValue,
        builder: (context, snapshot) {
          final items = <Map<String, String>>[];

          if (snapshot.hasData &&
              snapshot.data!.snapshot.exists &&
              snapshot.data!.snapshot.value != null) {
            final raw = Map<String, dynamic>.from(
              snapshot.data!.snapshot.value as Map,
            );
            raw.forEach((key, value) {
              if (value is! Map) return;
              final data = Map<String, dynamic>.from(value);
              if (data['isPublished'] == false) return;
              items.add({
                'title': (data['title'] ?? '').toString(),
                'subject': (data['subject'] ?? '').toString(),
                'chapter': (data['chapter'] ?? '').toString(),
                'youtubeId': (data['youtubeId'] ?? '').toString(),
                'description': (data['description'] ?? '').toString(),
                'duration': (data['duration'] ?? '').toString(),
                'thumbnail': (data['thumbnailUrl'] ?? '').toString(),
              });
            });
          }

          if (items.isEmpty) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.black.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.video,
                      size: 22,
                      color: GlassTheme.accentRed.withOpacity(0.4),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No videos available',
                      style: TextStyle(
                        color: GlassTheme.textTertiaryLight,
                        fontSize: 12.5,
                        fontFamily: 'PlusJakartaSans',
                        fontFamilyFallback: ['HindSiliguri'],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final item = items[i];
              return _TrendingCard(
                title: item['title'] ?? '',
                subject: item['subject'] ?? '',
                duration: (item['duration'] ?? '').isEmpty
                    ? '0:00'
                    : item['duration']!,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VideoPlayerScreen(
                        title: item['title'] ?? '',
                        subject: item['subject'] ?? '',
                        chapter: item['chapter'] ?? '',
                        description: item['description'] ?? '',
                        youtubeId: item['youtubeId'] ?? '',
                        thumbnailUrl: item['thumbnail'] ?? '',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSubjectsGrid(BuildContext context) {
    const subjects = [
      {'name': 'বাংলা', 'asset': 'assets/subjects/bengali.png'},
      {'name': 'English', 'asset': 'assets/subjects/english.png'},
      {'name': 'গণিত', 'asset': 'assets/subjects/mathematics.png'},
      {
        'name': 'ভৌতবিজ্ঞান',
        'asset': 'assets/subjects/physical_science.png'
      },
      {'name': 'জীবন বিজ্ঞান', 'asset': 'assets/subjects/life_science.png'},
      {'name': 'ইতিহাস', 'asset': 'assets/subjects/history.png'},
      {'name': 'ভূগোল', 'asset': 'assets/subjects/geography.png'},
      {'name': 'আরও', 'asset': 'assets/subjects/more.png'},
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: subjects.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final s = subjects[i];
          return GestureDetector(
            onTap: () => setState(() => _currentIndex = 1),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 140,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      s['asset']!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: GlassTheme.accentRed.withOpacity(0.10),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 40,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      bottom: 8,
                      right: 10,
                      child: Text(
                        s['name']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'PlusJakartaSans',
                          fontFamilyFallback: ['HindSiliguri'],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoticePreview() {
    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance.ref('notices').onValue,
      builder: (context, snapshot) {
        String title = 'Welcome to Madhyamik Shokha';
        String body = 'Notices will appear here.';

        if (snapshot.hasData &&
            snapshot.data!.snapshot.exists &&
            snapshot.data!.snapshot.value != null) {
          final raw = Map<String, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );
          if (raw.isNotEmpty) {
            final first = raw.values.first;
            if (first is Map) {
              final data = Map<String, dynamic>.from(first);
              title = (data['title'] ?? title).toString();
              body = (data['body'] ?? body).toString();
            }
          }
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: GlassTheme.accentRed.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.bullhorn,
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
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: GlassTheme.textPrimaryLight,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'PlusJakartaSans',
                        fontFamilyFallback: ['HindSiliguri'],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: GlassTheme.textTertiaryLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'PlusJakartaSans',
                        fontFamilyFallback: const ['HindSiliguri'],
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
        );
      },
    );
  }

  Widget _buildQuizTab(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 130),
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
          const Text(
            'Test yourself at 7:00 PM to 10:00 PM.',
            style: TextStyle(
              color: GlassTheme.textSecondaryLight,
              fontSize: 14,
              fontFamily: 'PlusJakartaSans',
              fontFamilyFallback: ['HindSiliguri'],
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/quiz'),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    GlassTheme.accentRed,
                    GlassTheme.accentRedDark
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: FaIcon(
                            FontAwesomeIcons.stopwatch,
                            size: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Quiz Time',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),
                      const Spacer(),
                      const FaIcon(
                        FontAwesomeIcons.arrowRight,
                        size: 13,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '7:00 PM to 10:00 PM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap to start a quiz now',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () =>
                Navigator.of(context).pushNamed('/leaderboard'),
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
              ),
              child: Row(
                children: [
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFE5B85C).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.trophy,
                        size: 16,
                        color: Color(0xFFE5B85C),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Leaderboard',
                          style: TextStyle(
                            color: GlassTheme.textPrimaryLight,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'PlusJakartaSans',
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'See top scorers this week.',
                          style: TextStyle(
                            color: GlassTheme.textTertiaryLight,
                            fontSize: 12.5,
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
        ],
      ),
    );
  }

  Widget _buildNoticeTab() {
    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance.ref('notices').onValue,
      builder: (context, snapshot) {
        final notices = <Map<String, dynamic>>[];

        if (snapshot.hasData &&
            snapshot.data!.snapshot.exists &&
            snapshot.data!.snapshot.value != null) {
          final raw = Map<String, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );
          raw.forEach((key, value) {
            if (value is! Map) return;
            final data = Map<String, dynamic>.from(value);
            data['id'] = key;
            notices.add(data);
          });
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 130),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Notices',
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
              const Text(
                'Announcements and updates.',
                style: TextStyle(
                  color: GlassTheme.textSecondaryLight,
                  fontSize: 14,
                  fontFamily: 'PlusJakartaSans',
                  fontFamilyFallback: ['HindSiliguri'],
                ),
              ),
              const SizedBox(height: 22),
              if (notices.isEmpty)
                _buildEmptyNotice()
              else
                ...notices.map(
                  (n) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildNoticeCard(
                      (n['title'] ?? '').toString(),
                      (n['body'] ?? '').toString(),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        children: [
          FaIcon(
            FontAwesomeIcons.bullhorn,
            size: 36,
            color: GlassTheme.textHintLight,
          ),
          const SizedBox(height: 16),
          const Text(
            'No notices yet',
            style: TextStyle(
              color: GlassTheme.textPrimaryLight,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'PlusJakartaSans',
              fontFamilyFallback: ['HindSiliguri'],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Notices will appear here soon.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: GlassTheme.textTertiaryLight,
              fontSize: 13,
              fontFamily: 'PlusJakartaSans',
              fontFamilyFallback: const ['HindSiliguri'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeCard(String title, String body) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: GlassTheme.accentRed.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.bullhorn,
                    size: 12,
                    color: GlassTheme.accentRed,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: GlassTheme.textPrimaryLight,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'PlusJakartaSans',
                    fontFamilyFallback: ['HindSiliguri'],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: const TextStyle(
              color: GlassTheme.textSecondaryLight,
              fontSize: 13,
              height: 1.5,
              fontFamily: 'PlusJakartaSans',
              fontFamilyFallback: ['HindSiliguri'],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// TRENDING CARD
// =====================================================================
class _TrendingCard extends StatelessWidget {
  final String title;
  final String subject;
  final String duration;
  final VoidCallback onTap;

  const _TrendingCard({
    required this.title,
    required this.subject,
    required this.duration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 220,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF5B8DEF), Color(0xFF2A3A5C)],
                      ),
                    ),
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.image,
                        size: 24,
                        color: Colors.white.withOpacity(0.45),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: GlassTheme.textPrimaryLight,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        fontFamily: 'PlusJakartaSans',
                        fontFamilyFallback: ['HindSiliguri'],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subject,
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
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// COUNTDOWN TIMER
// =====================================================================
class _CountdownTimer extends StatefulWidget {
  final DateTime targetDate;

  const _CountdownTimer({required this.targetDate});

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer>
    with SingleTickerProviderStateMixin {
  Duration _remaining = Duration.zero;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _update();
    _ticker = createTicker((_) {
      if (mounted) _update();
    })..start();
  }

  void _update() {
    final diff = widget.targetDate.difference(DateTime.now());
    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  String _pad(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final mins = _remaining.inMinutes % 60;
    final secs = _remaining.inSeconds % 60;

    return Row(
      children: [
        Expanded(child: _timeBox('$days', 'Days')),
        const SizedBox(width: 8),
        Expanded(child: _timeBox(_pad(hours), 'Hours')),
        const SizedBox(width: 8),
        Expanded(child: _timeBox(_pad(mins), 'Minutes')),
        const SizedBox(width: 8),
        Expanded(child: _timeBox(_pad(secs), 'Seconds')),
      ],
    );
  }

  Widget _timeBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: GlassTheme.accentRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: GlassTheme.accentRed.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: GlassTheme.accentRed,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              fontFamily: 'PlusJakartaSans',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: GlassTheme.textTertiaryLight,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
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
class _HomeBackground extends StatelessWidget {
  const _HomeBackground();

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