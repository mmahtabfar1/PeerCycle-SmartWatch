import 'package:wear/wear.dart';
import 'package:flutter/material.dart';
import 'package:peer_cycle/utils.dart';
import 'package:peer_cycle/widgets/rounded_button.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  Size getWatchScreenSize(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    final shape = WatchShape.of(context);
    if(shape == WearShape.round) {
      //getBoxSizeFromRadius takes radius of screen
      //and returns the size of the largest rectangular box that
      //can fit in the circular screen
      screenSize = Size(
          getBoxSizeFromRadius(screenSize.width / 2),
          getBoxSizeFromRadius(screenSize.height / 2)
      );
    }
    return screenSize;
  }

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
              height: screenSize.height,
              width: screenSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  RoundedButton(
                    text: "Choose Workout",
                    width: screenSize.width,
                    height: 40
                  ),
                  const SizedBox(height: 15),
                  RoundedButton(
                    text: "Settings",
                    width: screenSize.width,
                    height: 40
                  ),
                  const SizedBox(height: 15),
                  RoundedButton(
                      text: "Connect Partners",
                      width: screenSize.width,
                      height: 40
                  ),
                ]
              )
            )
          );
        },
      )
    );
  }
}