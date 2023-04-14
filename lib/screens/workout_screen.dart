import 'dart:async';

import 'package:logging/logging.dart';
import 'package:screen_state/screen_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wear/wear.dart';
import 'package:workout/workout.dart';
import 'package:flutter/material.dart';
import 'package:peer_cycle/screens/map_screen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:peer_cycle/logging/workout_logger.dart';
import 'package:peer_cycle/screens/peer_workout_screen.dart';
import 'package:peer_cycle/screens/personal_workout_screen.dart';
import 'package:peer_cycle/logging/app_event.dart';
import 'package:peer_cycle/workout/workout_wrapper.dart';
import 'package:peer_cycle/screens/workout_control_screen.dart';
import 'package:peer_cycle/workout/workout_start_result_wrapper.dart';
import 'package:peer_cycle/utils.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen(
      {super.key,
      required this.exerciseType,
      required this.displayPartnerScreen});

  final ExerciseType exerciseType;
  final bool displayPartnerScreen;
  static final log = Logger("workout_screen");

  @override
  State<StatefulWidget> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final workout = WorkoutWrapper();
  final screenState = Screen();
  StreamSubscription<ScreenStateEvent>? screenStateSubscription;
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  final List<String> pageNames = [];
  final PageController controller = PageController(initialPage: 1);

  @override
  void initState() {
    super.initState();
    // Log Screen state events
    try {
      screenStateSubscription = screenState.screenStateStream?.listen((event) {
        final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        switch (event) {
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

  Future<WorkoutStartResultWrapper> startWorkout() async {
    AndroidDeviceInfo deviceInfo = await deviceInfoPlugin.androidInfo;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    WorkoutLogger.instance.deviceId = deviceInfo.id;
    WorkoutLogger.instance.serialNum = deviceInfo.serialNumber;
    WorkoutLogger.instance.userName = prefs.getString(userNameKey) ?? "Unknown";
    //determine if the hr should be displayed as percentage of max HR
    //default max is 150 bpm if user has not specified
    int maxHR = prefs.getInt(maxHRKey) ?? 150;
    //determine if the power should be displayed as percentage of the max Power
    //default max power is 100 W if user has not specified
    int maxPower = prefs.getInt(ftpKey) ?? 100;
    bool useHRPercentage = prefs.getBool(useHRPercentageKey) ?? false;
    bool usePowerPercentage = prefs.getBool(usePowerPercentageKey) ?? false;
    WorkoutLogger.instance.addEvent({
      "event_type": AppEvent.workoutStarted.value,
      "workout_type": widget.exerciseType.toString(),
      "timestamp": DateTime.now().millisecondsSinceEpoch ~/ 1000,
    });
    WorkoutLogger.instance.startWorkout(widget.exerciseType);
    return workout.start(
      exerciseType: widget.exerciseType,
      features: [
        WorkoutFeature.heartRate,
        WorkoutFeature.calories,
        WorkoutFeature.steps,
        WorkoutFeature.distance,
        WorkoutFeature.speed,
        WorkoutFeature.location,
        WorkoutFeature.power,
      ],
      enableGps: true,
      useHRPercentage: useHRPercentage,
      usePowerPercentage: usePowerPercentage,
      maxHR: maxHR,
      maxPower: maxPower,
    );
  }

  void handlePageChange(int newPageIndex) {
    WorkoutLogger.instance.addEvent({
      "event_type": AppEvent.pageSwitched.value,
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
    controller.dispose();
    await screenStateSubscription?.cancel();
  }

  List<Widget> generatePageViews(
      AsyncSnapshot<WorkoutStartResultWrapper> snapshot) {
    List<Widget> pageViews = [];
    pageViews.add(getPageViewPage(
        const WorkoutControlScreen(), "workout_control_screen"));

    pageViews.add(getPageViewPage(
      PersonalWorkoutScreen(
        workout: workout,
        exerciseType: widget.exerciseType,
        workoutStartResultWrapper: snapshot.data!,
      ),
      "personal_workout_screen",
    ));

    if (widget.displayPartnerScreen) {
      pageViews.add(getPageViewPage(
        PeerWorkoutScreen(
          workout: workout,
        ),
        "peer_workout_screen",
      ));
    }

    pageViews.add(getPageViewPage(
      const MapScreen(),
      "map_screen",
    ));
    return pageViews;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (workout.completed) {
          return true;
        }
        controller.jumpToPage(0);
        return false;
      },
      child: FutureBuilder<WorkoutStartResultWrapper>(
          future: startWorkout(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              WorkoutScreen.log.warning(
                  "Unsupported features: ${snapshot.data!.workoutStartResult.unsupportedFeatures}");
              return Scaffold(
                  backgroundColor: Colors.black,
                  body: WatchShape(builder: (context, shape, _) {
                    return Center(
                        child: PageView(
                            controller: controller,
                            onPageChanged: handlePageChange,
                            scrollDirection: Axis.vertical,
                            children: generatePageViews(snapshot)));
                  }));
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}
