import '../../domain/entities/fleet.dart';

class FleetModel extends Fleet {
  const FleetModel({
    required super.id,
    required super.vehicleNumber,
    required super.type,
    required super.status,
    required super.driver,
    required super.fuelLevel,
    required super.odometerKm,
    required super.lastServiceDate,
    required super.latitude,
    required super.longitude,
  });

  factory FleetModel.fromMap(Map<String, dynamic> map) {
    final location = map['location'] as Map<String, dynamic>?;

    return FleetModel(
      id: map['id'] as String? ?? '',
      vehicleNumber: map['vehicleNumber'] as String? ?? '',
      type: map['type'] as String? ?? '',
      status: FleetStatusX.fromString(map['status'] as String? ?? ''),
      driver: map['driver'] as String? ?? '',
      fuelLevel: (map['fuelLevel'] as num?)?.toInt() ?? 0,
      odometerKm: (map['odometerKm'] as num?)?.toInt() ?? 0,
      lastServiceDate: DateTime.tryParse(map['lastServiceDate'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      latitude: (location?['lat'] as num?)?.toDouble() ?? 0,
      longitude: (location?['lng'] as num?)?.toDouble() ?? 0,
    );
  }
}
