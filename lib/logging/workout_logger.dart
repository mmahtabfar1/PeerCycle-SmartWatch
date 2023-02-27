import 'dart:convert';
import 'dart:io';

import 'package:fit_tool/fit_tool.dart';
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

  void startWorkout(Sport workoutType) {
    workout = Workout(workoutType);
  }

  void endWorkout() {
    workout?.endWorkout();
    String json = toJson();
    
    // Write to a file
    File file = File(DateTime.now().toIso8601String()+".json");
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