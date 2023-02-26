import 'dart:math';
import 'dart:async';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  late FToast fToast;
  CountDownController _countDownController = CountDownController();
  List<Widget> devices = [];
  bool scanning = false;
  bool listening = false;
  final int DISCOVERABILITY_TIMEOUT = 30;
  final int SERVER_TIMEOUT = 30;

  _ConnectPeersScreenState() {
    fToast = FToast();
    BluetoothManager.instance.deviceDataStream.listen((dataMap) {
      print('got data from a connection: $dataMap');
    });
  }

  //make the device discoverable and also
  //listen for bluetooth serial connections
  Future<bool> startBluetoothServer() async {
    int? res = await BluetoothManager.instance
        .requestDiscoverable(DISCOVERABILITY_TIMEOUT);

    if (res == null) {
      print("was not able to make device discoverable");
      return false;
    }

    return await BluetoothManager.instance
        .listenForConnections("peer-cycle", SERVER_TIMEOUT * 1000);
  }

  //sends a randomly generated number to all currently connected devices
  void sayHi() async {
    final int randomNum = random.nextInt(100);
    String dataStr = "randomNum:$randomNum";
    print("Broadcasting data: $dataStr");
    BluetoothManager.instance.broadcastString(dataStr);
  }

  List<Widget> getMainColumnWidgets() {
    List<Widget> widgets = [];
    if (listening) {
      widgets.add(const Text("Waiting for partners to connect...",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)));

      widgets.add(const SizedBox(height: 20));

      widgets.add(CircularCountDownTimer(
          controller: _countDownController,
          width: 100,
          height: 100,
          duration: SERVER_TIMEOUT,
          fillColor: Colors.blue,
          ringColor: Colors.red,
          textStyle: const TextStyle(
            fontSize: 33.0,
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
      FloatingActionButton.large(
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
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: color,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                SizedBox(
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
              toastDuration: Duration(seconds: 2));
        },
        child: Icon(Icons.wifi_rounded),
      ),
      SizedBox(width: 80),
      FloatingActionButton.large(
          heroTag: "scanBtn",
          onPressed: () {
            if (listening) return;
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ScanningScreen()));
          },
          child: Icon(Icons.search)),
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
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: getMainColumnWidgets(),
          ));
        }));
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
        final textWidget = RoundedButton(
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
                    horizontal: 24.0, vertical: 12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  color: color,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon,
                    SizedBox(
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
                  toastDuration: Duration(seconds: 2));

              // Exit if connected
              if (result) {
                Navigator.pop(context);
              }
            });
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
        height: 50,
        margin: const EdgeInsets.all(50),
        child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Center(child: Text("Exit"))),
      ),
      backgroundColor: Colors.black,
      body: WatchShape(
        builder: (context, shape, widget) {
          Size screenSize = getWatchScreenSize(context);
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
