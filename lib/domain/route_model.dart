import 'location_model.dart';

class RouteLocationModel {
  const RouteLocationModel({
    required this.routeId,
    required this.startLocation,
    required this.endLocation,
    required this.stops,
    required this.estimatedTime,
  });

  final String routeId;
  final LocationModel startLocation;
  final LocationModel endLocation;
  final List<LocationModel> stops;
  final String estimatedTime;

  String get routeName =>
      '${startLocation.locationName} - ${endLocation.locationName}';

  int get stopsCount => stops.length;

  RouteLocationModel copyWith({
    String? routeId,
    LocationModel? startLocation,
    LocationModel? endLocation,
    List<LocationModel>? stops,
    String? estimatedTime,
  }) {
    return RouteLocationModel(
      routeId: routeId ?? this.routeId,
      startLocation: startLocation ?? this.startLocation,
      endLocation: endLocation ?? this.endLocation,
      stops: stops ?? this.stops,
      estimatedTime: estimatedTime ?? this.estimatedTime,
    );
  }
}
