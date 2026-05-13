import 'package:flutter/material.dart';
import 'dart:math';

class TimerRing extends StatefulWidget {
  final double progress;
  final String timeLabel;
  final bool isRunning;
  final bool isBreak;

  const TimerRing({
    super.key,
    required this.progress,
    required this.timeLabel,
    required this.isRunning,
    required this.isBreak,
  });

  @override
  State<TimerRing> createState() => _TimerRingState();
}

class _TimerRingState extends State<TimerRing>
    with TickerProviderStateMixin {
  // Breathing animation — idle pulse
  late AnimationController _breathController;
  late Animation<double> _breathAnim;

  // Glow pulse when running
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    // Slow breathing — 3 seconds in, 3 seconds out
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _breathAnim = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    // Glow pulse when running — faster
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  // Color shifts between focus (indigo) and break (teal)
  Color get _primaryColor => widget.isBreak
      ? const Color(0xFF26A69A)
      : const Color(0xFF7986CB);

  Color get _glowColor => widget.isBreak
      ? const Color(0xFF26A69A).withOpacity(0.3)
      : const Color(0xFF5C6BC0).withOpacity(0.3);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breathAnim, _glowAnim]),
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isRunning ? 1.0 : _breathAnim.value,
          child: SizedBox(
            width: 260,
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring — only when running
                if (widget.isRunning)
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _glowColor.withOpacity(
                              _glowAnim.value * 0.4),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),

                // The actual arc ring
                CustomPaint(
                  size: const Size(260, 260),
                  painter: _GlowRingPainter(
                    progress: widget.progress,
                    primaryColor: _primaryColor,
                    glowOpacity: widget.isRunning ? _glowAnim.value : 0.3,
                    isRunning: widget.isRunning,
                  ),
                ),

                // Center content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Mode label
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        widget.isBreak ? 'BREAK' : 'FOCUS',
                        key: ValueKey(widget.isBreak),
                        style: TextStyle(
                          color: _primaryColor.withOpacity(0.7),
                          fontSize: 11,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Timer digits
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        color: Colors.white.withOpacity(
                            widget.isRunning ? 1.0 : 0.6),
                        fontSize: 52,
                        fontWeight: FontWeight.w200,
                        letterSpacing: 2,
                      ),
                      child: Text(widget.timeLabel),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Enhanced painter with glow effect on the arc
class _GlowRingPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final double glowOpacity;
  final bool isRunning;

  _GlowRingPainter({
    required this.progress,
    required this.primaryColor,
    required this.glowOpacity,
    required this.isRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;

    // Background track
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // Glow layer — slightly thicker, more transparent
    if (isRunning) {
      final glowPaint = Paint()
        ..color = primaryColor.withOpacity(glowOpacity * 0.4)
        ..strokeWidth = 20
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        glowPaint,
      );
    }

    // Main arc
    final arcPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: -pi / 2 + (2 * pi * progress),
        colors: [
          primaryColor.withOpacity(0.6),
          primaryColor,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      arcPaint,
    );

    // Bright dot at the tip of the arc
    final tipAngle = -pi / 2 + (2 * pi * progress);
    final tipX = center.dx + radius * cos(tipAngle);
    final tipY = center.dy + radius * sin(tipAngle);

    final dotPaint = Paint()
      ..color = primaryColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(Offset(tipX, tipY), 6, dotPaint);

    // Solid dot on top
    canvas.drawCircle(
      Offset(tipX, tipY),
      4,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_GlowRingPainter old) =>
      old.progress != progress ||
      old.glowOpacity != glowOpacity ||
      old.isRunning != isRunning;
}