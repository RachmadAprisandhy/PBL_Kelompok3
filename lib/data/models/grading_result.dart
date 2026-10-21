class GradingResult {
  const GradingResult({
    this.id,
    required this.imagePath,
    required this.grade,
    required this.confidence,
    required this.createdAt,
    required this.note,
  });

  final int? id;
  final String imagePath;
  final String grade;
  final double confidence;
  final DateTime createdAt;
  final String note;

  Map<String, Object?> toMap() => {
        'id': id,
        'imagePath': imagePath,
        'grade': grade,
        'confidence': confidence,
        'createdAt': createdAt.toIso8601String(),
        'note': note,
      };

  factory GradingResult.fromMap(Map<String, Object?> map) => GradingResult(
        id: map['id'] as int?,
        imagePath: map['imagePath'] as String,
        grade: map['grade'] as String,
        confidence: (map['confidence'] as num).toDouble(),
        createdAt: DateTime.parse(map['createdAt'] as String),
        note: map['note'] as String,
      );
}
