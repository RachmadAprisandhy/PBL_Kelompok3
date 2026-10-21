import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/banana_logo.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFDF4), Color(0xFFFFF2B4)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const Spacer(flex: 2),
                const BananaLogo(),
                const SizedBox(height: 15),
                const Text(
                  'Deteksi Grading Buah Pisang\nMenggunakan CNN',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.text, height: 1.5, fontSize: 15),
                ),
                const SizedBox(height: 34),
                const Text('🍃  🍌  🍃', style: TextStyle(fontSize: 44)),
                const Spacer(flex: 2),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: const Text('Mulai Sekarang'),
                ),
                const SizedBox(height: 12),
                const Text('Prototipe aplikasi BananaGrade', style: TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
