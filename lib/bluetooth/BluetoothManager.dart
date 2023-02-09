/*
For apps targeting Build.VERSION_CODES#R or lower, this requires the Manifest.permission#BLUETOOTH permission which can be gained with a simple <uses-permission> manifest tag.
For apps targeting Build.VERSION_CODES#S or or higher, this requires the Manifest.permission#BLUETOOTH_CONNECT permission which can be gained with Activity.requestPermissions(String[], int).
*/

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:async';
import 'package:logging/logging.dart';

class BluetoothManager {
  static final BluetoothManager _instance = BluetoothManager();
  static BluetoothManager get instance => _instance;

  // Map to store bluetooth connections
  final Map<BluetoothDevice, BluetoothConnection> _connections = {};

  // Maps bluetooth MAC address to stream subscription
  final Map<String, StreamSubscription> _subscriptions = {};

  // Device data that will be broadcasted
  final Map<String, Map<String, double>> _deviceData = {};

  // StreamController for the device data
  final StreamController<Map<String, Map<String, double>>>
      _deviceDataStreamController = StreamController.broadcast();

  // Stream for the device data
  Stream<Map<String, Map<String, double>>> get deviceDataStream =>
      _deviceDataStreamController.stream;

  // This can be cancelled by cancelling subscription to this stream
  Future<Stream<BluetoothDiscoveryResult>> startDeviceDiscovery() async {
    try {
      return FlutterBluetoothSerial.instance.startDiscovery();
    } catch (e) {
      Logger.root.severe("Error starting device discovery: $e");
      throw ('Error starting device discovery: $e');
    }
  }

  // According to FlutterBluetoothSerial, calling this isn't necessary as long as the event sink is closed
  Future<void> stopDeviceDiscovery() async {
    await FlutterBluetoothSerial.instance.cancelDiscovery();
  }

// Requests bluetooth discoverable status for a certain time.
// Duration can be capped. Try to stay below 120.
  Future<int?> requestDiscoverable(int seconds) async {
    return FlutterBluetoothSerial.instance.requestDiscoverable(seconds);
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      // Connect the device
      BluetoothConnection connection =
          await BluetoothConnection.toAddress(device.address);
      _connections[device] = connection;

      // Subscribe to data updates
      StreamSubscription? subscription = connection.input?.listen((data) {
        updateDeviceData(data);
      }, onDone: () {
        // Checking for when connection is closed
        disconnectFromDevice(device);
      });

      if (subscription != null) {
        _subscriptions[device.address] = subscription;
      }
    } catch (e) {
      Logger.root.severe('Error connecting to device: $e');
    }
  }

  // Method to disconnect from a device
  Future<void> disconnectFromDevice(BluetoothDevice device) async {
    try {
      await _connections[device]?.close();
      _connections.remove(device);
      _deviceData.remove(device.address);
      _subscriptions[device.address]?.cancel();
    } catch (e) {
      Logger.root.severe('Error disconnecting from device: $e');
    }
  }

// Sends device data to connected devices
  Future<void> broadcastDeviceDataFromMap(Map<String, double> data) async {
    // Create encoded string
    String? mac = await FlutterBluetoothSerial.instance.address;
    if (mac == null) {
      Logger.root.severe("Device MAC address is null!");
      return;
    }
    String dataString = mac;
    for (String key in data.keys) {
      dataString += ":$key:${data[key]}";
    }

    broadcastString(dataString);
  }

// Sends string to connected devices
  Future<void> broadcastString(String str) async {
    for (BluetoothConnection connection in _connections.values) {
      Logger.root.info("Sending string via bluetooth: $str");
      connection.output.add(ascii.encode(str));
    }
  }

// Update device data from connected devices
// Format for device data
//  - Data should be a string encoded as Uint8List
//  - All values should be separated by ":" (this will be the delimeter)
//  - First value will be the serial number of the device
//  - All other values will be pairs of keys and value
//  - Example data: serial_number:heart_bpm:114.0:calories:5.234:steps:10.124124
//  - All numbers should be given as doubles
  Future<void> updateDeviceData(Uint8List data) async {
    List<String> list = ascii.decode(data).split(':');
    if (list.isEmpty) {
      Logger.root.warning("Received device data that was empty or not decodeable");
    }

    if (list.length % 2 == 0) {
      Logger.root.warning("Received device data of even length. Needs to be odd!");
    }

    for (int i = 1; i < list.length; i += 2) {
      if (_deviceData[list[0]] == null) {
        _deviceData[list[0]] = {};
      }
      if (double.tryParse(list[i + 1]) == null) {
        Logger.root.warning("Expected double in received device data was not parseable");
      }
      _deviceData[list[0]]![list[i]] = double.parse(list[i + 1]);
    }

    // Update the deviceData stream
    _deviceDataStreamController.sink.add(_deviceData);
  }
}
