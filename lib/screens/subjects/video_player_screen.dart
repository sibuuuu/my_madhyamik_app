// lib/screens/subjects/video_player_screen.dart
//
// YouTube player - no zoom, YouTube's own controls work.
// Only logo/channel-name taps blocked + custom fullscreen.
// Developer: Sibnath Bairagi

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../config/glass_theme.dart';

class VideoPlayerScreen extends StatefulWidget {
  static const String routeName = '/video-player';

  final String videoId;
  final String title;
  final String subject;
  final String chapter;
  final String description;
  final String youtubeId;
  final String thumbnailUrl;

  const VideoPlayerScreen({
    super.key,
    this.videoId = '',
    this.title = '',
    this.subject = '',
    this.chapter = '',
    this.description = '',
    this.youtubeId = '',
    this.thumbnailUrl = '',
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final String _cleanId;
  YoutubePlayerController? _controller;
  StreamSubscription<YoutubePlayerValue>? _sub;
  Timer? _ticker;

  bool _isPlaying = false;
  bool _isFullscreen = false;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _cleanId = _extractYoutubeId(widget.youtubeId);
    if (_cleanId.isEmpty) return;

    try {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: _cleanId,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showControls: true, // YouTube controls enabled
          showFullscreenButton: false, // Hide YT's fullscreen (it goes to YT)
          enableCaption: false,
          strictRelatedVideos: true,
          showVideoAnnotations: false,
          playsInline: true,
        ),
      );

      _sub = _controller!.stream.listen(_onPlayerValue);

      _ticker = Timer.periodic(const Duration(milliseconds: 500), (_) {
        _refreshPosition();
      });
    } catch (_) {
      _controller = null;
    }
  }

  void _onPlayerValue(YoutubePlayerValue value) {
    if (!mounted) return;
    final playing = value.playerState == PlayerState.playing;
    final dur = value.metaData.duration;
    setState(() {
      _isPlaying = playing;
      if (dur > Duration.zero) _duration = dur;
    });
  }

  Future<void> _refreshPosition() async {
    if (!mounted || _controller == null) return;
    try {
      final seconds = await _controller!.currentTime;
      if (seconds == null || !mounted) return;
      setState(() {
        _position = Duration(milliseconds: (seconds * 1000).round());
      });
    } catch (_) {}
  }

  static String _extractYoutubeId(String input) {
    final value = input.trim();
    if (value.isEmpty) return '';
    if (!value.contains('/') && !value.contains('?')) return value;
    final patterns = <RegExp>[
      RegExp(r'youtube\.com/watch\?v=([\w\-]{11})'),
      RegExp(r'youtu\.be/([\w\-]{11})'),
      RegExp(r'youtube\.com/embed/([\w\-]{11})'),
      RegExp(r'youtube\.com/shorts/([\w\-]{11})'),
      RegExp(r'youtube\.com/live/([\w\-]{11})'),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(value);
      if (m != null) return m.group(1) ?? '';
    }
    final fallback = RegExp(r'([\w\-]{11})').firstMatch(value);
    return fallback?.group(1) ?? '';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _sub?.cancel();
    _controller?.close();
    if (_isFullscreen && !kIsWeb) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }

  Future<void> _toggleFullscreen() async {
    if (kIsWeb) {
      setState(() => _isFullscreen = !_isFullscreen);
      return;
    }
    if (_isFullscreen) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      if (mounted) setState(() => _isFullscreen = false);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
      );
      if (mounted) setState(() => _isFullscreen = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || _cleanId.isEmpty) {
      return _buildErrorScreen();
    }

    if (_isFullscreen) {
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          await _toggleFullscreen();
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned.fill(
                child: _buildPlayer(),
              ),
              // Custom fullscreen button (top-right)
              Positioned(
                top: 12,
                right: 12,
                child: SafeArea(
                  child: _fullscreenButton(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: GlassTheme.backgroundLight,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _buildPlayer(),
              ),
              Expanded(child: _buildBelowPlayer()),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================================
  // PLAYER — no zoom, YouTube controls work, only logo/channel blocked
  // =====================================================================
  Widget _buildPlayer() {
    return Container(
      decoration: const BoxDecoration(color: Colors.black),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // YouTube player - touches allowed (their controls work)
          Positioned.fill(
            child: YoutubePlayer(
              controller: _controller!,
              aspectRatio: 16 / 9,
            ),
          ),

          // Block top area — channel name / title (tap usually opens YouTube)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 55,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              onDoubleTap: () {},
              onLongPress: () {},
            ),
          ),

          // Block bottom-right corner — YouTube logo + YT's fullscreen button
          Positioned(
            right: 0,
            bottom: 0,
            width: 130,
            height: 50,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              onDoubleTap: () {},
              onLongPress: () {},
            ),
          ),

          // Custom fullscreen button (top-right corner)
          Positioned(
            top: 10,
            right: 10,
            child: _fullscreenButton(),
          ),
        ],
      ),
    );
  }

  Widget _fullscreenButton() {
    return GestureDetector(
      onTap: _toggleFullscreen,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.30),
            width: 1,
          ),
        ),
        child: Center(
          child: FaIcon(
            _isFullscreen
                ? FontAwesomeIcons.compress
                : FontAwesomeIcons.expand,
            size: 13,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _fmtTime(Duration d) {
    if (d.inSeconds <= 0) return '0:00';
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  // =====================================================================
  // TOP BAR
  // =====================================================================
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
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
            child: Text(
              widget.subject.isEmpty ? 'Video' : widget.subject,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: GlassTheme.textPrimaryLight,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'PlusJakartaSans',
                fontFamilyFallback: ['HindSiliguri'],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // BELOW PLAYER — info + recommended list
  // =====================================================================
  Widget _buildBelowPlayer() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title.isEmpty ? 'Untitled' : widget.title,
            style: const TextStyle(
              color: GlassTheme.textPrimaryLight,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              height: 1.3,
              fontFamily: 'PlusJakartaSans',
              fontFamilyFallback: ['HindSiliguri'],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (widget.subject.isNotEmpty)
                _metaChip(FontAwesomeIcons.book, widget.subject),
              if (widget.chapter.isNotEmpty) ...[
                const SizedBox(width: 8),
                _metaChip(
                  FontAwesomeIcons.layerGroup,
                  widget.chapter,
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          if (widget.description.isNotEmpty)
            Container(
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
                  const Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.circleInfo,
                        size: 12,
                        color: GlassTheme.accentRed,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'About this lesson',
                        style: TextStyle(
                          color: GlassTheme.textPrimaryLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'PlusJakartaSans',
                          fontFamilyFallback: ['HindSiliguri'],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.description,
                    style: const TextStyle(
                      color: GlassTheme.textSecondaryLight,
                      fontSize: 13.5,
                      height: 1.6,
                      fontFamily: 'PlusJakartaSans',
                      fontFamilyFallback: ['HindSiliguri'],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          const Row(
            children: [
              FaIcon(
                FontAwesomeIcons.listUl,
                size: 12,
                color: GlassTheme.accentRed,
              ),
              SizedBox(width: 10),
              Text(
                'Up Next',
                style: TextStyle(
                  color: GlassTheme.textPrimaryLight,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  fontFamily: 'PlusJakartaSans',
                  fontFamilyFallback: ['HindSiliguri'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildRecommendedList(),
        ],
      ),
    );
  }

  Widget _buildRecommendedList() {
    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance.ref('videos').onValue,
      builder: (context, snapshot) {
        final items = <Map<String, dynamic>>[];

        if (snapshot.hasData &&
            snapshot.data!.snapshot.exists &&
            snapshot.data!.snapshot.value != null) {
          final raw = Map<String, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );
          raw.forEach((key, value) {
            if (value is! Map) return;
            if (key == widget.videoId) return;
            if (value['isPublished'] == false) return;
            final data = Map<String, dynamic>.from(value);
            data['videoId'] = key;
            items.add(data);
          });
        }

        if (items.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(
              vertical: 30,
              horizontal: 20,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.black.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                FaIcon(
                  FontAwesomeIcons.video,
                  size: 22,
                  color: GlassTheme.textHintLight,
                ),
                const SizedBox(height: 10),
                const Text(
                  'No more videos',
                  style: TextStyle(
                    color: GlassTheme.textTertiaryLight,
                    fontSize: 12.5,
                    fontFamily: 'PlusJakartaSans',
                    fontFamilyFallback: ['HindSiliguri'],
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: items
              .take(10)
              .map(
                (v) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RecommendedTile(
                    title: (v['title'] ?? 'Untitled').toString(),
                    subject: (v['subject'] ?? '').toString(),
                    duration: (v['duration'] ?? '').toString(),
                    thumbnailUrl:
                        (v['thumbnailUrl'] ?? '').toString(),
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerScreen(
                            videoId: (v['videoId'] ?? '').toString(),
                            title: (v['title'] ?? '').toString(),
                            subject: (v['subject'] ?? '').toString(),
                            chapter: (v['chapter'] ?? '').toString(),
                            description:
                                (v['description'] ?? '').toString(),
                            youtubeId:
                                (v['youtubeId'] ?? '').toString(),
                            thumbnailUrl:
                                (v['thumbnailUrl'] ?? '').toString(),
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
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: GlassTheme.accentRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 10, color: GlassTheme.accentRed),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: GlassTheme.accentRed,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              fontFamily: 'PlusJakartaSans',
              fontFamilyFallback: ['HindSiliguri'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: GlassTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.triangleExclamation,
                        size: 32,
                        color: Colors.white70,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Video unavailable',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// RECOMMENDED VIDEO TILE
// =====================================================================
class _RecommendedTile extends StatelessWidget {
  final String title;
  final String subject;
  final String duration;
  final String thumbnailUrl;
  final VoidCallback onTap;

  const _RecommendedTile({
    required this.title,
    required this.subject,
    required this.duration,
    required this.thumbnailUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 68,
                width: 110,
                child: thumbnailUrl.isNotEmpty
                    ? Image.network(
                        thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallback(),
                      )
                    : _fallback(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: GlassTheme.textPrimaryLight,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                      letterSpacing: -0.2,
                      fontFamily: 'PlusJakartaSans',
                      fontFamilyFallback: ['HindSiliguri'],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (subject.isNotEmpty) ...[
                        Text(
                          subject,
                          style: const TextStyle(
                            color: GlassTheme.textTertiaryLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'PlusJakartaSans',
                            fontFamilyFallback: ['HindSiliguri'],
                          ),
                        ),
                        if (duration.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            height: 3,
                            width: 3,
                            decoration: const BoxDecoration(
                              color: GlassTheme.textHintLight,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                      if (duration.isNotEmpty)
                        Text(
                          duration,
                          style: const TextStyle(
                            color: GlassTheme.textTertiaryLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'PlusJakartaSans',
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const FaIcon(
              FontAwesomeIcons.circlePlay,
              size: 16,
              color: GlassTheme.accentRed,
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
          size: 18,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}