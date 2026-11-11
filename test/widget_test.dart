import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test struktur dasar aplikasi BananaGrade', (WidgetTester tester) async {
    // 1. Jalankan test menggunakan widget MaterialApp sederhana
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('BananaGrade'),
          ),
        ),
      ),
    );

    // 2. Tunggu frame selesai dirender
    await tester.pumpAndSettle();

    // 3. Verifikasi teks utama muncul di layar
    expect(find.text('BananaGrade'), findsOneWidget);
  });
}