// lib/screens/notice/notice_screen.dart
//
// Notice board — Firebase-driven, light theme.
// Developer: Sibnath Bairagi

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../config/glass_theme.dart';

class NoticeScreen extends StatefulWidget {
  static const String routeName = '/notice';
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  String _activeFilter = 'All';

  static const List<String> _filters = [
    'All',
    'Exam',
    'Class',
    'General',
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
        title: const Text('Notices'),
      ),
      body: Stack(
        children: [
          const _NoticeBackground(),
          SafeArea(
            child: StreamBuilder<DatabaseEvent>(
              stream: FirebaseDatabase.instance.ref('notices').onValue,
              builder: (context, snapshot) {
                final all = <Map<String, dynamic>>[];

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
                    all.add(data);
                  });
                }

                // Sort: pinned first, then by createdAt desc
                all.sort((a, b) {
                  final aPin = (a['isPinned'] ?? false) == true;
                  final bPin = (b['isPinned'] ?? false) == true;
                  if (aPin != bPin) return aPin ? -1 : 1;
                  final aT = _asInt(a['createdAt']);
                  final bT = _asInt(b['createdAt']);
                  return bT.compareTo(aT);
                });

                // Apply filter
                final filtered = _activeFilter == 'All'
                    ? all
                    : all.where((n) {
                        final cat =
                            (n['category'] ?? '').toString().toLowerCase();
                        return cat == _activeFilter.toLowerCase();
                      }).toList();

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Notice Board',
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
                      const SizedBox(height: 18),
                      _buildFilterChips(),
                      const SizedBox(height: 18),
                      if (filtered.isEmpty)
                        _buildEmptyState()
                      else
                        ...filtered.map(
                          (n) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: 12),
                            child: _NoticeCard(notice: n),
                          ),
                        ),
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

  Widget _buildFilterChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = _filters[i];
          final selected = f == _activeFilter;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = f),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? GlassTheme.accentRed
                    : Colors.white,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: selected
                      ? GlassTheme.accentRed
                      : Colors.black.withOpacity(0.06),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  f,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : GlassTheme.textPrimaryLight,
                    fontSize: 12.5,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    fontFamily: 'PlusJakartaSans',
                    fontFamilyFallback: const ['HindSiliguri'],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Column(
        children: [
          FaIcon(
            FontAwesomeIcons.bullhorn,
            size: 40,
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
          const Text(
            'Notices will appear here soon.',
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

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}

// =====================================================================
// NOTICE CARD
// =====================================================================
class _NoticeCard extends StatefulWidget {
  final Map<String, dynamic> notice;

  const _NoticeCard({required this.notice});

  @override
  State<_NoticeCard> createState() => _NoticeCardState();
}

class _NoticeCardState extends State<_NoticeCard> {
  bool _expanded = false;

  String get _category {
    final c = (widget.notice['category'] ?? 'general').toString();
    return c.isEmpty ? 'general' : c;
  }

  bool get _isPinned => (widget.notice['isPinned'] ?? false) == true;

  IconData get _icon {
    switch (_category.toLowerCase()) {
      case 'exam':
        return FontAwesomeIcons.fileLines;
      case 'class':
        return FontAwesomeIcons.bookOpen;
      default:
        return FontAwesomeIcons.circleInfo;
    }
  }

  Color get _accent {
    switch (_category.toLowerCase()) {
      case 'exam':
        return GlassTheme.accentRed;
      case 'class':
        return GlassTheme.accentBlue;
      default:
        return GlassTheme.accentAmber;
    }
  }

  String get _label {
    switch (_category.toLowerCase()) {
      case 'exam':
        return 'EXAM';
      case 'class':
        return 'CLASS';
      default:
        return 'GENERAL';
    }
  }

  String _formatDate(int ms) {
    if (ms <= 0) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) return 'Just now';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.notice;
    final title = (n['title'] ?? '').toString();
    final body = (n['body'] ?? '').toString();
    final createdAt = NoticeScreenStatic.asInt(n['createdAt']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isPinned
              ? _accent.withOpacity(0.40)
              : Colors.black.withOpacity(0.05),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isPinned)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.thumbtack,
                    size: 10,
                    color: _accent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'PINNED',
                    style: TextStyle(
                      color: _accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: _accent.withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: FaIcon(
                    _icon,
                    size: 14,
                    color: _accent,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _label,
                            style: TextStyle(
                              color: _accent,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (createdAt > 0)
                          Text(
                            _formatDate(createdAt),
                            style: const TextStyle(
                              color: GlassTheme.textHintLight,
                              fontSize: 10.5,
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title.isEmpty ? 'Notice' : title,
                      style: const TextStyle(
                        color: GlassTheme.textPrimaryLight,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        fontFamily: 'PlusJakartaSans',
                        fontFamilyFallback: ['HindSiliguri'],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: Text(
              body,
              maxLines: _expanded ? null : 3,
              overflow: _expanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: const TextStyle(
                color: GlassTheme.textSecondaryLight,
                fontSize: 13,
                height: 1.55,
                fontFamily: 'PlusJakartaSans',
                fontFamilyFallback: ['HindSiliguri'],
              ),
            ),
          ),
          if (body.length > 120) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _expanded ? 'Less' : 'Read more',
                    style: const TextStyle(
                      color: GlassTheme.accentRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                  const SizedBox(width: 4),
                  FaIcon(
                    _expanded
                        ? FontAwesomeIcons.chevronUp
                        : FontAwesomeIcons.chevronDown,
                    size: 10,
                    color: GlassTheme.accentRed,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Helper class so NoticeScreen static method can be called from _NoticeCard
class NoticeScreenStatic {
  static int asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}

// =====================================================================
// BACKGROUND
// =====================================================================
class _NoticeBackground extends StatelessWidget {
  const _NoticeBackground();

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