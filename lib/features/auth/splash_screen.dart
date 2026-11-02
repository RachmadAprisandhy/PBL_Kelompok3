import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/banana_logo.dart';
import '../home/app_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _pulseController;
  late final AnimationController _floatController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textFade;
  late final Animation<double> _progressValue;

  Timer? _autoNavigateTimer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.4, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.45),
      ),
    );

    _logoFade = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.30, curve: Curves.easeIn),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.28, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _textFade = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.28, 0.65, curve: Curves.easeIn),
    );

    _progressValue = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.35, 1.0, curve: Curves.easeInOut),
    );

    _mainController.forward();

    // Otomatis masuk ke halaman utama (Dashboard) setelah animasi selesai
    _autoNavigateTimer = Timer(const Duration(milliseconds: 3600), _goToHome);
  }

  void _goToHome() {
    if (_navigated || !mounted) return;
    _navigated = true;
    _autoNavigateTimer?.cancel();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: const AppShell(showTutorialOnInit: true),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _autoNavigateTimer?.cancel();
    _mainController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFDF5),
              Color(0xFFFFF4C2),
              Color(0xFFE7F5E8),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Ornamen Latar Belakang Melayang (Floating Decorations)
            AnimatedBuilder(
              animation: _floatController,
              builder: (context, _) {
                final dy = math.sin(_floatController.value * math.pi) * 10;
                return Stack(
                  children: [
                    Positioned(
                      top: 60 + dy,
                      left: -25,
                      child: _buildBgCircle(130, AppColors.lime.withOpacity(0.18)),
                    ),
                    Positioned(
                      bottom: 110 - dy,
                      right: -35,
                      child: _buildBgCircle(160, AppColors.yellow.withOpacity(0.22)),
                    ),
                    Positioned(
                      top: 110 - dy * 0.7,
                      right: 36,
                      child: Opacity(
                        opacity: 0.45,
                        child: Transform.rotate(
                          angle: 0.25,
                          child: const Text('🍃', style: TextStyle(fontSize: 32)),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 190 + dy * 0.8,
                      left: 34,
                      child: Opacity(
                        opacity: 0.45,
                        child: Transform.rotate(
                          angle: -0.2,
                          child: const Text('🍃', style: TextStyle(fontSize: 28)),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Konten Utama Splash Screen
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Logo dengan Animasi Pulse Ring & Scale Bounce
                    AnimatedBuilder(
                      animation: Listenable.merge([_mainController, _pulseController]),
                      builder: (context, child) {
                        final pulseScale = 1.0 + (_pulseController.value * 0.12);
                        return Opacity(
                          opacity: _logoFade.value,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Transform.scale(
                                  scale: pulseScale,
                                  child: Container(
                                    width: 148,
                                    height: 148,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.yellow.withOpacity(
                                        0.22 * (1 - _pulseController.value * 0.4),
                                      ),
                                    ),
                                  ),
                                ),
                                Transform.scale(
                                  scale: 1.0 + (_pulseController.value * 0.05),
                                  child: Container(
                                    width: 118,
                                    height: 118,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.green.withOpacity(0.08),
                                    ),
                                  ),
                                ),
                                child!,
                              ],
                            ),
                          ),
                        );
                      },
                      child: const BananaLogo(),
                    ),

                    const SizedBox(height: 20),

                    // Teks Judul & Badge Fitur dengan Animasi Slide + Fade
                    FadeTransition(
                      opacity: _textFade,
                      child: SlideTransition(
                        position: _textSlide,
                        child: Column(
                          children: [
                            const Text(
                              'Deteksi Grading Buah Pisang\nMenggunakan CNN',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.text,
                                height: 1.45,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 16,
                                    color: AppColors.green,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Selamat Datang di BananaGrade!',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.darkGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Progress Bar Animasi & Tombol Masuk ke Beranda
                    AnimatedBuilder(
                      animation: _progressValue,
                      builder: (context, _) {
                        return Column(
                          children: [
                            SizedBox(
                              width: 200,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: _progressValue.value,
                                  minHeight: 6,
                                  backgroundColor: Colors.white,
                                  color: AppColors.green,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Memuat halaman utama... ${(_progressValue.value * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: _goToHome,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text('Masuk ke Beranda'),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Prototipe aplikasi BananaGrade',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBgCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}