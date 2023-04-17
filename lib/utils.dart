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

//keys for storing user preferences/info
const String maxHRKey = "target_heart_rate";
const String ftpKey = "target_power";
const String useHRPercentageKey = "use_hr_percentage";
const String usePowerPercentageKey = "use_power_percentage";
const String userNameKey = "name";
const String userAgeKey = "age";

class Pair<T1, T2> {
  final T1 first;
  final T2 second;

  Pair(this.first, this.second);

  @override
  String toString() => '($first, $second)';
}