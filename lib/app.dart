import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/splash_screen.dart';

class BananaGradeApp extends StatelessWidget {
  const BananaGradeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BananaGrade',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
