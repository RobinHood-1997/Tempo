import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/insight_engine.dart';
import '../repositories/session_repository.dart';

// This provider gives any widget access to the insight engine
final insightEngineProvider = Provider<InsightEngine>((ref) {
  final repo = ref.read(sessionRepositoryProvider);
  final sessions = repo.getAllSessions();
  return InsightEngine(sessions);
});