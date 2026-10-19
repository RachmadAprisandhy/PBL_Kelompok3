import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/banana_illustration.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Center(
                  child: BananaIllustration(size: 120, showCameraBadge: true),
                ),
                const SizedBox(height: 20),
                Text(
                  "Selamat Datang Kembali!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Masuk untuk mulai mengidentifikasi\nkualitas pisang",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),

                // Input Username / Email (Gaya Mockup)
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Username atau Email",
                    filled: true,
                    fillColor: const Color(0xFFF1F5EC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF90A993)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF90A993)),
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Harap isi email atau username Anda" : null,
                ),
                const SizedBox(height: 14),

                // Input Kata Sandi (Gaya Mockup)
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: "Kata Sandi",
                    filled: true,
                    fillColor: const Color(0xFFF1F5EC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF90A993)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF90A993)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Harap isi kata sandi Anda" : null,
                ),

                // Lupa Kata Sandi
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Hubungi administrator atau gunakan akun default: admin / password123'),
                        ),
                      );
                    },
                    child: const Text(
                      "Lupa Kata Sandi?",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Tombol Masuk (Bentuk Pill / Kapsul sesuai Mockup)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: auth.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            final success = await auth.login(
                              _emailController.text.trim(),
                              _passwordController.text,
                            );
                            if (!context.mounted) return;
                            if (success) {
                              Navigator.pushReplacementNamed(context, '/home');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(auth.errorMessage ?? 'Gagal masuk.'),
                                  backgroundColor: AppColors.danger,
                                ),
                              );
                            }
                          }
                        },
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text("Masuk", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),

                // Pembatas "--- atau ---" sesuai Mockup
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("atau", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                  ],
                ),
                const SizedBox(height: 20),

                // Tombol Masuk dengan Google (Bentuk Pill sesuai Mockup)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: auth.isLoading
                      ? null
                      : () async {
                          final success = await auth.loginWithGoogle();
                          if (success && context.mounted) {
                            Navigator.pushReplacementNamed(context, '/home');
                          }
                        },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        image: AssetImage('assets/icons/google_logo.png'),
                        width: 20,
                        height: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Masuk dengan Google",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Link Daftar di bawah
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Belum punya akun? ",
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 13.5),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: const Text(
                        "Daftar",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}