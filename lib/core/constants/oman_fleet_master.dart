class OmanFleetMaster {
  const OmanFleetMaster._();

  static const lightVehicles = [
    'Light Vehicle (4WD)',
    'Pickup 1 Ton',
    'Pickup 3 Ton',
  ];

  static const heavyVehicles = [
    '7 Ton Truck',
    '10 Ton Truck',
    'Flatbed Truck',
    'Box Truck',
    'Tipper',
    'Tanker',
    'Prime Mover',
  ];

  static const specializedVehicles = [
    'HIAB Truck',
    'Crane Truck',
    'Winch Truck',
    'Water Tanker',
  ];

  static const fleetTypes = [
    ...lightVehicles,
    ...heavyVehicles,
    ...specializedVehicles,
  ];

  static const availabilityStatuses = [
    'Available',
    'Assigned',
    'Maintenance',
    'Blocked',
  ];

  static const ownershipTypes = ['Owned', 'Contracted'];
  static const activeStatuses = ['Active', 'Inactive'];

  static const omanLocations = [
    'Muscat',
    'Sohar',
    'Duqm',
    'Nizwa',
    'Salalah',
    'Sur',
    'Barka',
  ];

  static String vehicleClassForType(String fleetType) {
    if (lightVehicles.contains(fleetType)) {
      return 'Light';
    }
    return 'Heavy';
  }

  static String categoryForType(String fleetType) {
    if (lightVehicles.contains(fleetType)) {
      return 'Light Vehicle';
    }
    if (specializedVehicles.contains(fleetType)) {
      return 'Specialized Vehicle';
    }
    return 'Heavy Vehicle';
  }

  static String codeForType(String fleetType) {
    final index = fleetTypes.indexOf(fleetType);
    if (index < 0) {
      return 'VT-OMN-000';
    }
    final serial = (index + 1).toString().padLeft(3, '0');
    return 'VT-OMN-$serial';
  }
}
