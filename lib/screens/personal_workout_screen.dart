import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:peer_cycle/bluetooth/bluetooth_manager.dart';
import 'package:peer_cycle/logging/fit_activity_logger.dart';
import 'package:workout/workout.dart';
import 'package:peer_cycle/widgets/rounded_button.dart';

import '../logging/workout_logger.dart';

class PersonalWorkoutScreen extends StatefulWidget {
  const PersonalWorkoutScreen({
    super.key,
    required this.workout,
    required this.exerciseType
  });

  final Workout workout;
  final ExerciseType exerciseType;

  @override
  State<PersonalWorkoutScreen> createState() => _PersonalWorkoutScreenState();
}

class _PersonalWorkoutScreenState extends State<PersonalWorkoutScreen>
  with AutomaticKeepAliveClientMixin<PersonalWorkoutScreen> {

  final exerciseType = ExerciseType.walking;
  final features = [
    WorkoutFeature.heartRate,
    WorkoutFeature.calories,
    WorkoutFeature.steps,
    WorkoutFeature.distance,
    WorkoutFeature.speed,
  ];

  int heartRate = 0;
  int calories = 0;
  int steps = 0;
  int distance = 0;
  int speed = 0;

  final List<WorkoutReading> readings = [];
  late StreamSubscription<WorkoutReading> workoutStreamSubscription;

  @override
  void initState() {
    super.initState();
    workoutStreamSubscription = widget.workout.stream.listen((reading) {
      WorkoutLogger.instance.logMetric(reading);
      readings.add(reading);
      switch(reading.feature) {
        case WorkoutFeature.unknown:
          return;
        case WorkoutFeature.heartRate:
          setState(() {
            heartRate = reading.value.toInt();
          });
          BluetoothManager.instance.broadcastString("heartRate:${reading.value}");
          break;
        case WorkoutFeature.calories:
          setState(() {
            calories = reading.value.toInt();
          });
          BluetoothManager.instance.broadcastString("calories:${reading.value}");
          break;
        case WorkoutFeature.steps:
          setState(() {
            steps = reading.value.toInt();
          });
          BluetoothManager.instance.broadcastString("steps:${reading.value}");
          break;
        case WorkoutFeature.distance:
          setState(() {
            distance = reading.value.toInt();
          });
          BluetoothManager.instance.broadcastString("distance:${reading.value}");
          break;
        case WorkoutFeature.speed:
          setState(() {
            speed = reading.value.toInt();
          });
          BluetoothManager.instance.broadcastString("speed:${reading.value}");
          break;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    stopWorkout();
    workoutStreamSubscription.cancel();
    writeFitFile();
    WorkoutLogger.instance.endWorkout();
  }

  void writeFitFile() async {
    String currentTime = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    String appDocumentsDirectory = (await getApplicationDocumentsDirectory()).path;
    String fitFilePath = "$appDocumentsDirectory/workout@$currentTime.fit";
    print("fitFilePath: $fitFilePath");
    await FitActivityLogger.writeFitFile(fitFilePath, readings, exerciseType);
  }

  void stopWorkout() async {
    await widget.workout.stop();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(children: [
                  const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  ),
                  Text(
                    heartRate.toString(),
                    style: TextStyle(color: Colors.blue[600], fontSize: 30),
                  ),
                ]),
                const SizedBox(width: 8),
                Column(children: [
                  const Icon(
                    Icons.fastfood,
                    color: Colors.red,
                  ),
                  Text(
                    calories.toString(),
                    style: TextStyle(color: Colors.blue[600], fontSize: 30),
                  ),
                ]),
                const SizedBox(width: 8),
                Column(children: [
                  const Icon(
                    Icons.run_circle,
                    color: Colors.red,
                  ),
                  Text(
                    steps.toString(),
                    style: TextStyle(color: Colors.blue[600], fontSize: 30),
                  ),
                ]),
                const SizedBox(width: 8),
                Column(children: [
                  const Icon(
                    Icons.speed,
                    color: Colors.red,
                  ),
                  Text(
                    speed.toString(),
                    style: TextStyle(color: Colors.blue[600], fontSize: 30),
                  ),
                ]),
                const SizedBox(width: 8),
                Column(children: [
                  const Icon(
                    Icons.social_distance,
                    color: Colors.red,
                  ),
                  Text(
                    distance.toString(),
                    style: TextStyle(color: Colors.blue[600], fontSize: 30),
                  ),
                ]),
              ]
            ),
            const SizedBox(height: 15),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: RoundedButton(
                text: "Stop Workout",
                width: 1,
                height: 40,
                onPressed: () {
                  stopWorkout();
                  Navigator.pop(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}