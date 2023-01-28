import 'package:flutter/material.dart';

class AmbientWatchFace extends StatelessWidget {
  const AmbientWatchFace({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'PeerCycle',
            style: TextStyle(color: Colors.blue[600], fontSize: 30),
          ),
          const SizedBox(height: 15),
          const FlutterLogo(size: 60.0),
        ],
      ),
    ),
  );
}