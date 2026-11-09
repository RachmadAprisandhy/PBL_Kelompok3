import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'home_screen.dart';
import 'tutorial_overlay.dart';
import '../history/history_screen.dart';
import '../info/info_screens.dart';
import '../profile/profile_screen.dart';
import '../detection/detection_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.showTutorialOnInit = true,
  });

  final bool showTutorialOnInit;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  late bool _showTutorial;
  final ImagePicker _picker = ImagePicker();

  // GlobalKey untuk menandai setiap fitur di halaman utama (Dashboard)
  final GlobalKey _bannerKey = GlobalKey();
  final GlobalKey _gradeCategoryKey = GlobalKey();
  final GlobalKey _tipsKey = GlobalKey();
  final GlobalKey _historyBtnKey = GlobalKey();
  final GlobalKey _cameraFabKey = GlobalKey();
  final GlobalKey _bottomNavKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _showTutorial = widget.showTutorialOnInit;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _triggerTutorial() {
    setState(() {
      _currentIndex = 0;
      _showTutorial = true;
    });
  }

  Future<void> _handlePickImage(BuildContext modalContext, ImageSource source) async {
    final navigator = Navigator.of(context);
    Navigator.of(modalContext).pop();

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

  List<TutorialTargetItem> get _tutorialTargets => [
        TutorialTargetItem(
          key: _bannerKey,
          number: 1,
          title: 'Banner Deteksi Cepat AI',
          description:
              'Ketuk kartu kuning ini untuk langsung memotret pisang dengan kamera atau memilih foto dari galeri.',
        ),
        TutorialTargetItem(
          key: _gradeCategoryKey,
          number: 2,
          title: 'Informasi Kategori Grade',
          description:
              'Ringkasan standar mutu pisang: Grade A (kualitas baik), Grade B (cukup baik), dan Grade C (kurang layak).',
        ),
        TutorialTargetItem(
          key: _tipsKey,
          number: 3,
          title: 'Panduan & Tips Pengambilan Foto',
          description:
              'Ketuk kartu ini untuk membaca tips pencahayaan dan fokus kamera agar hasil deteksi CNN lebih akurat.',
        ),
        TutorialTargetItem(
          key: _historyBtnKey,
          number: 4,
          title: 'Pintasan Riwayat Deteksi',
          description:
              'Gunakan tombol ini untuk melihat daftar hasil grading pisang yang telah disimpan di perangkat.',
        ),
        TutorialTargetItem(
          key: _cameraFabKey,
          number: 5,
          title: 'Tombol Kamera Utama',
          description:
              'Tombol cepat di tengah bawah untuk memindai kualitas pisang kapan saja dari halaman mana pun.',
          isCircleShape: true,
        ),
        TutorialTargetItem(
          key: _bottomNavKey,
          number: 6,
          title: 'Menu Navigasi Utama',
          description:
              'Gunakan baris menu ini untuk berpindah antara halaman Beranda, Riwayat, Panduan, dan Profil.',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        onNavigate: _onTabTapped,
        onShowTutorial: _triggerTutorial,
        bannerKey: _bannerKey,
        gradeCategoryKey: _gradeCategoryKey,
        tipsKey: _tipsKey,
        historyBtnKey: _historyBtnKey,
      ),
      const HistoryScreen(),
      const GuideScreen(),
      ProfileScreen(onShowTutorial: _triggerTutorial),
    ];

    return Stack(
      children: [
        Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
          floatingActionButton: FloatingActionButton(
            key: _cameraFabKey,
            elevation: 4,
            backgroundColor: const Color(0xFF00880C),
            shape: const CircleBorder(),
            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 28),
            onPressed: () => _showScanOptions(context),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            key: _bottomNavKey,
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
                  const SizedBox(width: 48),
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
        ),

        // Overlay Halaman Tutorial di Atas Halaman Utama (Dashboard)
        if (_showTutorial && _currentIndex == 0)
          TutorialOverlay(
            targets: _tutorialTargets,
            onFinish: () {
              setState(() => _showTutorial = false);
            },
          ),
      ],
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