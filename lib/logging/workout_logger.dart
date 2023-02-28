import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:peer_cycle/logging/workout.dart';
import 'package:workout/workout.dart' hide Workout;

class WorkoutLogger {
  
  Workout? workout;
  List<Map<String, dynamic>> events = [];
  String? userName;
  String? deviceId;
  String? serialNum;
  
  static final WorkoutLogger instance = WorkoutLogger._();

  WorkoutLogger._();


  void logMetric(WorkoutReading reading) {
    workout?.addMetric(reading);
  }

  void startWorkout(ExerciseType exerciseType) {
    workout = Workout(exerciseType);
  }

  void endWorkout() async {
    workout?.endWorkout();
    String json = toJson();
    
    // Write to a file
    String appDocumentsDirectory = (await getApplicationDocumentsDirectory()).path;
    File file = File("$appDocumentsDirectory/${DateTime.now().toIso8601String()}.json");
    print("json log file path: ${file.path}");
    file.writeAsString(json);

    // Clean up logging
    workout = null;
    events.clear();
  }

  void addEvent(Map<String, dynamic> event) {
    events.add(event);
  }

  String toJson() {
    Map<String, dynamic> map = {
      "name": userName,
      "device_id": deviceId,
      "serial_number": serialNum,
      "workout": workout?.toJson(),
      "events": events
    };
    return jsonEncode(map);
  }
}