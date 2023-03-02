import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  void startWorkout(BuildContext context, ExerciseType exerciseType) async {
    final prefs = await SharedPreferences.getInstance();
    int? targetHeartRate = await prefs.getInt("target_heart_rate");
    if (targetHeartRate == null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => TargetHeartRateScreen()));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WorkoutScreen(exerciseType: exerciseType)));
    }
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
                    child: ListView(children: <Widget>[
                      Row(children: [
                        IconButton(
                            icon: const Icon(
                              Icons.hiking,
                              color: Colors.green,
                              size: 40,
                            ),
                            onPressed: () =>
                                {startWorkout(context, ExerciseType.walking)}),
                        IconButton(
                            icon: const Icon(
                              Icons.directions_run,
                              color: Colors.green,
                              size: 40,
                            ),
                            onPressed: () =>
                                {startWorkout(context, ExerciseType.running)}),
                        IconButton(
                            icon: const Icon(
                              Icons.directions_bike,
                              color: Colors.green,
                              size: 40,
                            ),
                            onPressed: () =>
                                {startWorkout(context, ExerciseType.biking)}),
                      ]),
                      const SizedBox(height: 5),
                      RoundedButton(
                        text: "Settings",
                        width: screenSize.width,
                        height: 40,
                        onPressed: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SettingsScreen()))
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
                                builder: (context) =>
                                    const ConnectPeersScreen()),
                          )
                        },
                      ),
                    ])));
          },
        ));
  }
}

class TargetHeartRateScreen extends StatefulWidget {
  const TargetHeartRateScreen({super.key});

  @override
  State<TargetHeartRateScreen> createState() => _TargetHeartRateScreenState();
}

class _TargetHeartRateScreenState extends State<TargetHeartRateScreen> {
  TextEditingController _heartRateController = TextEditingController();
  TextEditingController _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WatchShape(builder: (context, shape, widget) {
        return Container(
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              const Text("Enter Target Heart\n Rate Or Age",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                        child: TextField(
                          controller: _heartRateController,
                          style: TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: "Target Heart Rate",
                            labelStyle: TextStyle(color: Colors.blueAccent),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                        child: TextField(
                          controller: _ageController,
                          style: TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: "Age",
                            labelStyle: TextStyle(color: Colors.blueAccent),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: ElevatedButton(
                            onPressed: () async {
                              // Do input validation and then write the shared prefs
                              int? heartRate = int.tryParse(_heartRateController.text);
                              int? age = int.tryParse(_ageController.text);
                              if(age == null && heartRate == null) return;
                              int result = heartRate != null ? heartRate : (208 - 0.7*age!.toDouble()).toInt();
                              final sharedPreferences = await SharedPreferences.getInstance();
                              await sharedPreferences.setInt("target_heart_rate", result);
                              Navigator.pop(context);
                            }, child: Text("Confirm")),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
