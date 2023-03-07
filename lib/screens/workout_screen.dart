import 'dart:async';

import 'package:logging/logging.dart';
import 'package:screen_state/screen_state.dart';
import 'package:wear/wear.dart';
import 'package:workout/workout.dart';
import 'package:flutter/material.dart';
import 'package:peer_cycle/screens/map_screen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:peer_cycle/logging/workout_logger.dart';
import 'package:peer_cycle/screens/peer_workout_screen.dart';
import 'package:peer_cycle/screens/personal_workout_screen.dart';
import 'package:peer_cycle/logging/app_event.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({
    super.key,
    required this.exerciseType,
  });

  final ExerciseType exerciseType;
  static final log = Logger("workout_screen");

  static const features = [
    WorkoutFeature.heartRate,
    WorkoutFeature.calories,
    WorkoutFeature.steps,
    WorkoutFeature.distance,
    WorkoutFeature.speed,
  ];

  @override
  State<StatefulWidget> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final workout = Workout();
  final screenState = Screen();
  StreamSubscription<ScreenStateEvent>? screenStateSubscription;
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  final List<String> pageNames = [];

  @override
  void initState() {
    super.initState();
    // Log Screen state events
    try {
      screenStateSubscription = screenState.screenStateStream?.listen((event) {
        final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        switch(event) {
          case ScreenStateEvent.SCREEN_ON:
            WorkoutLogger.instance.addEvent({
              "event_type": AppEvent.screenOn.value,
              "description": "Screen turned on",
              "timestamp": timestamp
            });
            break;
          case ScreenStateEvent.SCREEN_OFF:
            WorkoutLogger.instance.addEvent({
              "event_type": AppEvent.screenOff.value,
              "description": "Screen turned off",
              "timestamp": timestamp
            });
            break;
          case ScreenStateEvent.SCREEN_UNLOCKED:
            WorkoutLogger.instance.addEvent({
              "event_type": AppEvent.screenUnlocked.value,
              "description": "Screen unlocked",
              "timestamp": timestamp
            });
            break;
        }
      });
    } on ScreenStateException catch (e) {
      WorkoutScreen.log.severe("Error when listening to screen state: $e");
    }
  }

  Future<WorkoutStartResult> startWorkout() async {
    AndroidDeviceInfo deviceInfo = await deviceInfoPlugin.androidInfo;
    WorkoutLogger.instance.deviceId = deviceInfo.id;
    WorkoutLogger.instance.serialNum = deviceInfo.serialNumber;
    //TODO: add the user's name to the WorkoutLogger here
    WorkoutLogger.instance.addEvent({
      "event_type": AppEvent.workoutStarted.value.toString(),
      "workout_type": widget.exerciseType.toString(),
      "timestamp": DateTime.now().millisecondsSinceEpoch ~/ 1000,
    });
    WorkoutLogger.instance.startWorkout(widget.exerciseType);
    return workout.start(
      exerciseType: widget.exerciseType,
      features: WorkoutScreen.features,
      enableGps: true,
    );
  }

  void handlePageChange(int newPageIndex) {
    WorkoutLogger.instance.addEvent({
      "event_type": AppEvent.pageSwitched.value.toString(),
      "current_page": pageNames[newPageIndex],
      "timestamp": DateTime.now().millisecondsSinceEpoch ~/ 1000,
    });
  }

  Widget getPageViewPage(Widget page, String name) {
    pageNames.add(name);
    return page;
  }

  @override
  void dispose() async {
    super.dispose();
    await screenStateSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WorkoutStartResult>(
        future: startWorkout(),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            return Scaffold(
                backgroundColor: Colors.black,
                body: WatchShape(
                    builder: (context, shape, _) {
                      return Center(
                          child: PageView(
                            onPageChanged: handlePageChange,
                            scrollDirection: Axis.vertical,
                            children: [
                              getPageViewPage(
                                PersonalWorkoutScreen(
                                    workout: workout,
                                    exerciseType: widget.exerciseType
                                ),
                                "personal_workout_screen",
                              ),
                              getPageViewPage(
                                PeerWorkoutScreen(
                                    workout: workout,
                                    exerciseType: widget.exerciseType
                                ),
                                "peer_workout_screen",
                              ),
                              getPageViewPage(
                                const MapScreen(),
                                "map_screen",
                              )
                            ],
                          )
                      );
                    }
                )
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
    );
  }

}