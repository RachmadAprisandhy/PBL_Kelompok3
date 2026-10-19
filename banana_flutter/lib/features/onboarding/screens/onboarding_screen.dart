import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OnboardingController();

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.document_scanner_rounded,
                  size: 88,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Cara Kerja BananaGrade',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              _buildStep(
                number: '1',
                title: 'Ambil atau Pilih Foto',
                subtitle: 'Ambil foto pisang menggunakan kamera atau pilih dari galeri perangkat Anda.',
              ),
              const SizedBox(height: 16),
              _buildStep(
                number: '2',
                title: 'Analisis Model AI (Offline)',
                subtitle: 'Aplikasi menganalisis karakteristik visual kulit pisang menggunakan model CNN TensorFlow Lite.',
              ),
              const SizedBox(height: 16),
              _buildStep(
                number: '3',
                title: 'Lihat Hasil & Rekomendasi',
                subtitle: 'Dapatkan klasifikasi Grade A, B, atau C beserta rekomendasi pemanfaatannya.',
              ),
              const Spacer(),
              CustomButton(
                text: 'Mulai',
                onPressed: () async {
                  await controller.setOnboardingSeen();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primary,
          child: Text(
            number,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}