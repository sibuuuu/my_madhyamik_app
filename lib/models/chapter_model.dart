// lib/models/chapter_model.dart
//
// Chapter model for Madhyamik Shokha.
// Developer: Sibnath Bairagi

class ChapterModel {
  final String id;
  final String subjectId;
  final String title;
  final String description;
  final String posterUrl;   // 16:9 landscape
  final int order;
  final bool isActive;

  ChapterModel({
    required this.id,
    required this.subjectId,
    required this.title,
    this.description = '',
    this.posterUrl = '',
    this.order = 0,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'subjectId': subjectId,
        'title': title,
        'description': description,
        'posterUrl': posterUrl,
        'order': order,
        'isActive': isActive,
      };

  factory ChapterModel.fromMap(String id, Map<String, dynamic> map) {
    return ChapterModel(
      id: id,
      subjectId: (map['subjectId'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      posterUrl: (map['posterUrl'] ?? '').toString(),
      order: _asInt(map['order']),
      isActive: (map['isActive'] ?? true) as bool,
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