import 'dart:io';
import 'dart:typed_data';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:workout/workout.dart';
import 'package:fit_tool/fit_tool.dart';

class FitActivityLogger {
  //map exercise types from android health services
  //to garmin sport types
  static final Map<ExerciseType, Sport> _exerciseTypeToSport = {
    ExerciseType.biking: Sport.cycling,
    ExerciseType.running: Sport.running,
    ExerciseType.walking: Sport.walking,
  };

  //set of features to exclude from FIT file
  static final Set<WorkoutFeature> _excludedFeatures = {
    WorkoutFeature.unknown,
    WorkoutFeature.steps,
  };

  //helper method to remove workout readings that should not / can not
  //be logged to a FIT file
  static List<WorkoutReading> _filterReadings(List<WorkoutReading> readings) {
    return readings
        .where((reading) => !_excludedFeatures.contains(reading.feature))
        .toList();
  }

  //helper method to organize readings by timestamp
  //SplayTreeMap iterates over the keys in sorted order
  //it is equivalent to map in c++
  @visibleForTesting
  static SplayTreeMap<int, List<WorkoutReading>> organizeReadingsByTime(
      List<WorkoutReading> readings) {
    final map = SplayTreeMap<int, List<WorkoutReading>>();

    for (var reading in readings) {
      final int timeStamp = reading.timestamp.millisecondsSinceEpoch;
      map.update(timeStamp,
        (readingsAtTimeStamp) => <WorkoutReading>[reading, ...readingsAtTimeStamp],
        ifAbsent: () => <WorkoutReading>[reading]);
    }

    return map;
  }

  @visibleForTesting
  static FitFile createFitFile(List<WorkoutReading> readings, ExerciseType exerciseType) {
    //first filter the readings that should not be logged
    readings = _filterReadings(readings);
    //then organize the readings by their timestamp
    final readingsByTimeStamp = organizeReadingsByTime(readings);

    final builder = FitFileBuilder(autoDefine: true, minStringSize: 50);

    builder.add(FileIdMessage()
      ..type = FileType.activity
      ..manufacturer = Manufacturer.development.value
      ..product = 0
      ..timeCreated = DateTime.now().millisecondsSinceEpoch
      ..serialNumber = 0x123456
    );

    for (final entry in readingsByTimeStamp.entries) {
      final msg = RecordMessage()
        ..timestamp = entry.key;

      for (final reading in entry.value) {
        switch(reading.feature) {
          case WorkoutFeature.heartRate:
            msg.heartRate = reading.value.toInt();
            break;
          case WorkoutFeature.calories:
            msg.calories = reading.value.toInt();
            break;
          case WorkoutFeature.distance:
            msg.distance = reading.value;
            break;
          case WorkoutFeature.speed:
            msg.speed = reading.value;
            break;
          default:
            throw Exception("Invalid WorkoutFeature. Can't create RecordMessage for: $reading");
        }
      }

      //add msg to the map
      builder.add(msg);
    }

    //each fit file needs at least one lap message
    final startTime = readings.first.timestamp.millisecondsSinceEpoch;
    final endTime = readings.last.timestamp.millisecondsSinceEpoch;
    final elapsedTime = (endTime - startTime).toDouble();
    builder.add(LapMessage()
      ..timestamp = endTime
      ..startTime = startTime
      ..totalElapsedTime = elapsedTime
      ..totalTimerTime = elapsedTime
    );

    //each fit file needs at least one session message
    builder.add(SessionMessage()
      ..timestamp = endTime
      ..startTime = startTime
      ..totalElapsedTime = elapsedTime
      ..totalTimerTime = elapsedTime
      ..sport = _exerciseTypeToSport[exerciseType]
      ..subSport = SubSport.exercise
      ..firstLapIndex = 0
      ..numLaps = 1
    );

    return builder.build();
  }

  static Future<void> writeFitFile(
      String filePath,
      List<WorkoutReading> readings,
      ExerciseType exerciseType) async {
    Uint8List bytes = createFitFile(readings, exerciseType).toBytes();
    File outFile = await File(filePath).create(recursive: true);
    await outFile.writeAsBytes(bytes);
  }
}