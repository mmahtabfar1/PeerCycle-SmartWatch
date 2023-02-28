import 'dart:math';
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
  //random object for sending random numbers to connections
  Random random = Random();
  FToast fToast = FToast();
  final CountDownController _countDownController = CountDownController();
  List<Widget> devices = [];
  bool scanning = false;
  bool listening = false;
  final int discoverabilityTimeout = 30;
  final int serverTimeout = 30;

  //Logger
  final logger = Logger("connect_peers_screen_logger");

  _ConnectPeersScreenState() {
    BluetoothManager.instance.deviceDataStream.listen((dataMap) {
      logger.log(Level.INFO, 'got data from a connection: $dataMap');
    });
  }

  //make the device discoverable and also
  //listen for bluetooth serial connections
  Future<bool> startBluetoothServer() async {
    int? res = await BluetoothManager.instance
        .requestDiscoverable(discoverabilityTimeout);

    if (res == null) {
      logger.log(Level.WARNING, 'was not able to make device discoverable');
      return false;
    }

    return await BluetoothManager.instance
        .listenForConnections("peer-cycle", serverTimeout * 1000);
  }

  List<Widget> getMainColumnWidgets() {
    List<Widget> widgets = [];
    if (listening) {
      widgets.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: const Text("Waiting for partners to connect...",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)))
      );

      widgets.add(const SizedBox(height: 2));

      widgets.add(CircularCountDownTimer(
          controller: _countDownController,
          width: 50,
          height: 50,
          duration: serverTimeout,
          fillColor: Colors.blue,
          ringColor: Colors.red,
          textStyle: const TextStyle(
            fontSize: 30.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textFormat: CountdownTextFormat.S,
          onComplete: () {
            setState(() {
              listening = false;
            });
          }));
    }

    widgets.add(
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      FloatingActionButton(
        heroTag: "serverBtn",
        onPressed: () async {
          if (listening) {
            return;
          }
          setState(() {
            listening = true;
          });
          bool result = await startBluetoothServer();
          setState(() {
            listening = false;
          });

          // Make toast
          Color color = result ? Colors.greenAccent : Colors.redAccent;
          String text = result ? "Connected!" : "Couldn't Connect!";
          Color textColor = result ? Colors.black : Colors.white;
          Icon icon = result
              ? Icon(Icons.check, color: textColor)
              : Icon(Icons.close, color: textColor);

          Widget toast = Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 2.0, vertical: 12.0),
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
        },
        child: const Icon(Icons.wifi_rounded),
      ),
      const SizedBox(width: 18),
      FloatingActionButton(
          heroTag: "scanBtn",
          onPressed: () {
            if (listening) return;
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ScanningScreen()));
          },
          child: const Icon(Icons.search)),
    ]));
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    fToast.init(context);
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
  bool connecting = false;

  _ScanningScreenState() {
    fToast = FToast();
    discoveryStream = BluetoothManager.instance.startDeviceDiscovery();
    discoveryStreamSubscription = discoveryStream?.listen((event) {
      setState(() {
        if (event.device.name == null || event.device.isConnected) return;
        final textWidget = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: RoundedButton(
              text: event.device.name!,
              height: 40,
              width: 40,
              onPressed: () async {
                if (connecting) return;
                setState(() {
                  connecting = true;
                });
                // Also keep boolean if currently connecting
                bool result =
                    await BluetoothManager.instance.connectToDevice(event.device);
        
                setState(() {
                  connecting = false;
                });
        
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
              }),
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
  void dispose() {
    discoveryStreamSubscription?.cancel();
    super.dispose();
  }
}
