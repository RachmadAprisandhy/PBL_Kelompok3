import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/custom_card.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panduan Penggunaan')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _GuideSection(
            icon: Icons.camera_enhance_rounded,
            title: '1. Cara Mengambil Foto yang Baik',
            content: 'Letakkan pisang di permukaan datar dengan latar belakang yang bersih. Pastikan cahaya merata dan tidak menimbulkan bayangan gelap pada kulit pisang.',
          ),
          SizedBox(height: 12),
          _GuideSection(
            icon: Icons.category_rounded,
            title: '2. Arti Kategori Grade A, B, dan C',
            content: '• Grade A: Kulit bersih, mulus, bentuk proporsional (Rekomendasi: Supermarket).\n'
                '• Grade B: Bercak ringan pada kulit namun buah masih bagus (Rekomendasi: Pasar Lokal).\n'
                '• Grade C: Memar, bercak hitam pekat, atau terlalu matang (Rekomendasi: Olahan, pakan ternak, atau pupuk).',
          ),
          SizedBox(height: 12),
          _GuideSection(
            icon: Icons.analytics_outlined,
            title: '3. Membaca Nilai Keyakinan (Confidence)',
            content: 'Persentase keyakinan menunjukkan seberapa mirip pola visual foto dengan data latih model CNN. Nilai ini bukan jaminan mutlak kualitas bagian dalam buah.',
          ),
          SizedBox(height: 12),
          _GuideSection(
            icon: Icons.build_circle_outlined,
            title: '4. Mengatasi Kesalahan Saat Grading',
            content: 'Jika tingkat keyakinan di bawah 65% atau hasil terasa kurang akurat, ambil foto ulang dari jarak 20–30 cm dan pastikan lensa kamera bersih.',
          ),
        ],
      ),
    );
  }
}

class _GuideSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _GuideSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(height: 1.4)),
        ],
      ),
    );
  }
}