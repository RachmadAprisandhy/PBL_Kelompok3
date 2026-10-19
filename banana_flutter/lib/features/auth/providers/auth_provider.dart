import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://192.168.66.106:8000/api'));
  
  String? _token;
  Map<String, dynamic>? _user;
  bool _isLoading = false;

  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;
  String? get token => _token;

  AuthProvider() {
    _loadSession();
  }

  String? get errorMessage => null;

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    final name = prefs.getString('user_name');
    final email = prefs.getString('user_email');
    if (_token != null && name != null && email != null) {
      _user = {'name': name, 'email': email};
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        await _saveSession(response.data['token'], response.data['user']);
        return true;
      }
    } catch (e) {
      print('Gagal Login: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false; // User batal sign in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final response = await _dio.post('/login/google', data: {
        'access_token': googleAuth.accessToken,
      });

      if (response.statusCode == 200) {
        await _saveSession(response.data['token'], response.data['user']);
        return true;
      }
    } catch (e) {
      print('Gagal Google Login: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout', options: Options(headers: {
        'Authorization': 'Bearer $_token'
      }));
    } catch (_) {}
    
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _googleSignIn.signOut();
    notifyListeners();
  }

  Future<void> _saveSession(String token, Map<String, dynamic> userData) async {
    _token = token;
    _user = userData;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_name', userData['name']);
    await prefs.setString('user_email', userData['email']);
  }
}

extension on GoogleSignInAuthentication {
  get accessToken => null;
}

extension on GoogleSignIn {
  Future<GoogleSignInAccount?> signIn() async {
    return await authenticate();
  }
}