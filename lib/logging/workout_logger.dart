import 'dart:io';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:peer_cycle/bluetooth/bluetooth_manager.dart';
import 'package:peer_cycle/logging/partner.dart';
import 'package:peer_cycle/secrets/secrets.dart';
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

  static final log = Logger("workout_logger");

  void logMetric(WorkoutReading reading) {
    workout?.addMetric(reading);
  }

  void startWorkout(ExerciseType exerciseType) {
    workout = Workout(exerciseType);
    // Add the workout partners
    BluetoothManager.instance.cleanupLingeringClosedConnections();
    final deviceData = BluetoothManager.instance.deviceData;
    for(int id in deviceData.keys) {
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
    
    // Write to a file
    String appDocumentsDirectory = (await getApplicationDocumentsDirectory()).path;
    File file = File("$appDocumentsDirectory/${DateTime.now().toIso8601String()}.json");
    log.info("json log file path: ${file.path}");
    file.writeAsString(json);

    //upload file to analytics team's Database
    await uploadWorkout(json);

    // Clean up logging
    workout = null;
    events.clear();
  }

  Future<bool> uploadWorkout(String json) async {
    //load secrets
    final secrets = await Secrets.getSecrets();
    final String apiKey = secrets["ANALYTICS_MONGODB_API_KEY"];
    final String apiEndpoint = secrets["ANALYTICS_MONGODB_API_ENDPOINT"];

    HttpClient httpClient = HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse("$apiEndpoint/insertOne"));
    request.headers.set("apiKey", apiKey);
    request.headers.set("Content-Type", "application/json");
    request.add(utf8.encode('''
    {
      "dataSource": "FitnessLog",
      "database": "FitnessLog",
      "collection": "Test",
      "document": $json
    }
    '''));

    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();

    if (response.hasSuccessStatusCode) {
      log.info(reply);
      log.info("SUCCESS UPLOADING");
      return true;
    }
    log.warning(response.statusCode);
    log.warning(reply);
    log.warning("Error uploading workout: ${response.reasonPhrase}");
    return false;
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
      map[prefKey] = prefs.get(prefKey);
    }
    return jsonEncode(map);
  }
}

extension on HttpClientResponse {
  bool get hasSuccessStatusCode {
    return (statusCode ~/ 100) == 2;
  }
}
