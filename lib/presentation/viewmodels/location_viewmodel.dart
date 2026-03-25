import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glsfleetmanagement/domain/entities/location.dart';

final locationViewModelProvider = StateNotifierProvider<LocationViewModel, LocationState>((ref) {
  return LocationViewModel();
});

class LocationState {
  final List<Location> locations;
  final bool isLoading;
  final String? error;
  final Location? selectedLocation;

  LocationState({
    this.locations = const [],
    this.isLoading = false,
    this.error,
    this.selectedLocation,
  });

  LocationState copyWith({
    List<Location>? locations,
    bool? isLoading,
    String? error,
    Location? selectedLocation,
  }) {
    return LocationState(
      locations: locations ?? this.locations,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedLocation: selectedLocation ?? this.selectedLocation,
    );
  }
}

class LocationViewModel extends StateNotifier<LocationState> {
  LocationViewModel() : super(LocationState()) {
    _initializeMockData();
  }

  void _initializeMockData() {
    final mockLocations = [
      Location(
        id: 'LOC001',
        name: 'Muscat Central Warehouse',
        latitude: 23.6100,
        longitude: 58.5400,
        address: 'Industrial Area, Muscat',
        description: 'Main distribution center',
      ),
      Location(
        id: 'LOC002',
        name: 'Salalah Distribution Center',
        latitude: 17.0151,
        longitude: 54.0924,
        address: 'Salalah, Dhofar',
        description: 'Southern region hub',
      ),
      Location(
        id: 'LOC003',
        name: 'Nizwa Regional Hub',
        latitude: 22.9333,
        longitude: 57.5333,
        address: 'Nizwa, Ad Dakhiliyah',
        description: 'Central region distribution',
      ),
      Location(
        id: 'LOC004',
        name: 'Sohar Port Terminal',
        latitude: 24.3500,
        longitude: 56.7333,
        address: 'Sohar, North Batinah',
        description: 'Port logistics center',
      ),
      Location(
        id: 'LOC005',
        name: 'Sur Coastal Depot',
        latitude: 22.5597,
        longitude: 59.5411,
        address: 'Sur, Ash Sharqiyah',
        description: 'Coastal distribution point',
      ),
    ];
    state = state.copyWith(locations: mockLocations);
  }

  void addLocation(Location location) {
    final updatedLocations = [...state.locations, location];
    state = state.copyWith(locations: updatedLocations);
  }

  void updateLocation(Location location) {
    final updatedLocations = state.locations.map((loc) {
      return loc.id == location.id ? location : loc;
    }).toList();
    state = state.copyWith(locations: updatedLocations);
  }

  void deleteLocation(String locationId) {
    final updatedLocations = state.locations.where((loc) => loc.id != locationId).toList();
    state = state.copyWith(locations: updatedLocations);
  }

  void selectLocation(Location location) {
    state = state.copyWith(selectedLocation: location);
  }

  void clearSelection() {
    state = state.copyWith(selectedLocation: null);
  }
}
