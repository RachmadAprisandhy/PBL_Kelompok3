
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

class GradingApi {
  // Alamat FastAPI di laptop
  static const String baseUrl = 'http://192.168.66.13:8000'; // Ganti dengan alamat IP laptop Anda

  // Konfigurasi Dio
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
    ),
  );

  // Mengirim gambar ke FastAPI untuk prediksi
  Future<Map<String, dynamic>> predict(String imagePath) async {
    try {
      // Membuat multipart form data
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imagePath,
          filename: p.basename(imagePath),
        ),
      });

      // Mengirim gambar ke endpoint /predict
      final response = await _dio.post(
        '/predict',
        data: formData,
      );

      // Memeriksa status response
      if (response.data['status'] != 'success') {
        throw Exception('Prediksi gagal dilakukan.');
      }

      // Mengembalikan hasil prediksi
      return Map<String, dynamic>.from(response.data);

    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['detail']?.toString()
          : e.message;

      throw Exception(
        message ?? 'Tidak dapat terhubung ke server.',
      );
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}

