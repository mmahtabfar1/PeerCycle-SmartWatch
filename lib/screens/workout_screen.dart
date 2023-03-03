import 'package:wear/wear.dart';
import 'package:workout/workout.dart';
import 'package:flutter/material.dart';
import 'package:peer_cycle/screens/map_screen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:peer_cycle/logging/workout_logger.dart';
import 'package:peer_cycle/screens/peer_workout_screen.dart';
import 'package:peer_cycle/screens/personal_workout_screen.dart';

import '../logging/app_event.dart';

class WorkoutScreen extends StatelessWidget {
  final ExerciseType exerciseType;
  final workout = Workout();
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  final List<String> pageNames = [];

  WorkoutScreen({
    super.key,
    required this.exerciseType,
  });

  final features = [
    WorkoutFeature.heartRate,
    WorkoutFeature.calories,
    WorkoutFeature.steps,
    WorkoutFeature.distance,
    WorkoutFeature.speed,
  ];

  Widget getPageViewPage(Widget page, String name) {
    pageNames.add(name);
    return page;
  }

  Future<WorkoutStartResult> startWorkout() async {
    AndroidDeviceInfo deviceInfo = await deviceInfoPlugin.androidInfo;
    WorkoutLogger.instance.deviceId = deviceInfo.id;
    WorkoutLogger.instance.serialNum = deviceInfo.serialNumber;
    //TODO: add the user's name to the WorkoutLogger here
    WorkoutLogger.instance.startWorkout(exerciseType);
    return workout.start(
      exerciseType: exerciseType,
      features: features,
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WorkoutStartResult>(
      future: startWorkout(),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: WatchShape(
              builder: (context, shape, widget) {
                return Center(
                  child: PageView(
                    onPageChanged: handlePageChange,
                    scrollDirection: Axis.vertical,
                    children: [
                      getPageViewPage(
                        PersonalWorkoutScreen(
                            workout: workout,
                            exerciseType: exerciseType
                        ),
                        "personal_workout_screen",
                      ),
                      getPageViewPage(
                         PeerWorkoutScreen(
                            workout: workout,
                            exerciseType: exerciseType
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