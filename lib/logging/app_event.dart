enum AppEvent {
  appLaunched(0),
  appClosed(1),
  buttonPressed(2),
  pageSwitched(3),
  settingsChanged(4),
  workoutStarted(5),
  workoutEnded(6),
  workoutPaused(7),
  workoutUnpaused(8),
  partnerConnected(9),
  partnerDisconnected(10),

  // I think these three only refer to BLE devices
  searchForBluetoothDevices(11),
  bluetoothDeviceConnected(12),
  bluetoothDeviceDisconnected(13),

  screenOn(14),
  screenOff(15),
  screenUnlocked(16);

  const AppEvent(this.value);
  final num value;
}