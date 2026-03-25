class Location {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? address;
  final String? description;

  Location({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    this.description,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'description': description,
    };
  }

  Location copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? address,
    String? description,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      description: description ?? this.description,
    );
  }

  @override
  String toString() =>
      'Location(id: $id, name: $name, latitude: $latitude, longitude: $longitude, address: $address, description: $description)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          address == other.address &&
          description == other.description;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      address.hashCode ^
      description.hashCode;
}
