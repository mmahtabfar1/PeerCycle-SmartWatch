import 'dart:async';

import 'package:wear/wear.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart' hide Logger;
import 'package:peer_cycle/utils.dart';
import 'package:peer_cycle/bluetooth/ble_manager.dart';
import 'package:peer_cycle/widgets/rounded_button.dart';

class ConnectSensorsScreen extends StatefulWidget {
  const ConnectSensorsScreen({super.key});

  @override State<StatefulWidget> createState() => _ConnectSensorsScreenState();
}

class _ConnectSensorsScreenState extends State<ConnectSensorsScreen> {
  //Logger
  static final log = Logger("connect_sensors_screen");

  _ConnectSensorsScreenState();

  StreamSubscription<DiscoveredDevice>? scanSubscription;

  //map device name to its widget to avoid duplicates
  Map<String, Widget> devices = {};

  @override
  void initState() {
    super.initState();
    scanSubscription = BleManager.instance.scan().listen((device) {
      if(devices.containsKey(device.name)) return;
      final textWidget = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: RoundedButton(
          name: "ConnectToBLESensor",
          onPressed: () {
            log.info("connecting to BLE Sensor: ${device.name}");
            if (BleManager.hasHeartRateService(device)) {
              BleManager.instance.connectHRSensor(device);
            }
            else {
              BleManager.instance.connectPowerSensor(device);
            }
          },
          child: Text(device.name, style: const TextStyle(color: Colors.white)),
        )
      );
      setState(() {
        devices[device.name] = textWidget;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    scanSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WatchShape(builder: (context, shape, widget) {
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
                  const Text("BLE Sensors",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )
                  ),
                  ...(devices.values),
                ],
              )
            )
          )
        );
      })
    );
  }
}