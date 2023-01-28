import 'package:wear/wear.dart';
import 'package:flutter/material.dart';
import 'package:peer_cycle/utils.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: WatchShape(
        builder: (context, shape, widget) {
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

          return Center(
            child: Container(
              color: Colors.white,
              height: screenSize.height,
              width: screenSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: const <Widget>[
                  FlutterLogo(size: 90),
                  SizedBox(height: 20),
                ]
              )
            )
          );
        }
      )
    );
  }
}