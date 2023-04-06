import 'package:shared_preferences/shared_preferences.dart';
import 'package:peer_cycle/utils.dart';

class PersonalInfo {
  final String? name;
  final int? age;
  final int? targetHeartRate;
  final int? targetPower;

  const PersonalInfo({
    required this.name,
    required this.age,
    required this.targetHeartRate,
    required this.targetPower,
  });

  static Future<PersonalInfo> getInstance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return PersonalInfo(
      name: prefs.getString(userNameKey),
      age: prefs.getInt(userAgeKey),
      targetHeartRate: prefs.getInt(maxHRKey),
      targetPower: prefs.getInt(maxPowerKey),
    );
  }
}
