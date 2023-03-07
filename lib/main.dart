import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peer_cycle/screens/start_screen.dart';
import 'package:wear/wear.dart';
import 'package:logging/logging.dart';

import 'logging/app_event.dart';
import 'logging/workout_logger.dart';

void main() {
  //event logging

  WorkoutLogger.instance.addEvent({
    "event_type": AppEvent.appLaunched.value.toString(),
    "timestamp": DateTime.now().millisecondsSinceEpoch ~/ 1000,
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key}) {
    Logger.root.onRecord.listen((record) {
      //if in debug mode write to stdout
      //can add else clause here to write logs to a file
      //during production
      if (kDebugMode) {
        print('${record.level.name}: ${record.time}: ${record.message}');
      }
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: "PeerCycle",
    theme: ThemeData(primarySwatch: Colors.blue),
    home: const WatchScreen(),
    debugShowCheckedModeBanner: false,
  );
}

class WatchScreen extends StatelessWidget {
  const WatchScreen({super.key});

  final _channel = const MethodChannel("peer_cycle/app_retain");

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(Navigator.of(context).canPop()) {
          return true;
        } else {
          _channel.invokeMethod("sendToBackground");
          return false;
        }
      },
      child: WatchShape(
        builder: (context, shape, widget) => const StartScreen()
      )
    );
  }
}
