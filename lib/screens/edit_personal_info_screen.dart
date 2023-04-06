import 'package:flutter/material.dart';
import 'package:peer_cycle/screens/view_personal_info_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wear/wear.dart';
import 'package:peer_cycle/utils.dart';
import 'package:peer_cycle/widgets/rounded_button.dart';
import 'package:peer_cycle/personal_info.dart';

class EditPersonalInfoScreen extends StatelessWidget {
  EditPersonalInfoScreen({super.key});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _powerController = TextEditingController();

  Future<void> getInitialState() async {
    PersonalInfo pInfo = await PersonalInfo.getInstance();
    _nameController.text = pInfo.name ?? "";
    _ageController.text = pInfo.age?.toString() ?? "";
    _heartRateController.text = pInfo.targetHeartRate?.toString() ?? "";
    _powerController.text = pInfo.targetPower?.toString() ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getInitialState(),
      builder: (context, snapshot) {
        if(snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator()
          );
        }
        return Scaffold(
          backgroundColor: Colors.black,
          body: WatchShape(
            builder: (context, shape, widget) {
              Size screenSize = getWatchScreenSize(context);
              return Center(
                child: Container(
                  color: Colors.black,
                  height: screenSize.height + 10,
                  width: screenSize.width + 10,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text("Edit User Profile",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          )
                        ),
                        const SizedBox(height: 10),
                        SizedBox(height: 50, width: screenSize.width + 10,
                          child: TextField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: "Name:",
                              labelStyle: TextStyle(color: Colors.blueAccent),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                )
                              ),
                              hintText: "Enter Name",
                            )
                          )
                        ),
                        const SizedBox(height: 10),
                        SizedBox(height: 50, width: screenSize.width + 10,
                          child: TextField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: "Age:",
                              labelStyle: TextStyle(color: Colors.blueAccent),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                )
                              ),
                              hintText: "Enter Age",
                            )
                          )
                        ),
                        const SizedBox(height: 10),
                        SizedBox(height: 50, width: screenSize.width + 10,
                          child: TextField(
                            controller: _heartRateController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: "MAX HR:",
                              labelStyle: TextStyle(color: Colors.blueAccent),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                )
                              ),
                              hintText: "Enter Max HR",
                            )
                          )
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 50, width: screenSize.width + 10,
                          child: TextField(
                            controller: _powerController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: "Max Power:",
                              labelStyle: TextStyle(color: Colors.blueAccent),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                )
                              ),
                              hintText: "Enter Max Power (W)",
                            )
                          ),
                        ),
                        const SizedBox(height: 10),
                        RoundedButton(
                          name: "SavePersonalInfoChanges",
                          height: 40,
                          width: screenSize.width + 10,
                          onPressed: () async {
                            //when pressed present success screen
                            SharedPreferences prefs = await SharedPreferences.getInstance();

                            String name = _nameController.text;
                            int? age = int.tryParse(_ageController.text);
                            int? heartRate = int.tryParse(_heartRateController.text);
                            int? power = int.tryParse(_powerController.text);

                            //update the users name
                            if(name.isNotEmpty) {
                              await prefs.setString(userNameKey, name);
                            }
                            //update the users age
                            if(age != null) {
                              await prefs.setInt(userAgeKey, age);
                            }
                            //update the users max heart rate
                            if(heartRate != null) {
                              await prefs.setInt(maxHRKey, heartRate);
                            }
                            //update the users max power
                            if(power != null) {
                              await prefs.setInt(maxPowerKey, power);
                            }

                            //remove this page and go back to the view
                            //personal info page but replace it so
                            //it will see the updated values
                            if(context.mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const ViewPersonalInfoScreen()
                                )
                              );
                            }
                          },
                          child: const Text("Save Changes"),
                        )
                      ]
                    )
                  )
                )
              );
            }
          )
        );
      }
    );
  }
}