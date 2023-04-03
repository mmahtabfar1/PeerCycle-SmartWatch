import 'package:wear/wear.dart';
import 'package:flutter/material.dart';
import 'package:peer_cycle/utils.dart';
import 'package:peer_cycle/widgets/rounded_button.dart';
import 'package:peer_cycle/screens/view_personal_info_screen.dart';
import 'package:peer_cycle/screens/connect_sensors_screen.dart';
import 'package:peer_cycle/screens/view_past_workouts_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("Settings",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      )
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 40,
                      child: RoundedButton(
                        name: "ProfileButton",
                        onPressed: () => {
                          Navigator.push(context,
                            MaterialPageRoute(
                              builder: (context) => const ViewPersonalInfoScreen()
                            )
                          )
                        },
                        child: const Text("Manage User Profile")
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 40,
                      child: RoundedButton(
                        name: "ViewPastWorkoutsButton",
                        onPressed: () => {
                          Navigator.push(context,
                            MaterialPageRoute(
                              builder: (context) => const ViewPastWorkoutsScreen()
                            )
                          )
                        },
                        child: const Text("View Past Workouts")
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 40,
                      child: RoundedButton(
                        name: "ConnectSensorsButton",
                        onPressed: () => {
                          Navigator.push(context,
                            MaterialPageRoute(
                              builder: (context) => const ConnectSensorsScreen()
                            )
                          )
                        },
                        child: const Text("Connect Sensors")
                      ),
                    ),
                  ]
                )
              )
            )
          );
        }
      )
    );
  }
}