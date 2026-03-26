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
    required this.statusFilter,
    required this.riskFilter,
    required this.regionFilter,
    required this.distanceFilter,
    required this.customerSpecificFilter,
    required this.lastUpdated,
  });

  final List<RouteLocationModel> routes;
  final List<LocationModel> locations;
  final String searchQuery;
  final RouteOperationalStatus? statusFilter;
  final RouteRiskLevel? riskFilter;
  final String regionFilter;
  final String distanceFilter;
  final String customerSpecificFilter;
  final DateTime lastUpdated;

  List<String> get regionOptions {
    final set = <String>{'All'};
    for (final route in routes) {
      final region = route.region.trim();
      if (region.isNotEmpty) {
        set.add(region);
      }
    }
    final items = set.toList();
    items.sort();
    return items;
  }

  List<RouteLocationModel> get filteredRoutes {
    final query = searchQuery.trim().toLowerCase();

    return routes.where((route) {
      if (statusFilter != null && route.status != statusFilter) {
        return false;
      }
      if (riskFilter != null && route.riskLevel != riskFilter) {
        return false;
      }
      if (regionFilter != 'All' && route.region != regionFilter) {
        return false;
      }
      if (customerSpecificFilter == 'Customer Specific' &&
          !route.customerSpecific) {
        return false;
      }
      if (customerSpecificFilter == 'General' && route.customerSpecific) {
        return false;
      }
      if (distanceFilter == 'Short Distance' && route.distanceKm > 300) {
        return false;
      }
      if (distanceFilter == 'Long Distance' && route.distanceKm <= 300) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }
      final stopsText = route.stopPoints
          .map((stop) => '${stop.location.locationName} ${stop.type.label}')
          .join(' ');
      final haystack = [
        route.routeCode,
        route.routeName,
        route.startLocation.locationName,
        route.endLocation.locationName,
        route.region,
        stopsText,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  RouteUiState copyWith({
    List<RouteLocationModel>? routes,
    List<LocationModel>? locations,
    String? searchQuery,
    RouteOperationalStatus? statusFilter,
    bool clearStatusFilter = false,
    RouteRiskLevel? riskFilter,
    bool clearRiskFilter = false,
    String? regionFilter,
    String? distanceFilter,
    String? customerSpecificFilter,
    DateTime? lastUpdated,
  }) {
    return RouteUiState(
      routes: routes ?? this.routes,
      locations: locations ?? this.locations,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      riskFilter: clearRiskFilter ? null : (riskFilter ?? this.riskFilter),
      regionFilter: regionFilter ?? this.regionFilter,
      distanceFilter: distanceFilter ?? this.distanceFilter,
      customerSpecificFilter:
          customerSpecificFilter ?? this.customerSpecificFilter,
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
      statusFilter: null,
      riskFilter: null,
      regionFilter: 'All',
      distanceFilter: 'All',
      customerSpecificFilter: 'All',
      lastUpdated: DateTime.now(),
    );
  }

  RouteLocationModel? findByCode(String? code) {
    final current = state.valueOrNull;
    if (current == null || code == null || code.trim().isEmpty) {
      return null;
    }
    final normalized = code.trim().toLowerCase();
    for (final route in current.routes) {
      if (route.routeCode.toLowerCase() == normalized ||
          route.routeId.toLowerCase() == normalized) {
        return route;
      }
    }
    return null;
  }

  RouteLocationModel? findByName(String? name) {
    final current = state.valueOrNull;
    if (current == null || name == null || name.trim().isEmpty) {
      return null;
    }
    final normalized = name.trim().toLowerCase();
    for (final route in current.routes) {
      if (route.routeName.toLowerCase() == normalized) {
        return route;
      }
    }
    return null;
  }

  void setSearchQuery(String value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    state = AsyncData(current.copyWith(searchQuery: value));
  }

  void setStatusFilter(RouteOperationalStatus? value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(
      value == null
          ? current.copyWith(clearStatusFilter: true)
          : current.copyWith(statusFilter: value),
    );
  }

  void setRiskFilter(RouteRiskLevel? value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(
      value == null
          ? current.copyWith(clearRiskFilter: true)
          : current.copyWith(riskFilter: value),
    );
  }

  void setRegionFilter(String value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(regionFilter: value));
  }

  void setDistanceFilter(String value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(distanceFilter: value));
  }

  void setCustomerSpecificFilter(String value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(customerSpecificFilter: value));
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

    final validationMessage = _validate(route, current.routes, isEdit: false);
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

    final validationMessage = _validate(route, current.routes,
        isEdit: true, originalRouteId: routeId);
    if (validationMessage != null) {
      return validationMessage;
    }

    final next =
        await ref.read(routeRepositoryProvider).updateRoute(routeId, route);
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

  Future<String> setRouteStatus(
    String routeId,
    RouteOperationalStatus status, {
    bool temporarilyRestricted = false,
    String restrictionReason = '',
  }) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Route state is not ready.';
    }

    RouteLocationModel? target;
    for (final route in current.routes) {
      if (route.routeId == routeId) {
        target = route;
        break;
      }
    }
    if (target == null) {
      return 'Route not found.';
    }

    final updated = target.copyWith(
      status: status,
      temporarilyRestricted: temporarilyRestricted,
      restrictionReason: restrictionReason,
    );

    final next =
        await ref.read(routeRepositoryProvider).updateRoute(routeId, updated);
    state =
        AsyncData(current.copyWith(routes: next, lastUpdated: DateTime.now()));
    return 'Route status updated.';
  }

  String? _validate(
    RouteLocationModel route,
    List<RouteLocationModel> existingRoutes, {
    required bool isEdit,
    String? originalRouteId,
  }) {
    if (route.routeCode.trim().isEmpty) {
      return 'Route code is required.';
    }
    if (route.routeName.trim().isEmpty) {
      return 'Route name is required.';
    }
    if (route.startLocation.locationCode == route.endLocation.locationCode) {
      return 'Origin and destination must be different.';
    }
    if (route.distanceKm <= 0) {
      return 'Distance must be greater than zero.';
    }
    if (route.estimatedTime.trim().isEmpty) {
      return 'Estimated travel time is required.';
    }

    final duplicateCode = existingRoutes.any(
      (entry) =>
          (!isEdit || entry.routeId != originalRouteId) &&
          entry.routeCode.toLowerCase() == route.routeCode.trim().toLowerCase(),
    );
    if (duplicateCode) {
      return 'Route code must be unique.';
    }

    final duplicateName = existingRoutes.any(
      (entry) =>
          (!isEdit || entry.routeId != originalRouteId) &&
          entry.routeName.toLowerCase() == route.routeName.trim().toLowerCase(),
    );
    if (duplicateName) {
      return 'Route name must be unique.';
    }

    final seen = <String>{};
    for (int index = 0; index < route.stopPoints.length; index++) {
      final stop = route.stopPoints[index];
      final code = stop.location.locationCode;
      if (code == route.startLocation.locationCode ||
          code == route.endLocation.locationCode) {
        return 'Stops cannot duplicate origin or destination.';
      }
      if (!seen.add(code)) {
        return 'Intermediate stops must be unique.';
      }
      if (stop.type == RouteStopType.other && stop.note.trim().isEmpty) {
        return 'Other stop type requires a note.';
      }
    }

    if (route.temporarilyRestricted && route.restrictionReason.trim().isEmpty) {
      return 'Restriction reason is required when route is restricted.';
    }

    return null;
  }
}

