import 'package:flutter/material.dart';
import 'package:peer_cycle/screens/update_personal_info_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peer_cycle/widgets/rounded_button.dart';

class ViewPersonalInfoScreen extends StatelessWidget {
  const ViewPersonalInfoScreen({super.key});

  Future<PersonalInfo> fetchPersonalInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //read values from shared preferences
    String? name = prefs.getString("name");
    int? age = prefs.getInt("age");
    int? heartRate = prefs.getInt("target_heart_rate");

    return PersonalInfo(
      name: name ?? "Unknown",
      age: age ?? -1,
      targetHeartRate: heartRate ?? -1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PersonalInfo>(
      future: fetchPersonalInfo(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(),
            )
          );
        }
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("USER PROFILE",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  )
                ),
                const SizedBox(height: 10),
                Text("Name: ${snapshot.data?.name}",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                ),
                const SizedBox(height: 5),
                Text("Age: ${snapshot.data?.age}",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                ),
                const SizedBox(height: 5),
                Text("Max HR: ${snapshot.data?.targetHeartRate}",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  height: 40,
                  width: 150,
                  child: RoundedButton(
                    name: "UpdateProfileButton",
                    onPressed: () => {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => UpdatePersonalInfoScreen()
                        )
                      )
                    },
                    child: const Text(
                      "Update Profile",
                      style: TextStyle(
                        color: Colors.white,
                      )
                    )
                  )
                )
              ]
            )
          )
        );
      }
    );
  }
}

class PersonalInfo {
  final String name;
  final int age;
  final int targetHeartRate;

  const PersonalInfo({
    required this.name,
    required this.age,
    required this.targetHeartRate,
  });
}