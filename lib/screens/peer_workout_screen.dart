import 'package:peer_cycle/bluetooth/bluetooth_manager.dart';
import 'package:wear/wear.dart';
import 'package:flutter/material.dart';
import 'package:workout/workout.dart';
import 'package:peer_cycle/widgets/rounded_button.dart';



class PeerWorkoutScreen extends StatefulWidget {
  const PeerWorkoutScreen({super.key});

  @override
  State<PeerWorkoutScreen> createState() => _PeerWorkoutScreenState();
}

class _PeerWorkoutScreenState extends State<PeerWorkoutScreen>
    with AutomaticKeepAliveClientMixin<PeerWorkoutScreen> {

  int heartRate = 0;
  int calories = 0; //change to time
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
    super.build(context);
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
                              Icons.favorite_border,
                              color: Colors.red,
                            ),
                            Text(
                              heartRate.toString(),
                              style: TextStyle(color: Colors.white,
                                  fontSize: 25),
                            ),
                          ]),
                          const SizedBox(width: 8),
                          Column(children: [
                            const Icon(
                              Icons.whatshot,
                              color: Colors.deepOrange,
                            ),
                            Text(
                              calories.toString(),
                              style: TextStyle(color: Colors.white,
                                  fontSize: 25),
                            ),
                          ]),
                          const SizedBox(width: 8),
                          Column(children: [
                            const Icon(
                              Icons.timer,
                              color: Colors.lightGreen,
                            ),
                            Text(
                              steps.toString(),
                              style: TextStyle(color: Colors.white,
                                  fontSize: 25),
                            ),
                          ]),
                          const SizedBox(width: 8),
                          Column(children: [
                            const Icon(
                              Icons.speed,
                              color: Colors.blue,
                            ),
                            Text(
                              speed.toString(),
                              style: TextStyle(color: Colors.white,
                                  fontSize: 25),
                            ),
                          ]),
                          const SizedBox(width: 8),
                          Column(children: [
                            const Icon(
                              Icons.place,
                              color: Colors.grey,
                            ),
                            Text(
                              distance.toString(),
                              style: TextStyle(color: Colors.white,
                                  fontSize: 25),
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
