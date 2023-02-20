import 'package:wear/wear.dart';
import 'package:flutter/material.dart';
import 'package:workout/workout.dart';
import 'package:peer_cycle/screens/map_screen.dart';
import 'package:peer_cycle/screens/peer_workout_screen.dart';
import 'package:peer_cycle/screens/personal_workout_screen.dart';

//TODO:
//we need to add provider for the start of the
//workout stream here,
//since here is where we should begin the workout
class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({
    super.key,
    required this.exerciseType,
  });

  final ExerciseType exerciseType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WatchShape(
        builder: (context, shape, widget) {
          return Center(
            child: PageView(
              scrollDirection: Axis.vertical,
              children: const <Widget>[
                PersonalWorkoutScreen(),
                PeerWorkoutScreen(),
                MapScreen(),
              ],
            )
          );
        }
      )
    );
  }
}