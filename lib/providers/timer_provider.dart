import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_model.dart';
import '../repositories/session_repository.dart';
//import '../services/notification_service.dart';

//This class represents the STATE of your timer at any moment
class TimerState {
  final int secondsRemaining;
  final bool isRunning;
  final bool isBreak;
  final String taskType; 

  const TimerState({
    required this.secondsRemaining,
    required this.isRunning,
    required this.isBreak,
    this.taskType ='Work', //default
  });

  //A helper to display time as "25:00" instead of raw seconds
  String get timeLabel {
    final minutes = secondsRemaining ~/ 60;
    final seconds = secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2,'0')}';
  }

  //How full is the ring? 1.0 = full, 0.0 = empty
  double get progress {
    final total = isBreak ? 300 : 1500; //5 min break, 25 min work
    return secondsRemaining / total;
  }

  // Dart's copyWidth pattern - creates a new state with one value changed.
  TimerState copyWidth({
    int? secondsRemaining,
    bool? isRunning,
    bool? isBreak,
    String? taskType,
  }) {
    return TimerState(secondsRemaining: secondsRemaining ?? this.secondsRemaining, 
    isRunning: isRunning ?? this.isRunning, 
    isBreak: isBreak ?? this.isBreak,
    taskType: taskType ?? this.taskType,
    );
  }
}

//StateNotifier is the LOGIC layer - it holds state and controls changes to it
class TimerNotifier extends StateNotifier<TimerState> {
  final SessionRepository _repository;
  //final NotificationService _notifications;
  Timer ? _timer; //dart:async Timer - fires every second
  int _elapsedSeconds = 0; //track how long they actually focused.

  TimerNotifier(this._repository):super(const TimerState(
    secondsRemaining: 1500, //25 minutes
    isRunning: false,
    isBreak: false,
  ));

  void setTaskType(String taskType){
    state = state.copyWidth(taskType: taskType);
  }

  void startPause() {
    if (state.isRunning) {
      _pause();
    } else {
      _start();
    }
  }

  void _start() {
    state = state.copyWidth(isRunning: true);

    //This fires every 1 second
    _timer = Timer.periodic(const Duration(seconds: 1), (_){
      _elapsedSeconds++;
      if (state.secondsRemaining <= 0) {
        _onSessionComplete(wasCompleted: true);
      } else {
        state = state.copyWidth(
          secondsRemaining: state.secondsRemaining - 1,
        );
      }
    });
  }

  void _pause(){
   _timer?.cancel();
   state = state.copyWidth(isRunning: false);
  }

  Future <void> _onSessionComplete({required bool wasCompleted}) async {
     _timer?.cancel();

     //save the session to Hive
     if(!state.isBreak){ //only save focus sessions, not breaks
      await _repository.saveSession(Session(
        taskType: state.taskType,
        completedAt: DateTime.now(),
        durationSeconds: _elapsedSeconds,
        wasCompleted: wasCompleted,
      ));

      //Notify user to take a break
      //await _notifications.showBreakReminder();

     } else {
      //Notify user break is over
      //await _notifications.showFocusReminder(state.taskType);
     }

     _elapsedSeconds = 0; //reset counter
    final wasBreak = state.isBreak;
    state = TimerState(
    secondsRemaining: wasBreak ? 1500 : 300, 
    isRunning: false, 
    isBreak: !wasBreak,
    taskType: state.taskType,
    );
  }

  void reset() { 
    _onSessionComplete(wasCompleted: false);
    //_timer?.cancel();
    state = TimerState(
    secondsRemaining: state.isBreak ? 300 : 1500, 
    isRunning: false, 
    isBreak: state.isBreak,
    taskType: state.taskType,
    );
  }

  //Always cancel the timer when this notifier is destroyed
  @override
  void dispose(){
    _timer?.cancel();
    super.dispose();
  }
}

// The provider - this is what your UI will watch
final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref){
  final repository = ref.read(sessionRepositoryProvider);
  //final notifications = ref.read(notificationServiceProvider);
  return TimerNotifier(repository);
});