import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peer_cycle/screens/start_screen.dart';
import 'package:wear/wear.dart';
import 'package:logging/logging.dart';

import 'package:peer_cycle/logging/app_event.dart';
import 'package:peer_cycle/logging/upload_manager.dart';
import 'package:peer_cycle/logging/workout_logger.dart';

void main() {
  //event logging

  WorkoutLogger.instance.addEvent({
    "event_type": AppEvent.appLaunched.value,
    "timestamp": DateTime.now().millisecondsSinceEpoch ~/ 1000,
  });

  //start the listener to synchronize un uploaded log files
  //when network status changes
  WidgetsFlutterBinding.ensureInitialized();
  UploadManager.instance.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key}) {
    Logger.root.onRecord.listen((record) {
      //if in debug mode write to stdout
      //can add else clause here to write logs to a file
      //during production
      if (kDebugMode) {
        print('${record.loggerName}: ${record.level.name}: ${record.time}: ${record.message}');
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
