import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/insight_provider.dart';
import '../providers/timer_provider.dart';
import '../repositories/session_repository.dart';
import '../models/session_model.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(sessionRepositoryProvider);
    final sessions = repo.getAllSessions();
    final streak = repo.getCurrentStreak();
    final engine = ref.read(insightEngineProvider);
    final currentTask = ref.read(timerProvider).taskType;
    final insights = engine.generateInsights(currentTask);
    final completionRates = engine.completionRatePerTaskType();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Your Insights',
          style: TextStyle(color: Colors.white70),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Streak banner ──────────────────────────────────
            _buildStreakBanner(streak),
            const SizedBox(height: 20),

            // ── Insight cards ──────────────────────────────────
            const _SectionLabel(text: 'INSIGHTS'),
            const SizedBox(height: 10),
            ...insights.map((insight) => _InsightCard(text: insight)),
            const SizedBox(height: 20),

            // ── Completion rates ───────────────────────────────
            if (completionRates.isNotEmpty) ...[
              const _SectionLabel(text: 'COMPLETION RATES'),
              const SizedBox(height: 10),
              ...completionRates.entries.map((entry) =>
                _CompletionBar(
                  taskType: entry.key,
                  rate: entry.value,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Session history ────────────────────────────────
            const _SectionLabel(text: 'RECENT SESSIONS'),
            const SizedBox(height: 10),
            sessions.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Complete a session to see history',
                        style: TextStyle(color: Colors.white38),
                      ),
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: sessions
                        .take(10) // show last 10 only
                        .map((s) => _SessionTile(session: s))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakBanner(int streak) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF5C6BC0).withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF5C6BC0).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$streak day streak',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const Text(
                'Keep it going!',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Reusable widgets ───────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white38,
        fontSize: 11,
        letterSpacing: 2,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String text;
  const _InsightCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          const Text('✦', style: TextStyle(color: Color(0xFF7986CB), fontSize: 14)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionBar extends StatelessWidget {
  final String taskType;
  final double rate;
  const _CompletionBar({required this.taskType, required this.rate});

  @override
  Widget build(BuildContext context) {
    final color = _taskColor(taskType);
    final percent = (rate * 100).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(taskType,
                  style: const TextStyle(color: Colors.white60, fontSize: 13)),
              Text('$percent%',
                  style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rate,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Color _taskColor(String taskType) {
    switch (taskType) {
      case 'Work': return const Color(0xFF5C6BC0);
      case 'Study': return const Color(0xFF26A69A);
      case 'Creative': return const Color(0xFFEC407A);
      default: return Colors.white38;
    }
  }
}

class _SessionTile extends StatelessWidget {
  final Session session;
  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final minutes = session.durationSeconds ~/ 60;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _taskColor(session.taskType),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.taskType,
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
                Text(
                  '${session.timeOfDay} · $minutes min',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          Icon(
            session.wasCompleted
                ? Icons.check_circle_outline
                : Icons.cancel_outlined,
            color: session.wasCompleted ? Colors.greenAccent : Colors.white24,
            size: 16,
          ),
        ],
      ),
    );
  }

  Color _taskColor(String taskType) {
    switch (taskType) {
      case 'Work': return const Color(0xFF5C6BC0);
      case 'Study': return const Color(0xFF26A69A);
      case 'Creative': return const Color(0xFFEC407A);
      default: return Colors.white38;
    }
  }
}
