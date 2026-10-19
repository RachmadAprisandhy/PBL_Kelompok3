import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../providers/grading_provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _autoTriggered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_autoTriggered) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['source'] != null) {
        _autoTriggered = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _pickImage(args['source'] == 'camera' ? ImageSource.camera : ImageSource.gallery);
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked != null && mounted) {
      Provider.of<GradingProvider>(context, listen: false).setSelectedImage(File(picked.path));
      Navigator.pushNamed(context, '/preview');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ambil / Pilih Foto Pisang')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.secondary, width: 2),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.center_focus_strong_rounded, size: 80, color: AppColors.primary),
                    const SizedBox(height: 20),
                    const Text(
                      'Petunjuk Pengambilan Foto',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    _buildTip('Pastikan objek pisang terlihat utuh dan jelas.'),
                    _buildTip('Gunakan pencahayaan yang cukup (tidak gelap/silau).'),
                    _buildTip('Hindari objek lain yang menutupi permukaan kulit pisang.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Ambil Foto dari Kamera',
              icon: Icons.camera_alt_rounded,
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Pilih dari Galeri',
              icon: Icons.photo_library_rounded,
              isOutlined: true,
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13.5))),
        ],
      ),
    );
  }
}