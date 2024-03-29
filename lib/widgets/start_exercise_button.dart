import 'package:flutter/material.dart';
import 'package:peer_cycle/logging/app_event.dart';
import 'package:peer_cycle/logging/workout_logger.dart';

class StartExerciseButton extends StatelessWidget {
  final Icon icon;
  final void Function() onPressed;
  final String name;

  const StartExerciseButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromRGBO(91, 91, 91, 1),
        shape: BoxShape.circle,
      ),
      width: 45,
      child: IconButton(
        icon: icon,
        onPressed: () {
          //log that the button was pressed
          WorkoutLogger.instance.addEvent({
            "event_type": AppEvent.buttonPressed.value,
            "button_name": name,
            "timestamp": DateTime.now().millisecondsSinceEpoch ~/ 1000,
          });
          onPressed();
        },
      )
    );
  }
}
