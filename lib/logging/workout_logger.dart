import 'dart:io';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:peer_cycle/bluetooth/bluetooth_manager.dart';
import 'package:peer_cycle/logging/partner.dart';
import 'package:peer_cycle/logging/workout.dart';
import 'package:workout/workout.dart' hide Workout;
import 'package:peer_cycle/utils.dart';
import 'package:peer_cycle/logging/upload_manager.dart';
import 'package:path_provider/path_provider.dart';

class WorkoutLogger {
  Workout? workout;
  List<Map<String, dynamic>> events = [];
  String? userName;
  String? deviceId;
  String? serialNum;

  static final WorkoutLogger instance = WorkoutLogger._();

  WorkoutLogger._();

  static final log = Logger("workout_logger");

  void logMetric(WorkoutReading reading) {
    //if logging a speed metric convert value from m/s to km/h
    if (reading.feature == WorkoutFeature.speed) {
      workout?.addMetric(
          WorkoutReading(
            WorkoutFeature.speed,
            mpsToKph(double.tryParse(reading.value) ?? -1.0).toString(),
            reading.timestamp.millisecondsSinceEpoch
          )
      );
    }
    else {
      workout?.addMetric(reading);
    }
  }

  void startWorkout(ExerciseType exerciseType) {
    workout = Workout(exerciseType);
    // Add the workout partners
    BluetoothManager.instance.cleanupLingeringClosedConnections();
    final deviceData = BluetoothManager.instance.deviceData;
    for (int id in deviceData.keys) {
      Map<String, String> data = deviceData[id]!;
      workout?.addPartner(Partner(
        name: data["name"],
        deviceId: data["device_id"],
        serialNum: data["serial_num"]
      ));
    }
  }

  void endWorkout() async {
    workout?.endWorkout();
    String json = await toJson();

    //upload file to analytics team's Database and save locally
    await UploadManager.instance.createWorkoutFile(
      DateTime.now().toIso8601String(),
      json,
    );

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
      "workout": await (workout?.toJson()),
      "events": events
    };

    return jsonEncode(map);
  }

  Future<void> writeSummaryFile() async {
    try {
      String appDocumentsDirectory =
        (await getApplicationDocumentsDirectory()).path;
      File file = await File("$appDocumentsDirectory/summaries/${workout?.startTimestamp}.json")
        .create(recursive: true);
      String strToWrite = _toJsonSummary();
      await file.writeAsString(strToWrite);
    } catch (e) {
      log.severe(e);
    }
  }

  ///
  /// returns a summary of the workout
  /// instead of time series for each metric this contains
  /// average values for each metric throughout the workout
  ///
  String _toJsonSummary() {
    return jsonEncode({
      "name": userName ?? "Unknown",
      "device_id": deviceId ?? "Unknown",
      "exercise_type": workout?.exerciseType.toString(),
      "startTime": workout?.startTimestamp.millisecondsSinceEpoch,
      "endTime": DateTime.now().millisecondsSinceEpoch,
      "partners": workout?.partners,
      //get averages for the workouts metrics
      "metrics": workout?.summarizeMetrics(),
    });
  }
}
