// lib/screens/search/search_screen.dart
//
// Real-time search screen for Madhyamik Shokha.
// Developer: Sibnath Bairagi

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../config/glass_theme.dart';

class SearchScreen extends StatefulWidget {
  static const String routeName = '/search';
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  String _query = '';
  bool _loading = true;
  List<Map<String, dynamic>> _allItems = [];

  StreamSubscription<DatabaseEvent>? _videosSub;
  StreamSubscription<DatabaseEvent>? _quizzesSub;

  @override
  void initState() {
    super.initState();
    _startListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _startListeners() {
    _videosSub = FirebaseDatabase.instance
        .ref('videos')
        .onValue
        .listen((event) {
      _mergeData('video', event.snapshot);
    }, onError: (_) {
      if (mounted) setState(() => _loading = false);
    });

    _quizzesSub = FirebaseDatabase.instance
        .ref('quizzes')
        .onValue
        .listen((event) {
      _mergeData('quiz', event.snapshot);
    }, onError: (_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  void _mergeData(String type, DataSnapshot snapshot) {
    final items = <Map<String, dynamic>>[];

    if (snapshot.exists && snapshot.value != null) {
      final raw = Map<String, dynamic>.from(snapshot.value as Map);
      raw.forEach((key, value) {
        if (value is! Map) return;
        final data = Map<String, dynamic>.from(value);
        items.add({
          'id': key,
          'title': (data['title'] ?? '').toString(),
          'subject': (data['subject'] ?? '').toString(),
          'chapter': (data['chapter'] ?? '').toString(),
          'type': type,
          'icon': type == 'quiz'
              ? FontAwesomeIcons.circleQuestion
              : FontAwesomeIcons.play,
        });
      });
    }

    if (!mounted) return;
    setState(() {
      _allItems.removeWhere((i) => i['type'] == type);
      _allItems.addAll(items);
      _loading = false;
    });
  }

  List<Map<String, dynamic>> get _results {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final results = <Map<String, dynamic>>[];
    for (final item in _allItems) {
      final title = (item['title'] ?? '').toString().toLowerCase();
      final subject = (item['subject'] ?? '').toString().toLowerCase();
      final chapter = (item['chapter'] ?? '').toString().toLowerCase();

      if (title.startsWith(q) ||
          subject.startsWith(q) ||
          chapter.startsWith(q) ||
          title.contains(q) ||
          subject.contains(q) ||
          chapter.contains(q)) {
        results.add(item);
      }
    }

    results.sort((a, b) {
      final aTitle = (a['title'] ?? '').toString().toLowerCase();
      final bTitle = (b['title'] ?? '').toString().toLowerCase();
      final aStart = aTitle.startsWith(q) ? 0 : 1;
      final bStart = bTitle.startsWith(q) ? 0 : 1;
      return aStart.compareTo(bStart);
    });

    return results;
  }

  @override
  void dispose() {
    _videosSub?.cancel();
    _quizzesSub?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlassTheme.backgroundLight,
      body: Stack(
        children: [
          const _SearchBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                const SizedBox(height: 8),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.black.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.arrowLeft,
                  size: 14,
                  color: GlassTheme.textPrimaryLight,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(
                        color: GlassTheme.textPrimaryLight,
                        fontSize: 15,
                        fontFamily: 'PlusJakartaSans',
                        fontFamilyFallback: ['HindSiliguri'],
                      ),
                      cursorColor: GlassTheme.accentRed,
                      decoration: const InputDecoration(
                        hintText: 'Search videos, quizzes...',
                        hintStyle: TextStyle(
                          color: GlassTheme.textHintLight,
                          fontSize: 14.5,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _controller.clear();
                        setState(() => _query = '');
                        _focusNode.requestFocus();
                      },
                      child: const FaIcon(
                        FontAwesomeIcons.circleXmark,
                        size: 16,
                        color: GlassTheme.textTertiaryLight,
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

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(GlassTheme.accentRed),
        ),
      );
    }

    if (_query.isEmpty) return _buildEmptyState();

    final results = _results;

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(
              FontAwesomeIcons.magnifyingGlass,
              size: 40,
              color: GlassTheme.textHintLight,
            ),
            const SizedBox(height: 16),
            Text(
              'No results for "$_query"',
              style: const TextStyle(
                color: GlassTheme.textSecondaryLight,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: 'PlusJakartaSans',
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
      physics: const BouncingScrollPhysics(),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _buildResultTile(results[i]),
    );
  }

  Widget _buildResultTile(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        final type = item['type'] as String;
        if (type == 'quiz') {
          Navigator.of(context).pushNamed('/quiz');
        } else {
          Navigator.of(context).pushNamed('/subjects');
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
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
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: GlassTheme.accentRed.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: FaIcon(
                  item['icon'] as IconData,
                  size: 15,
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
                    item['title'] as String,
                    style: const TextStyle(
                      color: GlassTheme.textPrimaryLight,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'PlusJakartaSans',
                      fontFamilyFallback: ['HindSiliguri'],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${item['subject']}  •  ${item['chapter']}',
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: GlassTheme.accentRed.withOpacity(0.08),
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.magnifyingGlass,
                size: 28,
                color: GlassTheme.accentRed,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Search anything',
            style: TextStyle(
              color: GlassTheme.textPrimaryLight,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'PlusJakartaSans',
              fontFamilyFallback: ['HindSiliguri'],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _allItems.isEmpty
                ? 'No videos uploaded yet'
                : '${_allItems.length} items available',
            style: const TextStyle(
              color: GlassTheme.textTertiaryLight,
              fontSize: 13.5,
              fontFamily: 'PlusJakartaSans',
              fontFamilyFallback: ['HindSiliguri'],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBackground extends StatelessWidget {
  const _SearchBackground();

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