import 'package:peer_cycle/widgets/rounded_button.dart';
import 'package:wear/wear.dart';
import 'package:flutter/material.dart';
import 'package:peer_cycle/utils.dart';
import 'package:peer_cycle/screens/connect_peers_screen.dart';
import 'package:peer_cycle/screens/choose_workout_screen.dart';

class ChooseWorkoutTypeScreen extends StatelessWidget {
  const ChooseWorkoutTypeScreen({super.key});

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "CHOOSE",
                    style: TextStyle(color: Colors.white),
                  ),
                  const Text(
                    "WORKOUT MODE",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  RoundedButton(
                    name: "PairedWorkoutButton",
                    height: 40,
                    color: const Color.fromRGBO(48, 79, 254, 1),
                    onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ConnectPeersScreen()
                        )
                      )
                    },
                    child: const Text(
                      "PAIRED",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 5),
                  RoundedButton(
                    name: "SoloWorkoutButton",
                    height: 40,
                    color: const Color.fromRGBO(48, 79, 254, 1),
                    onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChooseWorkoutScreen(partnerWorkout: false)
                        )
                      )
                    },
                    child: const Text(
                    "SOLO",
                    style: TextStyle(color: Colors.white),
                    )
                  )
                ],
              )
            )
          );
        }
      )
    );
  }
}