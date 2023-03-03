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
  int indivDistance = 0;

  int heartRate = 0;
  int calories = 0; //change to time
  int steps = 0;
  int speed = 0;
  Duration _timer = Duration.zero;

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
            indivDistance = reading.value.toInt();
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

  double? getPartnerAttribute(int partnerNum, String attribute) {
    final deviceData = BluetoothManager.instance.deviceData;
    try {
      return double.tryParse(deviceData.values.elementAt(partnerNum)[attribute]!);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        backgroundColor: Colors.black,
        body: WatchShape(
            builder: (context, shape, widget) {
              return Transform.scale(
                scale: 0.8,
                child: Column( //Top Set
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 0, 28, 5),
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
                          PartnerCard(
                            heartRate: getPartnerAttribute(0, "heartRate")?.toInt(),
                            speed: getPartnerAttribute(0, "speed")?.toInt(),
                            calories: getPartnerAttribute(0, "calories")?.toInt()
                          ),
                          SizedBox(height: 6),
                          PartnerCard(
                            heartRate: getPartnerAttribute(1, "heartRate")?.toInt(),
                            speed: getPartnerAttribute(1, "speed")?.toInt(),
                            calories: getPartnerAttribute(1, "calories")?.toInt()
                          ),
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
                ),
              );
            }
        )
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class PartnerCard extends StatelessWidget {

  int? heartRate;
  int? calories;
  int? speed;

   PartnerCard({
    super.key,
    this.heartRate,
    this.calories,
    this.speed
  });

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
            child: Center(child: Text(heartRate != null ? heartRate.toString() : "--", style: TextStyle(fontSize: 20, color: Colors.white))),
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
            child: Center(child: Text(speed != null ? speed.toString() : "--", style: TextStyle(fontSize: 20, color: Colors.white ))),
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
            child: Center(child: Text(calories != null ? calories.toString() : "--", style: TextStyle(fontSize: 20, color: Colors.white))),
          )
        ],
      ),
    );
  }
}
