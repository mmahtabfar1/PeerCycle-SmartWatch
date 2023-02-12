import 'dart:async';

import 'package:wear/wear.dart';
import 'package:peer_cycle/utils.dart';
import 'package:flutter/material.dart';
import 'package:peer_cycle/widgets/rounded_button.dart';
import 'package:peer_cycle/bluetooth/bluetooth_manager.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ConnectPeersScreen extends StatefulWidget {
  const ConnectPeersScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ConnectPeersScreenState();
}

class _ConnectPeersScreenState extends State<ConnectPeersScreen> {
  final BluetoothManager bluetoothManager = BluetoothManager();

  List<Widget> devices = [];
  bool scanning = false;

  Stream<BluetoothDiscoveryResult>? discoveryStream;
  StreamSubscription<BluetoothDiscoveryResult>? discoveryStreamSubscription;

  void startBluetoothScan() async {
    if(scanning) {
      return;
    }

    discoveryStream = await bluetoothManager.startDeviceDiscovery();

    final subscription = discoveryStream?.listen((event) {
      setState(() {
        final textWidget = Text(
            event.device.address,
            style: const TextStyle(
              color: Color.fromRGBO(255, 255, 255, 1)
            ));
        devices = [...devices, textWidget];
      });
    });

    //set state to now scanning
    setState(() {scanning = true;});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: WatchShape(
      builder: (context, shape, widget) {
        Size screenSize = getWatchScreenSize(context);
        return Center(
          child: Container(
            color: Colors.black,
            height: screenSize.height,
            width: screenSize.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  color: Colors.black,
                  height: 92,
                  width: screenSize.width,
                  child: ListView(
                    children: devices,
                  ),
                ),
                RoundedButton(
                  text: "Scan",
                  height: 40,
                  width: screenSize.width + 10,
                  onPressed: startBluetoothScan,
                ),
              ],
            )
          )
        );
      }
    )
  );
}