// lib/services/firebase_service.dart
//
// Firebase service layer for Madhyamik Shokha.
// Uses Realtime Database + local cache.
// Developer: Sibnath Bairagi

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../config/cache_config.dart';
import '../models/user_model.dart';
import '../models/quiz_model.dart';
import '../models/video_model.dart';
import '../models/subject_model.dart';
import '../models/chapter_model.dart';
import 'cache_service.dart';

class DbPaths {
  DbPaths._();
  static const String users = 'users';
  static const String videos = 'videos';
  static const String quizzes = 'quizzes';
  static const String notices = 'notices';
  static const String attempts = 'attempts';
  static const String subjects = 'subjects';
  static const String chapters = 'chapters';
  static const String leaderboard = 'leaderboard';
  static const String weeklyLeaderboard = 'leaderboard/weekly';
}

class FirebaseService {
  FirebaseService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseDatabase _db = FirebaseDatabase.instance;

  // =====================================================================
  // AUTH
  // =====================================================================
  static Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_authError(e));
    } catch (_) {
      throw Exception('Could not create account.');
    }
  }

  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_authError(e));
    } catch (_) {
      throw Exception('Could not sign in.');
    }
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_authError(e));
    } catch (_) {
      throw Exception('Could not send reset email.');
    }
  }

  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {}
  }

  static User? get currentUser => _auth.currentUser;
  static String? get currentUid => _auth.currentUser?.uid;
  static bool get isSignedIn => _auth.currentUser != null;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // =====================================================================
  // USER PROFILE
  // =====================================================================
  static Future<void> saveUserProfile(UserModel user) async {
    try {
      await _db.ref('${DbPaths.users}/${user.uid}').update(user.toMap());
      await CacheService.saveJson(CacheService.userKey(user.uid), user.toMap());
    } catch (_) {
      throw Exception('Could not save profile.');
    }
  }

  static Future<void> createUserProfile(UserModel user) async {
    try {
      await _db.ref('${DbPaths.users}/${user.uid}').set(user.toMap());
      await CacheService.saveJson(CacheService.userKey(user.uid), user.toMap());
    } catch (_) {
      throw Exception('Could not create profile.');
    }
  }

  static Future<UserModel?> getUserProfile(
    String uid, {
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh) {
        final cached = CacheService.readJson(
          CacheService.userKey(uid),
          CacheConfig.userProfile,
        );
        if (cached is Map) {
          final data = Map<String, dynamic>.from(cached);
          data['uid'] = uid;
          return UserModel.fromMap(data);
        }
      }

      final snapshot = await _db.ref('${DbPaths.users}/$uid').get();
      if (!snapshot.exists || snapshot.value == null) return null;
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      data['uid'] = uid;

      await CacheService.saveJson(CacheService.userKey(uid), data);

      return UserModel.fromMap(data);
    } catch (_) {
      return null;
    }
  }

  // =====================================================================
  // WELCOME BONUS (safe - runs once per user)
  // =====================================================================
  static Future<int> giveWelcomeBonusIfNotGiven(String uid) async {
    try {
      final ref = _db.ref('${DbPaths.users}/$uid');
      final snapshot = await ref.get();
      if (!snapshot.exists || snapshot.value == null) return 0;

      final data = Map<String, dynamic>.from(snapshot.value as Map);

      if (data['welcomeBonusGiven'] == true) {
        return _asInt(data['coins']);
      }

      final currentCoins = _asInt(data['coins']);
      final newCoins = currentCoins + CacheConfig.welcomeBonusCoins;

      await ref.update({
        'coins': newCoins,
        'welcomeBonusGiven': true,
      });

      await CacheService.remove(CacheService.userKey(uid));

      return newCoins;
    } catch (_) {
      return 0;
    }
  }

  // =====================================================================
  // COINS
  // =====================================================================
  static Future<int> getCoins(String uid, {bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final cached = CacheService.readJson(
          CacheService.userKey(uid),
          CacheConfig.userProfile,
        );
        if (cached is Map) {
          return _asInt(cached['coins']);
        }
      }
      final snapshot = await _db.ref('${DbPaths.users}/$uid/coins').get();
      if (!snapshot.exists || snapshot.value == null) return 0;
      return _asInt(snapshot.value);
    } catch (_) {
      return 0;
    }
  }

  static Future<void> updateCoins(String uid, int newBalance) async {
    try {
      final safe = newBalance < 0 ? 0 : newBalance;
      await _db.ref('${DbPaths.users}/$uid').update({'coins': safe});
      await CacheService.remove(CacheService.userKey(uid));
    } catch (_) {}
  }

  // =====================================================================
  // AD TRACKING
  // =====================================================================
  static Future<bool> canWatchAdToday(String uid) async {
    try {
      final snapshot = await _db.ref('${DbPaths.users}/$uid').get();
      if (!snapshot.exists || snapshot.value == null) return true;

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final lastAdAt = _asInt(data['lastAdWatchedAt']);
      final watched = _asInt(data['adsWatchedToday']);

      if (lastAdAt > 0) {
        final lastDay = DateTime.fromMillisecondsSinceEpoch(lastAdAt);
        final now = DateTime.now();
        final isNewDay = lastDay.year != now.year ||
            lastDay.month != now.month ||
            lastDay.day != now.day;
        if (isNewDay) return true;
      }

      return watched < CacheConfig.maxAdsPerDay;
    } catch (_) {
      return true;
    }
  }

  static Future<int> trackAdWatched(String uid) async {
    try {
      final ref = _db.ref('${DbPaths.users}/$uid');
      final snapshot = await ref.get();
      if (!snapshot.exists || snapshot.value == null) return 0;

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final currentCoins = _asInt(data['coins']);
      final watchedToday = _asInt(data['adsWatchedToday']);
      final lastAdAt = _asInt(data['lastAdWatchedAt']);

      int newWatchedCount = watchedToday + 1;
      if (lastAdAt > 0) {
        final lastDay = DateTime.fromMillisecondsSinceEpoch(lastAdAt);
        final now = DateTime.now();
        final isNewDay = lastDay.year != now.year ||
            lastDay.month != now.month ||
            lastDay.day != now.day;
        if (isNewDay) newWatchedCount = 1;
      }

      if (newWatchedCount > CacheConfig.maxAdsPerDay) {
        return currentCoins;
      }

      final newCoins = currentCoins + CacheConfig.coinsPerAd;

      await ref.update({
        'coins': newCoins,
        'adsWatchedToday': newWatchedCount,
        'lastAdWatchedAt': DateTime.now().millisecondsSinceEpoch,
      });

      await CacheService.remove(CacheService.userKey(uid));
      return newCoins;
    } catch (_) {
      return 0;
    }
  }

  // =====================================================================
  // QUIZ ATTEMPTS + WEEKLY LEADERBOARD
  // =====================================================================
  static Future<void> saveAttempt(QuizAttempt attempt) async {
    try {
      final ref = _db.ref(DbPaths.attempts).push();
      final data = attempt.toMap();
      data['attemptId'] = ref.key;
      await ref.set(data);

      final uid = attempt.uid;
      final userRef = _db.ref('${DbPaths.users}/$uid');
      final snapshot = await userRef.get();
      if (snapshot.exists && snapshot.value != null) {
        final userData =
            Map<String, dynamic>.from(snapshot.value as Map);
        final oldScore = _asInt(userData['totalScore']);
        final oldBest = _asInt(userData['bestScore']);
        final oldTaken = _asInt(userData['totalQuizzesTaken']);

        await userRef.update({
          'totalScore': oldScore + attempt.score,
          'bestScore':
              attempt.score > oldBest ? attempt.score : oldBest,
          'totalQuizzesTaken': oldTaken + 1,
        });

        await _addToWeeklyLeaderboard(
          uid: uid,
          name: (userData['name'] ?? 'Student').toString(),
          school: (userData['school'] ?? '').toString(),
          photo: (userData['profileImageUrl'] ?? '').toString(),
          scoreToAdd: attempt.score,
        );

        await CacheService.remove(CacheService.userKey(uid));
      }
    } catch (_) {
      throw Exception('Could not save result.');
    }
  }

  static Future<void> _addToWeeklyLeaderboard({
    required String uid,
    required String name,
    required String school,
    required String photo,
    required int scoreToAdd,
  }) async {
    try {
      final weekId = CacheService.currentWeekId();
      final ref = _db.ref('${DbPaths.weeklyLeaderboard}/$weekId/$uid');

      final snap = await ref.get();
      final currentWeeklyScore =
          (snap.exists && snap.value is Map)
              ? _asInt((snap.value as Map)['weeklyScore'])
              : 0;

      await ref.update({
        'uid': uid,
        'name': name,
        'school': school,
        'profileImageUrl': photo,
        'weeklyScore': currentWeeklyScore + scoreToAdd,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      await CacheService.remove(
        CacheService.leaderboardKey(weekId),
      );
    } catch (_) {}
  }

  static Future<List<QuizAttempt>> fetchUserAttempts(String uid) async {
    try {
      final snapshot = await _db
          .ref(DbPaths.attempts)
          .orderByChild('uid')
          .equalTo(uid)
          .get();
      if (!snapshot.exists || snapshot.value == null) return const [];

      final raw = Map<String, dynamic>.from(snapshot.value as Map);
      final results = <QuizAttempt>[];
      raw.forEach((key, value) {
        if (value is! Map) return;
        final data = Map<String, dynamic>.from(value);
        data['attemptId'] = key;
        results.add(QuizAttempt.fromMap(data));
      });
      return results;
    } catch (_) {
      return const [];
    }
  }

  // =====================================================================
  // WEEKLY LEADERBOARD (fetch)
  // =====================================================================
    static Future<List<Map<String, dynamic>>> fetchWeeklyLeaderboard({
    bool forceRefresh = false,
  }) async {
    try {
      final weekId = CacheService.currentWeekId();
      final cacheKey = CacheService.leaderboardKey(weekId);

      if (!forceRefresh) {
        final cached = CacheService.readJson(
          cacheKey,
          CacheConfig.leaderboard,
        );
        if (cached is List && cached.isNotEmpty) {
          return cached
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }

      // Try current week
      var snapshot = await _db
          .ref('${DbPaths.weeklyLeaderboard}/$weekId')
          .get();

      // Fallback: read entire weekly node
      if (!snapshot.exists || snapshot.value == null) {
        snapshot =
            await _db.ref(DbPaths.weeklyLeaderboard).get();
      }

      if (!snapshot.exists || snapshot.value == null) return const [];

      // If the snapshot is the whole weekly node, grab the most recent week
      final raw = Map<String, dynamic>.from(snapshot.value as Map);

      Map<String, dynamic> weekData = raw;
      if (raw.containsKey(weekId) && raw[weekId] is Map) {
        weekData = Map<String, dynamic>.from(raw[weekId] as Map);
      } else {
        // Find the latest week key
        final weekKeys = raw.keys.toList()..sort();
        if (weekKeys.isNotEmpty) {
          final latest = weekKeys.last;
          final latestVal = raw[latest];
          if (latestVal is Map) {
            weekData = Map<String, dynamic>.from(latestVal);
          }
        }
      }

      final entries = <Map<String, dynamic>>[];
      weekData.forEach((key, value) {
        if (value is! Map) return;
        final data = Map<String, dynamic>.from(value);
        data['uid'] = key;
        entries.add(data);
      });

      if (entries.isEmpty) return const [];

      entries.sort((a, b) {
        final aS = _asInt(a['weeklyScore']);
        final bS = _asInt(b['weeklyScore']);
        return bS.compareTo(aS);
      });

      final result = _shuffleWithWeeklySeed(entries, weekId);

      await CacheService.saveJson(cacheKey, result);

      return result;
    } catch (e) {
      return const [];
    }
  }

  /// Shuffles entries 4..N using a deterministic weekly seed.
  static List<Map<String, dynamic>> _shuffleWithWeeklySeed(
    List<Map<String, dynamic>> entries,
    String weekId,
  ) {
    if (entries.length <= CacheConfig.topFixedCount) return entries;

    final fixed = entries.take(CacheConfig.topFixedCount).toList();
    final rest = entries.skip(CacheConfig.topFixedCount).toList();

    // Deterministic seed from weekId string
    int seed = 0;
    for (final c in weekId.codeUnits) {
      seed = (seed * 31 + c) & 0x7fffffff;
    }
    rest.shuffle(Random(seed));

    return [...fixed, ...rest];
  }

  static Future<int> fetchUserRankThisWeek(String uid) async {
    try {
      final weekId = CacheService.currentWeekId();
      final snapshot = await _db
          .ref('${DbPaths.weeklyLeaderboard}/$weekId')
          .orderByChild('weeklyScore')
          .get();
      if (!snapshot.exists || snapshot.value == null) return 0;

      final raw = Map<String, dynamic>.from(snapshot.value as Map);
      final entries = <MapEntry<String, int>>[];
      raw.forEach((key, value) {
        if (value is! Map) return;
        final score = _asInt((value as Map)['weeklyScore']);
        entries.add(MapEntry(key, score));
      });
      entries.sort((a, b) => b.value.compareTo(a.value));

      for (int i = 0; i < entries.length; i++) {
        if (entries[i].key == uid) return i + 1;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  // =====================================================================
  // SUBJECTS (with cache)
  // =====================================================================
  static Future<List<SubjectModel>> fetchSubjects({
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh) {
        final cached = CacheService.readJson(
          CacheConfig.keySubjects,
          CacheConfig.subjects,
        );
        if (cached is List) {
          final list = cached
              .whereType<Map>()
              .map((e) => SubjectModel.fromMap(
                    (e['id'] ?? '').toString(),
                    Map<String, dynamic>.from(e),
                  ))
              .where((s) => s.isActive)
              .toList();
          list.sort((a, b) => a.order.compareTo(b.order));
          return list;
        }
      }

      final snapshot = await _db.ref(DbPaths.subjects).get();
      if (!snapshot.exists || snapshot.value == null) return const [];

      final raw = Map<String, dynamic>.from(snapshot.value as Map);
      final list = <Map<String, dynamic>>[];
      raw.forEach((key, value) {
        if (value is! Map) return;
        final data = Map<String, dynamic>.from(value);
        data['id'] = key;
        list.add(data);
      });

      await CacheService.saveJson(CacheConfig.keySubjects, list);

      final results = list
          .map((e) => SubjectModel.fromMap(
                (e['id'] ?? '').toString(),
                e,
              ))
          .where((s) => s.isActive)
          .toList();
      results.sort((a, b) => a.order.compareTo(b.order));

      return results;
    } catch (_) {
      return const [];
    }
  }

  // =====================================================================
  // CHAPTERS (with cache)
  // =====================================================================
  static Future<List<ChapterModel>> fetchChapters(
    String subjectId, {
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = CacheService.chaptersKey(subjectId);

      if (!forceRefresh) {
        final cached = CacheService.readJson(
          cacheKey,
          CacheConfig.chapters,
        );
        if (cached is List) {
          final list = cached
              .whereType<Map>()
              .map((e) => ChapterModel.fromMap(
                    (e['id'] ?? '').toString(),
                    Map<String, dynamic>.from(e),
                  ))
              .where((c) => c.isActive)
              .toList();
          list.sort((a, b) => a.order.compareTo(b.order));
          return list;
        }
      }

      final snapshot = await _db
          .ref(DbPaths.chapters)
          .orderByChild('subjectId')
          .equalTo(subjectId)
          .get();

      if (!snapshot.exists || snapshot.value == null) return const [];

      final raw = Map<String, dynamic>.from(snapshot.value as Map);
      final list = <Map<String, dynamic>>[];
      raw.forEach((key, value) {
        if (value is! Map) return;
        final data = Map<String, dynamic>.from(value);
        data['id'] = key;
        list.add(data);
      });

      await CacheService.saveJson(cacheKey, list);

      final results = list
          .map((e) => ChapterModel.fromMap(
                (e['id'] ?? '').toString(),
                e,
              ))
          .where((c) => c.isActive)
          .toList();
      results.sort((a, b) => a.order.compareTo(b.order));

      return results;
    } catch (_) {
      return const [];
    }
  }

  // =====================================================================
  // VIDEOS (with cache)
  // =====================================================================
  static Future<List<VideoModel>> fetchVideosByChapter(
    String subjectId,
    String chapterId, {
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = CacheService.videosKey(chapterId);

      if (!forceRefresh) {
        final cached = CacheService.readJson(
          cacheKey,
          CacheConfig.videos,
        );
        if (cached is List) {
          final list = cached
              .whereType<Map>()
              .map((e) =>
                  VideoModel.fromMap(Map<String, dynamic>.from(e)))
              .where((v) => v.isPublished)
              .toList();
          list.sort(
              (a, b) => a.orderIndex.compareTo(b.orderIndex));
          return list;
        }
      }

      final snapshot = await _db
          .ref(DbPaths.videos)
          .orderByChild('chapterId')
          .equalTo(chapterId)
          .get();

      if (!snapshot.exists || snapshot.value == null) return const [];

      final raw = Map<String, dynamic>.from(snapshot.value as Map);
      final list = <Map<String, dynamic>>[];
      raw.forEach((key, value) {
        if (value is! Map) return;
        final data = Map<String, dynamic>.from(value);
        data['videoId'] = key;
        list.add(data);
      });

      await CacheService.saveJson(cacheKey, list);

      final results = list
          .map((e) => VideoModel.fromMap(e))
          .where((v) => v.isPublished)
          .toList();
      results.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

      return results;
    } catch (_) {
      return const [];
    }
  }

  // =====================================================================
  // QUIZZES (no cache - anti-cheat)
  // =====================================================================
  static Future<List<QuizModel>> fetchQuizzes({
    required String subject,
    String? chapter,
  }) async {
    try {
      final snapshot = await _db
          .ref(DbPaths.quizzes)
          .orderByChild('subject')
          .equalTo(subject)
          .get();

      if (!snapshot.exists || snapshot.value == null) return const [];

      final raw = Map<String, dynamic>.from(snapshot.value as Map);
      final results = <QuizModel>[];
      raw.forEach((key, value) {
        if (value is! Map) return;
        final data = Map<String, dynamic>.from(value);
        data['quizId'] = key;
        final quiz = QuizModel.fromMap(data);

        final matchChapter = chapter == null ||
            chapter.isEmpty ||
            quiz.chapter == chapter;

        if (matchChapter && quiz.isActive) {
          results.add(quiz);
        }
      });
      return results;
    } catch (_) {
      return const [];
    }
  }

  // =====================================================================
  // NOTICES (with cache)
  // =====================================================================
  static Future<List<Map<String, dynamic>>> fetchNotices({
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh) {
        final cached = CacheService.readJson(
          CacheConfig.keyNotices,
          CacheConfig.notices,
        );
        if (cached is List) {
          return cached
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }

      final snapshot = await _db.ref(DbPaths.notices).get();
      if (!snapshot.exists || snapshot.value == null) return const [];

      final raw = Map<String, dynamic>.from(snapshot.value as Map);
      final list = <Map<String, dynamic>>[];
      raw.forEach((key, value) {
        if (value is! Map) return;
        final data = Map<String, dynamic>.from(value);
        data['id'] = key;
        list.add(data);
      });

      list.sort((a, b) {
        final aT = _asInt(a['createdAt']);
        final bT = _asInt(b['createdAt']);
        return bT.compareTo(aT);
      });

      await CacheService.saveJson(CacheConfig.keyNotices, list);
      return list;
    } catch (_) {
      return const [];
    }
  }

  // =====================================================================
  // HELPERS
  // =====================================================================
  static String _authError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with that email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Check your internet connection.';
      default:
        return e.message ?? 'Something went wrong.';
    }
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}