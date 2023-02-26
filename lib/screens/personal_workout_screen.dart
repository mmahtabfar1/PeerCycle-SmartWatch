import 'package:flutter/material.dart';
import 'package:peer_cycle/bluetooth/bluetooth_manager.dart';
import 'package:workout/workout.dart';
import 'package:peer_cycle/widgets/rounded_button.dart';

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

  @override
  void initState() {
    super.initState();
    widget.workout.stream.listen((event) {
      switch(event.feature) {
        case WorkoutFeature.unknown:
          return;
        case WorkoutFeature.heartRate:
          setState(() {
            heartRate = event.value.toInt();
          });
          BluetoothManager.instance.broadcastString("heartRate:${event.value}");
          break;
        case WorkoutFeature.calories:
          setState(() {
            calories = event.value.toInt();
          });
          BluetoothManager.instance.broadcastString("calories:${event.value}");
          break;
        case WorkoutFeature.steps:
          setState(() {
            steps = event.value.toInt();
          });
          BluetoothManager.instance.broadcastString("steps:${event.value}");
          break;
        case WorkoutFeature.distance:
          setState(() {
            distance = event.value.toInt();
          });
          BluetoothManager.instance.broadcastString("distance:${event.value}");
          break;
        case WorkoutFeature.speed:
          setState(() {
            speed = event.value.toInt();
          });
          BluetoothManager.instance.broadcastString("speed:${event.value}");
          break;
      }
    });
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