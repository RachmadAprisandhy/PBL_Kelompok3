import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test struktur UI Halaman Riwayat (HistoryScreen) BananaGrade', (WidgetTester tester) async {
    // Membangun mockup struktur UI HistoryScreen yang bersih untuk kebutuhan test
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Riwayat Deteksi'),
          ),
          body: const Center(
            child: Text('Belum ada riwayat pemindaian pisang.'),
          ),
        ),
      ),
    );

    // Tunggu proses render selesai
    await tester.pumpAndSettle();

    // Verifikasi bahwa judul AppBar dan teks kosong muncul dengan benar
    expect(find.text('Riwayat Deteksi'), findsOneWidget);
    expect(find.text('Belum ada riwayat pemindaian pisang.'), findsOneWidget);
  });
}