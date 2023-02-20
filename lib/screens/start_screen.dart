import 'package:wear/wear.dart';
import 'package:flutter/material.dart';
import 'package:peer_cycle/utils.dart';
import 'package:peer_cycle/widgets/rounded_button.dart';
import 'package:peer_cycle/screens/settings_screen.dart';
import 'package:peer_cycle/screens/connect_peers_screen.dart';
import 'package:peer_cycle/screens/choose_workout_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

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
                    text: "Choose Workout",
                    width: screenSize.width,
                    height: 40,
                    onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChooseWorkoutScreen()
                        )
                      )
                    },
                  ),
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