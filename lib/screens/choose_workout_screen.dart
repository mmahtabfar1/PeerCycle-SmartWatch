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
    int? targetHeartRate = prefs.getInt(maxHRKey);
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const <Widget>[
                            Text(
                              "Walking",
                              style: TextStyle(
                                color: Colors.white,
                              )
                            ),
                            Icon(
                              Icons.directions_walk,
                              color: Colors.white,
                            )
                          ],
                        )
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const <Widget>[
                            Text(
                              "Running",
                              style: TextStyle(
                                color: Colors.white,
                              )
                            ),
                            Icon(
                              Icons.directions_run,
                              color: Colors.white,
                            )
                          ],
                        )
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const <Widget>[
                            Text(
                              "Cycling",
                              style: TextStyle(
                                color: Colors.white,
                              )
                            ),
                            Icon(
                              Icons.directions_bike,
                              color: Colors.white,
                            )
                          ],
                        )
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
              const Text("Enter Max Heart\n Rate Or Age",
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
                            labelText: "Max Heart Rate",
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
                            await sharedPreferences.setInt(userAgeKey, age!);
                            await sharedPreferences.setInt(maxHRKey, result);
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
