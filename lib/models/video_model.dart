// lib/models/video_model.dart
//
// Video models for Madhyamik Shokha.

enum VideoSource { youtube, vimeo, directUrl, firebaseStorage }

extension VideoSourceX on VideoSource {
  String get value {
    switch (this) {
      case VideoSource.youtube:
        return 'youtube';
      case VideoSource.vimeo:
        return 'vimeo';
      case VideoSource.directUrl:
        return 'directUrl';
      case VideoSource.firebaseStorage:
        return 'firebaseStorage';
    }
  }

  static VideoSource fromValue(String? raw) {
    switch (raw) {
      case 'youtube':
        return VideoSource.youtube;
      case 'vimeo':
        return VideoSource.vimeo;
      case 'directUrl':
        return VideoSource.directUrl;
      case 'firebaseStorage':
        return VideoSource.firebaseStorage;
      default:
        return VideoSource.youtube;
    }
  }
}

// =====================================================================
// VIDEO MODEL
// =====================================================================
class VideoModel {
  final String videoId;
  final String title;
  final String subject;
  final String chapter;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final VideoSource source;
  final String duration;
  final int durationSeconds;
  final int orderIndex;
  final List<String> tags;
  final bool isPublished;
  final String language;
  final double sizeMb;
  final int likeCount;
  final int viewCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VideoModel({
    required this.videoId,
    required this.title,
    required this.subject,
    required this.chapter,
    this.description = '',
    this.thumbnailUrl = '',
    this.videoUrl = '',
    this.source = VideoSource.youtube,
    this.duration = '',
    this.durationSeconds = 0,
    this.orderIndex = 0,
    this.tags = const [],
    this.isPublished = true,
    this.language = '',
    this.sizeMb = 0,
    this.likeCount = 0,
    this.viewCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  double get aspectRatio => 16 / 9;

  bool get isPlayable => videoUrl.trim().isNotEmpty;

  int get durationMinutes {
    if (durationSeconds <= 0) return 0;
    return (durationSeconds / 60).ceil();
  }

  String get chapterLabel => chapter.trim().isEmpty ? 'General' : chapter;

  Map<String, dynamic> toMap() => {
        'videoId': videoId,
        'title': title,
        'subject': subject,
        'chapter': chapter,
        'description': description,
        'thumbnailUrl': thumbnailUrl,
        'videoUrl': videoUrl,
        'source': source.value,
        'duration': duration,
        'durationSeconds': durationSeconds,
        'orderIndex': orderIndex,
        'tags': tags,
        'isPublished': isPublished,
        'language': language,
        'sizeMb': sizeMb,
        'likeCount': likeCount,
        'viewCount': viewCount,
        'createdAt': createdAt?.millisecondsSinceEpoch,
        'updatedAt': updatedAt?.millisecondsSinceEpoch,
      };

  factory VideoModel.fromMap(Map<String, dynamic> map) {
    return VideoModel(
      videoId: (map['videoId'] ?? '') as String,
      title: (map['title'] ?? '') as String,
      subject: (map['subject'] ?? '') as String,
      chapter: (map['chapter'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      thumbnailUrl: (map['thumbnailUrl'] ?? '') as String,
      videoUrl: (map['videoUrl'] ?? '') as String,
      source: VideoSourceX.fromValue(map['source'] as String?),
      duration: (map['duration'] ?? '') as String,
      durationSeconds: _asInt(map['durationSeconds']),
      orderIndex: _asInt(map['orderIndex']),
      tags: _stringList(map['tags']),
      isPublished: (map['isPublished'] ?? true) as bool,
      language: (map['language'] ?? '') as String,
      sizeMb: _asDouble(map['sizeMb']),
      likeCount: _asInt(map['likeCount']),
      viewCount: _asInt(map['viewCount']),
      createdAt: _asDate(map['createdAt']),
      updatedAt: _asDate(map['updatedAt']),
    );
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _asDate(dynamic value) {
    if (value == null) return null;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    if (value is DateTime) return value;
    return null;
  }

  static List<String> _stringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value.map((e) => e.toString()).toList(growable: false);
    }
    return const [];
  }
}

// =====================================================================
// VIDEO CHAPTER
// =====================================================================
class VideoChapter {
  final String chapterId;
  final String subject;
  final String title;
  final String description;
  final int orderIndex;
  final List<String> videoIds;
  final bool isPublished;

  VideoChapter({
    required this.chapterId,
    required this.subject,
    required this.title,
    this.description = '',
    this.orderIndex = 0,
    this.videoIds = const [],
    this.isPublished = true,
  });

  int get videoCount => videoIds.length;

  Map<String, dynamic> toMap() => {
        'chapterId': chapterId,
        'subject': subject,
        'title': title,
        'description': description,
        'orderIndex': orderIndex,
        'videoIds': videoIds,
        'isPublished': isPublished,
      };

  factory VideoChapter.fromMap(Map<String, dynamic> map) {
    return VideoChapter(
      chapterId: (map['chapterId'] ?? '') as String,
      subject: (map['subject'] ?? '') as String,
      title: (map['title'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      orderIndex: VideoModel._asInt(map['orderIndex']),
      videoIds: VideoModel._stringList(map['videoIds']),
      isPublished: (map['isPublished'] ?? true) as bool,
    );
  }
}

// =====================================================================
// VIDEO PROGRESS
// =====================================================================
class VideoProgress {
  final String uid;
  final String videoId;
  final int watchedSeconds;
  final int durationSeconds;
  final bool isCompleted;
  final bool isBookmarked;
  final DateTime? lastWatchedAt;
  final DateTime? completedAt;

  VideoProgress({
    required this.uid,
    required this.videoId,
    this.watchedSeconds = 0,
    this.durationSeconds = 0,
    this.isCompleted = false,
    this.isBookmarked = false,
    this.lastWatchedAt,
    this.completedAt,
  });

  double get percentWatched {
    if (durationSeconds <= 0) return 0;
    final v = watchedSeconds / durationSeconds;
    if (v < 0) return 0;
    if (v > 1) return 1;
    return v;
  }

  int get percentWatchedRounded => (percentWatched * 100).round();

  bool get isInProgress => watchedSeconds > 0 && !isCompleted;

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'videoId': videoId,
        'watchedSeconds': watchedSeconds,
        'durationSeconds': durationSeconds,
        'isCompleted': isCompleted,
        'isBookmarked': isBookmarked,
        'lastWatchedAt': lastWatchedAt?.millisecondsSinceEpoch,
        'completedAt': completedAt?.millisecondsSinceEpoch,
      };

  factory VideoProgress.fromMap(Map<String, dynamic> map) {
    return VideoProgress(
      uid: (map['uid'] ?? '') as String,
      videoId: (map['videoId'] ?? '') as String,
      watchedSeconds: VideoModel._asInt(map['watchedSeconds']),
      durationSeconds: VideoModel._asInt(map['durationSeconds']),
      isCompleted: (map['isCompleted'] ?? false) as bool,
      isBookmarked: (map['isBookmarked'] ?? false) as bool,
      lastWatchedAt: VideoModel._asDate(map['lastWatchedAt']),
      completedAt: VideoModel._asDate(map['completedAt']),
    );
  }
}

// =====================================================================
// VIDEO COMMENT
// =====================================================================
class VideoComment {
  final String commentId;
  final String videoId;
  final String uid;
  final String userName;
  final String userPhoto;
  final String text;
  final int likeCount;
  final DateTime? createdAt;
  final DateTime? editedAt;

  VideoComment({
    required this.commentId,
    required this.videoId,
    required this.uid,
    required this.userName,
    this.userPhoto = '',
    required this.text,
    this.likeCount = 0,
    this.createdAt,
    this.editedAt,
  });

  bool get isEdited => editedAt != null;

  Map<String, dynamic> toMap() => {
        'commentId': commentId,
        'videoId': videoId,
        'uid': uid,
        'userName': userName,
        'userPhoto': userPhoto,
        'text': text,
        'likeCount': likeCount,
        'createdAt': createdAt?.millisecondsSinceEpoch,
        'editedAt': editedAt?.millisecondsSinceEpoch,
      };

  factory VideoComment.fromMap(Map<String, dynamic> map) {
    return VideoComment(
      commentId: (map['commentId'] ?? '') as String,
      videoId: (map['videoId'] ?? '') as String,
      uid: (map['uid'] ?? '') as String,
      userName: (map['userName'] ?? '') as String,
      userPhoto: (map['userPhoto'] ?? '') as String,
      text: (map['text'] ?? '') as String,
      likeCount: VideoModel._asInt(map['likeCount']),
      createdAt: VideoModel._asDate(map['createdAt']),
      editedAt: VideoModel._asDate(map['editedAt']),
    );
  }
}