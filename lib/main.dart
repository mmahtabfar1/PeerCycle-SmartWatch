import 'package:flutter/material.dart';
import 'package:peer_cycle/screens/ambient_screen.dart';
import 'package:peer_cycle/screens/start_screen.dart';
import 'package:wear/wear.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, widget) => AmbientMode(
          builder: (context, mode, widget) =>
              mode == WearMode.active ? const StartScreen() : const AmbientWatchFace()
      ),
    );
  }
}
