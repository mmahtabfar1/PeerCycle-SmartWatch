import 'package:flutter/rendering.dart';
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
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.favorite_border, color: Colors.red),
                            SizedBox(height: 5),
                            Text("99", style: TextStyle(color: Colors.white))
                          ],
                        ),
                        Column(
                          children: [
                            Icon(Icons.speed, color: Colors.blue),
                            SizedBox(height: 5),
                            Text("99", style: TextStyle(color: Colors.white))
                          ],
                        ),
                        Column(
                          children: [
                            Icon(Icons.whatshot, color: Colors.deepOrange),
                            SizedBox(height: 5),
                            Text("99", style: TextStyle(color: Colors.white))
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
                        PartnerCard(),
                        SizedBox(height: 10),
                        PartnerCard(),
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
                  ),
                ],
              );
            }
        )
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class PartnerCard extends StatefulWidget {
  const PartnerCard({
    super.key,
  });

  @override
  State<PartnerCard> createState() => _PartnerCardState();
}

class _PartnerCardState extends State<PartnerCard> {
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
            width: 40,
            child: Center(child: Text("99", style: TextStyle(fontSize: 20, color: Colors.white))),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,
                width: 3
              )
            ),
            height: 40,
            width: 40,
            child: Center(child: Text("99", style: TextStyle(fontSize: 20, color: Colors.white ))),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.orange,
                width: 3
              )
            ),
            height: 40,
            width: 40,
            child: Center(child: Text("99", style: TextStyle(fontSize: 20, color: Colors.white))),
          )
        ],
      ),
    );
  }
}
