import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/banana_illustration.dart';
import '../../../core/widgets/custom_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../history/providers/history_provider.dart';
import '../../history/screens/history_screen.dart';
import '../../guide/screens/guide_screen.dart';
import '../../profile/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _BerandaContent(onNavigateTab: _switchTab),
      const HistoryScreen(),
      const GuideScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NavigationBar(
            height: 65,
            selectedIndex: _currentIndex,
            onDestinationSelected: _switchTab,
            backgroundColor: Colors.white,
            indicatorColor: AppColors.secondary.withValues(alpha: 0.5),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: AppColors.primary),
                label: 'Beranda',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history, color: AppColors.primary),
                label: 'Riwayat',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book, color: AppColors.primary),
                label: 'Panduan',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: AppColors.primary),
                label: 'Profil',
              ),
            ],
          ),
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 6),
            child: const Text(
              'Tersimpan di perangkat',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _BerandaContent extends StatelessWidget {
  final Function(int) onNavigateTab;

  const _BerandaContent({required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final history = Provider.of<HistoryProvider>(context);
    final latestItem = history.historyList.isNotEmpty ? history.historyList.first : null;
    final unsyncedCount = history.historyList.where((e) => e['is_synced'] == 0).length;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header Sapaan (Dibungkus Expanded agar TIDAK OVERFLOW)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, ${auth.user?['name'] ?? 'Pengguna'}! 👋',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            unsyncedCount == 0 ? 'Online' : 'Lokal',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              unsyncedCount == 0
                                  ? ' • Tersinkronisasi'
                                  : ' • $unsyncedCount belum tersinkronisasi',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.4),
                  ),
                  icon: const Icon(Icons.sync, color: AppColors.primary),
                  onPressed: () => history.attemptSync(),
                  tooltip: 'Sinkronkan Data',
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 2. Kartu Utama Hijau dengan Ilustrasi Pisang & Tombol Kuning (Sesuai Mockup)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const BananaIllustration(size: 150),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.textPrimary,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/camera'),
                      child: const Text(
                        'Mulai Grading',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Dua Tombol Pilihan Input: Ambil Foto & Pilih dari Galeri (Sesuai Mockup)
            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/camera',
                      arguments: {'source': 'camera'},
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.camera_alt_outlined, size: 28, color: AppColors.textPrimary),
                        SizedBox(height: 8),
                        Text(
                          'Ambil Foto',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/camera',
                      arguments: {'source': 'gallery'},
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.photo_library_outlined, size: 28, color: AppColors.textPrimary),
                        SizedBox(height: 8),
                        Text(
                          'Pilih dari Galeri',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // 4. Bagian Riwayat Terakhir (Desain Kartu Ringkasan sesuai Mockup)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Riwayat Terakhir',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => onNavigateTab(1),
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Kartu Jumlah Hasil Grading dengan Ilustrasi Pisang Kecil di Kanan (Sesuai Mockup)
            CustomCard(
              onTap: () => onNavigateTab(1),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Text(
                    '${history.historyList.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Hasil\nGrading',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const BananaIllustration(size: 64),
                ],
              ),
            ),

            // Item Grading Terakhir (Jika sudah ada data)
            if (latestItem != null) ...[
              const SizedBox(height: 12),
              CustomCard(
                onTap: () => Navigator.pushNamed(
                  context,
                  '/detail-history',
                  arguments: latestItem,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: File(latestItem['image_path']).existsSync()
                          ? Image.file(
                              File(latestItem['image_path']),
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 56,
                              height: 56,
                              color: AppColors.secondary,
                              child: const Icon(Icons.image, color: AppColors.primary),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${latestItem['grade']} (${(latestItem['confidence'] * 100).toStringAsFixed(0)}%)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormatter.formatFull(latestItem['created_at']),
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      latestItem['is_synced'] == 1 ? Icons.cloud_done : Icons.schedule,
                      color: latestItem['is_synced'] == 1 ? AppColors.primary : Colors.orange,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}