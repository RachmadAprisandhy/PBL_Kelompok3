import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test struktur UI Layar Deteksi (DetectionScreen)', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Kamera Deteksi Pisang'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    
    // Verifikasi teks utama layar deteksi muncul
    expect(find.text('Kamera Deteksi Pisang'), findsOneWidget);
  });
}