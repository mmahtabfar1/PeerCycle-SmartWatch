import 'package:test/test.dart';
import 'package:workout/workout.dart' hide Workout;
import 'package:peer_cycle/logging/workout.dart';

void main() {
  test('heartRateOnly', () async {
    //Given a workout with a series of workout readings
    Workout workout = Workout(ExerciseType.walking);
    workout.startTimestamp = DateTime.fromMillisecondsSinceEpoch(1000000000);
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
    ];
    for (var reading in readings) {
      workout.addMetric(reading);
    }

    //when we summarize the workouts
    String val = workout.summarizeMetrics();

    //then we expect the value to be
    expect(val, equals('{"heartRate":106.0}'));
  });

  test('heartRateAndPower', () async {
    //Given a workout with a series of workout readings
    Workout workout = Workout(ExerciseType.walking);
    workout.startTimestamp = DateTime.fromMillisecondsSinceEpoch(1000000000);
    List<WorkoutReading> readings = [
      WorkoutReading(WorkoutFeature.heartRate, "100", 1000000000),
      WorkoutReading(WorkoutFeature.heartRate, "101", 1000000001),
      WorkoutReading(WorkoutFeature.heartRate, "102", 1000000002),
      WorkoutReading(WorkoutFeature.heartRate, "103", 1000000003),
      WorkoutReading(WorkoutFeature.heartRate, "104", 1000000004),
      WorkoutReading(WorkoutFeature.heartRate, "105", 1000000005),
      WorkoutReading(WorkoutFeature.power, "100", 1000000000),
      WorkoutReading(WorkoutFeature.power, "101", 1000000001),
      WorkoutReading(WorkoutFeature.power, "102", 1000000002),
      WorkoutReading(WorkoutFeature.power, "103", 1000000003),
      WorkoutReading(WorkoutFeature.power, "104", 1000000004),
      WorkoutReading(WorkoutFeature.power, "105", 1000000005),
    ];
    for (var reading in readings) {
      workout.addMetric(reading);
    }

    //when we summarize the workout
    String val = workout.summarizeMetrics();

    //then we expect the average value of both to be 102.5
    expect(val, equals('{"heartRate":102.5,"power":102.5}'));
  });
}