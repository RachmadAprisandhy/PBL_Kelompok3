import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../auth/splash_screen.dart';
import '../info/info_screens.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    this.onShowTutorial,
  });

  final VoidCallback? onShowTutorial;

  void _open(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil & Info Aplikasi')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 31,
                    backgroundColor: AppColors.green,
                    child: Icon(Icons.eco_rounded, size: 34, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pengguna BananaGrade',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Mode Langsung (Tanpa Login • Penyimpanan Lokal)',
                          style: TextStyle(color: AppColors.muted, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (onShowTutorial != null) ...[
            _ProfileTile(
              icon: Icons.touch_app_outlined,
              title: 'Tampilkan Tutorial Halaman Utama',
              onTap: onShowTutorial!,
            ),
            const SizedBox(height: 10),
          ],
          _ProfileTile(
            icon: Icons.storage_outlined,
            title: 'Status Penyimpanan Perangkat',
            onTap: () => _showStorageStatus(context),
          ),
          const SizedBox(height: 10),
          _ProfileTile(
            icon: Icons.menu_book_outlined,
            title: 'Panduan Penggunaan',
            onTap: () => _open(context, const GuideScreen()),
          ),
          const SizedBox(height: 10),
          _ProfileTile(
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            onTap: () => _open(context, const AboutScreen()),
          ),
          const SizedBox(height: 26),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const SplashScreen()),
              );
            },
            icon: const Icon(Icons.replay_rounded, color: AppColors.green),
            label: const Text(
              'Putar Ulang Animasi Splash Screen',
              style: TextStyle(color: AppColors.green),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }

  void _showStorageStatus(BuildContext context) => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Status Penyimpanan Lokal'),
          content: const Text(
            'Aplikasi berjalan secara mandiri di perangkat (Offline-First) tanpa memerlukan login. Seluruh riwayat deteksi disimpan ke database SQLite perangkat.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Icon(icon, color: AppColors.green),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      );
}