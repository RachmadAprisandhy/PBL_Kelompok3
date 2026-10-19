import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/banana_illustration.dart';
import '../../auth/providers/auth_provider.dart';
import '../controllers/onboarding_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final OnboardingController _onboardingController = OnboardingController();

  @override
  void initState() {
    super.initState();
    _checkRoute();
  }

  Future<void> _checkRoute() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final seenOnboarding = await _onboardingController.hasSeenOnboarding();
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (!seenOnboarding) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else if (auth.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF1B4D20),
            ],
          ),
        ),
        child: Stack(
          children: [
            
            // Konten Utama di Tengah
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const BananaIllustration(size: 135, showCameraBadge: true),
                  const SizedBox(height: 20),
                  Text(
                    'BananaGrade',
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Kenali Kualitas Pisang\ndengan Mudah',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 60),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: Colors.white70,
                      strokeWidth: 2.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}