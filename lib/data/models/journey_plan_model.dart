import '../../domain/entities/journey_plan.dart';

class JourneyPlanModel extends JourneyPlan {
  JourneyPlanModel({
    required super.id,
    required super.name,
    required super.fromLocation,
    required super.toLocation,
    super.middleStops = const [],
    required super.averageDistanceKm,
    required super.estimatedDuration,
    super.description,
  });

  factory JourneyPlanModel.fromMap(Map<String, dynamic> map) {
    final base = JourneyPlan.fromJson(map);
    return JourneyPlanModel(
      id: base.id,
      name: base.name,
      fromLocation: base.fromLocation,
      toLocation: base.toLocation,
      middleStops: base.middleStops,
      averageDistanceKm: base.averageDistanceKm,
      estimatedDuration: base.estimatedDuration,
      description: base.description,
    );
  }
}
