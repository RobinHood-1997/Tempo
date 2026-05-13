import 'package:flutter/material.dart';
import 'dart:math';

class CompletionBurst extends StatefulWidget {
  final VoidCallback onComplete;

  const CompletionBurst({super.key, required this.onComplete});

  @override
  State<CompletionBurst> createState() => _CompletionBurstState();
}

class _CompletionBurstState extends State<CompletionBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  // Generate 20 particles with random properties
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = List.generate(20, (_) => _Particle(_random));

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward().whenComplete(widget.onComplete);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _BurstPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _Particle {
  final double angle;
  final double speed;
  final double size;
  final Color color;

  _Particle(Random random)
      : angle = random.nextDouble() * 2 * pi,
        speed = 80 + random.nextDouble() * 140,
        size = 3 + random.nextDouble() * 5,
        color = [
          const Color(0xFF7986CB),
          const Color(0xFF26A69A),
          const Color(0xFFEC407A),
          Colors.white,
          const Color(0xFFFFD54F),
        ][random.nextInt(5)];
}

class _BurstPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _BurstPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final p in particles) {
      // Ease out — fast at start, slow at end
      final eased = Curves.easeOut.transform(progress);
      final distance = p.speed * eased;

      final x = center.dx + cos(p.angle) * distance;
      final y = center.dy + sin(p.angle) * distance;

      // Fade out as progress increases
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      canvas.drawCircle(
        Offset(x, y),
        p.size * (1 - progress * 0.5),
        Paint()..color = p.color.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.progress != progress;
}