class RouteStopDraft {
  const RouteStopDraft({
    required this.locationCode,
    required this.stopType,
    required this.note,
  });

  final String? locationCode;
  final RouteStopType stopType;
  final String note;

  RouteStopDraft copyWith({
    String? locationCode,
    bool clearLocationCode = false,
    RouteStopType? stopType,
    String? note,
  }) {
    return RouteStopDraft(
      locationCode:
          clearLocationCode ? null : (locationCode ?? this.locationCode),
      stopType: stopType ?? this.stopType,
      note: note ?? this.note,
    );
  }
}

class RouteFormState {
  const RouteFormState({
    required this.initialized,
    required this.originalRouteId,
    required this.routeCode,
    required this.routeName,
    required this.startLocationCode,
    required this.endLocationCode,
    required this.region,
    required this.status,
    required this.distanceKm,
    required this.estimatedTime,
    required this.expectedStops,
    required this.standardRestPoints,
    required this.standardStartWindow,
    required this.standardDeliveryWindow,
    required this.riskLevel,
    required this.nightDrivingAllowed,
    required this.restrictedSegments,
    required this.weatherSensitive,
    required this.routeNotes,
    required this.preferredVehicleType,
    required this.trailerTypePreference,
    required this.escortRequired,
    required this.specialHandlingNotes,
    required this.alternateRouteAvailable,
    required this.specialComplianceRequired,
    required this.safetyInstructions,
    required this.customerAuthorityRestrictions,
    required this.permitRequirement,
    required this.requiredDocuments,
    required this.customerSpecific,
    required this.temporarilyRestricted,
    required this.restrictionReason,
    required this.stopDrafts,
  });

