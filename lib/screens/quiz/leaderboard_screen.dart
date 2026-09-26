// lib/screens/quiz/leaderboard_screen.dart
//
// Weekly leaderboard — reads directly from Firebase.
// Developer: Sibnath Bairagi

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../config/glass_theme.dart';
import '../../services/firebase_service.dart';

class LeaderboardScreen extends StatefulWidget {
  static const String routeName = '/leaderboard';
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _myUid = '';

  @override
  void initState() {
    super.initState();
    _myUid = FirebaseService.currentUid ?? '';
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
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Leaderboard'),
      ),
      body: Stack(
        children: [
          const _LeaderboardBackground(),
          SafeArea(
            child: StreamBuilder<DatabaseEvent>(
              stream: FirebaseDatabase.instance
                  .ref('leaderboard/weekly')
                  .onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        GlassTheme.accentRed,
                      ),
                    ),
                  );
                }

                final entries = _extractEntries(snapshot);

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.fromLTRB(20, 12, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _PageHeader(),
                      const SizedBox(height: 22),
                      if (entries.isEmpty)
                        _buildEmpty()
                      else ...[
                        _buildTopThree(entries.take(3).toList()),
                        const SizedBox(height: 26),
                        _buildSectionTitle(
                            'Rankings', FontAwesomeIcons.listOl),
                        const SizedBox(height: 12),
                        ...List.generate(entries.length, (i) {
                          if (i < 3) return const SizedBox.shrink();
                          if (i >= 13) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _RankRow(
                              rank: i + 1,
                              entry: entries[i],
                              isMe: entries[i]['uid'] == _myUid,
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Reads the whole `leaderboard/weekly` node and picks the latest week.
  List<Map<String, dynamic>> _extractEntries(
      AsyncSnapshot<DatabaseEvent> snapshot) {
    if (!snapshot.hasData ||
        snapshot.data!.snapshot.value == null) {
      return const [];
    }

    final root =
        Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);

    // Find latest week key (e.g., "2026-W39")
    final weekKeys = root.keys.toList()..sort();
    if (weekKeys.isEmpty) return const [];

    final latestKey = weekKeys.last;
    final latestVal = root[latestKey];
    if (latestVal is! Map) return const [];

    final weekData = Map<String, dynamic>.from(latestVal);

    final entries = <Map<String, dynamic>>[];
    weekData.forEach((uid, value) {
      if (value is! Map) return;
      final data = Map<String, dynamic>.from(value);
      data['uid'] = uid;
      entries.add(data);
    });

    entries.sort((a, b) {
      final aS = _asInt(a['weeklyScore']);
      final bS = _asInt(b['weeklyScore']);
      return bS.compareTo(aS);
    });

    return entries;
  }

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Column(
        children: [
          FaIcon(
            FontAwesomeIcons.trophy,
            size: 40,
            color: GlassTheme.textHintLight,
          ),
          const SizedBox(height: 18),
          const Text(
            'No rankings yet',
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
            'Complete a quiz to appear here.',
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

  Widget _buildTopThree(List<Map<String, dynamic>> top3) {
    final second = top3.length > 1 ? top3[1] : null;
    final first = top3.isNotEmpty ? top3[0] : null;
    final third = top3.length > 2 ? top3[2] : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: second == null
              ? const SizedBox.shrink()
              : _PodiumSlot(
                  entry: second,
                  rank: 2,
                  height: 118,
                  accent: const Color(0xFFB8C0CC),
                ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: first == null
              ? const SizedBox.shrink()
              : _PodiumSlot(
                  entry: first,
                  rank: 1,
                  height: 150,
                  accent: const Color(0xFFE5B85C),
                ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: third == null
              ? const SizedBox.shrink()
              : _PodiumSlot(
                  entry: third,
                  rank: 3,
                  height: 104,
                  accent: const Color(0xFFD08A57),
                ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
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
      ],
    );
  }
}

// =====================================================================
// PODIUM SLOT
// =====================================================================
class _PodiumSlot extends StatelessWidget {
  final Map<String, dynamic> entry;
  final int rank;
  final double height;
  final Color accent;

  const _PodiumSlot({
    required this.entry,
    required this.rank,
    required this.height,
    required this.accent,
  });

  IconData get _medalIcon {
    switch (rank) {
      case 1:
        return FontAwesomeIcons.crown;
      case 2:
        return FontAwesomeIcons.medal;
      default:
        return FontAwesomeIcons.award;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name =
        (entry['name'] ?? entry['displayName'] ?? 'Student').toString();
    final score = entry['weeklyScore'] ?? 0;
    final photo = (entry['profileImageUrl'] ?? '').toString();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withOpacity(0.20),
            border: Border.all(
              color: accent.withOpacity(0.75),
              width: 1,
            ),
          ),
          child: Center(
            child: FaIcon(_medalIcon, size: 13, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: rank == 1 ? 62 : 54,
          width: rank == 1 ? 62 : 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: accent.withOpacity(0.85),
              width: rank == 1 ? 2 : 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: photo.isNotEmpty
                ? Image.network(
                    photo,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _initialsFallback(name, accent, rank),
                  )
                : _initialsFallback(name, accent, rank),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: GlassTheme.textPrimaryLight,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            fontFamily: 'PlusJakartaSans',
            fontFamilyFallback: ['HindSiliguri'],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$score',
          style: TextStyle(
            color: accent,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            fontFamily: 'PlusJakartaSans',
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.10),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(14),
            ),
            border: Border.all(
              color: accent.withOpacity(0.50),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                color: accent,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                fontFamily: 'PlusJakartaSans',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _initialsFallback(String name, Color color, int rank) {
    return Container(
      color: color.withOpacity(0.10),
      child: Center(
        child: Text(
          _initials(name),
          style: TextStyle(
            color: color,
            fontSize: rank == 1 ? 20 : 17,
            fontWeight: FontWeight.w700,
            fontFamily: 'PlusJakartaSans',
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'S';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

// =====================================================================
// RANK ROW
// =====================================================================
class _RankRow extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> entry;
  final bool isMe;

  const _RankRow({
    required this.rank,
    required this.entry,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final name =
        (entry['name'] ?? entry['displayName'] ?? 'Student').toString();
    final school = (entry['school'] ?? '').toString();
    final score = entry['weeklyScore'] ?? 0;
    final photo = (entry['profileImageUrl'] ?? '').toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? GlassTheme.accentRed.withOpacity(0.06)
            : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isMe
              ? GlassTheme.accentRed.withOpacity(0.40)
              : Colors.black.withOpacity(0.05),
          width: isMe ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: GlassTheme.accentRed.withOpacity(0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: GlassTheme.accentRed,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'PlusJakartaSans',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: GlassTheme.accentRed.withOpacity(0.08),
              border: Border.all(
                color: GlassTheme.accentRed.withOpacity(0.20),
                width: 1,
              ),
            ),
            child: ClipOval(
              child: photo.isNotEmpty
                  ? Image.network(
                      photo,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _initialsAvatar(name),
                    )
                  : _initialsAvatar(name),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
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
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: GlassTheme.accentRed,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            fontFamily: 'PlusJakartaSans',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (school.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    school,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: GlassTheme.textTertiaryLight,
                      fontSize: 11.5,
                      fontFamily: 'PlusJakartaSans',
                      fontFamilyFallback: ['HindSiliguri'],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '$score',
            style: const TextStyle(
              color: GlassTheme.textPrimaryLight,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              fontFamily: 'PlusJakartaSans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _initialsAvatar(String name) {
    return Container(
      color: GlassTheme.accentRed.withOpacity(0.08),
      child: Center(
        child: Text(
          _initials(name),
          style: const TextStyle(
            color: GlassTheme.accentRed,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            fontFamily: 'PlusJakartaSans',
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'S';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
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
      children: [
        const Text(
          'Leaderboard',
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
          'Top scorers this week.',
          style: TextStyle(
            color: GlassTheme.textSecondaryLight,
            fontSize: 14,
            fontFamily: 'PlusJakartaSans',
            fontFamilyFallback: const ['HindSiliguri'],
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// BACKGROUND
// =====================================================================
class _LeaderboardBackground extends StatelessWidget {
  const _LeaderboardBackground();

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
              child: _glow(const Color(0xFFE5B85C), 340),
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