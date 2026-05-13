import '../models/session_model.dart';

class InsightEngine {

  final List<Session> sessions;

  InsightEngine(this.sessions);

  //- 1. Best hour per task type
  // Returns e.g. {Work: 10, Study: 14, Creative: 20}
  Map<String, int> bestHourPerTaskType() {
    final Map<String, Map<int,int>> hourCounts = {};

    for (final session in sessions){
      if(!session.wasCompleted) continue; //only count completed sessions

      //Initialize the task type map if it doesnt exists yet
      hourCounts.putIfAbsent(session.taskType, () => {});

      //Increment the count for this hour
      final hour = session.hourOfDay;
      hourCounts[session.taskType]![hour] =
      (hourCounts[session.taskType]![hour] ?? 0) + 1;
    }
    
    //For each task type, find the hour with the highest count
    final Map<String, int> result = {};
    hourCounts.forEach((taskType, hourMap){
      final bestHour = hourMap.entries
      .reduce((a, b) => a.value > b.value ? a:b).key;
      result[taskType] = bestHour;
    });
    
    return result;

  }

  // -2. Completion rate per task type
  // Returns e.g. {work: 0.8, study: 0.6, creative: 0.4}
  Map<String, double> completionRatePerTaskType() {
    final Map<String, int> total = {};
    final Map<String, int> completed = {};

    for(final session in sessions){
      total[session.taskType] = (total[session.taskType]?? 0) + 1;
      if (session.wasCompleted) {
        completed[session.taskType] = (completed[session.taskType] ?? 0) + 1;
      }
    }

    final Map<String, double> result = {};
    total.forEach((taskType, count){
      final completedCount = completed[taskType] ?? 0;
      result[taskType] = completedCount / count; //e.g 4/5 = 0.8
    });

    return result;
  }

  //-3. Minutes until best focus window
  // Looks at your best Work hour and tells you how long until it arrives.

  String nextBestFocusWindow(String taskType){

    final bestHours = bestHourPerTaskType();
    if(!bestHours.containsKey(taskType)){
      return 'Complete more sessions to unlock this insight';
    }

    final bestHour = bestHours[taskType]!;
    final now = DateTime.now();
    final todayBestWindow = DateTime(
      now.year,
      now.month,
      now.day,
      bestHour,
    );

    //If best window already passed today, show tomorrow's
    final target = todayBestWindow.isBefore(now)
    ? todayBestWindow.add(const Duration(days:1))
    : todayBestWindow;

    final diff = target.difference(now);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    if(hours == 0) return 'Your best $taskType window is in $minutes min!';
    return 'Your best $taskType window is in ${hours}h ${minutes}min';
  }

  //-4. Generate insight cards
  // Returns a list of human-readable insight strings
  List<String> generateInsights(String currentTaskType){
    if (sessions.length <3){
      return ['Complete at least 3 sessions to unlock your insights ✦'];
    }

    final List<String> insights = [];
    final bestHours = bestHourPerTaskType();
    final completionRates = completionRatePerTaskType();

    //best hour insights
    bestHours.forEach((taskType, hour){
      final period = _formatHour(hour);
      insights.add('Your focus best on $taskType at $period');
    });

    //Completion rate insights
    completionRates.forEach((taskType, rate){
      final percent = (rate * 100).toStringAsFixed(0);
      insights.add('$taskType completion rate: $percent%');
    });

    //Next window insight
    insights.add(nextBestFocusWindow(currentTaskType));

    //Most productive task type
    if (completionRates.isNotEmpty) {
      final best = completionRates.entries
      .reduce((a,b) => a.value > b.value ? a:b)
      .key;
      insights.add('Your strongest focus type is $best');
    }

    return insights;
  }

  //Helper
  String _formatHour(int hour) {
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour == 0 ? 12: (hour > 12 ? hour - 12: hour);
    return '$displayHour:00 $period';
  }
}