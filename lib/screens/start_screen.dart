import 'package:wear/wear.dart';
import 'package:workout/workout.dart';
import 'package:flutter/material.dart';
import 'package:peer_cycle/utils.dart';
import 'package:peer_cycle/screens/workout_screen.dart';
import 'package:peer_cycle/widgets/rounded_button.dart';
import 'package:peer_cycle/screens/settings_screen.dart';
import 'package:peer_cycle/screens/connect_peers_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

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
              height: screenSize.height + 10,
              width: screenSize.width + 10,
              child: ListView(
                children: <Widget>[
                  Row(
                    children: [
                      IconButton(
                          icon: const Icon(
                            Icons.hiking,
                            color: Colors.green,
                            size: 40,
                          ),
                          onPressed: () => {
                            startWorkout(context, ExerciseType.walking)
                          }
                      ),
                      IconButton(
                          icon: const Icon(
                            Icons.directions_run,
                            color: Colors.green,
                            size: 40,
                          ),
                          onPressed: () => {
                            startWorkout(context, ExerciseType.running)
                          }
                      ),
                      IconButton(
                          icon: const Icon(
                            Icons.directions_bike,
                            color: Colors.green,
                            size: 40,
                          ),
                          onPressed: () => {
                            startWorkout(context, ExerciseType.biking)
                          }
                      ),
                    ]
                  ),
                  const SizedBox(height: 5),
                  RoundedButton(
                    text: "Settings",
                    width: screenSize.width,
                    height: 40,
                    onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen()
                        )
                      )
                    },
                  ),
                  RoundedButton(
                    text: "Connect Peers",
                    width: screenSize.width,
                    height: 40,
                    onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ConnectPeersScreen()
                        ),
                      )
                    },
                  ),
                ]
              )
            )
          );
        },
      )
    );
  }
}