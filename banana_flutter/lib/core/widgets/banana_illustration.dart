
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class BananaIllustration extends StatelessWidget {
  final double size;
  final bool showCameraBadge;

  const BananaIllustration({
    super.key,
    this.size = 160,
    this.showCameraBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.95,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Gambar tandan pisang dari PNG transparan.
          Positioned(
            bottom: 0,
            child: Image.asset(
              'assets/images/Banana.png',
              width: size,
              height: size * 0.78,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return SizedBox(
                  width: size,
                  height: size * 0.78,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),

          // Badge centang dan ornamen kilau.
          if (showCameraBadge) ...[
            Positioned(
              top: size * 0.10,
              child: Container(
                padding: EdgeInsets.all(size * 0.07),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.accent,
                  size: size * 0.22,
                ),
              ),
            ),
            Positioned(
              top: size * 0.2,
              left: size * 0.08,
              child: Icon(
                Icons.auto_awesome,
                color: AppColors.accent,
                size: size * 0.14,
              ),
            ),
            Positioned(
              top: size * 0.2,
              right: size * 0.08,
              child: Icon(
                Icons.auto_awesome,
                color: AppColors.accent,
                size: size * 0.12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}