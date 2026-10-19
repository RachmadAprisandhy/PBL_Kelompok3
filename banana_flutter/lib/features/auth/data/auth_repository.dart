import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.register,
      data: {'name': name, 'email': email, 'password': password},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> loginWithGoogle(String accessToken) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.loginGoogle,
      data: {'access_token': accessToken},
    );
    return response.data;
  }

  Future<void> logout() async {
    await _apiClient.dio.post(ApiEndpoints.logout);
  }
}