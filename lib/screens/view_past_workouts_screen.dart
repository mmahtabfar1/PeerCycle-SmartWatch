import 'dart:io';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:wear/wear.dart';
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:peer_cycle/utils.dart';
import 'package:peer_cycle/widgets/rounded_button.dart';

class ViewPastWorkoutsScreen extends StatelessWidget {
  const ViewPastWorkoutsScreen({super.key});

  static final log = Logger("view_past_workouts_screen");

  /// get the date label for the past workout button entry
  String _getWorkoutDate(DateTime dt) {
    String month = DateFormat(DateFormat.MONTH).format(dt);
    String day = DateFormat(DateFormat.DAY).format(dt);
    String year = DateFormat(DateFormat.YEAR).format(dt);
    return "$month $day $year";
  }

  /// get the icon for the workout type
  IconData _getIconDataForWorkout(String exerciseTypeStr) {
    final map = {
      "ExerciseType.walking": Icons.directions_walk,
      "ExerciseType.running": Icons.directions_run,
      "ExerciseType.biking": Icons.directions_bike,
    };
    return map[exerciseTypeStr] ?? Icons.directions_bike;
  }

  /// method that reads past workouts from disk
  /// and returns list of widgets representing
  /// each saved workout session
  Future<List<Widget>> _getPastWorkouts() async {
    String appDocumentsDirectory =
        (await getApplicationDocumentsDirectory()).path;
    Directory summariesDir = Directory("$appDocumentsDirectory/summaries");

    if(!summariesDir.existsSync()) return <Widget>[];
    try {
      return summariesDir
        .listSync()
        .map((entry) => entry.path)
        .where((path) => path.endsWith(".json"))
        .map((path) {
          File f = File(path);
          Map<String, dynamic> map = jsonDecode(f.readAsStringSync());
          String fileName = path.substring(path.lastIndexOf("/") + 1);
          final dt = DateTime.parse(fileName.substring(0, fileName.lastIndexOf(".json")));
          return RoundedButton(
            color: const Color.fromRGBO(48, 79, 254, 1),
            height: 40,
            name: "PastWorkoutEntryButton",
            onPressed: () async {
              //push the page to view this summary here
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Icon(
                    _getIconDataForWorkout(map["exercise_type"]),
                    color: Colors.white,
                  ),
                  Text(
                    _getWorkoutDate(dt),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  )
                ]
              )
            )
          );
        }).toList();
    } catch (e) {
      log.severe(e);
      return <Widget>[];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Widget>>(
      future: _getPastWorkouts(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Scaffold(
          backgroundColor: Colors.black,
          body: WatchShape(
            builder: (context, shape, widget) {
              Size screenSize = getWatchScreenSize(context);
              return Center(
                child: Container(
                  color: Colors.black,
                  height: screenSize.height +  10,
                  width: screenSize.width + 10,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text("PAST WORKOUTS",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                          )
                        ),
                        ...(snapshot.data!)
                      ],
                    )
                  )
                )
              );
            }
          )
        );
      }
    );
  }
}
