import 'package:wear/wear.dart';
import 'package:flutter/material.dart';

//getBoxSizeFromRadius takes radius of screen
//and returns the size of the largest rectangular box that
//can fit in the circular screen
double getBoxSizeFromRadius(double radius) => radius * 1.4142;

//get the size object for our screen,
//if the screen is round, return the largest rectangular
//box that can fit in the round frame
Size getWatchScreenSize(BuildContext context) {
  var screenSize = MediaQuery.of(context).size;
  final shape = WatchShape.of(context);
  if(shape == WearShape.round) {
    screenSize = Size(
        getBoxSizeFromRadius(screenSize.width / 2),
        getBoxSizeFromRadius(screenSize.height / 2)
    );
  }
  return screenSize;
}

//convert speed from meters per second to kilometers per hour
double mpsToKph(double speed) {
  return speed * 3.6;
}