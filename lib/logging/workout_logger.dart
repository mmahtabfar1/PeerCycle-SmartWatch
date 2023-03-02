import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:peer_cycle/logging/workout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout/workout.dart' hide Workout;

class WorkoutLogger {
  
  Workout? workout;
  List<Map<String, dynamic>> events = [];
  String? userName;
  String? deviceId;
  String? serialNum;
  
  final List<String> preferences = ["target_heart_rate"];
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
    String json = await toJson();
    
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

  Future<String> toJson() async {
    Map<String, dynamic> map = {
      "name": userName,
      "device_id": deviceId,
      "serial_number": serialNum,
      "workout": workout?.toJson(),
      "events": events
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    for(String prefKey in preferences) {
      map[prefKey] = await prefs.get(prefKey);
    }
    return jsonEncode(map);
  }
}