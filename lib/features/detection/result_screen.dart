import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../core/theme/app_theme.dart';
import '../../data/models/grading_result.dart';
import '../../data/local/app_database.dart';

class ResultScreen extends StatefulWidget {
  final String imagePath;
  final String ripenessLevel;
  final double confidence;

  const ResultScreen({
    super.key,
    required this.imagePath,
    required this.ripenessLevel,
    required this.confidence,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isSaving = false;

  double get _confidence => widget.confidence.isFinite
      ? widget.confidence.clamp(0.0, 1.0).toDouble()
      : 0.0;

  Future<void> _saveToHistory() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    String? savedImagePath;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = p.basename(widget.imagePath);
      final uniqueFileName =
          '${DateTime.now().microsecondsSinceEpoch}_$fileName';
      final permanentImage = await File(widget.imagePath)
          .copy(p.join(directory.path, uniqueFileName));
      savedImagePath = permanentImage.path;

      final newResult = GradingResult(
        id: '',
        imagePath: permanentImage.path,
        ripenessLevel: widget.ripenessLevel,
        confidence: _confidence,
        createdAt: DateTime.now(),
      );

      await AppDatabase.instance.insertResult(newResult);

      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil disimpan ke riwayat!')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (savedImagePath != null) {
        try {
          final savedImage = File(savedImagePath);
          if (await savedImage.exists()) {
            await savedImage.delete();
          }
        } catch (cleanupError) {
          if (mounted) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Gagal menyimpan: $e. Gagal membersihkan file sementara: $cleanupError',
                ),
              ),
            );
          }
          return;
        }
      }
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Deteksi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.text,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview Gambar
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: File(widget.imagePath).existsSync()
                    ? Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : const Center(child: Text('Gambar tidak ditemukan')),
              ),
            ),
            const SizedBox(height: 24),

            // Kartu Hasil Grade (Desain Asli Tautan Ketiga)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.ripenessLevel,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Kualitas visual baik',
                        style: TextStyle(fontSize: 14, color: AppColors.muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Progress Bar Keyakinan / Akurasi
            const Text(
              'Tingkat Keyakinan (Simulasi)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.text),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _confidence,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.green),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_confidence * 100).toStringAsFixed(1).replaceAll('.', ',')}%',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.green),
            ),
            const SizedBox(height: 24),

            // Keterangan
            const Text(
              'Keterangan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.text),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pada rancangan grading, Grade A ditujukan untuk pisang dengan kondisi visual baik, bentuk relatif baik, dan kerusakan permukaan minimal.',
              style: TextStyle(fontSize: 13, color: AppColors.muted, height: 1.5),
            ),
            const SizedBox(height: 16),

            // Banner Info Simulasi
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade800, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Ini adalah hasil contoh untuk menguji tampilan. Prediksi grade dan persentase belum berasal dari model CNN.',
                      style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Simpan ke Riwayat
            ElevatedButton(
              onPressed: _isSaving ? null : _saveToHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Simpan ke Riwayat',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
            const SizedBox(height: 12),

            // Tombol Kembali
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: const Text(
                'Kembali',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}