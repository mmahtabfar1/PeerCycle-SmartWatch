import 'package:flutter/material.dart';
import 'package:peer_cycle/logging/workout_logger.dart';

class SaveWorkoutScreen extends StatelessWidget {
  const SaveWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "SAVE WORKOUT?",
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
                      //go back to home page
                      Navigator.of(context).popUntil((route) => route.isFirst)
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
                    onPressed: () async {
                      //save the workout and then go back to home page
                      await WorkoutLogger.instance.writeSummaryFile();
                      if (context.mounted) {
                        Navigator.of(context).popUntil(
                          (route) => route.isFirst
                        );
                      }
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
