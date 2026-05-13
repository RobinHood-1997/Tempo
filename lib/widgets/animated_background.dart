import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final bool isBreak;
  final bool isRunning;
  final Widget child;

  const AnimatedBackground({
    super.key,
    required this.isBreak,
    required this.isRunning,
    required this.child,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Focus mode colors
  List<Color> get _focusColors => [
        const Color(0xFF0D0D1A),
        const Color(0xFF1A1A2E),
        const Color(0xFF16213E),
      ];

  // Break mode colors — warmer, calmer
  List<Color> get _breakColors => [
        const Color(0xFF0D1A1A),
        const Color(0xFF1A2E2E),
        const Color(0xFF0D2137),
      ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final colors = widget.isBreak ? _breakColors : _focusColors;
        return AnimatedContainer(
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                -0.3 + (_animation.value * 0.6),
                -0.5 + (_animation.value * 0.3),
              ),
              radius: 1.5,
              colors: colors,
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}