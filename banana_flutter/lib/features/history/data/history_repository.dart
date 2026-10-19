import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/database/db_helper.dart';
import '../../../core/network/api_client.dart';

class HistoryRepository {
  final DbHelper _dbHelper = DbHelper();
  final ApiClient _apiClient = ApiClient();

  Future<List<Map<String, dynamic>>> getLocalHistory() => _dbHelper.getAllGradings();

  Future<void> syncSingleItem(Map<String, dynamic> item) async {
    final file = File(item['image_path']);
    if (!await file.exists()) return;

    final formData = FormData.fromMap({
      'local_id': item['id'],
      'grade': item['grade'],
      'confidence': item['confidence'],
      'created_at': item['created_at'],
      'image': await MultipartFile.fromFile(file.path, filename: 'grading_${item['id']}.jpg'),
    });

    final response = await _apiClient.dio.post(ApiEndpoints.sync, data: formData);
    if (response.statusCode == 200 || response.statusCode == 201) {
      await _dbHelper.markAsSynced(item['id']);
    }
  }
}