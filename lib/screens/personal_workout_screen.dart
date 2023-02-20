import 'package:flutter/material.dart';
import 'package:workout/workout.dart';
import 'package:peer_cycle/widgets/rounded_button.dart';

class PersonalWorkoutScreen extends StatefulWidget {
  const PersonalWorkoutScreen({super.key});

  @override
  State<PersonalWorkoutScreen> createState() => _PersonalWorkoutScreenState();
}

class _PersonalWorkoutScreenState extends State<PersonalWorkoutScreen>
  with AutomaticKeepAliveClientMixin<PersonalWorkoutScreen> {
  final workout = Workout();

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

  bool started = false;

  _PersonalWorkoutScreenState() {
    workout.stream.listen((event) {
      print('${event.feature}: ${event.value} (${event.timestamp})');

      switch(event.feature) {
        case WorkoutFeature.unknown:
          return;
        case WorkoutFeature.heartRate:
          setState(() {
            heartRate = event.value.toInt();
          });
          break;
        case WorkoutFeature.calories:
          setState(() {
            calories = event.value.toInt();
          });
          break;
        case WorkoutFeature.steps:
          setState(() {
            steps = event.value.toInt();
          });
          break;
        case WorkoutFeature.distance:
          setState(() {
            distance = event.value.toInt();
          });
          break;
        case WorkoutFeature.speed:
          setState(() {
            speed = event.value.toInt();
          });
          break;
      }
    });
  }

  void toggleWorkout() async {
    if(started) {
      await workout.stop();
    }
    else {
      final result = await workout.start(
        // In a real application, check the supported exercise types first
        exerciseType: exerciseType,
        features: features,
        enableGps: true,
      );

      if (result.unsupportedFeatures.isNotEmpty) {
        // ignore: avoid_print
        print('Unsupported features: ${result.unsupportedFeatures}');
        // In a real application, update the UI to match
      } else {
        // ignore: avoid_print
        print('All requested features supported');
      }
    }

    setState(() => {
      started = !started
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
                  Icons.heart_broken,
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
              text: "Start/Stop Workout",
              width: 1,
              height: 40,
              onPressed: toggleWorkout,
            ),
          )
        ],
      ),
    ),
  );

  @override
  bool get wantKeepAlive => true;
}