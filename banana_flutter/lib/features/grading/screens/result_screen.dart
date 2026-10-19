import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../history/providers/history_provider.dart';
import '../data/grading_model.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isSaved = false;

  Future<void> _saveResult(Map<String, dynamic> args) async {
    if (_isSaved) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final history = Provider.of<HistoryProvider>(context, listen: false);

    final uniqueId = md5.convert(utf8.encode(DateTime.now().toIso8601String())).toString();

    await history.addGradingLocal(
      id: uniqueId,
      userId: auth.user?['email'],
      grade: args['grade'],
      confidence: args['confidence'],
      imagePath: args['imagePath'],
    );

    if (mounted) {
      setState(() => _isSaved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hasil grading berhasil disimpan di perangkat.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String grade = args['grade'];
    final double confidence = args['confidence'];
    final String imagePath = args['imagePath'];
    final bool isLowConfidence = confidence < 0.65;

    final details = GradingModel.getGradeDetails(grade);
    final Color badgeColor = grade == 'Grade A'
        ? AppColors.primary
        : (grade == 'Grade B' ? AppColors.accent : AppColors.danger);

    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Grading')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(File(imagePath), height: 220, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),

            // Peringatan Jika Nilai Keyakinan Rendah
            if (isLowConfidence)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tingkat keyakinan model rendah. Disarankan mengambil foto ulang dengan pencahayaan yang lebih jelas.',
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),

            // Kartu Utama Grade
            CustomCard(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      grade.toUpperCase(),
                      style: TextStyle(
                        color: grade == 'Grade B' ? AppColors.textPrimary : Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    details['title']!,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  LinearPercentIndicator(
                    lineHeight: 10,
                    percent: confidence.clamp(0.0, 1.0),
                    progressColor: badgeColor,
                    backgroundColor: Colors.grey.shade200,
                    barRadius: const Radius.circular(8),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Keyakinan Model: ${(confidence * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '*Nilai keyakinan merupakan estimasi visual AI dan bukan jaminan mutlak kualitas internal buah.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Karakteristik & Rekomendasi
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Karakteristik Visual:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(details['characteristics']!),
                  const Divider(height: 24),
                  const Text('Rekomendasi Pemanfaatan:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(details['recommendation']!),
                ],
              ),
            ),
            const SizedBox(height: 24),

            CustomButton(
              text: _isSaved ? 'Tersimpan di Riwayat' : 'Simpan Hasil',
              icon: _isSaved ? Icons.check : Icons.save_alt,
              backgroundColor: _isSaved ? Colors.grey : AppColors.accent,
              textColor: AppColors.textPrimary,
              onPressed: _isSaved ? null : () => _saveResult(args),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Grading Ulang',
                    isOutlined: true,
                    onPressed: () => Navigator.pushReplacementNamed(context, '/camera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Lihat Riwayat',
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}