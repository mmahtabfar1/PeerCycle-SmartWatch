import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:workout/workout.dart';
import 'package:peer_cycle/widgets/metric_tile.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  const WorkoutSummaryScreen({
    super.key,
    required this.summaryFilePath,
  });

  final String summaryFilePath;

  Future<Map<String, dynamic>> _loadWorkoutSummary(String path) async {
    File file = File(path);
    return jsonDecode(await file.readAsString());
  }

  String _getWorkoutDurationStr(int startTime, int endTime) {
    return Duration(milliseconds: endTime - startTime)
        .toString()
        .split('.')
        .first
        .padLeft(8, "0");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadWorkoutSummary(summaryFilePath),
      builder: (context, snapshot) {
        if(!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        Map<String, dynamic> metricMap = jsonDecode(snapshot.data!["metrics"]);
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "WORKOUT SUMMARY",
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
                    children: <Widget> [
                      MetricTile(
                        icon: const Icon(Icons.speed, color: Colors.lightBlue),
                        value: "${metricMap[WorkoutFeature.speed.name]} km/h",
                        valueColor: Colors.green,
                      ),
                      MetricTile(
                        icon: const Icon(Icons.pin_drop_outlined, color: Colors.red),
                        value: "${metricMap[WorkoutFeature.distance.name]} m",
                        valueColor: Colors.green,
                      ),
                      MetricTile(
                        icon: const Icon(Icons.timer, color: Colors.teal),
                        value: _getWorkoutDurationStr(
                          snapshot.data?["start_time"] ?? 0,
                          snapshot.data?["end_time"] ?? 0,
                        ),
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
                        icon: const Icon(Icons.favorite_outlined, color: Colors.red),
                        value: "${metricMap[WorkoutFeature.heartRate.name]} bpm",
                        valueColor: Colors.green,
                      ),
                      MetricTile(
                        icon: const Icon(Icons.electric_bolt, color: Colors.yellow),
                        value: "${metricMap[WorkoutFeature.power.name] ?? 0.0} W",
                        valueColor: Colors.green,
                      )
                    ]
                  )
                )
              ]
            )
          )
        );
      }
    );
  }
}
