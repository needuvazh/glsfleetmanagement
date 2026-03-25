import 'package:glsfleetmanagement/domain/entities/location.dart';

class JourneyPlan {
  final String id;
  final String name;
  final Location fromLocation;
  final Location toLocation;
  final List<Location> middleStops;
  final double averageDistanceKm;
  final Duration estimatedDuration;
  final String? description;

  JourneyPlan({
    required this.id,
    required this.name,
    required this.fromLocation,
    required this.toLocation,
    this.middleStops = const [],
    required this.averageDistanceKm,
    required this.estimatedDuration,
    this.description,
  });

  factory JourneyPlan.fromJson(Map<String, dynamic> json) {
    return JourneyPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      fromLocation: Location.fromJson(json['fromLocation'] as Map<String, dynamic>),
      toLocation: Location.fromJson(json['toLocation'] as Map<String, dynamic>),
      middleStops: (json['middleStops'] as List<dynamic>?)
              ?.map((e) => Location.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      averageDistanceKm: (json['averageDistanceKm'] as num).toDouble(),
      estimatedDuration: Duration(minutes: json['estimatedDurationMinutes'] as int),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fromLocation': fromLocation.toJson(),
      'toLocation': toLocation.toJson(),
      'middleStops': middleStops.map((e) => e.toJson()).toList(),
      'averageDistanceKm': averageDistanceKm,
      'estimatedDurationMinutes': estimatedDuration.inMinutes,
      'description': description,
    };
  }

  JourneyPlan copyWith({
    String? id,
    String? name,
    Location? fromLocation,
    Location? toLocation,
    List<Location>? middleStops,
    double? averageDistanceKm,
    Duration? estimatedDuration,
    String? description,
  }) {
    return JourneyPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      middleStops: middleStops ?? this.middleStops,
      averageDistanceKm: averageDistanceKm ?? this.averageDistanceKm,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      description: description ?? this.description,
    );
  }

  @override
  String toString() =>
      'JourneyPlan(id: $id, name: $name, from: ${fromLocation.name}, to: ${toLocation.name}, distance: $averageDistanceKm km, duration: ${estimatedDuration.inMinutes} min)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JourneyPlan &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          fromLocation == other.fromLocation &&
          toLocation == other.toLocation &&
          middleStops == other.middleStops &&
          averageDistanceKm == other.averageDistanceKm &&
          estimatedDuration == other.estimatedDuration &&
          description == other.description;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      fromLocation.hashCode ^
      toLocation.hashCode ^
      middleStops.hashCode ^
      averageDistanceKm.hashCode ^
      estimatedDuration.hashCode ^
      description.hashCode;
}
