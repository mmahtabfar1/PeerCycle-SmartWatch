import 'package:flutter/material.dart';
import 'package:peer_cycle/screens/save_workout_screen.dart';

class ConfirmEndWorkoutScreen extends StatelessWidget {
  const ConfirmEndWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "EXIT WORKOUT?",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              )
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(
                  height: 50.0,
                  width: 50.0,
                  child: IconButton(
                    padding: const EdgeInsets.all(0.0),
                    icon: const Icon(
                      Icons.cancel_outlined,
                      color: Colors.red,
                      size: 50.0,
                    ),
                    onPressed: () => {
                      Navigator.of(context).pop()
                    }
                  )
                ),
                SizedBox(
                  height: 50.0,
                  width: 50.0,
                  child: IconButton(
                    padding: const EdgeInsets.all(0.0),
                    icon: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.green,
                      size: 50.0,
                    ),
                    onPressed: () => {
                      //Navigator.of(context).popUntil((route) => route.isFirst)
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const SaveWorkoutScreen(),
                        )
                      )
                    }
                  )
                )
              ],
            )
          ],
        )
      )
    );
  }
}