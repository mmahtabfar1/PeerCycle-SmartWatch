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

  @override
  State<StatefulWidget> createState() => _ConnectSensorsScreenState();
}

enum _ConnectSensorsScreenStateType {
  CONNECTING,
  CONNECTED,
  DEFAULT,
  DISCONNECTING,
  DISCONNECTED
}

class _ConnectSensorsScreenState extends State<ConnectSensorsScreen> {
  //Logger
  static final log = Logger("connect_sensors_screen");

  _ConnectSensorsScreenState();

  StreamSubscription<DiscoveredDevice>? scanSubscription;
  StreamSubscription<Pair<DeviceConnectionState, String>>?
      connectionUpdateStream;

  //map device name to its widget to avoid duplicates
  Map<String, Widget> devices = {};

  _ConnectSensorsScreenStateType state = _ConnectSensorsScreenStateType.DEFAULT;

  @override
  void initState() {
    super.initState();
    connectionUpdateStream =
        BleManager.instance.connectionUpdateStream.listen((event) {
      if (event.first == DeviceConnectionState.connecting) {
        setState(() {
          state = _ConnectSensorsScreenStateType.CONNECTING;
        });
      } else if (event.first == DeviceConnectionState.connected) {
        setState(() {
          state = _ConnectSensorsScreenStateType.CONNECTED;
        });
      }
    });
    scanSubscription = BleManager.instance.scan().listen((device) {
      if (devices.containsKey(device.name)) return;
      final textWidget = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: RoundedButton(
            name: "ConnectToBLESensor",
            onPressed: () {
              log.info("connecting to BLE Sensor: ${device.name}");
              if (BleManager.hasHeartRateService(device)) {
                BleManager.instance.connectHRSensor(device);
              } else {
                BleManager.instance.connectPowerSensor(device);
              }
            },
            child:
                Text(device.name, style: const TextStyle(color: Colors.white)),
          ));
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

  Widget getConnectingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text("Connecting...", style: TextStyle(color: Colors.white)),
          SizedBox(height: 10),
          CircularProgressIndicator(color: Colors.blue),
        ],
      ),
    );
  }

  Widget getConnectedScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 60),
          const SizedBox(height: 5),
          SizedBox(
            height: 30,
            width: 120,
            child: RoundedButton(
              name: "ConnectAgainButton",
              height: 30,
              width: 100,
              onPressed: () {
                setState(() {
                  state = _ConnectSensorsScreenStateType.DEFAULT;
                });
              },
              child: const Text("Connect Another",
                  style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 30,
            width: 120,
            child: RoundedButton(
              name: "ExitButton",
              height: 30,
              width: 100,
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
              child: const Text("Exit", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget getDisconnectedScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cancel, color: Colors.red, size: 60),
          const SizedBox(height: 5),
          SizedBox(
            height: 30,
            width: 120,
            child: RoundedButton(
              name: "ConnectAgainButton",
              height: 30,
              width: 100,
              onPressed: () {
                setState(() {
                  state = _ConnectSensorsScreenStateType.DEFAULT;
                });
              },
              child: const Text("Try Again", style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          SizedBox(
            height: 30,
            width: 120,
            child: RoundedButton(
              name: "ExitButton",
              height: 30,
              width: 100,
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
              child: const Text("Exit", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget getDefaultScreen(BuildContext context) {
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
                    )),
                ...(devices.values),
              ],
            ))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: WatchShape(builder: (context, shape, widget) {
          switch (state) {
            case _ConnectSensorsScreenStateType.CONNECTING:
              return getConnectingScreen();
            case _ConnectSensorsScreenStateType.CONNECTED:
              return getConnectedScreen();
            case _ConnectSensorsScreenStateType.DEFAULT:
              return getDefaultScreen(context);
            case _ConnectSensorsScreenStateType.DISCONNECTING:
              return getDisconnectedScreen();
            case _ConnectSensorsScreenStateType.DISCONNECTED:
              return getDisconnectedScreen();
          }
        }));
  }
}
