import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/grading_result.dart'; // Sesuaikan path impor proyek kamu

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime? _selectedDate;
  
  // List penyimpanan data keseluruhan dan data yang sudah difilter
  List<GradingResult> _allHistoryData = [];
  List<GradingResult> _filteredData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  // Memuat data dari penyimpanan lokal
  void _loadHistoryData() {
    // TODO: Sesuaikan dengan pemanggilan database lokal kamu yang sebenarnya
    setState(() {
      _allHistoryData = [
        GradingResult(
          id: '1',
          imagePath: '', // Path gambar lokal / aset
          ripenessLevel: 'Grade A',
          confidence: 0.926,
          createdAt: DateTime(2026, 10, 19, 12, 16),
        ),
        GradingResult(
          id: '2',
          imagePath: '',
          ripenessLevel: 'Grade A',
          confidence: 0.926,
          createdAt: DateTime(2026, 10, 19, 12, 15),
        ),
        GradingResult(
          id: '3',
          imagePath: '',
          ripenessLevel: 'Grade A',
          confidence: 0.926,
          createdAt: DateTime(2026, 10, 19, 11, 14),
        ),
      ];
      _filteredData = _allHistoryData;
      _isLoading = false;
    });
  }

  // Fungsi untuk memunculkan dialog kalender
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF1B4D3E), // Warna tema hijau tua
              onPrimary: Colors.white,
              surface: Colors.grey,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _filterDataByDate(picked);
      });
    }
  }

  // Logika memfilter berdasarkan tahun, bulan, dan hari
  void _filterDataByDate(DateTime date) {
    setState(() {
      _filteredData = _allHistoryData.where((item) {
        return item.createdAt.year == date.year &&
               item.createdAt.month == date.month &&
               item.createdAt.day == date.day;
      }).toList();
    });
  }

  // Mereset filter tanggal kembali ke semua data
  void _clearFilter() {
    setState(() {
      _selectedDate = null;
      _filteredData = _allHistoryData;
    });
  }

  // Format tanggal teks agar menyerupai "19 Okt 2026, 12:16"
  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    String hour = dt.hour.toString().padLeft(2, '0');
    String minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month]} ${dt.year}, $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Deteksi'),
        backgroundColor: const Color(0xFF1B4D3E), // Sesuaikan warna AppBar utama
        foregroundColor: Colors.white,
        actions: [
          // Ikon Kalender di Pojok Kanan Atas AppBar
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _selectDate(context),
            tooltip: 'Filter Berdasarkan Tanggal',
          ),
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearFilter,
              tooltip: 'Reset Filter',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Banner kecil penanda filter aktif (bisa dihapus jika ingin benar-benar bersih tanpa banner)
                if (_selectedDate != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.green.withOpacity(0.15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter tanggal: ${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        TextButton(
                          onPressed: _clearFilter,
                          child: const Text('Tampilkan Semua', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),

                // Daftar Riwayat dengan Desain Kartu Semula
                Expanded(
                  child: _filteredData.isEmpty
                      ? const Center(
                          child: Text(
                            'Tidak ada riwayat pada tanggal ini.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredData.length,
                          padding: const EdgeInsets.all(12),
                          itemBuilder: (context, index) {
                            final item = _filteredData[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    // Thumbnail Gambar di Kiri
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: SizedBox(
                                        width: 70,
                                        height: 70,
                                        child: item.imagePath.isNotEmpty
                                            ? Image.file(
                                                File(item.imagePath),
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                color: Colors.grey.shade200,
                                                child: const Icon(
                                                  Icons.image,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    
                                    // Informasi Teks (Label & Waktu)
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.ripenessLevel,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1B4D3E),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${(item.confidence * 100).toStringAsFixed(1)}% • ${_formatDate(item.createdAt)}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Tombol Hapus di Kanan
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                      onPressed: () {
                                        // TODO: Tambahkan logika hapus item dari list/database lokal di sini
                                      },
                                    ),
                                  ],
                                ),
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