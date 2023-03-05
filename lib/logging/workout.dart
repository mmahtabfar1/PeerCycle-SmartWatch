import 'dart:core';

import 'partner.dart';
import 'package:workout/workout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Workout {
  ExerciseType exerciseType;
  List<Partner> partners = [];
  DateTime startTimestamp;
  DateTime? endTimestamp;
  Map<WorkoutFeature, List<WorkoutReading>> metrics = {};

  Workout(this.exerciseType) : startTimestamp = DateTime.now();

  /// Add partner if doesn't already exist
  void addPartner(Partner partner) {
    for(Partner p in partners) {
      if(p.deviceId == partner.deviceId) {
        return;
      }
    }
    partners.add(partner);
  }

  /// End workout and record timestamp
  void endWorkout() {
    endTimestamp = DateTime.now();
  }

  /// Add a new metric
  void addMetric(WorkoutReading metric) {
    if(metrics[metric.feature] == null) {
      metrics[metric.feature] = [];
    }
    
    metrics[metric.feature]!.add(metric);
  }

  /// Serialize the workout as a JSON string
  Future<Map<String, dynamic>> toJson() async {
    int? end =  endTimestamp?.millisecondsSinceEpoch;
    if(end != null) end = end ~/ 1000;
    Map<String, dynamic> map = {
      'workout_type': exerciseType.toString().replaceAll("ExerciseType.", ""),
      'partners': partners.map((p) => p.toJson()).toList(),
      'start_timestamp': startTimestamp.millisecondsSinceEpoch ~/ 1000,
      'end_timestamp': end,
    };
    map.addEntries(await _metricsToJson());
    return map;
  }

  Map<String, dynamic> _workoutReadingToJson(WorkoutReading reading) {
    return {
      "value": reading.value,
      "timestamp": reading.timestamp.millisecondsSinceEpoch ~/ 1000
    };
  }

  Future<List<MapEntry<String, dynamic>>> _metricsToJson() async {
    List<MapEntry<String, dynamic>> output = [];

    for(WorkoutFeature key in metrics.keys) {
      List<Map<String, dynamic>> data = [];
      for(WorkoutReading reading in metrics[key]!) {
        data.add(_workoutReadingToJson(reading));
      }
      Map<String, dynamic> map = { 
        "units": _getUnitForMetricName(key),
        "data": data
      };

      //add target heartRate if the WorkoutFeature is heart rate
      if(key == WorkoutFeature.heartRate) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        map["target_heart_rate"] = prefs.get("target_heart_rate");
      }

      output.add(MapEntry(_getMetricNameForJson(key), map));
    }

    return output;
  }

  String _getUnitForMetricName(WorkoutFeature feature) {
    Map<WorkoutFeature, String> map = {
      WorkoutFeature.heartRate: "beats_per_minute",
      WorkoutFeature.calories: "kilocalories",
      WorkoutFeature.distance: "meters",
      WorkoutFeature.steps: "steps",
      WorkoutFeature.speed: "kilometers_per_hour"
    };
    return map[feature] ?? "unknown";
  }

  String _getMetricNameForJson(WorkoutFeature feature) {
    Map<WorkoutFeature, String> map = {
      WorkoutFeature.heartRate: "heart_rate",
      WorkoutFeature.calories: "calories",
      WorkoutFeature.distance: "distance",
      WorkoutFeature.steps: "steps",
      WorkoutFeature.speed: "speed"
    };
    return map[feature] ?? "unknown";
  }
}
