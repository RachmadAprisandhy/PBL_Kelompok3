
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
  final Map<String, dynamic> probabilities;

  const ResultScreen({
    super.key,
    required this.imagePath,
    required this.ripenessLevel,
    required this.confidence,
    required this.probabilities,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isSaving = false;

  double get _confidence => widget.confidence.isFinite
      ? widget.confidence.clamp(0.0, 1.0).toDouble()
      : 0.0;

  Color get _gradeColor {
    switch (widget.ripenessLevel) {
      case 'Grade A':
        return Colors.green;
      case 'Grade B':
        return Colors.orange;
      case 'Grade C':
        return Colors.deepOrange;
      case 'Grade D':
        return Colors.blueGrey;
      default:
        return AppColors.green;
    }
  }

  String get _gradeDescription {
    switch (widget.ripenessLevel) {
      case 'Grade A':
        return 'Pisang termasuk kategori Grade A berdasarkan hasil klasifikasi model.';
      case 'Grade B':
        return 'Pisang termasuk kategori Grade B berdasarkan hasil klasifikasi model.';
      case 'Grade C':
        return 'Pisang termasuk kategori Grade C berdasarkan hasil klasifikasi model.';
      case 'Grade D':
        return 'Pisang termasuk kategori Grade D berdasarkan hasil klasifikasi model.';
      default:
        return 'Hasil klasifikasi tidak dikenali.';
    }
  }

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
        const SnackBar(
          content: Text('Berhasil disimpan ke riwayat!'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (savedImagePath != null) {
        try {
          final savedImage = File(savedImagePath);
          if (await savedImage.exists()) {
            await savedImage.delete();
          }
        } catch (_) {}
      }

      if (!mounted) return;

      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    }
  }

  Widget _buildProbabilityCard() {
    final grades = ['Grade A', 'Grade B', 'Grade C', 'Grade D'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Probabilitas Setiap Grade',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),

          ...grades.map((grade) {
            final value = widget.probabilities[grade];
            final probability = value is num
                ? (value.toDouble() / 100).clamp(0.0, 1.0).toDouble()
                : 0.0;

            Color color;

            switch (grade) {
              case 'Grade A':
                color = Colors.green;
                break;
              case 'Grade B':
                color = Colors.orange;
                break;
              case 'Grade C':
                color = Colors.deepOrange;
                break;
              default:
                color = Colors.blueGrey;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        grade,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${(probability * 100).toStringAsFixed(2).replaceAll('.', ',')}%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: probability,
                      minHeight: 9,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hasil Deteksi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.text,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview gambar
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: File(widget.imagePath).existsSync()
                    ? Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : const Center(
                        child: Text('Gambar tidak ditemukan'),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Hasil prediksi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _gradeColor.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _gradeColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.ripenessLevel,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _gradeColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _gradeDescription,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tingkat keyakinan
            const Text(
              'Tingkat Keyakinan Model',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),

            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _confidence,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(_gradeColor),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '${(_confidence * 100).toStringAsFixed(2).replaceAll('.', ',')}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _gradeColor,
              ),
            ),

            const SizedBox(height: 24),

            // Probabilitas semua grade
            _buildProbabilityCard(),

            const SizedBox(height: 24),

            // Keterangan
            const Text(
              'Keterangan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              _gradeDescription,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.muted,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // Simpan ke riwayat
            ElevatedButton(
              onPressed: _isSaving ? null : _saveToHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Simpan ke Riwayat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: const Text(
                'Kembali',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
