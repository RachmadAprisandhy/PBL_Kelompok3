import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import file app.dart atau main.dart Anda
import 'package:bananagrading/app.dart'; 

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Ubah MyApp() menjadi BananaGradeApp()
    await tester.pumpWidget(const BananaGradeApp());

    // Sesuaikan ekspektasi test jika diperlukan
  });
}