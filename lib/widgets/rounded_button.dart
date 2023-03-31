import 'package:flutter/material.dart';
import 'package:peer_cycle/logging/app_event.dart';
import 'package:peer_cycle/logging/workout_logger.dart';

class RoundedButton extends StatelessWidget {
  final String name;
  final double height;
  final double width;
  final Widget child;
  final Color color;
  final void Function() onPressed;

  const RoundedButton({
    super.key,
    required this.name,
    required this.child,
    required this.onPressed,
    this.height = 0,
    this.width = 0,
    this.color = const Color.fromRGBO(91, 91, 91, 1),
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        //log that this button was pressed
        WorkoutLogger.instance.addEvent({
          "event_type": AppEvent.buttonPressed.value,
          "button_name": name.replaceAll(" ", ""),
          "timestamp": DateTime.now().millisecondsSinceEpoch ~/ 1000,
        });
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        minimumSize: Size(width, height),
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
        ),
        padding: const EdgeInsets.all(5)
      ),
      child: Center(
          widthFactor: null,
          heightFactor: null,
          child: child,
      ),
    );
  }

}