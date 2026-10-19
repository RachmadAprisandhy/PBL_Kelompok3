import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TfliteHelper {
  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('banana_classifier.tflite');
      final labelData = await rootBundle.loadString('android/app/src/main/assets/labels.txt');
      _labels = labelData.split('\n').where((s) => s.isNotEmpty).toList();
    } catch (e) {
      print('Gagal memuat model TFLite: $e');
    }
  }

  Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    if (_interpreter == null || _labels == null) {
      await loadModel();
    }

    // Baca & Preprocess Gambar (Resizing sesuai spesifikasi input Model CNN, misal 224x224)
    final imageBytes = await imageFile.readAsBytes();
    final originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) throw Exception("Gambar tidak dapat dibaca");

    final resizedImage = img.copyResize(originalImage, width: 224, height: 224);
    
    // Konversi ke format Byte Buffer (Normalized Input)
    var input = Float32List(1 * 224 * 224 * 3);
    var pixelIndex = 0;
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        final pixel = resizedImage.getPixel(x, y);
        input[pixelIndex++] = (pixel.r - 0.0) / 255.0; // r
        input[pixelIndex++] = (pixel.g - 0.0) / 255.0; // g
        input[pixelIndex++] = (pixel.b - 0.0) / 255.0; // b
      }
    }

    // Persiapkan Buffer Output, misal 3 kelas: [Grade A, Grade B, Grade C]
    var output = List.filled(1 * 3, 0.0).reshape([1, 3]);

    _interpreter!.run(input.buffer.asFloat32List(), output);

    List<double> results = List<double>.from(output[0]);
    
    // Cari index dengan probabilitas/ confidence score terbesar
    int maxIndex = 0;
    double maxConfidence = 0.0;
    for (int i = 0; i < results.length; i++) {
      if (results[i] > maxConfidence) {
        maxConfidence = results[i];
        maxIndex = i;
      }
    }

    return {
      'grade': _labels![maxIndex].trim(), // 'Grade A', 'Grade B', atau 'Grade C'
      'confidence': maxConfidence,        // Nilai probabilitas (0.0 - 1.0)
    };
  }

  void close() {
    _interpreter?.close();
  }
}