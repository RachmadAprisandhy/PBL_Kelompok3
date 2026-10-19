class GradingModel {
  final String id;
  final String? userId;
  final String grade;
  final double confidence;
  final String imagePath;
  final String createdAt;
  final int isSynced;

  GradingModel({
    required this.id,
    this.userId,
    required this.grade,
    required this.confidence,
    required this.imagePath,
    required this.createdAt,
    this.isSynced = 0,
  });

  static Map<String, String> getGradeDetails(String grade) {
    switch (grade) {
      case 'Grade A':
        return {
          'title': 'Kualitas Utama (Supermarket)',
          'characteristics': 'Tampilan kulit relatif bersih, warna kuning merata, bentuk buah proporsional, dan kerusakan visual sangat minimal.',
          'recommendation': 'Direkomendasikan untuk distribusi dan penjualan ritel modern (supermarket) atau komoditas ekspor.',
        };
      case 'Grade B':
        return {
          'title': 'Kualitas Standar (Pasar Lokal)',
          'characteristics': 'Terdapat kekurangan atau bercak visual ringan pada kulit, namun daging buah masih dalam kondisi baik.',
          'recommendation': 'Direkomendasikan untuk penjualan di pasar tradisional atau konsumsi rumah tangga langsung.',
        };
      case 'Grade C':
      default:
        return {
          'title': 'Kualitas Olahan / Sortir Bawah',
          'characteristics': 'Terdapat cacat visual yang jelas, memar, bercak hitam pekat, atau kondisi terlalu matang/rusak.',
          'recommendation': 'Direkomendasikan untuk bahan olahan pangan (jika masih layak), pakan ternak, atau bahan kompos/pupuk organik.',
        };
    }
  }
}