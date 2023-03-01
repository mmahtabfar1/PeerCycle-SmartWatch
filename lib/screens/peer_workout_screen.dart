import 'package:flutter/rendering.dart';
import 'package:peer_cycle/bluetooth/bluetooth_manager.dart';
import 'package:wear/wear.dart';
import 'package:flutter/material.dart';
import 'package:workout/workout.dart';
import 'package:workout/workout.dart';
import 'package:peer_cycle/widgets/rounded_button.dart';
import 'dart:async';



class PeerWorkoutScreen extends StatefulWidget {
  const PeerWorkoutScreen({
      super.key,
      required this.workout,
      required this.exerciseType
  });
  final Workout workout;
  final ExerciseType exerciseType;
  @override
  State<PeerWorkoutScreen> createState() => _PeerWorkoutScreenState();
}

class _PeerWorkoutScreenState extends State<PeerWorkoutScreen>
    with AutomaticKeepAliveClientMixin<PeerWorkoutScreen> {

  int indivHeartRate = 0;
  int indivCalories = 0;
  int indivSpeed = 0;
  double indivDistance = 0;
  Duration _timer = Duration.zero;

  int heartRate = 0;
  int calories = 0;
  int steps = 0;
  int speed = 0;

  void startTimer(){
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timer += const Duration(seconds: 1);
      });
    });
  }
  final exerciseType = ExerciseType.walking;
  final features = [
    WorkoutFeature.heartRate,
    WorkoutFeature.calories,
    WorkoutFeature.steps,
    WorkoutFeature.distance,
    WorkoutFeature.speed,
  ];


  final List<WorkoutReading> readings = [];
  late StreamSubscription<WorkoutReading> workoutStreamSubscription;

  @override
  void initState() {
    super.initState();
    startTimer();
    workoutStreamSubscription = widget.workout.stream.listen((reading) {
      readings.add(reading);
      switch(reading.feature) {
        case WorkoutFeature.unknown:
          return;
        case WorkoutFeature.heartRate:
          setState(() {
            indivHeartRate = reading.value.toInt();
          });
          break;
        case WorkoutFeature.calories:
          setState(() {
            indivCalories = reading.value.toInt();
          });
          break;
        case WorkoutFeature.distance:
          setState(() {
            indivDistance = reading.value;
          });
          break;
        case WorkoutFeature.speed:
          setState(() {
            indivSpeed = reading.value.toInt();
          });
          break;
      }
    });
  }




  _PeerWorkoutScreenState() {
    BluetoothManager.instance.deviceDataStream.listen((event) {
      final map = event.values.first;

      for(final key in map.keys) {
        switch (key) {
          case "heartRate":
            setState(() {
              heartRate = double.parse(map[key] ?? "-1").toInt();
            });
            break;
          case "calories":
            setState(() {
              calories = double.parse(map[key] ?? "-1").toInt();
            });
            break;
          case "steps":
            setState(() {
              steps = double.parse(map[key] ?? "-1").toInt();
            });
            break;
          case "speed":
            setState(() {
              speed = double.parse(map[key] ?? "-1").toInt();
            });
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        backgroundColor: Colors.black,
        body: WatchShape(
            builder: (context, shape, widget) {
              return Column( //Top Set
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 18, 28, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.favorite_border, color: Colors.red, size: 25,),
                            SizedBox(height: 1),
                            Text(indivHeartRate.toString(), style: TextStyle(color: Colors.white, fontSize: 20))
                          ],
                        ),
                        Column(
                          children: [
                            Icon(Icons.speed, color: Colors.blue, size: 25),
                            SizedBox(height: 1),
                            Text(indivSpeed.toString(), style: TextStyle(color: Colors.white, fontSize: 20))
                          ],
                        ),
                        Column(
                          children: [
                            Icon(Icons.whatshot, color: Colors.deepOrange, size: 25),
                            SizedBox(height: 1),
                            Text(indivCalories.toString(), style: TextStyle(color: Colors.white, fontSize: 20))
                          ],
                        )
                      ],
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        PartnerCard(),
                        SizedBox(height: 10),
                        PartnerCard(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          const Icon(
                          Icons.place,
                          color: Colors.grey,
                        ),
                          Text(
                            indivDistance.toString() + " km",
                          style: const TextStyle(color: Colors.white, fontSize: 25),
                          ),
                        ]),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              Text(
                                _timer.toString().split('.').first.padLeft(8, "0"),
                                style: const TextStyle(color: Colors.white, fontSize: 25),
                              ),
                            ]),
                      ],
                    ),
                  ),
                ],
              );
            }
        )
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class PartnerCard extends StatefulWidget {

  const PartnerCard({
    super.key,
  });

  @override
  State<PartnerCard> createState() => _PartnerCardState();
}

class _PartnerCardState extends State<PartnerCard> {
  @override



  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: Color(0xFF5B5B5B)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 40,
            width: 35,
            child: Icon(Icons.person)
            ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.red,
                width: 3
              )
            ),
            height: 40,
            width: 50,
            child: Center(child: Text("999", style: TextStyle(fontSize: 20, color: Colors.white))),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,
                width: 3
              )
            ),
            height: 40,
            width: 50,
            child: Center(child: Text("999", style: TextStyle(fontSize: 20, color: Colors.white ))),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.orange,
                width: 3
              )
            ),
            height: 40,
            width: 50,
            child: Center(child: Text("999", style: TextStyle(fontSize: 20, color: Colors.white))),
          )
        ],
      ),
    );
  }
}
