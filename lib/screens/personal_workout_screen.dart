import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:peer_cycle/bluetooth/bluetooth_manager.dart';
import 'package:peer_cycle/logging/fit_activity_logger.dart';
import 'package:peer_cycle/workout/workout_start_result_wrapper.dart';
import 'package:workout/workout.dart';
import 'package:peer_cycle/logging/workout_logger.dart';
import 'package:peer_cycle/utils.dart';
import 'package:peer_cycle/workout/workout_wrapper.dart';
import 'package:peer_cycle/logging/app_event.dart';
import 'package:peer_cycle/widgets/metric_tile.dart';

class PersonalWorkoutScreen extends StatefulWidget {
  const PersonalWorkoutScreen({
    super.key,
    required this.workout,
    required this.exerciseType,
    required this.workoutStartResultWrapper,
  });

  final WorkoutWrapper workout;
  final ExerciseType exerciseType;
  final WorkoutStartResultWrapper workoutStartResultWrapper;
  static final log = Logger("personal_workout_screen");

  @override
  State<PersonalWorkoutScreen> createState() => _PersonalWorkoutScreenState();
}

class _PersonalWorkoutScreenState extends State<PersonalWorkoutScreen>
  with AutomaticKeepAliveClientMixin<PersonalWorkoutScreen> {

  int heartRate = 0;
  bool useHRPercentage = false;
  int calories = 0;
  int steps = 0;
  int distance = 0;
  int speed = 0;
  int power = 0;
  bool usePowerPercentage = false;
  int cadence = 0;
  Duration _duration = Duration.zero;
  late Timer _timer;

  void startTimer(){
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _duration += const Duration(seconds: 1);
      });
    });
  }

  final List<WorkoutReading> readings = [];
  late StreamSubscription<WorkoutReading> workoutStreamSubscription;

  @override
  void initState() {
    super.initState();
    startTimer();
    useHRPercentage = widget.workoutStartResultWrapper.useHRPercentage;
    usePowerPercentage = widget.workoutStartResultWrapper.usePowerPercentage;
    workoutStreamSubscription = widget.workout.stream.listen((reading) {
      WorkoutLogger.instance.logMetric(reading);
      readings.add(reading);
      switch(reading.feature) {
        case WorkoutFeature.unknown:
          return;
        case WorkoutFeature.heartRate:
          setState(() {
            heartRate = (double.tryParse(reading.value) ?? -1).toInt();
          });
          BluetoothManager.instance.broadcastString("heartRate:${reading.value}");
          break;
        case WorkoutFeature.calories:
          setState(() {
            calories = (double.tryParse(reading.value) ?? -1).toInt();
          });
          BluetoothManager.instance.broadcastString("calories:${reading.value}");
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
          BluetoothManager.instance.broadcastString("distance:${reading.value}");
          break;
        case WorkoutFeature.speed:
          double speedInKph = mpsToKph(double.tryParse(reading.value) ?? -1.0);
          setState(() {
            speed = speedInKph.toInt();
          });
          BluetoothManager.instance.broadcastString("speed:$speedInKph");
          break;
        case WorkoutFeature.location:
          PersonalWorkoutScreen.log.info("GOT LOCATION DATA ${reading.value}");
          break;
        case WorkoutFeature.power:
          setState(() {
            power = (double.tryParse(reading.value) ?? -1).toInt();
          });
          BluetoothManager.instance.broadcastString("power:${reading.value}");
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
    await stopWorkout();
    await workoutStreamSubscription.cancel();
    writeFitFile();
    WorkoutLogger.instance.addEvent({
      "event_type": AppEvent.workoutEnded.value,
      "workout_type": widget.exerciseType.toString(),
      "timestamp": DateTime.now().millisecondsSinceEpoch ~/ 1000,
    });
    WorkoutLogger.instance.endWorkout();
  }

  void writeFitFile() async {
    String currentTime = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    String appDocumentsDirectory = (await getApplicationDocumentsDirectory()).path;
    String fitFilePath = "$appDocumentsDirectory/workout@$currentTime.fit";
    PersonalWorkoutScreen.log.info("fitFilePath: $fitFilePath");
    await FitActivityLogger.writeFitFile(fitFilePath, readings, widget.exerciseType);
  }

  Future<void> stopWorkout() async {
    await widget.workout.stop();
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
            )
          ),
          Container(
            margin: const EdgeInsets.all(7.0),
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            )
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "WORKOUT STATS",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  )
                ),
                const SizedBox(height: 10),
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
                        icon: const Icon(Icons.speed, color: Colors.lightBlue),
                        value: "$speed km/h",
                        valueColor: Colors.green,
                      ),
                      MetricTile(
                        icon: const Icon(Icons.pin_drop_outlined, color: Colors.red),
                        value: "$distance m",
                        valueColor: Colors.green,
                      ),
                      MetricTile(
                        icon: const Icon(Icons.timer, color: Colors.teal),
                        value: _duration.toString().split('.').first.padLeft(8, "0"),
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
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            useHRPercentage = !useHRPercentage;
                          });
                        },
                        child: MetricTile(
                          icon: const Icon(Icons.favorite_outlined, color: Colors.red),
                          value: useHRPercentage
                              ? "${((heartRate / widget.workoutStartResultWrapper.maxHR) * 100).toStringAsFixed(1)} %"
                              : "$heartRate bpm",
                          valueColor: Colors.green,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            usePowerPercentage = !usePowerPercentage;
                          });
                        },
                        child: MetricTile(
                          icon: const Icon(Icons.electric_bolt, color: Colors.yellow),
                          value: usePowerPercentage
                              ? "${((power / widget.workoutStartResultWrapper.maxPower) * 100).toStringAsFixed(1)} %"
                              : "$power W",
                          valueColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }

  @override
  bool get wantKeepAlive => true;
}