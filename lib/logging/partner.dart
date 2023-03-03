class Partner {
  String? name;
  String? deviceId;
  String? serialNum;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'device_id': deviceId,
      'serial_number': serialNum
    };
  }

  Partner({
    this.name,
    this.deviceId,
    this.serialNum
  });
}