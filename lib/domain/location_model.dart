class LocationModel {
  const LocationModel({
    required this.locationName,
    required this.locationCode,
    required this.latitude,
    required this.longitude,
  });

  final String locationName;
  final String locationCode;
  final double latitude;
  final double longitude;

  LocationModel copyWith({
    String? locationName,
    String? locationCode,
    double? latitude,
    double? longitude,
  }) {
    return LocationModel(
      locationName: locationName ?? this.locationName,
      locationCode: locationCode ?? this.locationCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
