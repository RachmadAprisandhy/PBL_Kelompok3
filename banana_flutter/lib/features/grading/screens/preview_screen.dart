import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../providers/grading_provider.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gradingProvider = Provider.of<GradingProvider>(context);
    final imageFile = gradingProvider.selectedImage;

    if (imageFile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pratinjau Foto')),
        body: const Center(child: Text('Tidak ada foto yang dipilih.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pratinjau Foto')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Periksa kembali foto pisang Anda sebelum dianalisis oleh AI.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(imageFile, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Gunakan Foto',
                icon: Icons.check_circle_outline,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/processing');
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Pilih Ulang',
                      isOutlined: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Batal',
                      isOutlined: true,
                      backgroundColor: AppColors.danger,
                      textColor: AppColors.danger,
                      onPressed: () {
                        gradingProvider.setSelectedImage(null);
                        Navigator.popUntil(context, ModalRoute.withName('/home'));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}