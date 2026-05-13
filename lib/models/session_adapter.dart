import 'package:hive/hive.dart';
import 'session_model.dart';

class SessionAdapter extends TypeAdapter<Session>{
  
  @override
  final int typeId = 0;

  @override
  Session read(BinaryReader reader){
    return Session(
    taskType: reader.readString(), 
    completedAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()), 
    durationSeconds: reader.readInt(), 
    wasCompleted: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, Session obj){
    writer.writeString(obj.taskType);
    writer.writeInt(obj.completedAt.millisecondsSinceEpoch);
    writer.writeInt(obj.durationSeconds);
    writer.writeBool(obj.wasCompleted);
  }

}