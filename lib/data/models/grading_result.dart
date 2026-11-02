class GradingResult {
  final String id;
  final String imagePath;
  final String ripenessLevel;
  final double confidence;
  final DateTime createdAt;
  final String note;

  GradingResult({
    required this.id,
    required this.imagePath,
    required this.ripenessLevel,
    required this.confidence,
    required this.createdAt,
    this.note = '',
  });

  // Konversi ke Map jika menggunakan penyimpanan lokal (seperti SQLite/Hive/JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'grade': ripenessLevel,
      'confidence': confidence,
      'createdAt': createdAt.toIso8601String(),
      'note': note,
    };
  }

  factory GradingResult.fromMap(Map<String, dynamic> map) {
    return GradingResult(
      id: map['id']?.toString() ?? '',
      imagePath: map['imagePath'] ?? '',
      ripenessLevel: map['ripenessLevel'] ?? map['grade'] ?? '',
      confidence: map['confidence']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(map['createdAt']),
      note: map['note'] ?? '',
    );
  }
}
