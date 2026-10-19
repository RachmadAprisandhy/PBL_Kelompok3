import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/banana_logo.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Panduan Penggunaan')),
        body: ListView(padding: const EdgeInsets.all(20), children: const [
          Text('Cara mendapatkan foto yang baik', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.text)),
          SizedBox(height: 8),
          Text('Ikuti tips berikut agar gambar lebih mudah dianalisis oleh model saat CNN sudah terintegrasi.', style: TextStyle(color: AppColors.muted, height: 1.5)),
          SizedBox(height: 18),
          _GuideItem(icon: Icons.wb_sunny_outlined, number: '01', title: 'Pencahayaan cukup', description: 'Hindari foto terlalu gelap atau terlalu terang.'),
          _GuideItem(icon: Icons.center_focus_strong, number: '02', title: 'Fokus pada pisang', description: 'Pastikan buah terlihat jelas dan tidak buram.'),
          _GuideItem(icon: Icons.crop_free, number: '03', title: 'Satu objek utama', description: 'Gunakan satu sisir atau satu buah pisang yang menjadi objek utama foto.'),
          _GuideItem(icon: Icons.wallpaper_outlined, number: '04', title: 'Latar sederhana', description: 'Pilih latar yang tidak ramai agar buah mudah dibedakan.'),
          _GuideItem(icon: Icons.camera_alt_outlined, number: '05', title: 'Ambil dari sisi berbeda', description: 'Jika diperlukan, foto beberapa sisi untuk melihat kondisi permukaan.'),
        ]),
      );
}

class _GuideItem extends StatelessWidget {
  const _GuideItem({required this.icon, required this.number, required this.title, required this.description});
  final IconData icon;
  final String number;
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(leading: CircleAvatar(backgroundColor: const Color(0xFFE6F2E5), child: Icon(icon, color: AppColors.green)), title: Text('$number  $title', style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Text(description, style: const TextStyle(height: 1.4)))));
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Tentang Aplikasi')),
        body: ListView(padding: const EdgeInsets.all(24), children: [
          const SizedBox(height: 12),
          const Center(child: BananaLogo(compact: true)),
          const SizedBox(height: 12),
          const Text('Deteksi Grading Buah Pisang Menggunakan CNN', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, height: 1.5)),
          const SizedBox(height: 24),
          const Text('BananaGrade merupakan prototipe aplikasi mobile yang dirancang untuk membantu pengelompokan kualitas visual pisang ke dalam Grade A, Grade B, dan Grade C.', style: TextStyle(height: 1.6)),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFEAF4E8), borderRadius: BorderRadius.circular(18)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _AboutRow(icon: Icons.groups_outlined, text: 'Tim Project Based Learning'),
            SizedBox(height: 12),
            _AboutRow(icon: Icons.school_outlined, text: 'Politeknik Negeri Malang'),
            SizedBox(height: 12),
            _AboutRow(icon: Icons.phone_android_outlined, text: 'Flutter • Android'),
            SizedBox(height: 12),
            _AboutRow(icon: Icons.info_outline, text: 'Versi prototipe 1.0.0'),
          ])),
          const SizedBox(height: 18),
          const Text('Catatan: penilaian kualitas internal seperti rasa, aroma, dan tingkat gula tidak dapat ditentukan hanya dari citra RGB.', style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.5)),
        ]),
      );
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(children: [Icon(icon, color: AppColors.green), const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)))]);
}
