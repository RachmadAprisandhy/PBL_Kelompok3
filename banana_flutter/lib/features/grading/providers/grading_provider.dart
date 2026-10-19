import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/utils/tflite_helper.dart';

class GradingProvider extends ChangeNotifier {
  final TfliteHelper _tfliteHelper = TfliteHelper();

  File? _selectedImage;
  bool _isProcessing = false;
  String? _errorMessage;

  File? get selectedImage => _selectedImage;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;

  void setSelectedImage(File? file) {
    _selectedImage = file;
    _errorMessage = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> analyzeCurrentImage() async {
    if (_selectedImage == null) return null;

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _tfliteHelper.classifyImage(_selectedImage!);
      _isProcessing = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isProcessing = false;
      _errorMessage = 'Foto gagal diproses oleh model AI. Pastikan gambar tidak rusak.';
      notifyListeners();
      return null;
    }
  }
}