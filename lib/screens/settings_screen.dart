import 'package:wear/wear.dart';
import 'package:flutter/material.dart';

//TODO: need to implement this it is black screen for now
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WatchShape(
        builder: (context, shape, widget) {
          return const Center(
            child: Text(
              "Settings",
              style: TextStyle(color: Colors.white)
            )
          );
        }
      )
    );
  }
}