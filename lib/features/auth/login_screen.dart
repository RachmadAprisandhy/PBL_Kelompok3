import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/banana_logo.dart';
import '../home/app_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

void _enterApp() {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (_) => const AppShell()), // Tanpa const
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
          child: Column(
            children: [
              const BananaLogo(compact: true),
              const SizedBox(height: 10),
              const Text('Deteksi Grading Buah Pisang Menggunakan CNN', textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, height: 1.4)),
              const SizedBox(height: 34),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.email_outlined), hintText: 'Email atau Nomor HP'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_outline), hintText: 'Password'),
              ),
              const SizedBox(height: 18),
              ElevatedButton(onPressed: _enterApp, child: const Text('Masuk')),
              const SizedBox(height: 20),
              const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('atau', style: TextStyle(color: AppColors.muted))), Expanded(child: Divider())]),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: _enterApp,
                icon: const Icon(Icons.login),
                label: const Text('Lanjutkan sebagai tamu'),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50), foregroundColor: AppColors.darkGreen, side: const BorderSide(color: AppColors.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              ),
              const SizedBox(height: 18),
              const Text('Login hanya tampilan prototipe dan belum terhubung autentikasi.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.muted)),
            ],
          ),
        ),
      ),
    );
  }
}
