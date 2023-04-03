import 'package:flutter/material.dart';
import 'package:peer_cycle/screens/view_personal_info_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wear/wear.dart';
import 'package:peer_cycle/utils.dart';
import 'package:peer_cycle/widgets/rounded_button.dart';

class UpdatePersonalInfoScreen extends StatelessWidget {
  UpdatePersonalInfoScreen({super.key});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                                const Text("Update User Profile",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  )
                                ),
                                const SizedBox(height: 5),
                                SizedBox(height: 50, width: screenSize.width + 10,
                                  child: TextField(
                                    controller: _nameController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: "Enter Name",
                                      filled: true,
                                      fillColor: Colors.grey,
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
                                      border: OutlineInputBorder(),
                                      hintText: "Enter Age",
                                      filled: true,
                                      fillColor: Colors.grey,
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
                                      border: OutlineInputBorder(),
                                      hintText: "Enter Max HR",
                                      filled: true,
                                      fillColor: Colors.grey,
                                    )
                                  )
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

                                    //update the users name
                                    if(name.isNotEmpty) {
                                      await prefs.setString("name", name);
                                    }
                                    //update the users age
                                    if(age != null) {
                                      await prefs.setInt("age", age);
                                    }
                                    //update the users target heart rate
                                    if(heartRate != null) {
                                      await prefs.setInt("target_heart_rate", heartRate);
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
}