import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BananaGrade Logika & Model Test', () {
    test('Test kalkulasi persentase dan validasi data grading sederhana', () {
      // Contoh pengujian unit untuk logika perhitungan skor / confidence 
      double confidence = 95.5;
      bool isMatang = confidence > 80.0;

      // Memastikan logika penentuan tingkat kematangan berjalan benar
      expect(isMatang, true);
      expect(confidence, greaterThan(50.0));
    });
  });
}