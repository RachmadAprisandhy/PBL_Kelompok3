class ApiEndpoints {
  // Ganti dengan IP lokal komputer Anda (misal 192.168.1.x) jika menggunakan HP fisik,
  static const String baseUrl = 'http://192.168.66.106:8000/api';

  static const String login = '/login';
  static const String register = '/register';
  static const String loginGoogle = '/login/google';
  static const String logout = '/logout';
  static const String sync = '/sync';
}