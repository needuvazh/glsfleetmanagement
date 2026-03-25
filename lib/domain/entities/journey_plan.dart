import 'location.dart';

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

  // Compatibility getters for screens/viewmodels still using flat plan fields.
  String get planName => name;
  String get origin => fromLocation.name;
  String get destination => toLocation.name;
  double get distance => averageDistanceKm;
  double get estimatedTime => estimatedDuration.inMinutes / 60.0;
  List<String> get stops => middleStops.map((e) => e.name).toList();
  double get fuelEstimate => averageDistanceKm * 0.35;

  factory JourneyPlan.fromJson(Map<String, dynamic> json) {
    final fromMap = json['fromLocation'] as Map<String, dynamic>?;
    final toMap = json['toLocation'] as Map<String, dynamic>?;
    final originName = json['origin'] as String?;
    final destinationName = json['destination'] as String?;
    final stopsRaw = json['stops'] as List<dynamic>?;
    final middleStopsRaw = json['middleStops'] as List<dynamic>?;
    final estimatedTimeHours = (json['estimatedTime'] as num?)?.toDouble();

    return JourneyPlan(
      id: json['id'] as String,
      name: (json['name'] as String?) ??
          (json['planName'] as String?) ??
          'Journey Plan',
      fromLocation: fromMap != null
          ? Location.fromJson(fromMap)
          : Location(
              id: '${json['id']}_FROM',
              name: originName ?? 'Origin',
              latitude: 0,
              longitude: 0,
            ),
      toLocation: toMap != null
          ? Location.fromJson(toMap)
          : Location(
              id: '${json['id']}_TO',
              name: destinationName ?? 'Destination',
              latitude: 0,
              longitude: 0,
            ),
      middleStops: middleStopsRaw != null
          ? middleStopsRaw
              .map((e) => Location.fromJson(e as Map<String, dynamic>))
              .toList()
          : (stopsRaw
                  ?.map(
                    (e) => Location(
                      id: '${json['id']}_${e.toString()}',
                      name: e.toString(),
                      latitude: 0,
                      longitude: 0,
                    ),
                  )
                  .toList() ??
              const []),
      averageDistanceKm: (json['averageDistanceKm'] as num?)?.toDouble() ??
          (json['distance'] as num?)?.toDouble() ??
          0,
      estimatedDuration: Duration(
        minutes: (json['estimatedDurationMinutes'] as int?) ??
            ((estimatedTimeHours ?? 0) * 60).round(),
      ),
      description: json['description'] as String?,
    );
  }

  factory JourneyPlan.fromLegacyMap(Map<String, dynamic> json) {
    return JourneyPlan(
      id: json['id'] as String,
      name: (json['planName'] as String?) ?? 'Journey Plan',
      fromLocation: Location(
        id: '${json['id']}_FROM',
        name: (json['origin'] as String?) ?? 'Origin',
        latitude: 0,
        longitude: 0,
      ),
      toLocation: Location(
        id: '${json['id']}_TO',
        name: (json['destination'] as String?) ?? 'Destination',
        latitude: 0,
        longitude: 0,
      ),
      middleStops: (json['stops'] as List<dynamic>?)
              ?.map(
                (e) => Location(
                  id: '${json['id']}_${e.toString()}',
                  name: e.toString(),
                  latitude: 0,
                  longitude: 0,
                ),
              )
              .toList() ??
          [],
      averageDistanceKm: (json['distance'] as num?)?.toDouble() ?? 0,
      estimatedDuration: Duration(
          minutes: (((json['estimatedTime'] as num?)?.toDouble() ?? 0) * 60)
              .round()),
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
