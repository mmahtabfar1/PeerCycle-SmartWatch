import 'package:peer_cycle/widgets/preferences_switch.dart';
import 'package:wear/wear.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peer_cycle/utils.dart';
import 'package:peer_cycle/widgets/rounded_button.dart';
import 'package:peer_cycle/screens/view_personal_info_screen.dart';
import 'package:peer_cycle/screens/connect_sensors_screen.dart';
import 'package:peer_cycle/screens/view_past_workouts_screen.dart';

import '../bluetooth/bluetooth_manager.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
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
                              child: const Text("User Profile")
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
                              onPressed: () async {
                                bool success = await BluetoothManager.instance.requestBluetoothPermissions();
                                if(!success) return;
                                Navigator.push(context,
                                  MaterialPageRoute(
                                    builder: (context) => const ConnectSensorsScreen()
                                  )
                                );
                              },
                              child: const Text("Connect Sensors")
                            ),
                          ),
                          //
                          //button to toggle displaying HR as % of max
                          //
                          const SizedBox(height: 10),
                          PreferencesSwitch(
                            prefs: snapshot.data!,
                            prefKey: useHRPercentageKey,
                            text: "Display % HR",
                          ),
                          const SizedBox(height: 10),
                          PreferencesSwitch(
                            prefs: snapshot.data!,
                            prefKey: usePowerPercentageKey,
                            text: "Display % Power",
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
        return const Center(
          child: CircularProgressIndicator()
        );
      }
    );
  }
}