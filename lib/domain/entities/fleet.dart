enum FleetStatus { active, maintenance, idle }

extension FleetStatusX on FleetStatus {
  String get label {
    switch (this) {
      case FleetStatus.active:
        return 'Active';
      case FleetStatus.maintenance:
        return 'Maintenance';
      case FleetStatus.idle:
        return 'Idle';
    }
  }

  static FleetStatus fromString(String value) {
    switch (value.trim().toLowerCase()) {
      case 'active':
        return FleetStatus.active;
      case 'maintenance':
        return FleetStatus.maintenance;
      default:
        return FleetStatus.idle;
    }
  }
}

class Fleet {
  const Fleet({
    required this.id,
    required this.vehicleNumber,
    required this.type,
    required this.status,
    required this.driver,
    required this.fuelLevel,
    required this.odometerKm,
    required this.lastServiceDate,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String vehicleNumber;
  final String type;
  final FleetStatus status;
  final String driver;
  final int fuelLevel;
  final int odometerKm;
  final DateTime lastServiceDate;
  final double latitude;
  final double longitude;

  Fleet copyWith({
    String? id,
    String? vehicleNumber,
    String? type,
    FleetStatus? status,
    String? driver,
    int? fuelLevel,
    int? odometerKm,
    DateTime? lastServiceDate,
    double? latitude,
    double? longitude,
  }) {
    return Fleet(
      id: id ?? this.id,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      driver: driver ?? this.driver,
      fuelLevel: fuelLevel ?? this.fuelLevel,
      odometerKm: odometerKm ?? this.odometerKm,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
