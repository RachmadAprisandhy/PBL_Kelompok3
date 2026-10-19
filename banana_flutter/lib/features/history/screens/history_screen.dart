import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/custom_card.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'Semua';
  String _searchQuery = '';

  Future<void> _confirmClearAll(BuildContext context, HistoryProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Seluruh Riwayat?'),
        content: const Text('Semua data riwayat grading yang tersimpan di perangkat akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      for (var item in provider.historyList) {
        await provider.deleteHistory(item['id']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context);

    final filteredList = historyProvider.historyList.where((item) {
      final matchesGrade = _selectedFilter == 'Semua' || item['grade'] == _selectedFilter;
      final matchesSearch = item['grade'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['created_at'].toString().contains(_searchQuery);
      return matchesGrade && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Grading'),
        actions: [
          if (historyProvider.historyList.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Hapus Semua',
              onPressed: () => _confirmClearAll(context, historyProvider),
            ),
        ],
      ),
      body: Column(
        children: [
          // Bar Pencarian & Filter Kategori
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Cari berdasarkan grade atau tanggal...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Semua', 'Grade A', 'Grade B', 'Grade C'].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) => setState(() => _selectedFilter = filter),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Daftar Riwayat atau Empty State
          Expanded(
            child: filteredList.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 64, color: AppColors.textSecondary),
                          SizedBox(height: 12),
                          Text(
                            'Belum Ada Riwayat Grading',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Hasil klasifikasi pisang yang Anda simpan akan muncul di halaman ini.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      final isSynced = item['is_synced'] == 1;

                      return CustomCard(
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/detail-history',
                          arguments: item,
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: File(item['image_path']).existsSync()
                                  ? Image.file(
                                      File(item['image_path']),
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
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
                                    '${item['grade']} (${(item['confidence'] * 100).toStringAsFixed(1)}%)',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormatter.formatFull(item['created_at']),
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isSynced
                                          ? AppColors.secondary.withValues(alpha: 0.4)
                                          : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isSynced ? 'Tersinkronisasi' : 'Belum tersinkronisasi',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isSynced ? AppColors.primary : AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                              onPressed: () => historyProvider.deleteHistory(item['id']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}