import 'dart:math';
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
  //random object for sending random numbers to connections
  Random random = Random();

  List<Widget> devices = [];
  bool scanning = false;

  Stream<BluetoothDiscoveryResult>? discoveryStream;
  StreamSubscription<BluetoothDiscoveryResult>? discoveryStreamSubscription;

  _ConnectPeersScreenState() {
    BluetoothManager.instance.deviceDataStream.listen((dataMap) {
      print('got data from a connection: $dataMap');
    });
  }

  //make the device discoverable and also
  //listen for bluetooth serial connections
  void startBluetoothServer() async {
    int? res = await BluetoothManager.instance.requestDiscoverable(120);

    if(res == null) {
      print("was not able to make device discoverable");
      return;
    }

    await BluetoothManager.instance.listenForConnections("peer-cycle", 120);
  }

  //starts scanning for other nearby bluetooth devices
  void startScan() async {
    if(scanning) {
      return;
    }

    discoveryStream = await BluetoothManager.instance.startDeviceDiscovery();

    final subscription = discoveryStream?.listen((event) {
      setState(() {
        final textWidget = RoundedButton(
          text: event.device.name ?? "no name",
          height: 40,
          width: 40,
          onPressed: () => {
            BluetoothManager.instance.connectToDevice(event.device)
          }
        );
        devices = [...devices, textWidget];
      });
    });

    //set state to now scanning
    setState(() {scanning = true;});
  }

  //sends a randomly generated number to all currently connected devices
  void sayHi() async {
    final int randomNum = random.nextInt(100);
    String dataStr = "randomNum:$randomNum";
    print("Broadcasting data: $dataStr");
    BluetoothManager.instance.broadcastString(dataStr);
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
                  text: "Start Server",
                  height: 40,
                  width: screenSize.width + 10,
                  onPressed: startBluetoothServer,
                ),
                RoundedButton(
                  text: "Scan for other Devices",
                  height: 40,
                  width: screenSize.width + 10,
                  onPressed: startScan,
                ),
                RoundedButton(
                  text: "Say Hi",
                  height: 40,
                  width: screenSize.width + 10,
                  onPressed: sayHi,
                ),
              ],
            )
          )
        );
      }
    )
  );
}