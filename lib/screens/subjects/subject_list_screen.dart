// lib/screens/subjects/subject_list_screen.dart
//
// Subject list + Chapter list + Video list for Madhyamik Shokha.
// Firebase-driven with iPhone-style glass cards.
// Developer: Sibnath Bairagi

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../config/glass_theme.dart';
import 'video_player_screen.dart';

class SubjectListScreen extends StatefulWidget {
  static const String routeName = '/subjects';
  const SubjectListScreen({super.key});

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  // ৮টা subject — poster asset + name
  static const List<Map<String, String>> _subjects = [
    {
      'id': 'bengali',
      'name': 'বাংলা',
      'nameEnglish': 'Bengali',
      'poster': 'assets/subjects/bengali.png',
    },
    {
      'id': 'english',
      'name': 'English',
      'nameEnglish': 'English',
      'poster': 'assets/subjects/english.png',
    },
    {
      'id': 'mathematics',
      'name': 'গণিত',
      'nameEnglish': 'Mathematics',
      'poster': 'assets/subjects/mathematics.png',
    },
    {
      'id': 'physical_science',
      'name': 'ভৌতবিজ্ঞান',
      'nameEnglish': 'Physical Science',
      'poster': 'assets/subjects/physical_science.png',
    },
    {
      'id': 'life_science',
      'name': 'জীবন বিজ্ঞান',
      'nameEnglish': 'Life Science',
      'poster': 'assets/subjects/life_science.png',
    },
    {
      'id': 'history',
      'name': 'ইতিহাস',
      'nameEnglish': 'History',
      'poster': 'assets/subjects/history.png',
    },
    {
      'id': 'geography',
      'name': 'ভূগোল',
      'nameEnglish': 'Geography',
      'poster': 'assets/subjects/geography.png',
    },
    {
      'id': 'more',
      'name': 'আরও',
      'nameEnglish': 'More Courses',
      'poster': 'assets/subjects/more.png',
    },
  ];

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
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Subjects'),
      ),
      body: Stack(
        children: [
          const _SubjectsBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _PageHeader(),
                  const SizedBox(height: 22),
                  ..._subjects.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _SubjectPosterCard(
                        name: s['name']!,
                        nameEnglish: s['nameEnglish']!,
                        posterPath: s['poster']!,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChapterListScreen(
                                subjectId: s['id']!,
                                subjectName: s['name']!,
                                subjectPoster: s['poster']!,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// CHAPTER LIST SCREEN — Firebase-driven
// =====================================================================
class ChapterListScreen extends StatelessWidget {
  final String subjectId;
  final String subjectName;
  final String subjectPoster;

  const ChapterListScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
    required this.subjectPoster,
  });

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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(subjectName),
      ),
      body: Stack(
        children: [
          const _SubjectsBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Chapters',
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
                    'Pick a chapter to see its video lessons.',
                    style: TextStyle(
                      color: GlassTheme.textSecondaryLight,
                      fontSize: 14,
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
                        return _emptyState(
                          'No chapters yet',
                          'Chapters will be added from Admin Panel.',
                        );
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
                        final ao = (a['order'] ?? 0) as int;
                        final bo = (b['order'] ?? 0) as int;
                        return ao.compareTo(bo);
                      });

                      return Column(
                        children: chapters
                            .map(
                              (c) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _ChapterCard(
                                  title: (c['title'] ?? '').toString(),
                                  description:
                                      (c['description'] ?? '').toString(),
                                  posterUrl:
                                      (c['posterUrl'] ?? '').toString(),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => VideoListScreen(
                                          subjectId: subjectId,
                                          subjectName: subjectName,
                                          chapterId: c['id'].toString(),
                                          chapterTitle:
                                              (c['title'] ?? '').toString(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        children: [
          FaIcon(
            FontAwesomeIcons.bookOpen,
            size: 36,
            color: GlassTheme.textHintLight,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: GlassTheme.textPrimaryLight,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'PlusJakartaSans',
              fontFamilyFallback: ['HindSiliguri'],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
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
}

// =====================================================================
// CHAPTER CARD — glass with poster
// =====================================================================
class _ChapterCard extends StatelessWidget {
  final String title;
  final String description;
  final String posterUrl;
  final VoidCallback onTap;

  const _ChapterCard({
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.black.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Poster
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(23),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: posterUrl.isNotEmpty
                    ? Image.network(
                        posterUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallback(),
                      )
                    : _fallback(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.isEmpty ? 'Untitled Chapter' : title,
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
                          const SizedBox(height: 6),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: GlassTheme.textTertiaryLight,
                              fontSize: 12.5,
                              height: 1.4,
                              fontFamily: 'PlusJakartaSans',
                              fontFamilyFallback: ['HindSiliguri'],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: GlassTheme.accentRed.withOpacity(0.10),
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.arrowRight,
                        size: 12,
                        color: GlassTheme.accentRed,
                      ),
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

  Widget _fallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5B8DEF), Color(0xFF1E2A47)],
        ),
      ),
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.image,
          size: 32,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}

// =====================================================================
// VIDEO LIST SCREEN — Firebase-driven
// =====================================================================
class VideoListScreen extends StatelessWidget {
  final String subjectId;
  final String subjectName;
  final String chapterId;
  final String chapterTitle;

  const VideoListScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
    required this.chapterId,
    required this.chapterTitle,
  });

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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(chapterTitle),
      ),
      body: Stack(
        children: [
          const _SubjectsBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Video Lessons',
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
                    '$subjectName  •  $chapterTitle',
                    style: const TextStyle(
                      color: GlassTheme.textSecondaryLight,
                      fontSize: 13,
                      fontFamily: 'PlusJakartaSans',
                      fontFamilyFallback: ['HindSiliguri'],
                    ),
                  ),
                  const SizedBox(height: 22),
                  StreamBuilder<DatabaseEvent>(
                    stream: FirebaseDatabase.instance
                        .ref('videos')
                        .orderByChild('chapterId')
                        .equalTo(chapterId)
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
                        return _emptyState();
                      }

                      final raw = Map<String, dynamic>.from(
                        snapshot.data!.snapshot.value as Map,
                      );
                      final videos = <Map<String, dynamic>>[];

                      raw.forEach((key, value) {
                        if (value is! Map) return;
                        final data = Map<String, dynamic>.from(value);
                        if ((data['isPublished'] ?? true) == true) {
                          data['id'] = key;
                          videos.add(data);
                        }
                      });

                      videos.sort((a, b) {
                        final ao = (a['orderIndex'] ?? 0) as int;
                        final bo = (b['orderIndex'] ?? 0) as int;
                        return ao.compareTo(bo);
                      });

                      return Column(
                        children: videos
                            .map(
                              (v) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _VideoCard(
                                  title: (v['title'] ?? '').toString(),
                                  description:
                                      (v['description'] ?? '').toString(),
                                  thumbnailUrl:
                                      (v['thumbnailUrl'] ?? '').toString(),
                                  duration:
                                      (v['duration'] ?? '').toString(),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => VideoPlayerScreen(
                                          videoId: (v['id'] ?? '').toString(),
                                          title:
                                              (v['title'] ?? '').toString(),
                                          subject: subjectName,
                                          chapter: chapterTitle,
                                          description:
                                              (v['description'] ?? '')
                                                  .toString(),
                                          youtubeId:
                                              (v['youtubeId'] ?? '').toString(),
                                          thumbnailUrl:
                                              (v['thumbnailUrl'] ?? '')
                                                  .toString(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        children: [
          FaIcon(
            FontAwesomeIcons.video,
            size: 36,
            color: GlassTheme.textHintLight,
          ),
          const SizedBox(height: 16),
          const Text(
            'No videos yet',
            textAlign: TextAlign.center,
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
            'Videos will be added from Admin Panel.',
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
}

// =====================================================================
// VIDEO CARD — glass with thumbnail + duration
// =====================================================================
class _VideoCard extends StatelessWidget {
  final String title;
  final String description;
  final String thumbnailUrl;
  final String duration;
  final VoidCallback onTap;

  const _VideoCard({
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.duration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(21),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    thumbnailUrl.isNotEmpty
                        ? Image.network(
                            thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _fallback(),
                          )
                        : _fallback(),
                    // Duration badge
                    if (duration.isNotEmpty)
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            duration,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isEmpty ? 'Untitled' : title,
                    style: const TextStyle(
                      color: GlassTheme.textPrimaryLight,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      fontFamily: 'PlusJakartaSans',
                      fontFamilyFallback: ['HindSiliguri'],
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: GlassTheme.textTertiaryLight,
                        fontSize: 12.5,
                        height: 1.4,
                        fontFamily: 'PlusJakartaSans',
                        fontFamilyFallback: ['HindSiliguri'],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
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
          size: 28,
          color: Colors.white.withOpacity(0.45),
        ),
      ),
    );
  }
}

// =====================================================================
// SUBJECT POSTER CARD — iPhone-style
// =====================================================================
class _SubjectPosterCard extends StatelessWidget {
  final String name;
  final String nameEnglish;
  final String posterPath;
  final VoidCallback onTap;

  const _SubjectPosterCard({
    required this.name,
    required this.nameEnglish,
    required this.posterPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  posterPath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallbackPoster(name),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 90,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.45),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.85),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.95),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.arrowRight,
                      size: 13,
                      color: GlassTheme.accentRed,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                bottom: 16,
                right: 60,
                child: Text(
                  nameEnglish,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    fontFamily: 'PlusJakartaSans',
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackPoster(String name) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5B8DEF), Color(0xFF1E2A47)],
        ),
      ),
      child: Center(
        child: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: 'PlusJakartaSans',
            fontFamilyFallback: ['HindSiliguri'],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// PAGE HEADER
// =====================================================================
class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'All Subjects',
          style: TextStyle(
            color: GlassTheme.textPrimaryLight,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
            height: 1.15,
            fontFamily: 'PlusJakartaSans',
            fontFamilyFallback: ['HindSiliguri'],
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Choose a subject to start learning.',
          style: TextStyle(
            color: GlassTheme.textSecondaryLight,
            fontSize: 14,
            fontFamily: 'PlusJakartaSans',
            fontFamilyFallback: ['HindSiliguri'],
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// BACKGROUND
// =====================================================================
class _SubjectsBackground extends StatelessWidget {
  const _SubjectsBackground();

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