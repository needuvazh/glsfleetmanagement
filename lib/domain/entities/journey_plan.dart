class JourneyPlan {
  const JourneyPlan({
    required this.id,
    required this.planName,
    required this.origin,
    required this.destination,
    required this.distance,
    required this.estimatedTime,
    required this.stops,
    required this.fuelEstimate,
  });

  final String id;
  final String planName;
  final String origin;
  final String destination;
  final double distance;
  final double estimatedTime;
  final List<String> stops;
  final double fuelEstimate;

  JourneyPlan copyWith({
    String? id,
    String? planName,
    String? origin,
    String? destination,
    double? distance,
    double? estimatedTime,
    List<String>? stops,
    double? fuelEstimate,
  }) {
    return JourneyPlan(
      id: id ?? this.id,
      planName: planName ?? this.planName,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      distance: distance ?? this.distance,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      stops: stops ?? this.stops,
      fuelEstimate: fuelEstimate ?? this.fuelEstimate,
    );
  }
}
