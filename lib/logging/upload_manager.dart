import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logging/logging.dart';
import 'package:peer_cycle/secrets/secrets.dart';
import 'package:path_provider/path_provider.dart';

class UploadManager {
  static final log = Logger("workout_logger");

  static final UploadManager _instance = UploadManager._();
  static UploadManager get instance => _instance;

  UploadManager._();

  void init() {
    Connectivity().onConnectivityChanged.listen((event) {
      log.info("got event ${event.name}");
      if (event == ConnectivityResult.wifi || event == ConnectivityResult.mobile) {
        _syncUnuploadedFiles();
      }
    });
  }

  Future<bool> createWorkoutFile(String filename, String json) async {
    try {
      String appDocumentsDirectory =
          (await getApplicationDocumentsDirectory()).path;
      File file = await File("$appDocumentsDirectory/unuploaded/$filename.json")
          .create(recursive: true);
      await file.writeAsString(json);
      _uploadUncompletedFile(filename);
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<bool> _uploadUncompletedFile(String filename) async {
    String appDocumentsDirectory =
          (await getApplicationDocumentsDirectory()).path;
    File file = File("$appDocumentsDirectory/unuploaded/$filename.json");
    String json = await file.readAsString();
    bool result = await _uploadWorkout(json);
    if(result) {
      String filename = file.path.substring(file.path.lastIndexOf("/"));

      //create uploaded directory if it doesn't exist
      await Directory("$appDocumentsDirectory/uploaded").create(recursive: true);

      file.rename("$appDocumentsDirectory/uploaded$filename");
    }
    return true;
  }

  void _syncUnuploadedFiles() async {
    String appDocumentsDirectory =
          (await getApplicationDocumentsDirectory()).path;
    Directory unuploadedDir = await Directory("$appDocumentsDirectory/unuploaded").create(recursive: true);
    List<FileSystemEntity> entities = await unuploadedDir.list().toList();
    log.info("there are ${entities.length} files that need to be synced");
    for(FileSystemEntity entity in entities) {
      if(entity is! File) {
        continue;
      }
      File file = entity;
      String json = await file.readAsString();
      bool result = await _uploadWorkout(json);
      if(result) {
        String filename = file.path.substring(file.path.lastIndexOf("/"));

        //create uploaded directory if it doesn't exist
        await Directory("$appDocumentsDirectory/uploaded").create(recursive: true);

        file.rename("$appDocumentsDirectory/uploaded$filename");
      }
    }

  }

  Future<bool> _uploadWorkout(String json) async {
    //load secrets
    final secrets = await Secrets.getSecrets();
    final String apiKey = secrets["ANALYTICS_MONGODB_API_KEY"];
    final String apiEndpoint = secrets["ANALYTICS_MONGODB_API_ENDPOINT"];

    HttpClient httpClient = HttpClient();
    HttpClientRequest request =
        await httpClient.postUrl(Uri.parse("$apiEndpoint/insertOne"));
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
}

extension on HttpClientResponse {
  bool get hasSuccessStatusCode {
    return (statusCode ~/ 100) == 2;
  }
}
