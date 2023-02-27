import 'dart:core';

import 'package:workout/workout.dart';
import 'package:fit_tool/fit_tool.dart';
import 'partner.dart';

class Workout {
  Sport workoutType;
  List<Partner> partners = [];
  DateTime startTimestamp;
  DateTime? endTimestamp;
  Map<WorkoutFeature, List<WorkoutReading>> metrics = {};

  Workout(Sport workoutType) : startTimestamp = DateTime.now(), this.workoutType = workoutType;

  /// Add partner if doesn't already exist
  void addPartner(Partner partner) {
    for(Partner p in partners) {
      if(p.deviceId == partner.deviceId)
        return;
    }
    partners.add(partner);
  }

  /// End workout and record timestamp
  void endWorkout() {
    endTimestamp = DateTime.now();
  }

  /// Add a new metric
  void addMetric(WorkoutReading metric) {
    if(metrics[metric.feature] == null)
      metrics[metric.feature] = [];
    
    metrics[metric.feature]!.add(metric);
  }

  /// Serialize the workout as a JSON string
  Map<String, dynamic> toJson() {
    int? end =  endTimestamp?.millisecondsSinceEpoch;
    if(end != null) end ~/ 1000;
    Map<String, dynamic> map = {
      'workout_type': workoutType.toString(),
      'partners': partners.map((p) => p.toJson()).toList(),
      'start_timestamp': startTimestamp.millisecondsSinceEpoch ~/ 1000,
      'end_timestamp': end,
    };
    map.addEntries(_metricsToJson());
    return map;
  }

  Map<String, dynamic> _workoutReadingToJson(WorkoutReading reading) {
    return {
      "value": reading.value,
      "timestamp": reading.timestamp.millisecondsSinceEpoch ~/ 1000
    };
  }

  List<MapEntry<String, dynamic>> _metricsToJson() {
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
      output.add(MapEntry(_getMetricNameForJson(key), map));
    }

    return output;
  }

  String _getUnitForMetricName(WorkoutFeature feature) {
    Map<WorkoutFeature, String> map = {
      WorkoutFeature.heartRate: "bpm",
      WorkoutFeature.calories: "kcal",
      WorkoutFeature.distance: "m",
      WorkoutFeature.steps: "steps",
      WorkoutFeature.speed: "km/h"
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
