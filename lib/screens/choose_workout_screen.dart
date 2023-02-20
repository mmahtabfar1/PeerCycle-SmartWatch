import 'package:wear/wear.dart';
import 'package:flutter/material.dart';
import 'package:peer_cycle/utils.dart';
import 'package:workout/workout.dart';
import 'package:peer_cycle/screens/workout_screen.dart';
import 'package:peer_cycle/widgets/rounded_button.dart';

class ChooseWorkoutScreen extends StatelessWidget {
  const ChooseWorkoutScreen({super.key});

  //start the selected workout
  void startWorkout(BuildContext context, ExerciseType exerciseType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutScreen(exerciseType: exerciseType)
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WatchShape(
        builder: (context, shape, widget) {
          Size screenSize = getWatchScreenSize(context);
          return Center(
            child: Container(
              color: Colors.black,
              height: screenSize.height,
              width: screenSize.width,
              child: ListView(
                children: <Widget>[
                  RoundedButton(
                      text: "Cycling",
                      width: screenSize.width,
                      height: 40,
                      onPressed: () => {
                        startWorkout(context, ExerciseType.biking)
                      }
                  ),
                  RoundedButton(
                    text: "Walking",
                    width: screenSize.width,
                    height: 40,
                    onPressed: () => {
                      startWorkout(context, ExerciseType.walking)
                    }
                  ),
                  RoundedButton(
                      text: "Running",
                      width: screenSize.width,
                      height: 40,
                      onPressed: () => {
                        startWorkout(context, ExerciseType.running)
                      }
                  ),
                ]
              )
            )
          );
        }
      )
    );
  }
}