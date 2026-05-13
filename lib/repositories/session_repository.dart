import 'package:hive/hive.dart';
import '../models/session_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionRepository {

  //Get the already opened box
  Box<Session> get _box => Hive.box<Session>('sessions');

  //Save a completed session
  Future<void> saveSession(Session session) async {
    await _box.add(session);
  }

  //Get all sessions, newest first
  List<Session> getAllSessions(){
    final sessions = _box.values.toList();
    sessions.sort((a,b) => b.completedAt.compareTo(a.completedAt));
    return sessions;
  }

  //Get sessions for a specific task type
  List<Session> getSessionsByTask(String taskType){
    return _box.values
    .where((s) => s.taskType == taskType)
    .toList();
  }

  //How many days in a row has the user completed at least one session? 
  int getCurrentStreak() {
    final sessions = getAllSessions();
    if(sessions.isEmpty) return 0;

    int streak = 0;
    DateTime checking = DateTime.now();

    while(true){
      //Does any session exist to this day? 
      final hasSession = sessions.any((s) =>
      s.completedAt.year == checking.year &&
      s.completedAt.month == checking.month &&
      s.completedAt.day == checking.day &&
      s.wasCompleted
      );

      if (hasSession) {
        streak++;

        //Go back one more day and check again
        checking = checking.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    return streak;
  }
}

//A provider for the repository so Riverpod can inject it

final sessionRepositoryProvider = Provider<SessionRepository>((ref){
  return SessionRepository();
});