  final bool initialized;
  final String? originalRouteId;
  final String routeCode;
  final String routeName;
  final String? startLocationCode;
  final String? endLocationCode;
  final String region;
  final RouteOperationalStatus status;
  final String distanceKm;
  final String estimatedTime;
  final String expectedStops;
  final String standardRestPoints;
  final String standardStartWindow;
  final String standardDeliveryWindow;
  final RouteRiskLevel riskLevel;
  final bool nightDrivingAllowed;
  final String restrictedSegments;
  final bool weatherSensitive;
  final String routeNotes;
  final String preferredVehicleType;
  final String trailerTypePreference;
  final bool escortRequired;
  final String specialHandlingNotes;
  final bool alternateRouteAvailable;
  final bool specialComplianceRequired;
  final String safetyInstructions;
  final String customerAuthorityRestrictions;
  final String permitRequirement;
  final String requiredDocuments;
  final bool customerSpecific;
  final bool temporarilyRestricted;
  final String restrictionReason;
  final List<RouteStopDraft> stopDrafts;

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

    final stops = <RouteStopModel>[];
    for (int index = 0; index < stopDrafts.length; index++) {
      final draft = stopDrafts[index];
      final code = draft.locationCode?.trim() ?? '';
      if (code.isEmpty) {
        throw StateError('Stop location is required for stop ${index + 1}.');
      }
      if (draft.stopType == RouteStopType.other && draft.note.trim().isEmpty) {
        throw StateError('Stop ${index + 1}: note is required for Other type.');
      }
      stops.add(
        RouteStopModel(
          location: findByCode(code),
          type: draft.stopType,
          note: draft.note.trim(),
        ),
      );
    }

    final routeId = originalRouteId ?? _generateRouteId();
    final origin = findByCode(startLocationCode!);
    final destination = findByCode(endLocationCode!);

