import 'dart:async';

import 'package:workout/workout.dart';
import 'package:peer_cycle/bluetooth/ble_manager.dart';

class WorkoutWrapper {
  Workout workout = Workout();

  Stream<WorkoutReading> get stream => _streamController.stream;
  final StreamController<WorkoutReading> _streamController = StreamController.broadcast();

  StreamSubscription<WorkoutReading>? watchSubscription;
  StreamSubscription<WorkoutReading>? bleSubscription;

  // start
  // 1. start the flutter_workout,
  // 2. start reading from ble_manager heartRate / power sensors
  Future<WorkoutStartResult> start({
    required ExerciseType exerciseType,
    required List<WorkoutFeature> features,
    required bool enableGps
  }) {

    //remove heartRate feature from requested features
    //if ble hr sensor is connected
    if(BleManager.instance.hasHRSensor()
        && features.contains(WorkoutFeature.heartRate)) {
      features.remove(WorkoutFeature.heartRate);
    }

    var res = workout.start(
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

    return res;
  }

  Future<void> stop() {
    watchSubscription?.cancel();
    bleSubscription?.cancel();
    return workout.stop();
  }
}