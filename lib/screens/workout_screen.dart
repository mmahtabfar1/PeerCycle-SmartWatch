import 'package:wear/wear.dart';
import 'package:workout/workout.dart';
import 'package:flutter/material.dart';
import 'package:peer_cycle/screens/map_screen.dart';
import 'package:peer_cycle/screens/peer_workout_screen.dart';
import 'package:peer_cycle/screens/personal_workout_screen.dart';

class WorkoutScreen extends StatelessWidget {
  final ExerciseType exerciseType;
  final workout = Workout();

  WorkoutScreen({
    super.key,
    required this.exerciseType,
  });

  final features = [
    WorkoutFeature.heartRate,
    WorkoutFeature.calories,
    WorkoutFeature.steps,
    WorkoutFeature.distance,
    WorkoutFeature.speed,
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WorkoutStartResult>(
      future: workout.start(
        exerciseType: exerciseType,
        features: features,
        enableGps: true,
      ),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: WatchShape(
              builder: (context, shape, widget) {
                return Center(
                  child: PageView(
                    scrollDirection: Axis.vertical,
                    children: <Widget>[
                      PersonalWorkoutScreen(
                        workout: workout,
                        exerciseType: exerciseType
                      ),
                      const PeerWorkoutScreen(),
                      const MapScreen(),
                    ],
                  )
                );
              }
            )
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    );
  }
}