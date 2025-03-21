import 'dart:ui';

class WordModel {
  final int id;
  final String word;
  final String description;
  final String imagePath;
  final String? videoPath;
  final String difficultyLevel;
  final bool isMostUsed;
  final int sectionId;
  final String? translation;
  final bool isCommonPhrase;

  WordModel({
    required this.id,
    required this.word,
    this.description = '',
    required this.imagePath,
    this.videoPath,
    this.difficultyLevel = 'beginner',
    this.isMostUsed = false,
    required this.sectionId,
    this.translation,
    this.isCommonPhrase = false,
  });

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      id: json['id'] ?? 0,
      word: json['word'] ?? 'Unknown',
      description: json['description'] ?? '',
      imagePath: json['image_path'] ?? 'assets/images/signs/default.png',
      videoPath: json['video_path'],
      difficultyLevel: json['difficulty_level'] ?? 'beginner',
      isMostUsed: json['is_most_used'] ?? false,
      sectionId: json['section_id'] ?? 0,
      translation: json['translation'],
      isCommonPhrase: json['is_common_phrase'] ?? false,
    );
  }

  // Helper method to get difficulty text in Arabic
  String get difficultyText {
    switch (difficultyLevel) {
      case 'beginner':
        return 'مبتدئ';
      case 'intermediate':
        return 'متوسط';
      case 'advanced':
        return 'متقدم';
      default:
        return 'مبتدئ';
    }
  }

  // Helper method to get difficulty color
  Color get difficultyColor {
    switch (difficultyLevel) {
      case 'beginner':
        return const Color(0xFFFCE8DD); // Light orange
      case 'intermediate':
        return const Color(0xFFD4F8E5); // Light green
      case 'advanced':
        return const Color(0xFFFFDDF4); // Light pink
      default:
        return const Color(0xFFFCE8DD); // Light orange
    }
  }
  
}
