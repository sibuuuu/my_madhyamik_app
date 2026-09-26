// lib/models/quiz_model.dart
//
// Quiz models for Madhyamik Shokha.

class QuizQuestion {
  final String questionId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final int marks;
  final String topic;
  final String difficulty;

  QuizQuestion({
    this.questionId = '',
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.marks = 1,
    this.topic = '',
    this.difficulty = 'medium',
  });

  String get correctAnswer {
    if (correctIndex < 0 || correctIndex >= options.length) return '';
    return options[correctIndex];
  }

  bool isCorrect(int index) => index == correctIndex;

  Map<String, dynamic> toMap() => {
        'questionId': questionId,
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
        'marks': marks,
        'topic': topic,
        'difficulty': difficulty,
      };

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      questionId: (map['questionId'] ?? '') as String,
      question: (map['question'] ?? '') as String,
      options: _stringList(map['options']),
      correctIndex: _asInt(map['correctIndex']),
      explanation: (map['explanation'] ?? '') as String,
      marks: _asInt(map['marks'], fallback: 1),
      topic: (map['topic'] ?? '') as String,
      difficulty: (map['difficulty'] ?? 'medium') as String,
    );
  }

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static List<String> _stringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value.map((e) => e.toString()).toList(growable: false);
    }
    return const [];
  }
}

class QuizModel {
  final String quizId;
  final String subject;
  final String chapter;
  final String chapterTitle;
  final List<QuizQuestion> questions;
  final int durationMinutes;
  final bool isActive;
  final int orderIndex;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  QuizModel({
    required this.quizId,
    required this.subject,
    required this.chapter,
    this.chapterTitle = '',
    this.questions = const [],
    this.durationMinutes = 0,
    this.isActive = true,
    this.orderIndex = 0,
    this.createdAt,
    this.updatedAt,
  });

  int get questionCount => questions.length;

  int get totalMarks =>
      questions.fold<int>(0, (sum, q) => sum + (q.marks <= 0 ? 1 : q.marks));

  bool get isEmpty => questions.isEmpty;

  Map<String, dynamic> toMap() => {
        'quizId': quizId,
        'subject': subject,
        'chapter': chapter,
        'chapterTitle': chapterTitle,
        'questions': questions.map((q) => q.toMap()).toList(),
        'durationMinutes': durationMinutes,
        'isActive': isActive,
        'orderIndex': orderIndex,
        'createdAt': createdAt?.millisecondsSinceEpoch,
        'updatedAt': updatedAt?.millisecondsSinceEpoch,
      };

  factory QuizModel.fromMap(Map<String, dynamic> map) {
    return QuizModel(
      quizId: (map['quizId'] ?? '') as String,
      subject: (map['subject'] ?? '') as String,
      chapter: (map['chapter'] ?? '') as String,
      chapterTitle: (map['chapterTitle'] ?? '') as String,
      questions: _questionList(map['questions']),
      durationMinutes: _asInt(map['durationMinutes']),
      isActive: (map['isActive'] ?? true) as bool,
      orderIndex: _asInt(map['orderIndex']),
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

  static DateTime? _asDate(dynamic value) {
    if (value == null) return null;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    if (value is DateTime) return value;
    return null;
  }

  static List<QuizQuestion> _questionList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value
          .whereType<Map>()
          .map((e) => QuizQuestion.fromMap(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    }
    return const [];
  }
}

class QuizAttempt {
  final String attemptId;
  final String uid;
  final String studentName;
  final String school;
  final String quizId;
  final String subject;
  final String chapter;
  final int score;
  final int totalMarks;
  final int correctCount;
  final int wrongCount;
  final int skippedCount;
  final Map<String, int> answers;
  final List<String> questionOrder;
  final int timeSpentSeconds;
  final DateTime? startedAt;
  final DateTime? submittedAt;

  QuizAttempt({
    required this.attemptId,
    required this.uid,
    this.studentName = '',
    this.school = '',
    required this.quizId,
    required this.subject,
    required this.chapter,
    required this.score,
    required this.totalMarks,
    required this.correctCount,
    required this.wrongCount,
    this.skippedCount = 0,
    this.answers = const {},
    this.questionOrder = const [],
    this.timeSpentSeconds = 0,
    this.startedAt,
    this.submittedAt,
  });

  int get percent {
    if (totalMarks <= 0) return 0;
    return ((score / totalMarks) * 100).round();
  }

  bool get isPassed => percent >= 60;

  Map<String, dynamic> toMap() => {
        'attemptId': attemptId,
        'uid': uid,
        'studentName': studentName,
        'school': school,
        'quizId': quizId,
        'subject': subject,
        'chapter': chapter,
        'score': score,
        'totalMarks': totalMarks,
        'correctCount': correctCount,
        'wrongCount': wrongCount,
        'skippedCount': skippedCount,
        'answers': answers,
        'questionOrder': questionOrder,
        'timeSpentSeconds': timeSpentSeconds,
        'startedAt': startedAt?.millisecondsSinceEpoch,
        'submittedAt': submittedAt?.millisecondsSinceEpoch,
      };

  factory QuizAttempt.fromMap(Map<String, dynamic> map) {
    return QuizAttempt(
      attemptId: (map['attemptId'] ?? '') as String,
      uid: (map['uid'] ?? '') as String,
      studentName: (map['studentName'] ?? '') as String,
      school: (map['school'] ?? '') as String,
      quizId: (map['quizId'] ?? '') as String,
      subject: (map['subject'] ?? '') as String,
      chapter: (map['chapter'] ?? '') as String,
      score: _asInt(map['score']),
      totalMarks: _asInt(map['totalMarks']),
      correctCount: _asInt(map['correctCount']),
      wrongCount: _asInt(map['wrongCount']),
      skippedCount: _asInt(map['skippedCount']),
      answers: _intMap(map['answers']),
      questionOrder: _stringList(map['questionOrder']),
      timeSpentSeconds: _asInt(map['timeSpentSeconds']),
      startedAt: _asDate(map['startedAt']),
      submittedAt: _asDate(map['submittedAt']),
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

  static Map<String, int> _intMap(dynamic value) {
    if (value == null) return const {};
    if (value is Map) {
      final out = <String, int>{};
      value.forEach((k, v) {
        final key = k.toString();
        if (v is int) {
          out[key] = v;
        } else if (v is double) {
          out[key] = v.toInt();
        } else if (v is String) {
          out[key] = int.tryParse(v) ?? 0;
        }
      });
      return out;
    }
    return const {};
  }
}