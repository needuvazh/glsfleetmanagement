import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/location_mock_datasource.dart';
import '../../data/location_repository.dart';
import '../../domain/location_model.dart';

class LocationUiState {
  const LocationUiState({
    required this.locations,
    required this.searchQuery,
    required this.lastUpdated,
  });

  final List<LocationModel> locations;
  final String searchQuery;
  final DateTime lastUpdated;

  List<LocationModel> get filteredLocations {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return locations;
    }

    return locations.where((location) {
      return [
        location.locationName,
        location.locationCode,
      ].join(' ').toLowerCase().contains(query);
    }).toList();
  }

  LocationUiState copyWith({
    List<LocationModel>? locations,
    String? searchQuery,
    DateTime? lastUpdated,
  }) {
    return LocationUiState(
      locations: locations ?? this.locations,
      searchQuery: searchQuery ?? this.searchQuery,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final locationMockDataSourceProvider = Provider<LocationMockDataSource>(
  (ref) => const LocationMockDataSourceImpl(),
);

final locationRepositoryProvider = Provider<LocationRepository>(
  (ref) => LocationRepositoryImpl(
    mockDataSource: ref.watch(locationMockDataSourceProvider),
  ),
);

final locationViewModelProvider =
    AsyncNotifierProvider<LocationViewModel, LocationUiState>(
  LocationViewModel.new,
);

class LocationViewModel extends AsyncNotifier<LocationUiState> {
  @override
  Future<LocationUiState> build() async {
    final locations = await ref.watch(locationRepositoryProvider).getLocations();
    return LocationUiState(
      locations: locations,
      searchQuery: '',
      lastUpdated: DateTime.now(),
    );
  }

  void setSearchQuery(String value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(searchQuery: value));
  }

  Future<String> addLocation(LocationModel location) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Location state is not ready.';
    }

    final validationMessage = _validate(location, current.locations);
    if (validationMessage != null) {
      return validationMessage;
    }

    final next = await ref.read(locationRepositoryProvider).addLocation(location);
    state = AsyncData(
      current.copyWith(
        locations: next,
        lastUpdated: DateTime.now(),
      ),
    );
    return 'Location added successfully.';
  }

  Future<String> updateLocation(
    String originalCode,
    LocationModel location,
  ) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Location state is not ready.';
    }

    final otherLocations = current.locations
        .where(
          (entry) =>
              entry.locationCode.toLowerCase() != originalCode.toLowerCase(),
        )
        .toList();

    final validationMessage = _validate(location, otherLocations);
    if (validationMessage != null) {
      return validationMessage;
    }

    final next = await ref
        .read(locationRepositoryProvider)
        .updateLocation(originalCode, location);
    state = AsyncData(
      current.copyWith(
        locations: next,
        lastUpdated: DateTime.now(),
      ),
    );
    return 'Location updated successfully.';
  }

  String? _validate(
    LocationModel location,
    List<LocationModel> existingLocations,
  ) {
    if (location.locationName.trim().isEmpty) {
      return 'Location name is required.';
    }
    if (location.locationCode.trim().isEmpty) {
      return 'Location code is required.';
    }

    final duplicateCode = existingLocations.any(
      (entry) =>
          entry.locationCode.toLowerCase() ==
          location.locationCode.trim().toLowerCase(),
    );
    if (duplicateCode) {
      return 'Location code must be unique.';
    }

    return null;
  }
}

class LocationFormState {
  const LocationFormState({
    required this.initialized,
    required this.originalCode,
    required this.locationName,
    required this.locationCode,
    required this.latitude,
    required this.longitude,
  });

  final bool initialized;
  final String? originalCode;
  final String locationName;
  final String locationCode;
  final String latitude;
  final String longitude;

  bool get isEditMode => originalCode != null;

  LocationModel toLocationModel() {
    return LocationModel(
      locationName: locationName.trim(),
      locationCode: locationCode.trim().toUpperCase(),
      latitude: double.parse(latitude.trim()),
      longitude: double.parse(longitude.trim()),
    );
  }

  LocationFormState copyWith({
    bool? initialized,
    String? originalCode,
    bool clearOriginalCode = false,
    String? locationName,
    String? locationCode,
    String? latitude,
    String? longitude,
  }) {
    return LocationFormState(
      initialized: initialized ?? this.initialized,
      originalCode:
          clearOriginalCode ? null : (originalCode ?? this.originalCode),
      locationName: locationName ?? this.locationName,
      locationCode: locationCode ?? this.locationCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

final locationFormProvider =
    AutoDisposeNotifierProvider<LocationFormNotifier, LocationFormState>(
  LocationFormNotifier.new,
);

class LocationFormNotifier extends AutoDisposeNotifier<LocationFormState> {
  @override
  LocationFormState build() {
    return const LocationFormState(
      initialized: false,
      originalCode: null,
      locationName: '',
      locationCode: '',
      latitude: '',
      longitude: '',
    );
  }

  void initialize(LocationModel? location) {
    if (state.initialized) {
      return;
    }

    if (location == null) {
      state = state.copyWith(
        initialized: true,
        clearOriginalCode: true,
      );
      return;
    }

    state = LocationFormState(
      initialized: true,
      originalCode: location.locationCode,
      locationName: location.locationName,
      locationCode: location.locationCode,
      latitude: location.latitude.toString(),
      longitude: location.longitude.toString(),
    );
  }

  void setLocationName(String value) {
    state = state.copyWith(locationName: value);
  }

  void setLocationCode(String value) {
    state = state.copyWith(locationCode: value.toUpperCase());
  }

  void setLatitude(String value) {
    state = state.copyWith(latitude: value);
  }

  void setLongitude(String value) {
    state = state.copyWith(longitude: value);
  }
}
