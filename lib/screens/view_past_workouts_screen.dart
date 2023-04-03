import 'package:flutter/material.dart';
import 'package:wear/wear.dart';
import 'package:peer_cycle/utils.dart';

class ViewPastWorkoutsScreen extends StatelessWidget {
  const ViewPastWorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  children: const <Widget>[
                    Text("PAST WORKOUTS",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      )
                    ),
                  ],
                )
              )
            )
          );
        }
      )
    );
  }
}
