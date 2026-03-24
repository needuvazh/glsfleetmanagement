import '../../domain/entities/journey_plan.dart';

class JourneyPlanModel extends JourneyPlan {
  const JourneyPlanModel({
    required super.id,
    required super.planName,
    required super.origin,
    required super.destination,
    required super.distance,
    required super.estimatedTime,
    required super.stops,
    required super.fuelEstimate,
  });

  factory JourneyPlanModel.fromMap(Map<String, dynamic> map) {
    final stopsRaw = map['stops'] as List<dynamic>? ?? const <dynamic>[];

    return JourneyPlanModel(
      id: map['id'] as String? ?? '',
      planName: map['planName'] as String? ?? '',
      origin: map['origin'] as String? ?? '',
      destination: map['destination'] as String? ?? '',
      distance: (map['distance'] as num?)?.toDouble() ?? 0,
      estimatedTime: (map['estimatedTime'] as num?)?.toDouble() ?? 0,
      stops: stopsRaw.map((item) => item.toString()).toList(),
      fuelEstimate: (map['fuelEstimate'] as num?)?.toDouble() ?? 0,
    );
  }
}
