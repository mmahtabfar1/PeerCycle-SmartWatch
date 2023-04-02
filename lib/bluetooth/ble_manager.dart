import 'dart:async';

import 'package:logging/logging.dart';
import 'package:workout/workout.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart' hide Logger;

class BleManager {
  static final BleManager _instance = BleManager._();
  static BleManager get instance => _instance;

  final String _powerDeviceKey = "POWER";
  final String _heartRateDeviceKey = "HR";

  static final Uuid _heartRateServiceUUID = Uuid.parse('180d');
  static final Uuid _heartRateCharacteristicUUID = Uuid.parse('2a37');
  static final Uuid _cyclingPowerServiceUUID = Uuid.parse('1818');
  static final Uuid _cyclingPowerCharacteristicUUID = Uuid.parse('2a63');

  Stream<WorkoutReading> get stream => _streamController.stream;
  final StreamController<WorkoutReading> _streamController = StreamController.broadcast();

  final FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();

  /// Private constructor
  BleManager._();

  /// Logger
  static final log = Logger("ble_manager");

  /// Map of Connect Devices
  Map<String, StreamSubscription<ConnectionStateUpdate>> connectedDevices = {};

  /// static helper method to determine if device has heart rate service
  static bool hasHeartRateService(DiscoveredDevice device) {
    return device
      .serviceUuids
      .toString()
      .contains(
        _heartRateServiceUUID.toString()
      );
  }

  /// static helper method to determine if device has cycling power service
  static bool hasPowerService(DiscoveredDevice device) {
    return device
      .serviceUuids
      .toString()
      .contains(
        _cyclingPowerServiceUUID.toString()
      );
  }

  /// method to check if there is a heartRate Device Connected
  bool hasHRSensor() {
    return connectedDevices.containsKey(_heartRateDeviceKey);
  }

  /// method to check if there is a power Device Connected
  bool hasPowerSensor() {
    return connectedDevices.containsKey(_powerDeviceKey);
  }

  /// method to return stream of nearby ble devices
  /// scanning will stop when stream is cancelled
  Stream<DiscoveredDevice> scan() {
    return flutterReactiveBle.scanForDevices(withServices: [
      _heartRateServiceUUID,
      _cyclingPowerServiceUUID,
    ]);
  }

  void connectHRSensor(DiscoveredDevice device) {
    if(hasHRSensor()) {
      log.severe("Already have a HR Sensor connected!");
      return;
    }
    if(!hasHeartRateService(device)) {
      log.severe("Couldn't connect to ${device.name}, device does not provide heart rate service");
      return;
    }

    StreamSubscription<List<int>>? heartRateCharacteristicStream;

    StreamSubscription<ConnectionStateUpdate> heartRateSensorConnection = flutterReactiveBle.connectToDevice(
      id: device.id,
      servicesWithCharacteristicsToDiscover: {
        _heartRateServiceUUID: [_heartRateCharacteristicUUID]
      }
    ).listen((ConnectionStateUpdate connectionUpdate) {
      if(connectionUpdate.connectionState == DeviceConnectionState.connected) {
        heartRateCharacteristicStream = flutterReactiveBle.subscribeToCharacteristic(
            QualifiedCharacteristic(
                characteristicId: _heartRateCharacteristicUUID,
                serviceId: _heartRateServiceUUID,
                deviceId: device.id
            )
        ).listen((data) {
          //create a workout reading from the data
          //sink into stream
          _streamController.sink.add(
              WorkoutReading(
                WorkoutFeature.heartRate,
                data[1].toDouble().toString(),
                null,
              )
          );
        }, onError: (error) {
          log.severe("COULDN'T CONNECT TO HR SENSOR: $error");
        });
      }
      if(connectionUpdate.connectionState == DeviceConnectionState.disconnecting) {
        heartRateCharacteristicStream?.cancel();
      }
    });

    connectedDevices[_heartRateDeviceKey] = heartRateSensorConnection;
  }

  void connectPowerSensor(DiscoveredDevice device) {
    if(hasPowerSensor()) {
      log.severe("Already have a HR Sensor connected!");
      return;
    }
    if(!hasPowerService(device)) {
      log.severe("Couldn't connect to ${device.name}, device does not provide power service");
      return;
    }

    StreamSubscription<List<int>>? powerCharacteristicStream;

    StreamSubscription<ConnectionStateUpdate> powerSensorConnection = flutterReactiveBle.connectToDevice(
        id: device.id,
        servicesWithCharacteristicsToDiscover: {
          _cyclingPowerServiceUUID: [_cyclingPowerCharacteristicUUID]
        }
    ).listen((ConnectionStateUpdate connectionUpdate) {
      if(connectionUpdate.connectionState == DeviceConnectionState.connected) {
        powerCharacteristicStream = flutterReactiveBle.subscribeToCharacteristic(
            QualifiedCharacteristic(
                characteristicId: _heartRateCharacteristicUUID,
                serviceId: _heartRateServiceUUID,
                deviceId: device.id
            )
        ).listen((data) {
          //create a workout reading from the data
          //sink into stream
          _streamController.sink.add(
              WorkoutReading(
                WorkoutFeature.power,
                data[2].toDouble().toString(),
                null,
              )
          );

          _streamController.sink.add(
            WorkoutReading(
              WorkoutFeature.cadence,
              data[4].toDouble().toString(),
              null,
            )
          );
        });
      }
      if(connectionUpdate.connectionState == DeviceConnectionState.disconnecting) {
        powerCharacteristicStream?.cancel();
      }
    });

    connectedDevices[_powerDeviceKey] = powerSensorConnection;
  }
}