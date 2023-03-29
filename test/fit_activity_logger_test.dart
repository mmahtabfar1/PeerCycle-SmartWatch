import 'package:test/test.dart';
import 'package:workout/workout.dart';
import 'package:peer_cycle/logging/fit_activity_logger.dart';

void main() {
  test('heartRateOnlyCloseTimes', () async {
    //Given a series of workout readings for user heart rate
    List<WorkoutReading> readings = [
      WorkoutReading(WorkoutFeature.heartRate, "100", 1000000000),
      WorkoutReading(WorkoutFeature.heartRate, "101", 1000000001),
      WorkoutReading(WorkoutFeature.heartRate, "102", 1000000002),
      WorkoutReading(WorkoutFeature.heartRate, "103", 1000000003),
      WorkoutReading(WorkoutFeature.heartRate, "104", 1000000004),
      WorkoutReading(WorkoutFeature.heartRate, "105", 1000000005),
      WorkoutReading(WorkoutFeature.heartRate, "106", 1000000006),
      WorkoutReading(WorkoutFeature.heartRate, "107", 1000000007),
      WorkoutReading(WorkoutFeature.heartRate, "108", 1000000008),
      WorkoutReading(WorkoutFeature.heartRate, "109", 1000000009),
      WorkoutReading(WorkoutFeature.heartRate, "110", 1000000010),
      WorkoutReading(WorkoutFeature.heartRate, "111", 1000000011),
      WorkoutReading(WorkoutFeature.heartRate, "112", 1000000012),
      WorkoutReading(WorkoutFeature.heartRate, "113", 1000000013),
    ];

    //When we create the fit file
    final fitFile = FitActivityLogger.createFitFile(readings, ExerciseType.biking);
    //When we convert to bytes
    fitFile.toBytes(checkCrc: true);

    //Then assert that there were no errors
  });

  test('heartRateAndCalories', () async {
    int timeStamp = DateTime.now().millisecondsSinceEpoch;

    //Given a series of workout readings for user heart rate and calories
    List<WorkoutReading> readings = [
      WorkoutReading(WorkoutFeature.heartRate, "100", timeStamp),
      WorkoutReading(WorkoutFeature.heartRate, "101", timeStamp + 10000),
      WorkoutReading(WorkoutFeature.speed, "12", timeStamp),
      WorkoutReading(WorkoutFeature.speed, "13", timeStamp + 10000),
    ];

    //When we create the fit file
    final fitFile = FitActivityLogger.createFitFile(readings, ExerciseType.biking);
    //When wer convert the fit file to bytes
    fitFile.toBytes(checkCrc: true);

    //Then assert that there were no errors
  });

  //when all metrics are provided,
  //workout readings with feature unknown and steps should not be logged
  //into the fit file since they are now in the FIT file spec
  test('allMetrics', () async {
    int timeStamp = DateTime.now().millisecondsSinceEpoch;

    //Given a series of workout readings for users workout
    List<WorkoutReading> readings = [
      WorkoutReading(WorkoutFeature.heartRate, "100", timeStamp),
      WorkoutReading(WorkoutFeature.heartRate, "101", timeStamp + 10000),
      WorkoutReading(WorkoutFeature.calories, "2", timeStamp),
      WorkoutReading(WorkoutFeature.calories, "8", timeStamp + 10000),
      WorkoutReading(WorkoutFeature.steps, "50", timeStamp),
      WorkoutReading(WorkoutFeature.steps, "60", timeStamp + 10000),
      WorkoutReading(WorkoutFeature.speed, "13", timeStamp),
      WorkoutReading(WorkoutFeature.speed, "18", timeStamp + 10000),
      WorkoutReading(WorkoutFeature.distance, "100", timeStamp),
      WorkoutReading(WorkoutFeature.distance, "150", timeStamp + 10000),
      WorkoutReading(WorkoutFeature.unknown, "199", timeStamp),
      WorkoutReading(WorkoutFeature.unknown, "12300", timeStamp + 10000),
    ];

    //When we create the fit file
    final fitFile = FitActivityLogger.createFitFile(readings, ExerciseType.biking);
    //When we convert the fit file to bytes
    fitFile.toBytes(checkCrc: true);

    //Then assert that there were no errors
  });
}
