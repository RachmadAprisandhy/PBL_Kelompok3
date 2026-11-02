import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class TutorialTargetItem {
  const TutorialTargetItem({
    required this.key,
    required this.number,
    required this.title,
    required this.description,
    this.isCircleShape = false,
  });

  final GlobalKey key;
  final int number;
  final String title;
  final String description;
  final bool isCircleShape;
}

class TutorialOverlay extends StatefulWidget {
  const TutorialOverlay({
    super.key,
    required this.targets,
    required this.onFinish,
  });

  final List<TutorialTargetItem> targets;
  final VoidCallback onFinish;

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  int _activeIndex = 0;
  bool _showAllAtOnce = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Rect? _getTargetRect(GlobalKey key) {
    final renderObject = key.currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      final offset = renderObject.localToGlobal(Offset.zero);
      return offset & renderObject.size;
    }
    return null;
  }

  void _nextStep() {
    if (_activeIndex < widget.targets.length - 1) {
      setState(() => _activeIndex++);
    } else {
      widget.onFinish();
    }
  }

  void _prevStep() {
    if (_activeIndex > 0) {
      setState(() => _activeIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final activeTarget = widget.targets[_activeIndex];
    final activeRect = _getTargetRect(activeTarget.key);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 1. Layar Gelap dengan Lubang Sorotan (Spotlight Cutout)
          GestureDetector(
            onTap: _showAllAtOnce ? null : _nextStep,
            child: CustomPaint(
              size: screenSize,
              painter: _SpotlightPainter(
                targetRect: _showAllAtOnce ? null : activeRect,
                isCircle: activeTarget.isCircleShape,
              ),
            ),
          ),

          // 2. Lingkaran Kecil Berdenyut di SETIAP Fitur pada Halaman Utama
          ...List.generate(widget.targets.length, (index) {
            final item = widget.targets[index];
            final rect = _getTargetRect(item.key);
            if (rect == null) return const SizedBox.shrink();

            final isSelected = !_showAllAtOnce && index == _activeIndex;
            final badgeLeft = item.isCircleShape
                ? rect.center.dx - 16
                : (rect.left + 8).clamp(8.0, screenSize.width - 44.0);
            final badgeTop = item.isCircleShape
                ? rect.top - 14
                : (rect.top - 12).clamp(48.0, screenSize.height - 80.0);

            return Positioned(
              left: badgeLeft,
              top: badgeTop,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showAllAtOnce = false;
                    _activeIndex = index;
                  });
                },
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    final scale = isSelected
                        ? 1.0 + (_pulseController.value * 0.18)
                        : 1.0 + (_pulseController.value * 0.08);
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.scale(
                          scale: scale + 0.25,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (isSelected
                                      ? AppColors.yellow
                                      : Colors.white)
                                  .withOpacity(0.35 * (1 - _pulseController.value * 0.5)),
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppColors.yellow
                                  : AppColors.green,
                              border: Border.all(color: Colors.white, width: 2.2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${item.number}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: isSelected
                                    ? AppColors.darkGreen
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          }),

          // 3A. Mode "Lihat Semua": Tampilkan Teks Singkat di Setiap Fitur Sekaligus
          if (_showAllAtOnce)
            ...List.generate(widget.targets.length, (index) {
              final item = widget.targets[index];
              final rect = _getTargetRect(item.key);
              if (rect == null) return const SizedBox.shrink();

              final topPos = item.isCircleShape
                  ? rect.top - 66
                  : (rect.top + 16).clamp(70.0, screenSize.height - 130.0);

              return Positioned(
                left: 24,
                right: 24,
                top: topPos,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showAllAtOnce = false;
                      _activeIndex = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.96),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.green, width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 13,
                          backgroundColor: AppColors.green,
                          child: Text(
                            '${item.number}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                              Text(
                                item.description,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.text,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

          // 3B. Mode Langkah: Tampilkan Balon Teks Singkat di Dekat Fitur yang Disorot
          if (!_showAllAtOnce && activeRect != null)
            _buildStepCalloutCard(context, screenSize, activeRect, activeTarget),

          // 4. Bar Kontrol Atas
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          color: AppColors.yellow,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Petunjuk Fitur',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.92),
                      foregroundColor: AppColors.darkGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      setState(() => _showAllAtOnce = !_showAllAtOnce);
                    },
                    icon: Icon(
                      _showAllAtOnce
                          ? Icons.filter_1_rounded
                          : Icons.visibility_rounded,
                      size: 15,
                    ),
                    label: Text(
                      _showAllAtOnce ? 'Mode Langkah' : 'Lihat Semua',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.65),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: widget.onFinish,
                    tooltip: 'Tutup Tutorial',
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            ),
          ),

          if (_showAllAtOnce)
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  foregroundColor: AppColors.darkGreen,
                ),
                onPressed: widget.onFinish,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Mengerti, Mulai Gunakan Aplikasi'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepCalloutCard(
    BuildContext context,
    Size screenSize,
    Rect targetRect,
    TutorialTargetItem item,
  ) {
    final bool showBelow = targetRect.center.dy < screenSize.height * 0.55;
    final double cardTop = showBelow
        ? (targetRect.bottom + 14).clamp(80.0, screenSize.height - 230.0)
        : (targetRect.top - 185).clamp(70.0, screenSize.height - 230.0);

    return Positioned(
      left: 20,
      right: 20,
      top: cardTop,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.yellow, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.green,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${item.number}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ),
                Text(
                  '${_activeIndex + 1}/${widget.targets.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.text,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                TextButton(
                  onPressed: widget.onFinish,
                  child: const Text(
                    'Lewati',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (_activeIndex > 0)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                    ),
                    onPressed: _prevStep,
                    child: const Text('Sebelumnya', style: TextStyle(fontSize: 12)),
                  ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                  ),
                  onPressed: _nextStep,
                  icon: Icon(
                    _activeIndex == widget.targets.length - 1
                        ? Icons.check_rounded
                        : Icons.arrow_forward_rounded,
                    size: 16,
                  ),
                  label: Text(
                    _activeIndex == widget.targets.length - 1
                        ? 'Selesai'
                        : 'Lanjut',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter({
    required this.targetRect,
    required this.isCircle,
  });

  final Rect? targetRect;
  final bool isCircle;

  @override
  void paint(Canvas canvas, Size size) {
    final fullPath = Path()..addRect(Offset.zero & size);

    if (targetRect == null) {
      canvas.drawPath(
        fullPath,
        Paint()..color = Colors.black.withOpacity(0.55),
      );
      return;
    }

    final paddedRect = targetRect!.inflate(6);
    final holePath = Path();
    if (isCircle) {
      holePath.addOval(
        Rect.fromCircle(
          center: paddedRect.center,
          radius: paddedRect.shortestSide / 2 + 4,
        ),
      );
    } else {
      holePath.addRRect(
        RRect.fromRectAndRadius(paddedRect, const Radius.circular(20)),
      );
    }

    final overlayPath = Path.combine(
      PathOperation.difference,
      fullPath,
      holePath,
    );

    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black.withOpacity(0.62),
    );

    final borderPaint = Paint()
      ..color = AppColors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    if (isCircle) {
      canvas.drawCircle(
        paddedRect.center,
        paddedRect.shortestSide / 2 + 4,
        borderPaint,
      );
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(paddedRect, const Radius.circular(20)),
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.isCircle != isCircle;
  }
}