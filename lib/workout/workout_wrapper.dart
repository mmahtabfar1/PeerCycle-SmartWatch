import 'dart:async';

import 'package:workout/workout.dart';
import 'package:peer_cycle/bluetooth/ble_manager.dart';
import 'package:peer_cycle/workout/workout_start_result_wrapper.dart';

class WorkoutWrapper {
  Workout workout = Workout();

  Stream<WorkoutReading> get stream => _streamController.stream;
  final StreamController<WorkoutReading> _streamController = StreamController.broadcast();

  StreamSubscription<WorkoutReading>? watchSubscription;
  StreamSubscription<WorkoutReading>? bleSubscription;

  // start
  // 1. start the flutter_workout,
  // 2. start reading from ble_manager heartRate / power sensors
  Future<WorkoutStartResultWrapper> start({
    required ExerciseType exerciseType,
    required List<WorkoutFeature> features,
    required bool enableGps,
    required bool useHRPercentage,
    required bool usePowerPercentage,
    required int maxHR,
    required int maxPower,
  }) async {

    //remove heartRate feature from requested features
    //if ble hr sensor is connected
    if(BleManager.instance.hasHRSensor()
        && features.contains(WorkoutFeature.heartRate)) {
      features.remove(WorkoutFeature.heartRate);
    }

    var res = await workout.start(
      exerciseType: exerciseType,
      features: features,
      enableGps: enableGps
    );

    watchSubscription = workout.stream.listen((reading) {
      _streamController.sink.add(reading);
    });
    bleSubscription = BleManager.instance.stream.listen((reading) {
      _streamController.sink.add(reading);
    });

    return WorkoutStartResultWrapper(
      workoutStartResult: res,
      useHRPercentage: useHRPercentage,
      usePowerPercentage: usePowerPercentage,
      maxHR: maxHR.toDouble(),
      maxPower: maxPower.toDouble(),
    );
  }

  Future<void> stop() {
    watchSubscription?.cancel();
    bleSubscription?.cancel();
    return workout.stop();
  }
}