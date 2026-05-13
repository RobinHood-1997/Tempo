import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timer_provider.dart';
import '../widgets/timer_ring.dart';
import '../widgets/task_tag_selector.dart';
import '../widgets/animated_background.dart';
import '../widgets/completion_burst.dart';
import 'stats_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedTask = 'Work';
  bool _showBurst = false;
  bool _wasRunning = false;

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(timerProvider);

    // Detect session completion — trigger burst
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_wasRunning && !timer.isRunning && timer.progress == 1.0) {
        if (mounted) setState(() => _showBurst = true);
        HapticFeedback.heavyImpact();
      }
      _wasRunning = timer.isRunning;
    });

    return AnimatedBackground(
      isBreak: timer.isBreak,
      isRunning: timer.isRunning,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              timer.isBreak ? 'Break Time ✦' : 'Focus Timer',
              key: ValueKey(timer.isBreak),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.w300,
                letterSpacing: 1,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.bar_chart_rounded,
                color: Colors.white38,
              ),
              onPressed: () => Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, animation, __) => const StatsScreen(),
                  transitionsBuilder: (_, animation, __, child) {
                    // Smooth slide up transition
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Timer ring
                Center(
                  child: TimerRing(
                    progress: timer.progress,
                    timeLabel: timer.timeLabel,
                    isRunning: timer.isRunning,
                    isBreak: timer.isBreak,
                  ),
                ),

                const SizedBox(height: 52),

                // Tag selector
                TaskTagSelector(
                  selectedTag: _selectedTask,
                  onTagSelected: (tag) {
                    setState(() => _selectedTask = tag);
                    ref.read(timerProvider.notifier).setTaskType(tag);
                  },
                ),

                const SizedBox(height: 52),

                // Start / Pause button
                _AnimatedStartButton(
                  isRunning: timer.isRunning,
                  isBreak: timer.isBreak,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    ref.read(timerProvider.notifier).startPause();
                  },
                ),

                const SizedBox(height: 20),

                // Reset
                AnimatedOpacity(
                  opacity: timer.isRunning ? 0.0 : 0.4,
                  duration: const Duration(milliseconds: 300),
                  child: TextButton(
                    onPressed: timer.isRunning
                        ? null
                        : () => ref.read(timerProvider.notifier).reset(),
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Particle burst overlay
            if (_showBurst)
              CompletionBurst(
                onComplete: () {
                  if (mounted) setState(() => _showBurst = false);
                },
              ),
          ],
        ),
      ),
    );
  }
}

// Separate widget for the animated start button
class _AnimatedStartButton extends StatelessWidget {
  final bool isRunning;
  final bool isBreak;
  final VoidCallback onPressed;

  const _AnimatedStartButton({
    required this.isRunning,
    required this.isBreak,
    required this.onPressed,
  });

  Color get _color => isBreak
      ? const Color(0xFF26A69A)
      : const Color(0xFF5C6BC0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: isRunning ? 40 : 52,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: isRunning
              ? Colors.white.withOpacity(0.07)
              : _color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          boxShadow: isRunning
              ? []
              : [
                  BoxShadow(
                    color: _color.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 6),
                  ),
                ],
          border: Border.all(
            color: isRunning ? Colors.white12 : Colors.transparent,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            isRunning ? 'Pause' : (isBreak ? 'Start Break' : 'Start Focus'),
            key: ValueKey('$isRunning$isBreak'),
            style: TextStyle(
              color: isRunning ? Colors.white38 : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}