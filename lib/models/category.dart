enum Level { beginner, intermediate, advanced }

class Category {
  final String id;
  final String cat;
  final Level level;

  Category({
    required this.id,
    required this.cat,
    required this.level,
  });

  // Convert JSON to Dart object
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      cat: json['cat'],
      level: _levelFromString(json['level']),
    );
  }

  // Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'cat': cat,
      'level': level.name,
    };
  }

  // Helper to convert string to enum
  static Level _levelFromString(String level) {
    switch (level) {
      case 'beginner':
        return Level.beginner;
      case 'intermediate':
        return Level.intermediate;
      case 'advanced':
        return Level.advanced;
      default:
        throw Exception('Unknown level: $level');
    }
  }
}
