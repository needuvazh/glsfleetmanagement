import '../../domain/entities/tracking_point.dart';

class TrackingPointModel extends TrackingPoint {
  const TrackingPointModel({
    required super.id,
    required super.vehicleNumber,
    required super.driver,
    required super.status,
    required super.latitude,
    required super.longitude,
    required super.speedKph,
    required super.heading,
    required super.lastUpdated,
  });

  factory TrackingPointModel.fromMap(Map<String, dynamic> map) {
    final location = map['location'] as Map<String, dynamic>?;
    final now = DateTime.now();

    return TrackingPointModel(
      id: map['id'] as String? ?? '',
      vehicleNumber: map['vehicleNumber'] as String? ?? map['plate'] as String? ?? '',
      driver: map['driver'] as String? ?? map['driverName'] as String? ?? '',
      status: TrackingStatusX.fromString(map['status'] as String? ?? ''),
      latitude: (map['latitude'] as num?)?.toDouble() ??
          (location?['lat'] as num?)?.toDouble() ??
          0,
      longitude: (map['longitude'] as num?)?.toDouble() ??
          (location?['lng'] as num?)?.toDouble() ??
          0,
      speedKph: (map['speedKph'] as num?)?.toDouble() ??
          (map['speed'] as num?)?.toDouble() ??
          0,
      heading: (map['heading'] as num?)?.toDouble() ?? 0,
      lastUpdated: DateTime.tryParse(map['lastUpdated'] as String? ?? '') ?? now,
    );
  }

  factory TrackingPointModel.fromFleetMap(Map<String, dynamic> map) {
    final location = map['location'] as Map<String, dynamic>?;
    final seed = (map['odometerKm'] as num?)?.toDouble() ?? 0;

    return TrackingPointModel(
      id: map['id'] as String? ?? '',
      vehicleNumber: map['vehicleNumber'] as String? ?? '',
      driver: map['driver'] as String? ?? '',
      status: TrackingStatusX.fromString(map['status'] as String? ?? ''),
      latitude: (location?['lat'] as num?)?.toDouble() ?? 0,
      longitude: (location?['lng'] as num?)?.toDouble() ?? 0,
      speedKph: 35 + (seed % 40),
      heading: seed % 360,
      lastUpdated: DateTime.now(),
    );
  }
}
