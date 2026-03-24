import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/vehicle_type_local_datasource.dart';
import '../../data/repositories/vehicle_type_repository_impl.dart';
import '../../domain/entities/vehicle_type.dart';
import '../../domain/repositories/vehicle_type_repository.dart';
import '../../domain/usecases/vehicle_type_usecases.dart';

class VehicleTypeUiState {
  const VehicleTypeUiState({
    required this.items,
    required this.query,
    required this.categoryFilter,
    required this.lastUpdated,
  });

  final List<VehicleType> items;
  final String query;
  final String categoryFilter;
  final DateTime lastUpdated;

  List<VehicleType> get filteredItems {
    final normalizedQuery = query.trim().toLowerCase();
    return items.where((item) {
      final categoryPass =
          categoryFilter == 'All' || item.category == categoryFilter;
      if (!categoryPass) {
        return false;
      }

      if (normalizedQuery.isEmpty) {
        return true;
      }

      final text =
          '${item.name} ${item.code} ${item.vehicleClass} ${item.loadType}'
              .toLowerCase();
      return text.contains(normalizedQuery);
    }).toList();
  }

  VehicleTypeUiState copyWith({
    List<VehicleType>? items,
    String? query,
    String? categoryFilter,
    DateTime? lastUpdated,
  }) {
    return VehicleTypeUiState(
      items: items ?? this.items,
      query: query ?? this.query,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final _vehicleTypeLocalDataSourceProvider =
    Provider<VehicleTypeLocalDataSource>(
  (ref) => VehicleTypeLocalDataSourceImpl(assetBundle: rootBundle),
);

final _vehicleTypeRepositoryProvider = Provider<VehicleTypeRepository>(
  (ref) => VehicleTypeRepositoryImpl(
    localDataSource: ref.watch(_vehicleTypeLocalDataSourceProvider),
  ),
);

final _getVehicleTypesUseCaseProvider = Provider<GetVehicleTypesUseCase>(
  (ref) => GetVehicleTypesUseCase(ref.watch(_vehicleTypeRepositoryProvider)),
);

final _addVehicleTypeUseCaseProvider = Provider<AddVehicleTypeUseCase>(
  (ref) => AddVehicleTypeUseCase(ref.watch(_vehicleTypeRepositoryProvider)),
);

final _updateVehicleTypeUseCaseProvider = Provider<UpdateVehicleTypeUseCase>(
  (ref) => UpdateVehicleTypeUseCase(ref.watch(_vehicleTypeRepositoryProvider)),
);

final _deleteVehicleTypeUseCaseProvider = Provider<DeleteVehicleTypeUseCase>(
  (ref) => DeleteVehicleTypeUseCase(ref.watch(_vehicleTypeRepositoryProvider)),
);

final vehicleTypeViewModelProvider =
    AsyncNotifierProvider<VehicleTypeViewModel, VehicleTypeUiState>(
  VehicleTypeViewModel.new,
);

class VehicleTypeViewModel extends AsyncNotifier<VehicleTypeUiState> {
  @override
  Future<VehicleTypeUiState> build() async {
    final list = await ref.watch(_getVehicleTypesUseCaseProvider).call();
    return VehicleTypeUiState(
      items: list,
      query: '',
      categoryFilter: 'All',
      lastUpdated: DateTime.now(),
    );
  }

  void setQuery(String value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(query: value));
  }

  void setCategoryFilter(String value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(categoryFilter: value));
  }

  Future<String> addVehicleType(VehicleType item) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Vehicle type state is not ready.';
    }

    final validationMessage = _validate(item, current.items);
    if (validationMessage != null) {
      return validationMessage;
    }

