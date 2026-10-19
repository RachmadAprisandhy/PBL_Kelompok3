import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/network/network_info.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../history/providers/history_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final online = await NetworkInfo().isConnected;
    if (mounted) setState(() => _isOnline = online);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final history = Provider.of<HistoryProvider>(context);
    final unsyncedCount = history.historyList.where((e) => e['is_synced'] == 0).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil & Pengaturan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomCard(
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.secondary,
                    child: Icon(Icons.person, size: 32, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.user?['name'] ?? 'Pengguna Offline',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          auth.user?['email'] ?? 'Mode Lokal (Tanpa Akun)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status Arsitektur & Penyimpanan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Divider(height: 24),
                  _buildStatusRow(
                    'Status Koneksi Server',
                    _isOnline ? 'Online (Terhubung)' : 'Offline (Lokal)',
                    _isOnline ? AppColors.primary : Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildStatusRow(
                    'Model AI TensorFlow Lite',
                    'Aktif di Perangkat',
                    AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  _buildStatusRow(
                    'Status Sinkronisasi SQLite',
                    unsyncedCount == 0 ? 'Tersinkronisasi' : '$unsyncedCount Belum Sync',
                    unsyncedCount == 0 ? AppColors.primary : Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Sinkronkan Data Sekarang',
              icon: Icons.sync,
              isLoading: history.isSyncing,
              onPressed: () async {
                await _checkConnection();
                await history.attemptSync();
              },
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Keluar Akun',
              icon: Icons.logout,
              isOutlined: true,
              backgroundColor: AppColors.danger,
              textColor: AppColors.danger,
              onPressed: () async {
                await auth.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Menggunakan Expanded pada kedua sisi agar teks tidak pernah bertabrakan / overflow
  Widget _buildStatusRow(String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 4,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}