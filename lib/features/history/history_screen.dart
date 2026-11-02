import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/models/grading_result.dart';
import '../../data/local/app_database.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime? _selectedDate;
  String? _selectedGrade;

  List<GradingResult> _allHistoryData = [];
  List<GradingResult> _filteredData = [];
  bool _isLoading = true;
  String? _loadError;

  // Filter grade dibatasi dari Grade A sampai Grade D
  final List<String> _availableGrades = [
    'Grade A',
    'Grade B',
    'Grade C',
    'Grade D',
  ];

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final localData = await AppDatabase.instance.getResults();
      if (!mounted) return;
      setState(() {
        _allHistoryData = localData;
        _filteredData = _filterResults(localData);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = e.toString();
      });
    }
  }

  Future<void> _deleteItem(String id, String imagePath) async {
    try {
      final rowId = int.tryParse(id);
      if (rowId == null) {
        throw FormatException('ID riwayat tidak valid: $id');
      }

      await AppDatabase.instance.deleteResult(rowId);
      if (imagePath.isNotEmpty && await File(imagePath).exists()) {
        await File(imagePath).delete();
      }

      await _loadHistoryData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Riwayat berhasil dihapus'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menghapus riwayat: $e')));
    }
  }

  List<GradingResult> _filterResults(List<GradingResult> results) {
    return results.where((item) {
      bool matchesDate = true;
      if (_selectedDate != null) {
        matchesDate =
            item.createdAt.year == _selectedDate!.year &&
            item.createdAt.month == _selectedDate!.month &&
            item.createdAt.day == _selectedDate!.day;
      }

      bool matchesGrade = true;
      if (_selectedGrade != null && _selectedGrade!.isNotEmpty) {
        matchesGrade =
            item.ripenessLevel.toLowerCase() == _selectedGrade!.toLowerCase();
      }

      return matchesDate && matchesGrade;
    }).toList();
  }

  void _applyFilters() {
    setState(() {
      _filteredData = _filterResults(_allHistoryData);
    });
  }

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
              primary: Color(0xFF1B4D3E),
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
      });
      _applyFilters();
    }
  }

  void _showGradeFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Berdasarkan Grade'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _availableGrades.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ListTile(
                    title: const Text(
                      'Semua Grade',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedGrade = null;
                      });
                      _applyFilters();
                      Navigator.pop(context);
                    },
                  );
                }
                final grade = _availableGrades[index - 1];
                return ListTile(
                  title: Text(grade),
                  onTap: () {
                    setState(() {
                      _selectedGrade = grade;
                    });
                    _applyFilters();
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedDate = null;
      _selectedGrade = null;
      _filteredData = _allHistoryData;
    });
  }

  String _formatDate(DateTime dt) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    String hour = dt.hour.toString().padLeft(2, '0');
    String minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month]} ${dt.year}, $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    bool isFiltered = _selectedDate != null || _selectedGrade != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Deteksi'),
        backgroundColor: const Color(0xFF1B4D3E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _selectedGrade != null ? Colors.amberAccent : Colors.white,
            ),
            onPressed: () => _showGradeFilterDialog(context),
            tooltip: 'Filter Grade',
          ),
          IconButton(
            icon: Icon(
              Icons.calendar_month,
              color: _selectedDate != null ? Colors.amberAccent : Colors.white,
            ),
            onPressed: () => _selectDate(context),
            tooltip: 'Filter Tanggal',
          ),
          if (isFiltered)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearAllFilters,
              tooltip: 'Reset Semua Filter',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Gagal memuat riwayat deteksi.'),
                    const SizedBox(height: 8),
                    Text(
                      _loadError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadHistoryData,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                if (isFiltered)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.green.withValues(alpha: 0.15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Filter: ${_selectedGrade ?? "Semua Grade"} ${(_selectedDate != null) ? "• ${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}" : ""}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton(
                          onPressed: _clearAllFilters,
                          child: const Text(
                            'Reset',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _filteredData.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada riwayat deteksi.',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredData.length,
                          padding: const EdgeInsets.all(12),
                          itemBuilder: (context, index) {
                            final item = _filteredData[index];
                            final imageFile =
                                (item.imagePath.isNotEmpty &&
                                    File(item.imagePath).existsSync())
                                ? File(item.imagePath)
                                : null;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: SizedBox(
                                        width: 70,
                                        height: 70,
                                        child: imageFile != null
                                            ? Image.file(
                                                imageFile,
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
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () =>
                                          _deleteItem(item.id, item.imagePath),
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
