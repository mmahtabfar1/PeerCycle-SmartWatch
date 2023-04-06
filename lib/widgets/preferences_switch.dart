import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesSwitch extends StatefulWidget {
  final SharedPreferences prefs;
  final String prefKey;
  final String text;

  const PreferencesSwitch({
    super.key,
    required this.prefs,
    required this.prefKey,
    required this.text,
  });

  @override
  State<PreferencesSwitch> createState() => _PreferencesSwitchState();
}

class _PreferencesSwitchState extends State<PreferencesSwitch> {
  bool value = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(91, 91, 91, 1),
        borderRadius: BorderRadius.circular(15),
      ),
      height: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              widget.text,
              style: const TextStyle(
                color: Colors.white,
              )
            ),
            Switch(
              value: widget.prefs.getBool(widget.prefKey) ?? false,
              activeColor: Colors.lightBlue,
              onChanged: (bool newValue) async {
                setState(() {
                  value = newValue;
                });
                await widget.prefs.setBool(widget.prefKey, newValue);
              }
            )
          ]
        )
      )
    );
  }

  @override
  void initState() {
    super.initState();
    value = widget.prefs.getBool(widget.prefKey) ?? false;
  }
}