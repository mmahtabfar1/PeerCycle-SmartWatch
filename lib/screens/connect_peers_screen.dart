import 'dart:async';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logging/logging.dart';
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
  late FToast fToast;
  List<Widget> devices = [];

  _ScanningScreenState() {
    fToast = FToast();
    discoveryStream = BluetoothManager.instance.startDeviceDiscovery();
    discoveryStreamSubscription = discoveryStream?.listen((event) {
      setState(() {
        if (event.device.name == null || event.device.isConnected) return;
        final textWidget = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: RoundedButton(
              name: "ConnectToBluetoothDeviceButton",
              height: 40,
              width: 40,
              onPressed: () async {
                if (BluetoothManager.instance.connecting) return;
                bool result =
                    await BluetoothManager.instance.connectToDevice(event.device);

                // Make toast
                Color color = result ? Colors.greenAccent : Colors.redAccent;
                String text = result ? "Connected!" : "Couldn't Connect!";
                Color textColor = result ? Colors.black : Colors.white;
                Icon icon = result
                    ? Icon(Icons.check, color: textColor)
                    : Icon(Icons.close, color: textColor);
        
                Widget toast = Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 2.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    color: color,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      icon,
                      const SizedBox(
                        width: 12.0,
                      ),
                      Text(text, style: TextStyle(color: textColor)),
                    ],
                  ),
                );
                // Show Toast
                fToast.showToast(
                    child: toast,
                    gravity: ToastGravity.TOP,
                    toastDuration: const Duration(seconds: 2));
        
                // Exit if connected
                if (result && context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text(event.device.name!,
                  style: const TextStyle(color: Colors.white)
              ),
          ),
        );
        devices = [...devices, textWidget];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    fToast.init(context);
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
            children: devices,
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
  FToast fToast = FToast();
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
    fToast.init(context);
    return FutureBuilder<bool>(
      future: startBluetoothServer(),
      builder: (context, snapshot) {
        //once we have the result make the toast if success or failure,
        //and pop back to previous screen
        if (snapshot.hasData) {
          bool result = snapshot.data!;
          String text = result ? "Connected!" : "No Connection Recevied!";
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
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 30,
                    width: 100,
                    child: RoundedButton(
                      name: "DismissButton",
                      height: 30,
                      width: 100,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Dismiss",
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
