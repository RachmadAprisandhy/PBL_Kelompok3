import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/app_database.dart';
import '../../data/models/grading_result.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.imagePath});
  final String imagePath;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _saving = false;
  bool _saved = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await AppDatabase.instance.insertResult(GradingResult(
        imagePath: widget.imagePath,
        grade: 'A',
        confidence: 92.6,
        createdAt: DateTime.now(),
        note: 'Kualitas visual baik (hasil simulasi; CNN belum terhubung).',
      ));
      if (!mounted) return;
      setState(() { _saving = false; _saved = true; });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil disimpan ke riwayat.')));
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Deteksi')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        ClipRRect(borderRadius: BorderRadius.circular(22), child: Image.file(File(widget.imagePath), height: 245, fit: BoxFit.cover)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: const Color(0xFFE7F4E6), borderRadius: BorderRadius.circular(20)),
          child: const Row(children: [
            CircleAvatar(radius: 26, backgroundColor: AppColors.green, child: Icon(Icons.check_circle_outline, color: Colors.white, size: 30)),
            SizedBox(width: 13),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Grade A', style: TextStyle(fontSize: 23, color: AppColors.green, fontWeight: FontWeight.w900)),
              Text('Kualitas visual baik', style: TextStyle(fontWeight: FontWeight.w600)),
            ])),
          ]),
        ),
        const SizedBox(height: 18),
        const Text('Tingkat Keyakinan (Simulasi)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        const SizedBox(height: 9),
        ClipRRect(borderRadius: BorderRadius.circular(20), child: const LinearProgressIndicator(value: .926, minHeight: 10, color: AppColors.green, backgroundColor: Color(0xFFDDE6DC))),
        const SizedBox(height: 8),
        const Text('92,6%', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.green, fontSize: 18)),
        const SizedBox(height: 16),
        const Text('Keterangan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        const SizedBox(height: 6),
        const Text('Pada rancangan grading, Grade A ditujukan untuk pisang dengan kondisi visual baik, bentuk relatif baik, dan kerusakan permukaan minimal.', style: TextStyle(color: AppColors.muted, height: 1.5)),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: const Color(0xFFFFF4CF), borderRadius: BorderRadius.circular(14)), child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.info_outline, color: Color(0xFF8A6500)), SizedBox(width: 8), Expanded(child: Text('Ini adalah hasil contoh untuk menguji tampilan. Prediksi grade dan persentase belum berasal dari model CNN.', style: TextStyle(color: Color(0xFF6C5200), height: 1.4, fontSize: 12)))])),
        const SizedBox(height: 20),
        ElevatedButton.icon(onPressed: (_saving || _saved) ? null : _save, icon: Icon(_saved ? Icons.check : Icons.save_alt), label: Text(_saving ? 'Menyimpan...' : _saved ? 'Tersimpan' : 'Simpan ke Riwayat')),
        const SizedBox(height: 10),
        OutlinedButton(onPressed: () => Navigator.of(context).pop(_saved), child: const Text('Kembali')),
      ]),
    );
  }
}
