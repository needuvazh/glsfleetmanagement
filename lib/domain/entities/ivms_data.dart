class IVMSData {
  final String vehicleId;
  final String vehicleRegistration;
  final double latitude;
  final double longitude;
  final double speed;
  final double heading;
  final DateTime timestamp;
  final String status; // IDLE, MOVING, STOPPED, OFFLINE
  final double fuelLevel;
  final double temperature;
  final int rpm;
  final double odometer;
  final bool engineStatus;
  final bool doorsLocked;
  final String? lastLocation;
  final String? driverName;
  final int? tripDuration; // in minutes
  final double? distanceTraveled; // in km

  IVMSData({
    required this.vehicleId,
    required this.vehicleRegistration,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.heading,
    required this.timestamp,
    required this.status,
    required this.fuelLevel,
    required this.temperature,
    required this.rpm,
    required this.odometer,
    required this.engineStatus,
    required this.doorsLocked,
    this.lastLocation,
    this.driverName,
    this.tripDuration,
    this.distanceTraveled,
  });

  factory IVMSData.fromJson(Map<String, dynamic> json) {
    return IVMSData(
      vehicleId: json['vehicleId'] as String,
      vehicleRegistration: json['vehicleRegistration'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      speed: (json['speed'] as num).toDouble(),
      heading: (json['heading'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String,
      fuelLevel: (json['fuelLevel'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      rpm: json['rpm'] as int,
      odometer: (json['odometer'] as num).toDouble(),
      engineStatus: json['engineStatus'] as bool,
      doorsLocked: json['doorsLocked'] as bool,
      lastLocation: json['lastLocation'] as String?,
      driverName: json['driverName'] as String?,
      tripDuration: json['tripDuration'] as int?,
      distanceTraveled: json['distanceTraveled'] != null ? (json['distanceTraveled'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'vehicleRegistration': vehicleRegistration,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'fuelLevel': fuelLevel,
      'temperature': temperature,
      'rpm': rpm,
      'odometer': odometer,
      'engineStatus': engineStatus,
      'doorsLocked': doorsLocked,
      'lastLocation': lastLocation,
      'driverName': driverName,
      'tripDuration': tripDuration,
      'distanceTraveled': distanceTraveled,
    };
  }

  IVMSData copyWith({
    String? vehicleId,
    String? vehicleRegistration,
    double? latitude,
    double? longitude,
    double? speed,
    double? heading,
    DateTime? timestamp,
    String? status,
    double? fuelLevel,
    double? temperature,
    int? rpm,
    double? odometer,
    bool? engineStatus,
    bool? doorsLocked,
    String? lastLocation,
    String? driverName,
    int? tripDuration,
    double? distanceTraveled,
  }) {
    return IVMSData(
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleRegistration: vehicleRegistration ?? this.vehicleRegistration,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      fuelLevel: fuelLevel ?? this.fuelLevel,
      temperature: temperature ?? this.temperature,
      rpm: rpm ?? this.rpm,
      odometer: odometer ?? this.odometer,
      engineStatus: engineStatus ?? this.engineStatus,
      doorsLocked: doorsLocked ?? this.doorsLocked,
      lastLocation: lastLocation ?? this.lastLocation,
      driverName: driverName ?? this.driverName,
      tripDuration: tripDuration ?? this.tripDuration,
      distanceTraveled: distanceTraveled ?? this.distanceTraveled,
    );
  }

  String getStatusColor() {
    switch (status) {
      case 'MOVING':
        return '#4CAF50'; // Green
      case 'IDLE':
        return '#FFC107'; // Amber
      case 'STOPPED':
        return '#FF9800'; // Orange
      case 'OFFLINE':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  String getStatusIcon() {
    switch (status) {
      case 'MOVING':
        return '🚗';
      case 'IDLE':
        return '⏸️';
      case 'STOPPED':
        return '🛑';
      case 'OFFLINE':
        return '❌';
      default:
        return '❓';
    }
  }

  @override
  String toString() =>
      'IVMSData(vehicle: $vehicleRegistration, status: $status, speed: ${speed.toStringAsFixed(1)} km/h, fuel: ${fuelLevel.toStringAsFixed(1)}%)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IVMSData &&
          runtimeType == other.runtimeType &&
          vehicleId == other.vehicleId &&
          timestamp == other.timestamp;

  @override
  int get hashCode => vehicleId.hashCode ^ timestamp.hashCode;
}
