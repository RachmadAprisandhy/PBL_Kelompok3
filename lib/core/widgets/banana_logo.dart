import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BananaLogo extends StatelessWidget {
  const BananaLogo({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 64 : 88,
          height: compact ? 64 : 88,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5C9),
            borderRadius: BorderRadius.circular(compact ? 18 : 26),
          ),
          alignment: Alignment.center,
          child: Text(compact ? '🍌' : '🍌', style: TextStyle(fontSize: compact ? 38 : 54)),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: compact ? 22 : 29,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
            children: const [
              TextSpan(text: 'Banana', style: TextStyle(color: AppColors.darkGreen)),
              TextSpan(text: 'Grade', style: TextStyle(color: Color(0xFFE9A900))),
            ],
          ),
        ),
      ],
    );
  }
}
