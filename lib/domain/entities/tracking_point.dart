enum TrackingStatus { active, maintenance, idle }

extension TrackingStatusX on TrackingStatus {
  String get label {
    switch (this) {
      case TrackingStatus.active:
        return 'Active';
      case TrackingStatus.maintenance:
        return 'Maintenance';
      case TrackingStatus.idle:
        return 'Idle';
    }
  }

  static TrackingStatus fromString(String value) {
    switch (value.trim().toLowerCase()) {
      case 'maintenance':
        return TrackingStatus.maintenance;
      case 'idle':
        return TrackingStatus.idle;
      default:
        return TrackingStatus.active;
    }
  }
}

class TrackingPoint {
  const TrackingPoint({
    required this.id,
    required this.vehicleNumber,
    required this.driver,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.speedKph,
    required this.heading,
    required this.lastUpdated,
  });

  final String id;
  final String vehicleNumber;
  final String driver;
  final TrackingStatus status;
  final double latitude;
  final double longitude;
  final double speedKph;
  final double heading;
  final DateTime lastUpdated;

  TrackingPoint copyWith({
    String? id,
    String? vehicleNumber,
    String? driver,
    TrackingStatus? status,
    double? latitude,
    double? longitude,
    double? speedKph,
    double? heading,
    DateTime? lastUpdated,
  }) {
    return TrackingPoint(
      id: id ?? this.id,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      driver: driver ?? this.driver,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speedKph: speedKph ?? this.speedKph,
      heading: heading ?? this.heading,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
