import 'package:flutter/material.dart';
import 'package:peer_cycle/screens/edit_personal_info_screen.dart';
import 'package:peer_cycle/widgets/rounded_button.dart';
import 'package:peer_cycle/personal_info.dart';

class ViewPersonalInfoScreen extends StatelessWidget {
  const ViewPersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PersonalInfo>(
      future: PersonalInfo.getInstance(),
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
                Text("Name: ${snapshot.data?.name ?? "Unknown"}",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                ),
                const SizedBox(height: 5),
                Text("Age: ${snapshot.data?.age ?? "Unknown"}",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                ),
                const SizedBox(height: 5),
                Text("Max HR: ${snapshot.data?.targetHeartRate ?? "Unknown"} bpm",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                ),
                const SizedBox(height: 5),
                Text("FTP: ${snapshot.data?.targetPower ?? "Unknown"} W",
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  height: 40,
                  width: 120,
                  child: RoundedButton(
                    name: "EditProfileButton",
                    onPressed: () => {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => EditPersonalInfoScreen()
                        )
                      )
                    },
                    child: const Text(
                      "Edit Profile",
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
