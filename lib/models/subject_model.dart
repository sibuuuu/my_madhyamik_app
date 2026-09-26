// lib/models/subject_model.dart
//
// Subject model for Madhyamik Shokha.
// Developer: Sibnath Bairagi

class SubjectModel {
  final String id;
  final String name;          // Bengali name
  final String englishName;   // English name
  final String icon;          // Font Awesome icon name
  final String posterUrl;     // 16:9 landscape poster (ImgBB URL)
  final int order;
  final bool isActive;

  SubjectModel({
    required this.id,
    required this.name,
    this.englishName = '',
    this.icon = 'book',
    this.posterUrl = '',
    this.order = 0,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'englishName': englishName,
        'icon': icon,
        'posterUrl': posterUrl,
        'order': order,
        'isActive': isActive,
      };

  factory SubjectModel.fromMap(String id, Map<String, dynamic> map) {
    return SubjectModel(
      id: id,
      name: (map['name'] ?? '').toString(),
      englishName: (map['englishName'] ?? '').toString(),
      icon: (map['icon'] ?? 'book').toString(),
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