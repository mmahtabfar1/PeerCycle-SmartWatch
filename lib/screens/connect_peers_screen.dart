import 'dart:async';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:logging/logging.dart';
import 'package:wear/wear.dart';
import 'package:peer_cycle/utils.dart';
import 'package:flutter/material.dart';
import 'package:peer_cycle/widgets/rounded_button.dart';
import 'package:peer_cycle/bluetooth/bluetooth_manager.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:peer_cycle/screens/connect_device_screen.dart';

class ConnectPeersScreen extends StatefulWidget {
  const ConnectPeersScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ConnectPeersScreenState();
}

class _ConnectPeersScreenState extends State<ConnectPeersScreen> {
  //Logger
  static final log = Logger("connect_peers_screen");

  _ConnectPeersScreenState() {
    BluetoothManager.instance.deviceDataStream.listen((dataMap) {
      log.log(Level.INFO, 'got data from a connection: $dataMap');
    });
  }

  List<Widget> getMainColumnWidgets() {
    List<Widget> widgets = [];
    widgets.add(
        Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 150,
                height: 50,
                child: RoundedButton(
                    name: "StartBluetoothServerButton",
                    color: Colors.lightBlue,
                    onPressed: () async {
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) => const BluetoothServerScreen()
                          )
                      );
                    },
                    child: Row(
                      children: const <Widget>[
                        Icon(Icons.bluetooth_searching),
                        Text("Bluetooth Server", style: TextStyle(color: Colors.white)),
                      ],
                    )
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: 150,
                height: 50,
                child: RoundedButton(
                    name: "ScanForBluetoothServersButton",
                    color: Colors.lightBlue,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ScanningScreen()));
                    },
                    child: Row(
                      children: const <Widget>[
                        Icon(Icons.search),
                        Text("Search For Peers", style: TextStyle(color: Colors.white)),
                      ],
                    )
                ),
              )
            ]
        )
    );
    return widgets;
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
                height: screenSize.height,
                width: screenSize.width + 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: getMainColumnWidgets(),
                ),
              )
          );
        })
    );
  }
}

class ScanningScreen extends StatefulWidget {
  const ScanningScreen({super.key});

  @override
  State<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen> {
  Stream<BluetoothDiscoveryResult>? discoveryStream;
  StreamSubscription<BluetoothDiscoveryResult>? discoveryStreamSubscription;
  //map device name to its widget
  Map<String, Widget> devices = {};

  _ScanningScreenState() {
    discoveryStream = BluetoothManager.instance.startDeviceDiscovery();
    discoveryStreamSubscription = discoveryStream?.listen((event) {
      setState(() {
        if (event.device.name == null || event.device.isConnected) return;
        if (devices.containsKey(event.device.name)) return;
        final textWidget = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: RoundedButton(
              name: "ConnectToBluetoothDeviceButton",
              height: 40,
              width: 40,
              onPressed: () {
                if (BluetoothManager.instance.connecting) return;

                //replace this screen with the connect device screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConnectDeviceScreen(bluetoothDevice: event.device)
                  )
                );
              },
              child: Text(event.device.name!,
                  style: const TextStyle(color: Colors.white)
              ),
          ),
        );
        devices[event.device.name!] = textWidget;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 30,
        width: 100,
        margin: const EdgeInsets.only(bottom: 10),
        child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Center(child: Text("Exit"))),
      ),
      backgroundColor: Colors.black,
      body: WatchShape(
        builder: (context, shape, widget) {
          return ListView(
            padding: const EdgeInsets.only(top: 40, bottom: 40),
            children: devices.values.toList(growable: false),
          );
        },
      ),
    );
  }

  @override
  void dispose() async {
    await discoveryStreamSubscription?.cancel();
    super.dispose();
  }
}

class BluetoothServerScreen extends StatefulWidget {
  const BluetoothServerScreen({super.key});

  @override
  State<StatefulWidget> createState() => _BluetoothServerScreenState();
}

class _BluetoothServerScreenState extends State<BluetoothServerScreen> {
  final int discoverabilityTimeout = 30;
  final int serverTimeout = 30;
  final CountDownController _countDownController = CountDownController();

  //Logger
  static final log = Logger("bluetooth_server_screen");

  //make the device discoverable and also
  //listen for bluetooth serial connections
  Future<bool> startBluetoothServer() async {
    int? res = await BluetoothManager.instance
        .requestDiscoverable(discoverabilityTimeout);

    if (res == null) {
      log.log(Level.WARNING, 'was not able to make device discoverable');
      return false;
    }

    return await BluetoothManager.instance
        .listenForConnections("peer-cycle", serverTimeout * 1000);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: startBluetoothServer(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          bool result = snapshot.data!;
          String text = result ? "Connected!" : "No Connection Received!";
          IconData icon = result ? Icons.check_circle : Icons.cancel;
          Color color = result ? Colors.green : Colors.red;
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(text, style: const TextStyle(color: Colors.white)),
                  Icon(icon, color: color, size: 60),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 30,
                    width: 120,
                    child: RoundedButton(
                      name: "ConnectAgainButton",
                      height: 30,
                      width: 100,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Connect Again",
                          style: TextStyle(color: Colors.white)
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 30,
                    width: 120,
                    child: RoundedButton(
                      name: "GoHomeButton",
                      height: 30,
                      width: 100,
                      onPressed: () {
                        final nav = Navigator.of(context);
                        nav.pop();
                        nav.pop();
                      },
                      child: const Text("Go Home",
                          style: TextStyle(color: Colors.white)
                      ),
                    ),
                  ),
                ]
              )
            )
          );
        }
        //while we are waiting on the result from startBluetoothServer()
        return Scaffold(
          backgroundColor: Colors.black,
          body: WatchShape(
            builder: (context, shape, widget) {
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: const Text("Waiting for partners to connect...",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)
                        )
                    ),
                    const SizedBox(height: 2),
                    CircularCountDownTimer(
                        isReverse: true,
                        controller: _countDownController,
                        width: 50,
                        height: 50,
                        duration: serverTimeout + 1,
                        fillColor: Colors.blue,
                        ringColor: Colors.red,
                        textStyle: const TextStyle(
                          fontSize: 30.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textFormat: CountdownTextFormat.S,
                        onComplete: () {}
                    ),
                  ]
              );
            },
          ),
        );
      }
    );
  }
}
