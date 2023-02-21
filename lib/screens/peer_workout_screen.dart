import 'package:peer_cycle/bluetooth/bluetooth_manager.dart';
import 'package:wear/wear.dart';
import 'package:flutter/material.dart';

class PeerWorkoutScreen extends StatefulWidget {
  const PeerWorkoutScreen({super.key});

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
          case "distance":
            setState(() {
              distance = double.parse(map[key] ?? "-1").toInt();
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
    return Scaffold(
        backgroundColor: Colors.black,
        body: WatchShape(
            builder: (context, shape, widget) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(children: [
                            const Icon(
                              Icons.heart_broken,
                              color: Colors.red,
                            ),
                            Text(
                              heartRate.toString(),
                              style: TextStyle(color: Colors.blue[600],
                                  fontSize: 30),
                            ),
                          ]),
                          const SizedBox(width: 8),
                          Column(children: [
                            const Icon(
                              Icons.fastfood,
                              color: Colors.red,
                            ),
                            Text(
                              calories.toString(),
                              style: TextStyle(color: Colors.blue[600],
                                  fontSize: 30),
                            ),
                          ]),
                          const SizedBox(width: 8),
                          Column(children: [
                            const Icon(
                              Icons.run_circle,
                              color: Colors.red,
                            ),
                            Text(
                              steps.toString(),
                              style: TextStyle(color: Colors.blue[600],
                                  fontSize: 30),
                            ),
                          ]),
                          const SizedBox(width: 8),
                          Column(children: [
                            const Icon(
                              Icons.speed,
                              color: Colors.red,
                            ),
                            Text(
                              speed.toString(),
                              style: TextStyle(color: Colors.blue[600],
                                  fontSize: 30),
                            ),
                          ]),
                          const SizedBox(width: 8),
                          Column(children: [
                            const Icon(
                              Icons.social_distance,
                              color: Colors.red,
                            ),
                            Text(
                              distance.toString(),
                              style: TextStyle(color: Colors.blue[600],
                                  fontSize: 30),
                            ),
                          ]),
                        ]
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
