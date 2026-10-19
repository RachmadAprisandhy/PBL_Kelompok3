import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../../../core/database/db_helper.dart';

class HistoryProvider extends ChangeNotifier {
  final DbHelper _dbHelper = DbHelper();
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://YOUR_SERVER_IP/api'));

  List<Map<String, dynamic>> _historyList = [];
  bool _isLoading = false;
  bool _isSyncing = false;

  List<Map<String, dynamic>> get historyList => _historyList;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;

  Future<void> fetchHistory() async {
    _isLoading = true;
    notifyListeners();
    _historyList = await _dbHelper.getAllGradings();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addGradingLocal({
    required String id,
    required String? userId,
    required String grade,
    required double confidence,
    required String imagePath,
  }) async {
    final timestamp = DateTime.now().toIso8601String();
    await _dbHelper.insertGrading({
      'id': id,
      'user_id': userId,
      'grade': grade,
      'confidence': confidence,
      'image_path': imagePath,
      'created_at': timestamp,
      'is_synced': 0
    });
    await fetchHistory();
    attemptSync(); // Coba sync langsung jika online
  }

  Future<void> attemptSync() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return;

    final unsynced = await _dbHelper.getUnsyncedGradings();
    if (unsynced.isEmpty) return;

    _isSyncing = true;
    notifyListeners();

    for (var item in unsynced) {
      try {
        final File file = File(item['image_path']);
        if (!await file.exists()) continue;

        FormData formData = FormData.fromMap({
          'local_id': item['id'],
          'grade': item['grade'],
          'confidence': item['confidence'],
          'created_at': item['created_at'],
          'image': await MultipartFile.fromFile(file.path, filename: 'grading_${item['id']}.jpg'),
        });

        // Misal divalidasi dan diotorisasi menggunakan user token yang tersimpan di Auth
        final response = await _dio.post(
          '/sync',
          data: formData,
          options: Options(headers: {
            'Accept': 'application/json',
            // Tambahkan auth header jika User login
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          await _dbHelper.markAsSynced(item['id']);
        }
      } catch (e) {
        print('Gagal Sinkronisasi untuk ID ${item['id']}: $e');
      }
    }

    _isSyncing = false;
    await fetchHistory();
  }

  Future<void> deleteHistory(String id) async {
    await _dbHelper.deleteGrading(id);
    await fetchHistory();
  }
}