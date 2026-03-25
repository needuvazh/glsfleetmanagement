import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/route_mock_datasource.dart';
import '../../data/route_repository.dart';
import '../../domain/location_model.dart';
import '../../domain/route_model.dart';
import 'location_viewmodel.dart';

class RouteUiState {
  const RouteUiState({
    required this.routes,
    required this.locations,
    required this.searchQuery,
    required this.lastUpdated,
  });

  final List<RouteLocationModel> routes;
  final List<LocationModel> locations;
  final String searchQuery;
  final DateTime lastUpdated;

  List<RouteLocationModel> get filteredRoutes {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return routes;
    }

    return routes.where((route) {
      final stopsText = route.stops.map((stop) => stop.locationName).join(' ');
      final haystack = [
        route.routeName,
        route.startLocation.locationName,
        route.endLocation.locationName,
        stopsText,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  RouteUiState copyWith({
    List<RouteLocationModel>? routes,
    List<LocationModel>? locations,
    String? searchQuery,
    DateTime? lastUpdated,
  }) {
    return RouteUiState(
      routes: routes ?? this.routes,
      locations: locations ?? this.locations,
      searchQuery: searchQuery ?? this.searchQuery,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final routeMockDataSourceProvider = Provider<RouteMockDataSource>(
  (ref) => RouteMockDataSourceImpl(
    locationRepository: ref.watch(locationRepositoryProvider),
  ),
);

final routeRepositoryProvider = Provider<RouteLocationRepository>(
  (ref) => RouteLocationRepositoryImpl(
    mockDataSource: ref.watch(routeMockDataSourceProvider),
  ),
);

final routeViewModelProvider =
    AsyncNotifierProvider<RouteViewModel, RouteUiState>(
  RouteViewModel.new,
);

class RouteViewModel extends AsyncNotifier<RouteUiState> {
  @override
  Future<RouteUiState> build() async {
    final routeRepository = ref.watch(routeRepositoryProvider);
    final locationRepository = ref.watch(locationRepositoryProvider);

    final routes = await routeRepository.getRoutes();
    final locations = await locationRepository.getLocations();

    return RouteUiState(
      routes: routes,
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

  Future<void> refreshLocationOptions() async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final locations = await ref.read(locationRepositoryProvider).getLocations();
    state = AsyncData(
      current.copyWith(
        locations: locations,
        lastUpdated: DateTime.now(),
      ),
    );
  }

  Future<String> addRoute(RouteLocationModel route) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Route state is not ready.';
    }

    final validationMessage = _validate(route);
    if (validationMessage != null) {
      return validationMessage;
    }

    final next = await ref.read(routeRepositoryProvider).addRoute(route);
    final locations = await ref.read(locationRepositoryProvider).getLocations();
    state = AsyncData(
      current.copyWith(
        routes: next,
        locations: locations,
        lastUpdated: DateTime.now(),
      ),
    );
    return 'Route added successfully.';
  }

  Future<String> updateRoute(String routeId, RouteLocationModel route) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Route state is not ready.';
    }

    final validationMessage = _validate(route);
    if (validationMessage != null) {
      return validationMessage;
    }

    final next = await ref.read(routeRepositoryProvider).updateRoute(routeId, route);
    final locations = await ref.read(locationRepositoryProvider).getLocations();
    state = AsyncData(
      current.copyWith(
        routes: next,
        locations: locations,
        lastUpdated: DateTime.now(),
      ),
    );
    return 'Route updated successfully.';
  }

  String? _validate(RouteLocationModel route) {
    if (route.estimatedTime.trim().isEmpty) {
      return 'Estimated time is required.';
    }
    if (route.startLocation.locationCode == route.endLocation.locationCode) {
      return 'Start location and end location must be different.';
    }

    final seen = <String>{};
    for (int index = 0; index < route.stops.length; index++) {
      final stop = route.stops[index];
      if (stop.locationCode == route.startLocation.locationCode ||
          stop.locationCode == route.endLocation.locationCode) {
        return 'Stops cannot duplicate start or end locations.';
      }
      if (!seen.add(stop.locationCode)) {
        return 'Intermediate stops must be unique.';
      }
    }

    return null;
  }
}

class RouteFormState {
  const RouteFormState({
    required this.initialized,
    required this.originalRouteId,
    required this.startLocationCode,
    required this.endLocationCode,
    required this.estimatedTime,
    required this.stopLocationCodes,
  });

  final bool initialized;
  final String? originalRouteId;
  final String? startLocationCode;
  final String? endLocationCode;
  final String estimatedTime;
  final List<String?> stopLocationCodes;

  bool get isEditMode => originalRouteId != null;

  RouteLocationModel toRouteModel(List<LocationModel> locations) {
    LocationModel findByCode(String code) {
      for (final location in locations) {
        if (location.locationCode == code) {
          return location;
        }
      }
      throw StateError('Location $code not found.');
    }

    final stops = <LocationModel>[];
    for (int index = 0; index < stopLocationCodes.length; index++) {
      final code = stopLocationCodes[index]?.trim() ?? '';
      if (code.isEmpty) {
        throw StateError('Stop location is required for stop ${index + 1}.');
      }
      stops.add(findByCode(code));
    }

    return RouteLocationModel(
      routeId: originalRouteId ?? _generateRouteId(),
      startLocation: findByCode(startLocationCode!),
      endLocation: findByCode(endLocationCode!),
      stops: stops,
      estimatedTime: estimatedTime.trim(),
    );
  }

  RouteFormState copyWith({
    bool? initialized,
    String? originalRouteId,
    bool clearOriginalRouteId = false,
    String? startLocationCode,
    bool clearStartLocationCode = false,
    String? endLocationCode,
    bool clearEndLocationCode = false,
    String? estimatedTime,
    List<String?>? stopLocationCodes,
  }) {
    return RouteFormState(
      initialized: initialized ?? this.initialized,
      originalRouteId: clearOriginalRouteId
          ? null
          : (originalRouteId ?? this.originalRouteId),
      startLocationCode: clearStartLocationCode
          ? null
          : (startLocationCode ?? this.startLocationCode),
      endLocationCode:
          clearEndLocationCode ? null : (endLocationCode ?? this.endLocationCode),
      estimatedTime: estimatedTime ?? this.estimatedTime,
      stopLocationCodes: stopLocationCodes ?? this.stopLocationCodes,
    );
  }

  static String _generateRouteId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return 'RTE-${timestamp.substring(timestamp.length - 6)}';
  }
}

final routeFormProvider =
    AutoDisposeNotifierProvider<RouteFormNotifier, RouteFormState>(
  RouteFormNotifier.new,
);

class RouteFormNotifier extends AutoDisposeNotifier<RouteFormState> {
  @override
  RouteFormState build() {
    return const RouteFormState(
      initialized: false,
      originalRouteId: null,
      startLocationCode: null,
      endLocationCode: null,
      estimatedTime: '',
      stopLocationCodes: [],
    );
  }

  void initialize(RouteLocationModel? route) {
    if (state.initialized) {
      return;
    }

    if (route == null) {
      state = state.copyWith(
        initialized: true,
        clearOriginalRouteId: true,
        clearStartLocationCode: true,
        clearEndLocationCode: true,
      );
      return;
    }

    state = RouteFormState(
      initialized: true,
      originalRouteId: route.routeId,
      startLocationCode: route.startLocation.locationCode,
      endLocationCode: route.endLocation.locationCode,
      estimatedTime: route.estimatedTime,
      stopLocationCodes: [
        for (final stop in route.stops) stop.locationCode,
      ],
    );
  }

  void setStartLocation(String? value) {
    state = state.copyWith(startLocationCode: value);
  }

  void setEndLocation(String? value) {
    state = state.copyWith(endLocationCode: value);
  }

  void setEstimatedTime(String value) {
    state = state.copyWith(estimatedTime: value);
  }

  void addStop() {
    final next = List<String?>.from(state.stopLocationCodes)..add(null);
    state = state.copyWith(stopLocationCodes: next);
  }

  void updateStop(int index, String? value) {
    if (index < 0 || index >= state.stopLocationCodes.length) {
      return;
    }

    final next = List<String?>.from(state.stopLocationCodes);
    next[index] = value;
    state = state.copyWith(stopLocationCodes: next);
  }

  void removeStop(int index) {
    if (index < 0 || index >= state.stopLocationCodes.length) {
      return;
    }

    final next = List<String?>.from(state.stopLocationCodes)..removeAt(index);
    state = state.copyWith(stopLocationCodes: next);
  }
}