    final next = await ref.read(_addVehicleTypeUseCaseProvider).call(item);
    state =
        AsyncData(current.copyWith(items: next, lastUpdated: DateTime.now()));
    return 'Vehicle type added successfully.';
  }

  Future<String> updateVehicleType(
      String originalCode, VehicleType item) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Vehicle type state is not ready.';
    }

    final otherItems = current.items
        .where(
            (entry) => entry.code.toLowerCase() != originalCode.toLowerCase())
        .toList();
    final validationMessage = _validate(item, otherItems);
    if (validationMessage != null) {
      return validationMessage;
    }

    final next = await ref
        .read(_updateVehicleTypeUseCaseProvider)
        .call(originalCode, item);
    state =
        AsyncData(current.copyWith(items: next, lastUpdated: DateTime.now()));
    return 'Vehicle type updated successfully.';
  }

  Future<String> deleteVehicleType(String code) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Vehicle type state is not ready.';
    }

    final next = await ref.read(_deleteVehicleTypeUseCaseProvider).call(code);
    state =
        AsyncData(current.copyWith(items: next, lastUpdated: DateTime.now()));
    return 'Vehicle type deleted successfully.';
  }

  String? _validate(VehicleType item, List<VehicleType> existing) {
    if (item.name.trim().isEmpty) {
      return 'Vehicle type name is required.';
    }
    if (item.code.trim().isEmpty) {
      return 'Short code is required.';
    }
    if (item.ownershipTypes.isEmpty) {
      return 'At least one ownership type is required.';
    }
    if (item.ownershipTypes.contains('Vendor Owned') && !item.vendorRequired) {
      return 'Vendor mapping is required when Vendor Owned is selected.';
    }
    if (item.isHazardous && !item.requiresSafetyCompliance) {
      return 'Safety compliance must be ON for hazardous vehicle types.';
    }
    if (item.loadType == 'PDO') {
      if (!(item.requiresInsurance &&
          item.requiresPermit &&
          item.requiresFitness &&
          item.requiresPollution)) {
        return 'If PDO selected, insurance/permit/fitness/pollution are mandatory.';
      }

      const requiredPdoDocs = {
        'Mulkiya Card',
        'RAS Inspection',
        'IVMS',
        'DFMS',
        'Speed Limiter',
        'Third Party Inspection',
      };
      final docNames =
          item.documentRequirements.map((entry) => entry.documentName).toSet();
      final hasAll = requiredPdoDocs.every(docNames.contains);
      if (!hasAll) {
        return 'PDO compliance documents are mandatory.';
      }
    }

    if (item.vehicleClass == 'Trailer') {
      final hasKingPin = item.documentRequirements.any(
        (entry) => entry.documentName == 'King Pin Certificate',
      );
      if (!hasKingPin) {
        return 'Trailer must include King Pin certificate.';
      }
    }

    final duplicateCode = existing
        .any((entry) => entry.code.toLowerCase() == item.code.toLowerCase());
    if (duplicateCode) {
      return 'Short code must be unique.';
    }

    final duplicateName = existing
        .any((entry) => entry.name.toLowerCase() == item.name.toLowerCase());
    if (duplicateName) {
      return 'Vehicle type name must be unique.';
    }

    return null;
  }
}

class VehicleTypeFormState {
  const VehicleTypeFormState({
    required this.initialized,
    required this.originalCode,
    required this.name,
    required this.code,
    required this.category,
    required this.vehicleClass,
    required this.ownershipTypes,
    required this.vendorRequired,
    required this.loadType,
    required this.transportType,
    required this.maxTripsPerDay,
    required this.allowMultiDayJourney,
    required this.allowMultipleStops,
    required this.maxStopsAllowed,
    required this.requireRoutePlanApproval,
    required this.isHazardous,
    required this.requiresSafetyCompliance,
    required this.temperatureControlled,
    required this.requiresEscortVehicle,
    required this.defaultCapacity,
    required this.capacityUnit,
    required this.features,
    required this.requiresInsurance,
    required this.requiresPermit,
    required this.requiresFitness,
    required this.requiresPollution,
    required this.complianceMode,
    required this.documentRequirements,
    required this.status,
    required this.isDefaultType,
  });

