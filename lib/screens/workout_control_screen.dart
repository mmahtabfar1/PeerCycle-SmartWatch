import 'package:flutter/material.dart';
import 'package:peer_cycle/icons/chequered_flag_icon.dart';
import 'package:peer_cycle/screens/confirm_end_workout_screen.dart';

class WorkoutControlScreen extends StatelessWidget {
  const WorkoutControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "WORKOUT CONTROLS",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              )
            ),
            SizedBox(
              height: 50.0,
              width: 50.0,
              child: IconButton(
                padding: const EdgeInsets.all(0.0),
                icon: const Icon(
                  ChequeredFlagIcon.chequeredFlag,
                  color: Colors.orangeAccent,
                  size: 50.0,
                ),
                onPressed: () => {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ConfirmEndWorkoutScreen()
                    )
                  )
                }
              )
            )
          ],
        )
      )
    );
  }
}