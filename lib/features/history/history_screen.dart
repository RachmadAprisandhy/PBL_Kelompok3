import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/app_database.dart';
import '../../data/models/grading_result.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<GradingResult>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() => _future = AppDatabase.instance.getResults();

  Future<void> _delete(GradingResult result) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus hasil?'),
        content: const Text('Data ini akan dihapus dari riwayat perangkat.'),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Hapus'))],
      ),
    );
    if (confirm == true && result.id != null) {
      await AppDatabase.instance.deleteResult(result.id!);
      if (mounted) setState(_refresh);
    }
  }

  Future<void> _deleteAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus semua riwayat?'),
        content: const Text('Semua hasil yang tersimpan akan dihapus.'),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Hapus semua'))],
      ),
    );
    if (confirm == true) {
      await AppDatabase.instance.deleteAllResults();
      if (mounted) setState(_refresh);
    }
  }

  Color _gradeColor(String grade) => switch (grade) {'A' => AppColors.green, 'B' => const Color(0xFFE3A400), _ => AppColors.red};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Deteksi'), actions: [IconButton(tooltip: 'Hapus semua', onPressed: _deleteAll, icon: const Icon(Icons.delete_outline))]),
      body: FutureBuilder<List<GradingResult>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Gagal memuat riwayat: ${snapshot.error}')));
          final results = snapshot.data ?? [];
          if (results.isEmpty) {
            return Center(child: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisSize: MainAxisSize.min, children: const [
              Icon(Icons.history, size: 58, color: AppColors.muted),
              SizedBox(height: 12),
              Text('Belum ada riwayat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              SizedBox(height: 6),
              Text('Hasil grading yang kamu simpan akan muncul di sini.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
            ])));
          }
          return RefreshIndicator(
            onRefresh: () async => setState(_refresh),
            child: ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = results[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(width: 65, height: 65, child: File(item.imagePath).existsSync() ? Image.file(File(item.imagePath), fit: BoxFit.cover) : const ColoredBox(color: Color(0xFFE9EEE7), child: Icon(Icons.image_not_supported_outlined)))),
                    title: Text('Grade ${item.grade}', style: TextStyle(color: _gradeColor(item.grade), fontWeight: FontWeight.w900)),
                    subtitle: Text('${item.confidence.toStringAsFixed(1)}% • ${DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(item.createdAt)}', style: const TextStyle(fontSize: 12, height: 1.6)),
                    trailing: IconButton(tooltip: 'Hapus item', onPressed: () => _delete(item), icon: const Icon(Icons.delete_outline, color: AppColors.muted)),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
