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

  int lastConnectionId = 0;

  /// Maps bluetooth connection id to its connection
  final Map<int, BluetoothConnection> _connections = {};

  /// Maps bluetooth connection id to stream subscription
  final Map<int, StreamSubscription> _subscriptions = {};

  /// Device data that will be broadcasted
  final Map<int, Map<String, String>> _deviceData = {};

  /// StreamController for the device data
  final StreamController<Map<int, Map<String, String>>>
      _deviceDataStreamController = StreamController.broadcast();

  /// Stream for the device data
  Stream<Map<int, Map<String, String>>> get deviceDataStream =>
      _deviceDataStreamController.stream;

  /// This can be cancelled by cancelling subscription to this stream
  Future<Stream<BluetoothDiscoveryResult>> startDeviceDiscovery() async {
    try {
      return FlutterBluetoothSerial.instance.startDiscovery();
    } catch (e) {
      Logger.root.severe("Error starting device discovery: $e");
      throw ('Error starting device discovery: $e');
    }
  }

  /// According to FlutterBluetoothSerial, calling this isn't necessary as long as the event sink is closed
  Future<void> stopDeviceDiscovery() async {
    await FlutterBluetoothSerial.instance.cancelDiscovery();
  }

/// Requests bluetooth discoverable status for a certain time.
///
/// Duration can be capped. Try to stay below 120.
  Future<int?> requestDiscoverable(int seconds) async {
    return FlutterBluetoothSerial.instance.requestDiscoverable(seconds);
  }
  
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      // Connect the device
      BluetoothConnection connection =
          await BluetoothConnection.toAddress(device.address);
      _connections[lastConnectionId] = connection;

      // Subscribe to data updates
      StreamSubscription? subscription = connection.input?.listen((data) {
        updateDeviceData(lastConnectionId, data);
      }, onDone: () {
        // Checking for when connection is closed
        disconnectFromDevice(lastConnectionId);
      });

      if (subscription != null) {
        _subscriptions[lastConnectionId] = subscription;
      }
      lastConnectionId++;
    } catch (e) {
      Logger.root.severe('Error connecting to device: $e');
    }
  }

  Future<void> listenForConnections(String sdpName, int timeout) async {
    try {
      // Connect the device
      BluetoothConnection connection =
          await BluetoothConnection.listenForConnections(sdpName, timeout);
      _connections[lastConnectionId] = connection;

      // Subscribe to data updates
      StreamSubscription? subscription = connection.input?.listen((data) {
        updateDeviceData(lastConnectionId, data);
      }, onDone: () {
        // Checking for when connection is closed
        disconnectFromDevice(lastConnectionId);
      });

      if (subscription != null) {
        _subscriptions[lastConnectionId] = subscription;
      }
      lastConnectionId++;
    } catch (e) {
      Logger.root.severe('Error connecting to device: $e');
    }
  }

  // Method to disconnect from a device
  Future<void> disconnectFromDevice(int id) async {
    try {
      await _connections[id]?.close();
      _connections.remove(id);
      _deviceData.remove(id);
      _subscriptions[id]?.cancel();
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
//  - All other values will be pairs of keys and value
  Future<void> updateDeviceData(int id, Uint8List data) async {
    List<String> list = ascii.decode(data).split(':');
    if (list.isEmpty) {
      Logger.root.severe("Received device data that was empty or not decodeable");
    }
    if (list.length % 2 != 0) {
      Logger.root.severe("Received device data was of odd length");
    }

    for(int i = 0; i < list.length; i += 2) {
      String key = list[i];
      String value = list[i+1];
      if (_deviceData[id] == null) {
        _deviceData[id] = {};
      }
      _deviceData[id]![key] = value;
    }
    _deviceDataStreamController.sink.add(_deviceData);
  }
    
}
