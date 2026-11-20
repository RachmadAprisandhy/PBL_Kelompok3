import 'package:flutter_test/flutter_test.dart';

// Fungsi helper menghitung total riwayat pemindaian dan rata-rata akurasi
Map<String, dynamic> calculateHistoryStatistics(List<double> confidenceList) {
  if (confidenceList.isEmpty) {
    return {'total': 0, 'averageConfidence': 0.0};
  }
  
  double sum = confidenceList.reduce((a, b) => a + b);
  double average = sum / confidenceList.length;

  return {
    'total': confidenceList.length,
    'averageConfidence': double.parse(average.toStringAsFixed(2)),
  };
}

void main() {
  group('Unit Test - Kalkulasi Statistik Riwayat Pemindaian', () {
    test('Harus menghitung total dan rata-rata akurasi dengan benar', () {
      List<double> mockScores = [85.0, 90.0, 95.0];
      var stats = calculateHistoryStatistics(mockScores);

      expect(stats['total'], 3);
      expect(stats['averageConfidence'], 90.0);
    });

    test('Harus mengembalikan nilai 0 jika list riwayat kosong', () {
      List<double> mockScores = [];
      var stats = calculateHistoryStatistics(mockScores);

      expect(stats['total'], 0);
      expect(stats['averageConfidence'], 0.0);
    });
  });
}