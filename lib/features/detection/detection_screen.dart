import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import 'result_screen.dart';

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({Key? key, this.initialImage}) : super(key: key);
  
  final XFile? initialImage;

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialImage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deteksi Grading', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.text,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kategori Grade
            const Text(
              'Kategori Grade',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGradeCard('Grade A', 'Kualitas baik', Colors.green.shade50, Colors.green),
                _buildGradeCard('Grade B', 'Cukup baik', Colors.orange.shade50, Colors.orange),
                _buildGradeCard('Grade C', 'Kurang layak', Colors.red.shade50, Colors.red),
              ],
            ),
            const SizedBox(height: 24),

            // Area Preview Foto Terpilih
            Container(
              height: 320,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        File(_selectedImage!.path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text('Gagal memuat file gambar'),
                          );
                        },
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'Belum ada foto dipilih',
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 32),

            // Tombol Utama: Analisis Grading -> ResultScreen
            ElevatedButton(
              onPressed: _selectedImage == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultScreen(imagePath: _selectedImage!.path),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                '✨ Analisis Grading',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Catatan: hasil yang ditampilkan masih berupa simulasi UI. Model CNN/TFLite belum terhubung.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Kartu Kategori Grade
  Widget _buildGradeCard(String title, String subtitle, Color bgColor, Color textColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.muted), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}