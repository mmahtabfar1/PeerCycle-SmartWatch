import "package:workout/workout.dart";

class WorkoutStartResultWrapper {
  final WorkoutStartResult workoutStartResult;
  final bool useHRPercentage;
  final bool usePowerPercentage;
  final double maxHR;
  final double maxPower;

  const WorkoutStartResultWrapper({
    required this.workoutStartResult,
    required this.useHRPercentage,
    required this.usePowerPercentage,
    required this.maxHR,
    required this.maxPower,
  });
}