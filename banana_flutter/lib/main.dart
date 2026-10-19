import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import 'core/database/db_helper.dart';
import 'core/theme/app_theme.dart';

// Providers
import 'features/auth/providers/auth_provider.dart';
import 'features/grading/providers/grading_provider.dart';
import 'features/history/providers/history_provider.dart';

// Screens
import 'features/onboarding/screens/splash_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/onboarding/screens/home_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/grading/screens/camera_screen.dart';
import 'features/grading/screens/preview_screen.dart';
import 'features/grading/screens/processing_screen.dart';
import 'features/grading/screens/result_screen.dart';
import 'features/history/screens/history_screen.dart';
import 'features/history/screens/detail_history_screen.dart';
import 'features/guide/screens/guide_screen.dart';
import 'features/profile/screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DbHelper().database;
  runApp(const BananaGradeApp());
}

class BananaGradeApp extends StatelessWidget {
  const BananaGradeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GradingProvider()),
        ChangeNotifierProvider(
          create: (_) => HistoryProvider()
            ..fetchHistory()
            ..attemptSync(),
        ),
      ],
      child: MaterialApp(
        title: 'BananaGrade',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/camera': (context) => const CameraScreen(),
          '/preview': (context) => const PreviewScreen(),
          '/processing': (context) => const ProcessingScreen(),
          '/result': (context) => const ResultScreen(),
          '/history': (context) => const HistoryScreen(),
          '/detail-history': (context) => const DetailHistoryScreen(),
          '/guide': (context) => const GuideScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}