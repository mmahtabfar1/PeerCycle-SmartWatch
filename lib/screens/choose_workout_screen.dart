import 'package:flutter/services.dart';
import 'package:wear/wear.dart';
import 'package:flutter/material.dart';
import 'package:peer_cycle/utils.dart';
import 'package:peer_cycle/widgets/rounded_button.dart';
import 'package:peer_cycle/screens/workout_screen.dart';
import 'package:workout/workout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChooseWorkoutScreen extends StatelessWidget {
  const ChooseWorkoutScreen({super.key});

  //start the selected workout
  void startWorkout(BuildContext context, ExerciseType exerciseType) async {
    final prefs = await SharedPreferences.getInstance();
    int? targetHeartRate = prefs.getInt("target_heart_rate");
    if (targetHeartRate == null && context.mounted) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const TargetHeartRateScreen()));
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //TODO: add workout icons to these buttons
                  const Text(
                    "SELECT WORKOUT",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 30,
                    width: screenSize.width - 20,
                    child: RoundedButton(
                      name: "StartWalkButton",
                      color: const Color.fromRGBO(48, 79, 254, 1),
                      onPressed: () => {
                        startWorkout(context, ExerciseType.walking)
                      },
                      child: const Text(
                        "Walking",
                        style: TextStyle(color: Colors.black),
                      )
                    )
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 30,
                    width: screenSize.width - 20,
                    child: RoundedButton(
                      name: "StartRunButton",
                      color: const Color.fromRGBO(48, 79, 254, 1),
                      onPressed: () => {
                        startWorkout(context, ExerciseType.running)
                      },
                      child: const Text(
                        "Running",
                        style: TextStyle(color: Colors.black),
                      )
                    )
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 30,
                    width: screenSize.width - 20,
                    child: RoundedButton(
                      name: "StartCycleButton",
                      color: const Color.fromRGBO(48, 79, 254, 1),
                      onPressed: () => {
                        startWorkout(context, ExerciseType.biking)
                      },
                      child: const Text(
                        "Cycling",
                        style: TextStyle(color: Colors.black),
                      )
                    )
                  ),
                ]
              )
            )
          );
        }
      )
    );
  }
}

class TargetHeartRateScreen extends StatefulWidget {
  const TargetHeartRateScreen({super.key});

  @override
  State<TargetHeartRateScreen> createState() => _TargetHeartRateScreenState();
}

class _TargetHeartRateScreenState extends State<TargetHeartRateScreen> {
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WatchShape(builder: (context, shape, widget) {
        return Container(
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
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
                          style: const TextStyle(color: Colors.white),
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
                          style: const TextStyle(color: Colors.white),
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
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: ElevatedButton(
                          onPressed: () async {
                            // Do input validation and then write the shared prefs
                            int? heartRate = int.tryParse(_heartRateController.text);
                            int? age = int.tryParse(_ageController.text);
                            if(age == null && heartRate == null) return;
                            int result = heartRate ?? (208 - 0.7*age!.toDouble()).toInt();
                            final sharedPreferences = await SharedPreferences.getInstance();
                            await sharedPreferences.setInt("age", age!);
                            await sharedPreferences.setInt("target_heart_rate", result);
                            if(context.mounted) Navigator.pop(context);
                          }, child: const Text("Confirm")),
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
