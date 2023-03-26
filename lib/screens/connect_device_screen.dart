import 'package:flutter/material.dart';
import 'package:peer_cycle/widgets/rounded_button.dart';
import 'package:peer_cycle/bluetooth/bluetooth_manager.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ConnectDeviceScreen extends StatelessWidget {
  const ConnectDeviceScreen({
    super.key,
    required this.bluetoothDevice,
  });

  //the bluetooth device to initiate a connection to
  final BluetoothDevice bluetoothDevice;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: BluetoothManager.instance.connectToDevice(bluetoothDevice),
      builder: (context, snapshot) {
        //if not yet connected render the progress indicator
        if(!snapshot.hasData) {
          String deviceName = bluetoothDevice.name ?? "BT Device";
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Connecting to $deviceName", style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 10),
                  const CircularProgressIndicator(),
                ]
              )
            )
          );
        }

        //now that we are connected display success / failure messages
        bool connected = snapshot.data ?? false;
        String text = connected ? "Connected!" : "Unable To Connect!";
        IconData icon = connected ? Icons.check_circle : Icons.cancel;
        Color color = connected ? Colors.green : Colors.red;

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
    );
  }
}