  final bool initialized;
  final String? originalCode;
  final String name;
  final String code;
  final String category;
  final String vehicleClass;
  final List<String> ownershipTypes;
  final bool vendorRequired;
  final String loadType;
  final String transportType;
  final String maxTripsPerDay;
  final bool allowMultiDayJourney;
  final bool allowMultipleStops;
  final String maxStopsAllowed;
  final bool requireRoutePlanApproval;
  final bool isHazardous;
  final bool requiresSafetyCompliance;
  final bool temperatureControlled;
  final bool requiresEscortVehicle;
  final String defaultCapacity;
  final String capacityUnit;
  final List<String> features;
  final bool requiresInsurance;
  final bool requiresPermit;
  final bool requiresFitness;
  final bool requiresPollution;
  final String complianceMode;
  final List<VehicleTypeDocumentRequirement> documentRequirements;
  final String status;
  final bool isDefaultType;

  bool get isEditMode => originalCode != null;

  VehicleType toEntity() {
    return VehicleType(
      name: name.trim(),
      code: code.trim(),
      category: category,
      vehicleClass: vehicleClass,
      ownershipTypes: ownershipTypes,
      vendorRequired: vendorRequired,
      loadType: loadType,
      transportType: transportType,
      maxTripsPerDay: int.tryParse(maxTripsPerDay.trim()) ?? 0,
      allowMultiDayJourney: allowMultiDayJourney,
      allowMultipleStops: allowMultipleStops,
      maxStopsAllowed: int.tryParse(maxStopsAllowed.trim()) ?? 0,
      requireRoutePlanApproval: requireRoutePlanApproval,
      isHazardous: isHazardous,
      requiresSafetyCompliance: requiresSafetyCompliance,
      temperatureControlled: temperatureControlled,
      requiresEscortVehicle: requiresEscortVehicle,
      defaultCapacity: double.tryParse(defaultCapacity.trim()) ?? 0,
      capacityUnit: capacityUnit,
      features: features,
      requiresInsurance: requiresInsurance,
      requiresPermit: requiresPermit,
      requiresFitness: requiresFitness,
      requiresPollution: requiresPollution,
      complianceMode: complianceMode,
      documentRequirements: documentRequirements,
      status: status,
      isDefaultType: isDefaultType,
    );
  }

  VehicleTypeFormState copyWith({
    bool? initialized,
    String? originalCode,
    bool clearOriginalCode = false,
    String? name,
    String? code,
    String? category,
    String? vehicleClass,
    List<String>? ownershipTypes,
    bool? vendorRequired,
    String? loadType,
    String? transportType,
    String? maxTripsPerDay,
    bool? allowMultiDayJourney,
    bool? allowMultipleStops,
    String? maxStopsAllowed,
    bool? requireRoutePlanApproval,
    bool? isHazardous,
    bool? requiresSafetyCompliance,
    bool? temperatureControlled,
    bool? requiresEscortVehicle,
    String? defaultCapacity,
    String? capacityUnit,
    List<String>? features,
    bool? requiresInsurance,
    bool? requiresPermit,
    bool? requiresFitness,
    bool? requiresPollution,
    String? complianceMode,
    List<VehicleTypeDocumentRequirement>? documentRequirements,
    String? status,
    bool? isDefaultType,
  }) {
    return VehicleTypeFormState(
      initialized: initialized ?? this.initialized,
      originalCode:
          clearOriginalCode ? null : (originalCode ?? this.originalCode),
      name: name ?? this.name,
      code: code ?? this.code,
      category: category ?? this.category,
      vehicleClass: vehicleClass ?? this.vehicleClass,
      ownershipTypes: ownershipTypes ?? this.ownershipTypes,
      vendorRequired: vendorRequired ?? this.vendorRequired,
      loadType: loadType ?? this.loadType,
      transportType: transportType ?? this.transportType,
      maxTripsPerDay: maxTripsPerDay ?? this.maxTripsPerDay,
      allowMultiDayJourney: allowMultiDayJourney ?? this.allowMultiDayJourney,
      allowMultipleStops: allowMultipleStops ?? this.allowMultipleStops,
      maxStopsAllowed: maxStopsAllowed ?? this.maxStopsAllowed,
      requireRoutePlanApproval:
          requireRoutePlanApproval ?? this.requireRoutePlanApproval,
      isHazardous: isHazardous ?? this.isHazardous,
      requiresSafetyCompliance:
          requiresSafetyCompliance ?? this.requiresSafetyCompliance,
      temperatureControlled:
          temperatureControlled ?? this.temperatureControlled,
      requiresEscortVehicle:
          requiresEscortVehicle ?? this.requiresEscortVehicle,
      defaultCapacity: defaultCapacity ?? this.defaultCapacity,
      capacityUnit: capacityUnit ?? this.capacityUnit,
      features: features ?? this.features,
      requiresInsurance: requiresInsurance ?? this.requiresInsurance,
      requiresPermit: requiresPermit ?? this.requiresPermit,
      requiresFitness: requiresFitness ?? this.requiresFitness,
      requiresPollution: requiresPollution ?? this.requiresPollution,
      complianceMode: complianceMode ?? this.complianceMode,
      documentRequirements: documentRequirements ?? this.documentRequirements,
      status: status ?? this.status,
      isDefaultType: isDefaultType ?? this.isDefaultType,
    );
  }
}

