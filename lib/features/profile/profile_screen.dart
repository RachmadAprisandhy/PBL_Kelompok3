import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../info/info_screens.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _open(BuildContext context, Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [
          const CircleAvatar(radius: 31, backgroundColor: AppColors.green, child: Icon(Icons.person, size: 36, color: Colors.white)),
          const SizedBox(width: 14),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Pengguna BananaGrade', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            SizedBox(height: 4),
            Text('Mode prototipe', style: TextStyle(color: AppColors.muted)),
          ])),
        ]))),
        const SizedBox(height: 16),
        _ProfileTile(icon: Icons.person_outline, title: 'Informasi Akun', onTap: () => _showAccount(context)),
        _ProfileTile(icon: Icons.settings_outlined, title: 'Pengaturan Aplikasi', onTap: () => _showSettings(context)),
        _ProfileTile(icon: Icons.menu_book_outlined, title: 'Panduan Penggunaan', onTap: () => _open(context, const GuideScreen())),
        _ProfileTile(icon: Icons.info_outline, title: 'Tentang Aplikasi', onTap: () => _open(context, const AboutScreen())),
        const SizedBox(height: 26),
        OutlinedButton.icon(onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst), icon: const Icon(Icons.logout, color: AppColors.red), label: const Text('Keluar dari prototipe', style: TextStyle(color: AppColors.red)), style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFF0CECE)), minimumSize: const Size.fromHeight(48))),
      ]),
    );
  }

  void _showAccount(BuildContext context) => showDialog<void>(context: context, builder: (context) => AlertDialog(title: const Text('Informasi Akun'), content: const Text('Aplikasi masih berjalan dalam mode prototipe. Sistem akun belum terhubung ke backend.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))]));
  void _showSettings(BuildContext context) => showDialog<void>(context: context, builder: (context) => AlertDialog(title: const Text('Pengaturan Aplikasi'), content: const Text('Pengaturan bahasa, tema, dan akun akan ditambahkan pada pengembangan berikutnya.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))]));
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(child: ListTile(leading: Icon(icon, color: AppColors.green), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), trailing: const Icon(Icons.chevron_right), onTap: onTap));
}
