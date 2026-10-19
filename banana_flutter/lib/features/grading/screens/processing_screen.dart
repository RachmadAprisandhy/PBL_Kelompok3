import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../providers/grading_provider.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startGrading());
  }

  Future<void> _startGrading() async {
    final gradingProvider = Provider.of<GradingProvider>(context, listen: false);
    await Future.delayed(const Duration(milliseconds: 800));
    final result = await gradingProvider.analyzeCurrentImage();

    if (!mounted) return;
    if (result != null) {
      Navigator.pushReplacementNamed(
        context,
        '/result',
        arguments: {
          'grade': result['grade'],
          'confidence': result['confidence'],
          'imagePath': gradingProvider.selectedImage!.path,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradingProvider = Provider.of<GradingProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: gradingProvider.errorMessage != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 72, color: AppColors.danger),
                      const SizedBox(height: 16),
                      Text(
                        gradingProvider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Coba Foto Lain',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (gradingProvider.selectedImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            gradingProvider.selectedImage!,
                            height: 220,
                            width: 220,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 32),
                      const CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: 20),
                      const Text(
                        'Sedang menganalisis kualitas pisang…',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Menggunakan TensorFlow Lite (Offline)',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}