    return RouteLocationModel(
      routeId: routeId,
      routeCode: routeCode.trim().toUpperCase(),
      routeName: routeName.trim(),
      startLocation: origin,
      endLocation: destination,
      stopPoints: stops,
      estimatedTime: estimatedTime.trim(),
      distanceKm: double.parse(distanceKm.trim()),
      region: region.trim(),
      riskLevel: riskLevel,
      status: status,
      customerSpecific: customerSpecific,
      expectedStops: int.tryParse(expectedStops.trim()) ?? stops.length,
      standardRestPoints: standardRestPoints.trim().isEmpty
          ? const []
          : standardRestPoints
              .split(',')
              .map((entry) => entry.trim())
              .where((entry) => entry.isNotEmpty)
              .toList(),
      standardStartWindow: standardStartWindow.trim(),
      standardDeliveryWindow: standardDeliveryWindow.trim(),
      nightDrivingAllowed: nightDrivingAllowed,
      restrictedSegments: restrictedSegments.trim(),
      weatherSensitive: weatherSensitive,
      routeNotes: routeNotes.trim(),
      preferredVehicleType: preferredVehicleType.trim(),
      trailerTypePreference: trailerTypePreference.trim(),
      escortRequired: escortRequired,
      specialHandlingNotes: specialHandlingNotes.trim(),
      alternateRouteAvailable: alternateRouteAvailable,
      specialComplianceRequired: specialComplianceRequired,
      safetyInstructions: safetyInstructions.trim(),
      customerAuthorityRestrictions: customerAuthorityRestrictions.trim(),
      permitRequirement: permitRequirement.trim(),
      requiredDocuments: requiredDocuments.trim().isEmpty
          ? const []
          : requiredDocuments
              .split(',')
              .map((entry) => entry.trim())
              .where((entry) => entry.isNotEmpty)
              .toList(),
      temporarilyRestricted: temporarilyRestricted,
      restrictionReason: restrictionReason.trim(),
    );
  }

  RouteFormState copyWith({
    bool? initialized,
    String? originalRouteId,
    bool clearOriginalRouteId = false,
    String? routeCode,
    String? routeName,
    String? startLocationCode,
    bool clearStartLocationCode = false,
    String? endLocationCode,
    bool clearEndLocationCode = false,
    String? region,
    RouteOperationalStatus? status,
    String? distanceKm,
    String? estimatedTime,
    String? expectedStops,
    String? standardRestPoints,
    String? standardStartWindow,
    String? standardDeliveryWindow,
    RouteRiskLevel? riskLevel,
    bool? nightDrivingAllowed,
    String? restrictedSegments,
    bool? weatherSensitive,
    String? routeNotes,
    String? preferredVehicleType,
    String? trailerTypePreference,
    bool? escortRequired,
    String? specialHandlingNotes,
    bool? alternateRouteAvailable,
    bool? specialComplianceRequired,
    String? safetyInstructions,
    String? customerAuthorityRestrictions,
    String? permitRequirement,
    String? requiredDocuments,
    bool? customerSpecific,
    bool? temporarilyRestricted,
    String? restrictionReason,
    List<RouteStopDraft>? stopDrafts,
  }) {
    return RouteFormState(
      initialized: initialized ?? this.initialized,
      originalRouteId: clearOriginalRouteId
          ? null
          : (originalRouteId ?? this.originalRouteId),
      routeCode: routeCode ?? this.routeCode,
      routeName: routeName ?? this.routeName,
      startLocationCode: clearStartLocationCode
          ? null
          : (startLocationCode ?? this.startLocationCode),
      endLocationCode: clearEndLocationCode
          ? null
          : (endLocationCode ?? this.endLocationCode),
      region: region ?? this.region,
      status: status ?? this.status,
      distanceKm: distanceKm ?? this.distanceKm,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      expectedStops: expectedStops ?? this.expectedStops,
      standardRestPoints: standardRestPoints ?? this.standardRestPoints,
      standardStartWindow: standardStartWindow ?? this.standardStartWindow,
      standardDeliveryWindow:
          standardDeliveryWindow ?? this.standardDeliveryWindow,
      riskLevel: riskLevel ?? this.riskLevel,
      nightDrivingAllowed: nightDrivingAllowed ?? this.nightDrivingAllowed,
      restrictedSegments: restrictedSegments ?? this.restrictedSegments,
      weatherSensitive: weatherSensitive ?? this.weatherSensitive,
      routeNotes: routeNotes ?? this.routeNotes,
      preferredVehicleType: preferredVehicleType ?? this.preferredVehicleType,
      trailerTypePreference:
          trailerTypePreference ?? this.trailerTypePreference,
      escortRequired: escortRequired ?? this.escortRequired,
      specialHandlingNotes: specialHandlingNotes ?? this.specialHandlingNotes,
      alternateRouteAvailable:
          alternateRouteAvailable ?? this.alternateRouteAvailable,
      specialComplianceRequired:
          specialComplianceRequired ?? this.specialComplianceRequired,
      safetyInstructions: safetyInstructions ?? this.safetyInstructions,
      customerAuthorityRestrictions:
          customerAuthorityRestrictions ?? this.customerAuthorityRestrictions,
      permitRequirement: permitRequirement ?? this.permitRequirement,
      requiredDocuments: requiredDocuments ?? this.requiredDocuments,
      customerSpecific: customerSpecific ?? this.customerSpecific,
      temporarilyRestricted:
          temporarilyRestricted ?? this.temporarilyRestricted,
      restrictionReason: restrictionReason ?? this.restrictionReason,
      stopDrafts: stopDrafts ?? this.stopDrafts,
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
      routeCode: '',
      routeName: '',
      startLocationCode: null,
      endLocationCode: null,
      region: '',
      status: RouteOperationalStatus.active,
      distanceKm: '',
      estimatedTime: '',
      expectedStops: '0',
      standardRestPoints: '',
      standardStartWindow: '',
      standardDeliveryWindow: '',
      riskLevel: RouteRiskLevel.low,
      nightDrivingAllowed: true,
      restrictedSegments: '',
      weatherSensitive: false,
      routeNotes: '',
      preferredVehicleType: '',
      trailerTypePreference: '',
      escortRequired: false,
      specialHandlingNotes: '',
      alternateRouteAvailable: false,
      specialComplianceRequired: false,
      safetyInstructions: '',
      customerAuthorityRestrictions: '',
      permitRequirement: '',
      requiredDocuments: '',
      customerSpecific: false,
      temporarilyRestricted: false,
      restrictionReason: '',
      stopDrafts: [],
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
      routeCode: route.routeCode,
      routeName: route.routeName,
      startLocationCode: route.startLocation.locationCode,
      endLocationCode: route.endLocation.locationCode,
      region: route.region,
      status: route.status,
      distanceKm: route.distanceKm.toStringAsFixed(1),
      estimatedTime: route.estimatedTime,
      expectedStops: route.expectedStops.toString(),
      standardRestPoints: route.standardRestPoints.join(', '),
      standardStartWindow: route.standardStartWindow,
      standardDeliveryWindow: route.standardDeliveryWindow,
      riskLevel: route.riskLevel,
      nightDrivingAllowed: route.nightDrivingAllowed,
      restrictedSegments: route.restrictedSegments,
      weatherSensitive: route.weatherSensitive,
      routeNotes: route.routeNotes,
      preferredVehicleType: route.preferredVehicleType,
      trailerTypePreference: route.trailerTypePreference,
      escortRequired: route.escortRequired,
      specialHandlingNotes: route.specialHandlingNotes,
      alternateRouteAvailable: route.alternateRouteAvailable,
      specialComplianceRequired: route.specialComplianceRequired,
      safetyInstructions: route.safetyInstructions,
      customerAuthorityRestrictions: route.customerAuthorityRestrictions,
      permitRequirement: route.permitRequirement,
      requiredDocuments: route.requiredDocuments.join(', '),
      customerSpecific: route.customerSpecific,
      temporarilyRestricted: route.temporarilyRestricted,
      restrictionReason: route.restrictionReason,
      stopDrafts: [
        for (final stop in route.stopPoints)
          RouteStopDraft(
            locationCode: stop.location.locationCode,
            stopType: stop.type,
            note: stop.note,
          ),
      ],
    );
  }

  void setRouteCode(String value) => state = state.copyWith(routeCode: value);
  void setRouteName(String value) => state = state.copyWith(routeName: value);
  void setStartLocation(String? value) =>
      state = state.copyWith(startLocationCode: value);
  void setEndLocation(String? value) =>
      state = state.copyWith(endLocationCode: value);
  void setRegion(String value) => state = state.copyWith(region: value);
  void setStatus(RouteOperationalStatus value) =>
      state = state.copyWith(status: value);
  void setDistanceKm(String value) => state = state.copyWith(distanceKm: value);
  void setEstimatedTime(String value) =>
      state = state.copyWith(estimatedTime: value);
  void setExpectedStops(String value) =>
      state = state.copyWith(expectedStops: value);
  void setStandardRestPoints(String value) =>
      state = state.copyWith(standardRestPoints: value);
  void setStandardStartWindow(String value) =>
      state = state.copyWith(standardStartWindow: value);
  void setStandardDeliveryWindow(String value) =>
      state = state.copyWith(standardDeliveryWindow: value);
  void setRiskLevel(RouteRiskLevel value) =>
      state = state.copyWith(riskLevel: value);
  void setNightDrivingAllowed(bool value) =>
      state = state.copyWith(nightDrivingAllowed: value);
  void setRestrictedSegments(String value) =>
      state = state.copyWith(restrictedSegments: value);
  void setWeatherSensitive(bool value) =>
      state = state.copyWith(weatherSensitive: value);
  void setRouteNotes(String value) => state = state.copyWith(routeNotes: value);
  void setPreferredVehicleType(String value) =>
      state = state.copyWith(preferredVehicleType: value);
  void setTrailerTypePreference(String value) =>
      state = state.copyWith(trailerTypePreference: value);
  void setEscortRequired(bool value) =>
      state = state.copyWith(escortRequired: value);
  void setSpecialHandlingNotes(String value) =>
      state = state.copyWith(specialHandlingNotes: value);
  void setAlternateRouteAvailable(bool value) =>
      state = state.copyWith(alternateRouteAvailable: value);
  void setSpecialComplianceRequired(bool value) =>
      state = state.copyWith(specialComplianceRequired: value);
  void setSafetyInstructions(String value) =>
      state = state.copyWith(safetyInstructions: value);
  void setCustomerAuthorityRestrictions(String value) =>
      state = state.copyWith(customerAuthorityRestrictions: value);
  void setPermitRequirement(String value) =>
      state = state.copyWith(permitRequirement: value);
  void setRequiredDocuments(String value) =>
      state = state.copyWith(requiredDocuments: value);
  void setCustomerSpecific(bool value) =>
      state = state.copyWith(customerSpecific: value);
  void setTemporarilyRestricted(bool value) =>
      state = state.copyWith(temporarilyRestricted: value);
  void setRestrictionReason(String value) =>
      state = state.copyWith(restrictionReason: value);

  void addStop() {
    final next = List<RouteStopDraft>.from(state.stopDrafts)
      ..add(const RouteStopDraft(
          locationCode: null, stopType: RouteStopType.rest, note: ''));
    state = state.copyWith(stopDrafts: next);
  }

  void updateStopLocation(int index, String? value) {
    if (index < 0 || index >= state.stopDrafts.length) {
      return;
    }
    final next = List<RouteStopDraft>.from(state.stopDrafts);
    next[index] = next[index].copyWith(locationCode: value);
    state = state.copyWith(stopDrafts: next);
  }

  void updateStopType(int index, RouteStopType value) {
    if (index < 0 || index >= state.stopDrafts.length) {
      return;
    }
    final next = List<RouteStopDraft>.from(state.stopDrafts);
    next[index] = next[index].copyWith(stopType: value);
    state = state.copyWith(stopDrafts: next);
  }

  void updateStopNote(int index, String value) {
    if (index < 0 || index >= state.stopDrafts.length) {
      return;
    }
    final next = List<RouteStopDraft>.from(state.stopDrafts);
    next[index] = next[index].copyWith(note: value);
    state = state.copyWith(stopDrafts: next);
  }

  void removeStop(int index) {
    if (index < 0 || index >= state.stopDrafts.length) {
      return;
    }
    final next = List<RouteStopDraft>.from(state.stopDrafts)..removeAt(index);
    state = state.copyWith(stopDrafts: next);
  }
}
