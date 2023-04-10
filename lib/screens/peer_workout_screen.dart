import 'dart:async';

import 'package:logging/logging.dart';
import 'package:peer_cycle/bluetooth/bluetooth_manager.dart';
import 'package:wear/wear.dart';
import 'package:flutter/material.dart';
import 'package:workout/workout.dart';
import 'package:peer_cycle/utils.dart';
import 'package:peer_cycle/workout/workout_wrapper.dart';
import 'package:peer_cycle/widgets/metric_tile.dart';

class PeerWorkoutScreen extends StatefulWidget {
  const PeerWorkoutScreen({
    super.key,
    required this.workout,
  });
  final WorkoutWrapper workout;

  static final log = Logger("peer_workout_screen");

  @override
  State<PeerWorkoutScreen> createState() => _PeerWorkoutScreenState();
}

class _PeerWorkoutScreenState extends State<PeerWorkoutScreen>
    with AutomaticKeepAliveClientMixin<PeerWorkoutScreen> {
  int heartRate = 0;
  int calories = 0;
  int steps = 0;
  int distance = 0;
  int speed = 0;
  int power = 0;
  int cadence = 0;
  Duration _duration = Duration.zero;
  late Timer _timer;

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _duration += const Duration(seconds: 1);
      });
    });
  }

  final List<WorkoutReading> readings = [];
  late StreamSubscription<WorkoutReading> workoutStreamSubscription;
  late StreamSubscription<Map<int, Map<String, String>>>
      bluetoothStreamSubscription;

  @override
  void initState() {
    super.initState();
    startTimer();
    workoutStreamSubscription = widget.workout.stream.listen((reading) {
      switch (reading.feature) {
        case WorkoutFeature.unknown:
          return;
        case WorkoutFeature.heartRate:
          setState(() {
            heartRate = (double.tryParse(reading.value) ?? -1).toInt();
          });
          BluetoothManager.instance
              .broadcastString("heartRate:${reading.value}");
          break;
        case WorkoutFeature.calories:
          setState(() {
            calories = (double.tryParse(reading.value) ?? -1).toInt();
          });
          BluetoothManager.instance
              .broadcastString("calories:${reading.value}");
          break;
        case WorkoutFeature.steps: //change to time.
          setState(() {
            steps = (double.tryParse(reading.value) ?? -1).toInt();
          });
          BluetoothManager.instance.broadcastString("steps:${reading.value}");
          break;
        case WorkoutFeature.distance:
          setState(() {
            distance = (double.tryParse(reading.value) ?? -1).toInt();
          });
          BluetoothManager.instance
              .broadcastString("distance:${reading.value}");
          break;
        case WorkoutFeature.speed:
          double speedInKph = mpsToKph(double.tryParse(reading.value) ?? -1.0);
          setState(() {
            speed = speedInKph.toInt();
          });
          BluetoothManager.instance.broadcastString("speed:$speedInKph");
          break;
        case WorkoutFeature.location:
          break;
        case WorkoutFeature.power:
          setState(() {
            power = (double.tryParse(reading.value) ?? -1).toInt();
          });
          break;
        case WorkoutFeature.cadence:
          setState(() {
            cadence = (double.tryParse(reading.value) ?? -1).toInt();
          });
          break;
      }
    });
  }

  @override
  void dispose() async {
    super.dispose();
    _timer.cancel();
    await workoutStreamSubscription.cancel();
  }

  _PeerWorkoutScreenState() {
    bluetoothStreamSubscription =
        BluetoothManager.instance.deviceDataStream.listen((event) {
      final map = event.values.first;

      for (final key in map.keys) {
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
      return double.tryParse(
          deviceData.values.elementAt(partnerNum)[attribute]!);
    } catch (e) {
      PeerWorkoutScreen.log.severe(e.toString());
      PeerWorkoutScreen.log.severe("ERROR in getPartnerAttribute!!!");
      PeerWorkoutScreen.log.severe("deviceData: $deviceData");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: <Widget>[
            Container(
                margin: const EdgeInsets.all(0.0),
                decoration: const BoxDecoration(
                  color: Color(0xFF47cb3b),
                  shape: BoxShape.circle,
                )),
            Container(
                margin: const EdgeInsets.all(7.0),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                )),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        MetricTile(
                          icon:
                              const Icon(Icons.speed, color: Colors.lightBlue),
                          value: "$speed km/h",
                          valueColor: Colors.green,
                        ),
                        MetricTile(
                          icon: const Icon(Icons.pin_drop_outlined,
                              color: Colors.red),
                          value: "$distance m",
                          valueColor: Colors.green,
                        ),
                        MetricTile(
                          icon: const Icon(Icons.timer, color: Colors.teal),
                          value: _duration
                              .toString()
                              .split('.')
                              .first
                              .padLeft(8, "0"),
                          valueColor: Colors.green,
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        MetricTile(
                          icon: const Icon(Icons.favorite_outlined,
                              color: Colors.red),
                          value: "$heartRate bpm",
                          valueColor: Colors.green,
                        ),
                        MetricTile(
                          icon: const Icon(Icons.electric_bolt,
                              color: Colors.yellow),
                          value: "$power W",
                          valueColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                  ...getPartnerCards()
                ],
              ),
            ),
          ],
        ));
  }

  List<Widget> getPartnerCards() {
    List<Widget> partnerCards = [];
    final deviceData = BluetoothManager.instance.deviceData;
    if (deviceData[0] != null) {
      double? heartRate =
          double.tryParse(deviceData.values.elementAt(0)["heartRate"] ?? "");
      double? power =
          double.tryParse(deviceData.values.elementAt(0)["power"] ?? "");
      partnerCards.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child:
            PartnerCard(heartRate: heartRate?.toInt(), power: power?.toInt()),
      ));
    }
    if (deviceData[1] != null) {
      double? heartRate =
          double.tryParse(deviceData.values.elementAt(1)["heartRate"] ?? "");
      double? power =
          double.tryParse(deviceData.values.elementAt(1)["power"] ?? "");
      partnerCards.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: PartnerCard(
          heartRate: heartRate?.toInt(),
          power: power?.toInt(),
        ),
      ));
    }
    return partnerCards;
  }

  @override
  bool get wantKeepAlive => true;
}

class PartnerCard extends StatelessWidget {
  final int? heartRate;
  final int? power;

  const PartnerCard({super.key, this.heartRate, this.power});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Transform.scale(
        scale: 0.6,
        child: Container(
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
            child: const Icon(
              Icons.person,
              color: Colors.black,
            )),
      ),
      Text(heartRate != null ? "$heartRate bpm" : "-- bpm",
          style: TextStyle(color: Colors.green)),
      SizedBox(width: 25),
      Text(
        power != null ? "$power w" : "-- bpm",
        style: TextStyle(color: Colors.green),
      )
    ]);
  }
}