final vehicleTypeFormProvider =
    AutoDisposeNotifierProvider<VehicleTypeFormNotifier, VehicleTypeFormState>(
  VehicleTypeFormNotifier.new,
);

class VehicleTypeFormNotifier
    extends AutoDisposeNotifier<VehicleTypeFormState> {
  static const categories = [
    'Light Vehicle',
    'Heavy Vehicle',
    'Trailer',
    'Tanker',
  ];
  static const vehicleClasses = [
    'Dry Movers',
    'XXL',
    'XXXL',
    'Trailer',
    'Tanker',
  ];
  static const ownershipOptions = ['Company Owned', 'Vendor Owned'];
  static const loadTypes = ['PDO', 'NON-PDO'];
  static const transportTypes = ['Internal', 'External'];
  static const capacityUnits = ['KG', 'Tons', 'Liters'];
  static const statuses = ['Active', 'Inactive'];
  static const complianceModes = ['PDO', 'NON-PDO'];
  static const validityUnits = ['Months', 'Year'];
  static const applicableFor = ['PDO', 'Trailer', 'All'];
  static const featureOptions = [
    'GPS',
    'IVMS',
    'DFMS',
    'Refrigeration',
    'Speed Limiter',
  ];
  static const documentNameOptions = [
    'Mulkiya Card',
    'RAS Inspection',
    'IVMS',
    'DFMS',
    'Speed Limiter',
    'Third Party Inspection',
    'King Pin Certificate',
  ];

  static const _pdoAutoDocs = [
    ('Mulkiya Card', 1, 'Year', 'PDO'),
    ('RAS Inspection', 1, 'Year', 'PDO'),
    ('IVMS', 1, 'Year', 'PDO'),
    ('DFMS', 1, 'Year', 'PDO'),
    ('Speed Limiter', 1, 'Year', 'PDO'),
    ('Third Party Inspection', 6, 'Months', 'PDO'),
  ];

  static const _trailerAutoDocs = [
    ('Mulkiya Card', 1, 'Year', 'Trailer'),
    ('RAS Inspection', 1, 'Year', 'Trailer'),
    ('King Pin Certificate', 1, 'Year', 'Trailer'),
  ];

  @override
  VehicleTypeFormState build() {
    return const VehicleTypeFormState(
      initialized: false,
      originalCode: null,
      name: '',
      code: '',
      category: 'Heavy Vehicle',
      vehicleClass: 'Dry Movers',
      ownershipTypes: [],
      vendorRequired: false,
      loadType: 'NON-PDO',
      transportType: 'Internal',
      maxTripsPerDay: '1',
      allowMultiDayJourney: false,
      allowMultipleStops: true,
      maxStopsAllowed: '1',
      requireRoutePlanApproval: false,
      isHazardous: false,
      requiresSafetyCompliance: false,
      temperatureControlled: false,
      requiresEscortVehicle: false,
      defaultCapacity: '',
      capacityUnit: 'KG',
      features: [],
      requiresInsurance: true,
      requiresPermit: true,
      requiresFitness: true,
      requiresPollution: true,
      complianceMode: 'NON-PDO',
      documentRequirements: [],
      status: 'Active',
      isDefaultType: false,
    );
  }

  void initialize(VehicleType? item) {
    if (state.initialized) {
      return;
    }

    if (item == null) {
      state = state.copyWith(initialized: true, clearOriginalCode: true);
      return;
    }

    state = VehicleTypeFormState(
      initialized: true,
      originalCode: item.code,
      name: item.name,
      code: item.code,
      category: item.category,
      vehicleClass: item.vehicleClass,
      ownershipTypes: item.ownershipTypes,
      vendorRequired: item.vendorRequired,
      loadType: item.loadType,
      transportType: item.transportType,
      maxTripsPerDay: item.maxTripsPerDay.toString(),
      allowMultiDayJourney: item.allowMultiDayJourney,
      allowMultipleStops: item.allowMultipleStops,
      maxStopsAllowed: item.maxStopsAllowed.toString(),
      requireRoutePlanApproval: item.requireRoutePlanApproval,
      isHazardous: item.isHazardous,
      requiresSafetyCompliance: item.requiresSafetyCompliance,
      temperatureControlled: item.temperatureControlled,
      requiresEscortVehicle: item.requiresEscortVehicle,
      defaultCapacity: item.defaultCapacity.toString(),
      capacityUnit: item.capacityUnit,
      features: item.features,
      requiresInsurance: item.requiresInsurance,
      requiresPermit: item.requiresPermit,
      requiresFitness: item.requiresFitness,
      requiresPollution: item.requiresPollution,
      complianceMode: item.complianceMode,
      documentRequirements: item.documentRequirements,
      status: item.status,
      isDefaultType: item.isDefaultType,
    );
    _applyAutoDocuments();
  }

  void setName(String value) => state = state.copyWith(name: value);

  void setCode(String value) => state = state.copyWith(code: value);

  void setCategory(String value) => state = state.copyWith(category: value);

  void setVehicleClass(String value) {
    state = state.copyWith(vehicleClass: value);
    _applyAutoDocuments();
  }

  void toggleOwnershipType(String value) {
    final next = List<String>.from(state.ownershipTypes);
    if (next.contains(value)) {
      next.remove(value);
    } else {
      next.add(value);
    }

    final vendorOwned = next.contains('Vendor Owned');
    state = state.copyWith(
      ownershipTypes: next,
      vendorRequired: vendorOwned ? state.vendorRequired : false,
    );
  }

  void setVendorRequired(bool value) {
    if (!state.ownershipTypes.contains('Vendor Owned')) {
      return;
    }
    state = state.copyWith(vendorRequired: value);
  }

  void setLoadType(String value) {
    var next = state.copyWith(loadType: value);
    if (value == 'PDO') {
      next = next.copyWith(
        complianceMode: 'PDO',
        requiresInsurance: true,
        requiresPermit: true,
        requiresFitness: true,
        requiresPollution: true,
      );
    }
    state = next;
    _applyAutoDocuments();
  }

  void setTransportType(String value) =>
      state = state.copyWith(transportType: value);

  void setMaxTripsPerDay(String value) =>
      state = state.copyWith(maxTripsPerDay: value);

  void setAllowMultiDayJourney(bool value) =>
      state = state.copyWith(allowMultiDayJourney: value);

  void setAllowMultipleStops(bool value) =>
      state = state.copyWith(allowMultipleStops: value);

  void setMaxStopsAllowed(String value) =>
      state = state.copyWith(maxStopsAllowed: value);

  void setRequireRoutePlanApproval(bool value) =>
      state = state.copyWith(requireRoutePlanApproval: value);

  void setIsHazardous(bool value) => state = state.copyWith(isHazardous: value);

  void setRequiresSafetyCompliance(bool value) =>
      state = state.copyWith(requiresSafetyCompliance: value);

  void setTemperatureControlled(bool value) =>
      state = state.copyWith(temperatureControlled: value);

  void setRequiresEscortVehicle(bool value) =>
      state = state.copyWith(requiresEscortVehicle: value);

  void setDefaultCapacity(String value) =>
      state = state.copyWith(defaultCapacity: value);

  void setCapacityUnit(String value) => state = state.copyWith(capacityUnit: value);

  void toggleFeature(String feature) {
    final next = List<String>.from(state.features);
    if (next.contains(feature)) {
      next.remove(feature);
    } else {
      next.add(feature);
    }
    state = state.copyWith(features: next);
  }

  void setRequiresInsurance(bool value) =>
      state = state.copyWith(requiresInsurance: value);

  void setRequiresPermit(bool value) => state = state.copyWith(requiresPermit: value);

  void setRequiresFitness(bool value) =>
      state = state.copyWith(requiresFitness: value);

  void setRequiresPollution(bool value) =>
      state = state.copyWith(requiresPollution: value);

  void setComplianceMode(String value) => state = state.copyWith(complianceMode: value);

  void addDocumentRequirement() {
    final next = List<VehicleTypeDocumentRequirement>.from(
      state.documentRequirements,
    );
    next.add(
      const VehicleTypeDocumentRequirement(
        documentName: 'Mulkiya Card',
        mandatory: true,
        validityValue: 1,
        validityUnit: 'Year',
        applicableFor: 'All',
      ),
    );
    state = state.copyWith(documentRequirements: next);
  }

  void removeDocumentRequirement(int index) {
    if (index < 0 || index >= state.documentRequirements.length) {
      return;
    }
    final next = List<VehicleTypeDocumentRequirement>.from(
      state.documentRequirements,
    );
    next.removeAt(index);
    state = state.copyWith(documentRequirements: next);
  }

  void updateDocumentRequirementName(int index, String value) {
    _updateDocumentRequirement(index, (entry) => entry.copyWith(documentName: value));
  }

  void updateDocumentRequirementMandatory(int index, bool value) {
    _updateDocumentRequirement(index, (entry) => entry.copyWith(mandatory: value));
  }

  void updateDocumentRequirementValidityValue(int index, String value) {
    final parsed = int.tryParse(value.trim()) ?? 0;
    _updateDocumentRequirement(
      index,
      (entry) => entry.copyWith(validityValue: parsed),
    );
  }

  void updateDocumentRequirementValidityUnit(int index, String value) {
    _updateDocumentRequirement(index, (entry) => entry.copyWith(validityUnit: value));
  }

  void updateDocumentRequirementApplicableFor(int index, String value) {
    _updateDocumentRequirement(index, (entry) => entry.copyWith(applicableFor: value));
  }

  void setStatus(String value) => state = state.copyWith(status: value);

  void setIsDefaultType(bool value) => state = state.copyWith(isDefaultType: value);

  void _updateDocumentRequirement(
    int index,
    VehicleTypeDocumentRequirement Function(VehicleTypeDocumentRequirement) update,
  ) {
    if (index < 0 || index >= state.documentRequirements.length) {
      return;
    }
    final next = List<VehicleTypeDocumentRequirement>.from(
      state.documentRequirements,
    );
    next[index] = update(next[index]);
    state = state.copyWith(documentRequirements: next);
  }

  void _applyAutoDocuments() {
    var next = List<VehicleTypeDocumentRequirement>.from(
      state.documentRequirements,
    );

    if (state.loadType == 'PDO') {
      for (final doc in _pdoAutoDocs) {
        next = _ensureDocument(
          next,
          VehicleTypeDocumentRequirement(
            documentName: doc.$1,
            mandatory: true,
            validityValue: doc.$2,
            validityUnit: doc.$3,
            applicableFor: doc.$4,
          ),
        );
      }
    }

    if (state.vehicleClass == 'Trailer') {
      for (final doc in _trailerAutoDocs) {
        next = _ensureDocument(
          next,
          VehicleTypeDocumentRequirement(
            documentName: doc.$1,
            mandatory: true,
            validityValue: doc.$2,
            validityUnit: doc.$3,
            applicableFor: doc.$4,
          ),
        );
      }
    }

    state = state.copyWith(documentRequirements: next);
  }

  List<VehicleTypeDocumentRequirement> _ensureDocument(
    List<VehicleTypeDocumentRequirement> source,
    VehicleTypeDocumentRequirement entry,
  ) {
    final exists = source.any((item) => item.documentName == entry.documentName);
    if (exists) {
      return source;
    }
    return [entry, ...source];
  }
}
