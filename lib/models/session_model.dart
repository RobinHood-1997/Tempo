import 'package:hive/hive.dart';

// Tell Hive this is a storable object, typeID must be unique per model
@HiveType(typeId: 0)
class Session extends HiveObject{

    @HiveField(0)
    final String taskType; //Work, Study, Creative
    
    @HiveField(1)
    final DateTime completedAt; //exact time session finished

    @HiveField(2)
    final int durationSeconds; //how long was the session

    @HiveField(3)
    final bool wasCompleted; //did they finish or abandoned it? 

    Session({
        required this.taskType,
        required this.completedAt,
        required this.durationSeconds,
        required this.wasCompleted,
    });

    //Convenience getter - which hour of day was this? (0-23)
    // This is what Phase 4 uses to find your best focus hours
    int get hourOfDay => completedAt.hour;

    //Was this a morning, afternoon or evening session?
    String get timeOfDay{
        if(hourOfDay < 12) return 'Morning';
        if(hourOfDay < 17) return 'Afternoon';
        return 'Evening';
    }
}

