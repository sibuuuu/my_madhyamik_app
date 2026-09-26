// lib/models/user_model.dart
//
// User profile model for Madhyamik Shokha.
// Developer: Sibnath Bairagi

enum AuthProviderType { email, phone, emailAndPhone }

extension AuthProviderTypeX on AuthProviderType {
  String get value {
    switch (this) {
      case AuthProviderType.email:
        return 'email';
      case AuthProviderType.phone:
        return 'phone';
      case AuthProviderType.emailAndPhone:
        return 'emailAndPhone';
    }
  }

  static AuthProviderType fromValue(String? raw) {
    switch (raw) {
      case 'email':
        return AuthProviderType.email;
      case 'phone':
        return AuthProviderType.phone;
      case 'emailAndPhone':
        return AuthProviderType.emailAndPhone;
      default:
        return AuthProviderType.email;
    }
  }
}

class UserModel {
  final String uid;
  final String name;
  final String? email;
  final String? phone;
  final AuthProviderType authProvider;
  final String classLevel;
  final String school;
  final String district;
  final String board;
  final List<String> selectedSubjects;
  final String profileImageUrl;
  final int totalQuizzesTaken;
  final int totalScore;
  final int bestScore;
  final int currentStreakDays;
  final int coins;
  final bool welcomeBonusGiven;
  final int adsWatchedToday;
  final int lastAdWatchedAt;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final bool isProfileComplete;
  final String? fcmToken;

  UserModel({
    required this.uid,
    required this.name,
    this.email,
    this.phone,
    this.authProvider = AuthProviderType.email,
    this.classLevel = 'Class 10',
    this.school = '',
    this.district = '',
    this.board = 'WBBSE',
    this.selectedSubjects = const [],
    this.profileImageUrl = '',
    this.totalQuizzesTaken = 0,
    this.totalScore = 0,
    this.bestScore = 0,
    this.currentStreakDays = 0,
    this.coins = 0,
    this.welcomeBonusGiven = false,
    this.adsWatchedToday = 0,
    this.lastAdWatchedAt = 0,
    this.createdAt,
    this.lastLoginAt,
    this.isProfileComplete = false,
    this.fcmToken,
  });

  String get displayName {
    if (name.trim().isNotEmpty) return name.trim();
    if (email != null && email!.isNotEmpty) {
      return email!.split('@').first;
    }
    if (phone != null && phone!.isNotEmpty) return phone!;
    return 'Student';
  }

  String get initials {
    final source = displayName.trim();
    if (source.isEmpty) return 'S';
    final parts = source.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  double get averageScore {
    if (totalQuizzesTaken == 0) return 0;
    return totalScore / totalQuizzesTaken;
  }

  /// True if ads count should reset (a new day has started).
  bool get shouldResetAdsCount {
    if (lastAdWatchedAt <= 0) return false;
    final lastDay = DateTime.fromMillisecondsSinceEpoch(lastAdWatchedAt);
    final now = DateTime.now();
    return lastDay.year != now.year ||
        lastDay.month != now.month ||
        lastDay.day != now.day;
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'authProvider': authProvider.value,
      'classLevel': classLevel,
      'school': school,
      'district': district,
      'board': board,
      'selectedSubjects': selectedSubjects,
      'profileImageUrl': profileImageUrl,
      'totalQuizzesTaken': totalQuizzesTaken,
      'totalScore': totalScore,
      'bestScore': bestScore,
      'currentStreakDays': currentStreakDays,
      'coins': coins,
      'welcomeBonusGiven': welcomeBonusGiven,
      'adsWatchedToday': adsWatchedToday,
      'lastAdWatchedAt': lastAdWatchedAt,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt?.millisecondsSinceEpoch,
      'isProfileComplete': isProfileComplete,
      'fcmToken': fcmToken,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: (map['uid'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      authProvider:
          AuthProviderTypeX.fromValue(map['authProvider'] as String?),
      classLevel: (map['classLevel'] ?? 'Class 10') as String,
      school: (map['school'] ?? '') as String,
      district: (map['district'] ?? '') as String,
      board: (map['board'] ?? 'WBBSE') as String,
      selectedSubjects: _stringList(map['selectedSubjects']),
      profileImageUrl: (map['profileImageUrl'] ?? '') as String,
      totalQuizzesTaken: _asInt(map['totalQuizzesTaken']),
      totalScore: _asInt(map['totalScore']),
      bestScore: _asInt(map['bestScore']),
      currentStreakDays: _asInt(map['currentStreakDays']),
      coins: _asInt(map['coins']),
      welcomeBonusGiven: (map['welcomeBonusGiven'] ?? false) as bool,
      adsWatchedToday: _asInt(map['adsWatchedToday']),
      lastAdWatchedAt: _asInt(map['lastAdWatchedAt']),
      createdAt: _asDate(map['createdAt']),
      lastLoginAt: _asDate(map['lastLoginAt']),
      isProfileComplete: (map['isProfileComplete'] ?? false) as bool,
      fcmToken: map['fcmToken'] as String?,
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    AuthProviderType? authProvider,
    String? classLevel,
    String? school,
    String? district,
    String? board,
    List<String>? selectedSubjects,
    String? profileImageUrl,
    int? totalQuizzesTaken,
    int? totalScore,
    int? bestScore,
    int? currentStreakDays,
    int? coins,
    bool? welcomeBonusGiven,
    int? adsWatchedToday,
    int? lastAdWatchedAt,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isProfileComplete,
    String? fcmToken,
    bool clearEmail = false,
    bool clearPhone = false,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: clearEmail ? null : (email ?? this.email),
      phone: clearPhone ? null : (phone ?? this.phone),
      authProvider: authProvider ?? this.authProvider,
      classLevel: classLevel ?? this.classLevel,
      school: school ?? this.school,
      district: district ?? this.district,
      board: board ?? this.board,
      selectedSubjects: selectedSubjects ?? this.selectedSubjects,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      totalQuizzesTaken: totalQuizzesTaken ?? this.totalQuizzesTaken,
      totalScore: totalScore ?? this.totalScore,
      bestScore: bestScore ?? this.bestScore,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      coins: coins ?? this.coins,
      welcomeBonusGiven: welcomeBonusGiven ?? this.welcomeBonusGiven,
      adsWatchedToday: adsWatchedToday ?? this.adsWatchedToday,
      lastAdWatchedAt: lastAdWatchedAt ?? this.lastAdWatchedAt,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
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