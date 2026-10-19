import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/custom_card.dart';
import '../../grading/data/grading_model.dart';

class DetailHistoryScreen extends StatelessWidget {
  const DetailHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final item = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String grade = item['grade'];
    final double confidence = item['confidence'];
    final bool isSynced = item['is_synced'] == 1;
    final details = GradingModel.getGradeDetails(grade);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Riwayat Grading')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: File(item['image_path']).existsSync()
                  ? Image.file(File(item['image_path']), height: 240, fit: BoxFit.cover)
                  : Container(
                      height: 200,
                      color: AppColors.secondary,
                      child: const Icon(Icons.broken_image, size: 64, color: AppColors.primary),
                    ),
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        grade,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Chip(
                        avatar: Icon(
                          isSynced ? Icons.cloud_done : Icons.storage,
                          size: 16,
                          color: isSynced ? AppColors.primary : Colors.orange,
                        ),
                        label: Text(isSynced ? 'Tersinkronisasi Server' : 'Tersimpan Lokal'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Nilai Keyakinan: ${(confidence * 100).toStringAsFixed(1)}%'),
                  const SizedBox(height: 4),
                  Text('Waktu Grading: ${DateFormatter.formatFull(item['created_at'])}'),
                  const Divider(height: 24),
                  const Text('Karakteristik Visual:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(details['characteristics']!),
                  const SizedBox(height: 12),
                  const Text('Rekomendasi Pemanfaatan:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(details['recommendation']!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}