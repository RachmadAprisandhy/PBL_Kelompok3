import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'home_screen.dart';
import '../history/history_screen.dart';
import '../info/info_screens.dart';
import '../profile/profile_screen.dart';
import '../detection/detection_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({Key? key}) : super(key: key);

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final ImagePicker _picker = ImagePicker();

  late final List<Widget> _pages = [
    HomeScreen(
      onNavigate: (index) {
        _onTabTapped(index);
      },
    ),
    const HistoryScreen(),
    const GuideScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Fungsi penanganan Ambil Foto / Galeri yang aman dari async context unmounted
  Future<void> _handlePickImage(BuildContext modalContext, ImageSource source) async {
    final navigator = Navigator.of(context);
    Navigator.of(modalContext).pop(); // Tutup BottomSheet

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image != null) {
        navigator.push(
          MaterialPageRoute(
            builder: (context) => DetectionScreen(initialImage: image),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showScanOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Metode Grading Pisang',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Opsi 1: Ambil Foto dari Kamera
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE6F2E5),
                  child: Icon(Icons.camera_alt, color: Color(0xFF00880C)),
                ),
                title: const Text('Ambil Foto', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Gunakan kamera secara langsung'),
                onTap: () => _handlePickImage(modalContext, ImageSource.camera),
              ),
              const Divider(),

              // Opsi 2: Pilih dari Galeri
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE6F2E5),
                  child: Icon(Icons.photo_library, color: Color(0xFF00880C)),
                ),
                title: const Text('Pilih dari Galeri', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Ambil foto dari penyimpanan perangkat'),
                onTap: () => _handlePickImage(modalContext, ImageSource.gallery),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // Tombol Tengah diubah menjadi Ikon Kamera
      floatingActionButton: FloatingActionButton(
        elevation: 4,
        backgroundColor: const Color(0xFF00880C),
        shape: const CircleBorder(),
        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 28),
        onPressed: () => _showScanOptions(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Navigation Bar Bawah
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Beranda',
                isSelected: _currentIndex == 0,
                onTap: () => _onTabTapped(0),
              ),
              _buildNavItem(
                icon: Icons.history_rounded,
                label: 'Riwayat',
                isSelected: _currentIndex == 1,
                onTap: () => _onTabTapped(1),
              ),
              const SizedBox(width: 48), // Ruang untuk FloatingActionButton tengah
              _buildNavItem(
                icon: Icons.menu_book_rounded,
                label: 'Panduan',
                isSelected: _currentIndex == 2,
                onTap: () => _onTabTapped(2),
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                label: 'Profil',
                isSelected: _currentIndex == 3,
                onTap: () => _onTabTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = isSelected ? const Color(0xFF00880C) : Colors.grey;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}