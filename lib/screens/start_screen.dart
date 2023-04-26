import 'package:peer_cycle/screens/connect_sensors_screen.dart';
import 'package:wear/wear.dart';
import 'package:flutter/material.dart';
import 'package:peer_cycle/utils.dart';
import 'package:peer_cycle/widgets/rounded_button.dart';
import 'package:peer_cycle/screens/settings_screen.dart';
import 'package:peer_cycle/screens/choose_workout_type_screen.dart';

import '../bluetooth/bluetooth_manager.dart';

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
                    height: screenSize.height + 10,
                    width: screenSize.width + 10,
                    child: ListView(children: <Widget>[
                      const SizedBox(height: 5),
                      RoundedButton(
                          name: "WorkoutButton",
                          width: screenSize.width,
                          height: 40,
                          color: const Color.fromRGBO(48, 79, 254, 1),
                          onPressed: () => {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ChooseWorkoutTypeScreen()))
                          },
                          child: const Text(
                            "WORKOUT",
                            style: TextStyle(color: Colors.white),
                          )
                      ),
                      RoundedButton(
                        name: "SettingsButton",
                        width: screenSize.width,
                        height: 40,
                        color: const Color.fromRGBO(48, 79, 254, 1),
                        onPressed: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SettingsScreen()))
                        },
                        child: const Text(
                          "SETTINGS",
                          style: TextStyle(color: Colors.white),
                        )
                      ),
                      RoundedButton(
                        name: "ConnectSensorsButton",
                        width: screenSize.width,
                        height: 40,
                        color: const Color.fromRGBO(48, 79, 254, 1),
                        onPressed: () async {
                          bool success = await BluetoothManager.instance.requestBluetoothPermissions();
                          if(!success) return;
                          if(context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ConnectSensorsScreen()
                              ),
                            );
                          }
                        },
                        child: const Text(
                          "CONNECT SENSORS",
                          style: TextStyle(color: Colors.white),
                        )
                      ),
                    ])));
          },
        ));
  }
}

