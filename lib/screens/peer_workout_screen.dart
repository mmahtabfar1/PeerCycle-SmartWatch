import 'package:wear/wear.dart';
import 'package:flutter/material.dart';

class PeerWorkoutScreen extends StatelessWidget {
  const PeerWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: WatchShape(
            builder: (context, shape, widget) {
              return const Center(
                  child: Text(
                      "PeerWorkoutScreen",
                      style: TextStyle(color: Colors.white)
                  )
              );
            }
        )
    );
  }
}
