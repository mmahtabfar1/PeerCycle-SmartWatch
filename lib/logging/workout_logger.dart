import 'dart:io';
import 'dart:convert';

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
      print(reply);
      print("SUCCESS UPLOADING");
      return true;
    }
    print(response.statusCode);
    print(reply);
    print("Error uploading workout: ${response.reasonPhrase}");
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
      map[prefKey] = await prefs.get(prefKey);
    }
    return jsonEncode(map);
  }
}

extension on HttpClientResponse {
  bool get hasSuccessStatusCode {
    return (statusCode ~/ 100) == 2;
  }
}
