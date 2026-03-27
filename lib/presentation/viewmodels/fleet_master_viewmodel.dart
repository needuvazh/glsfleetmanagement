import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/fleet_master_mock_datasource.dart';
import '../../data/fleet_master_repository.dart';
import '../../data/vehicle_type_master_mock_datasource.dart';
import '../../data/vehicle_type_master_repository.dart';
import '../../data/vendor_mock_datasource.dart';
import '../../domain/fleet_master_model.dart';
import '../../domain/vehicle_type_master_model.dart';
import '../../domain/vendor_model.dart';

class FleetMasterUiState {
  const FleetMasterUiState({
    required this.fleets,
    required this.vehicleTypes,
    required this.vendors,
    required this.searchQuery,
    required this.availabilityFilter,
    required this.complianceFilter,
    required this.statusFilter,
    required this.lastUpdated,
  });

  final List<FleetMasterModel> fleets;
  final List<VehicleTypeMasterModel> vehicleTypes;
  final List<VendorModel> vendors;
  final String searchQuery;
  final AvailabilityStatusType? availabilityFilter;
  final ComplianceIndicatorType? complianceFilter;
  final RecordStatusType? statusFilter;
  final DateTime lastUpdated;

  VehicleTypeMasterModel? vehicleTypeFor(String vehicleTypeId) {
    for (final item in vehicleTypes) {
      if (item.vehicleTypeId == vehicleTypeId) {
        return item;
      }
    }
    return null;
  }

  VendorModel? vendorFor(String vendorId) {
    for (final item in vendors) {
      if (item.vendorId == vendorId) {
        return item;
      }
    }
    return null;
  }

  List<FleetMasterModel> get filteredFleets {
    final query = searchQuery.trim().toLowerCase();
    final now = DateTime.now();
    return fleets.where((fleet) {
      if (availabilityFilter != null &&
          fleet.availabilityStatus != availabilityFilter) {
        return false;
      }
      if (statusFilter != null && fleet.status != statusFilter) {
        return false;
      }
      if (complianceFilter != null &&
          fleet.overallCompliance(now) != complianceFilter) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final vehicleType = vehicleTypeFor(fleet.vehicleTypeId);
      final vendor = vendorFor(fleet.vendorId);
      final text = [
        fleet.fleetId,
        fleet.fleetNumber,
        fleet.registrationNumber,
        vehicleType?.vehicleTypeName ?? '',
        vendor?.vendorName ?? '',
      ].join(' ').toLowerCase();
      return text.contains(query);
    }).toList();
  }

  FleetMasterUiState copyWith({
    List<FleetMasterModel>? fleets,
    List<VehicleTypeMasterModel>? vehicleTypes,
    List<VendorModel>? vendors,
    String? searchQuery,
    AvailabilityStatusType? availabilityFilter,
    bool clearAvailabilityFilter = false,
    ComplianceIndicatorType? complianceFilter,
    bool clearComplianceFilter = false,
    RecordStatusType? statusFilter,
    bool clearStatusFilter = false,
    DateTime? lastUpdated,
  }) {
    return FleetMasterUiState(
      fleets: fleets ?? this.fleets,
      vehicleTypes: vehicleTypes ?? this.vehicleTypes,
      vendors: vendors ?? this.vendors,
      searchQuery: searchQuery ?? this.searchQuery,
      availabilityFilter: clearAvailabilityFilter
          ? null
          : (availabilityFilter ?? this.availabilityFilter),
      complianceFilter: clearComplianceFilter
          ? null
          : (complianceFilter ?? this.complianceFilter),
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final _fleetMasterDataSourceProvider = Provider<FleetMasterMockDataSource>(
  (ref) => FleetMasterMockDataSourceImpl(),
);

final _fleetMasterRepositoryProvider = Provider<FleetMasterRepository>(
  (ref) => FleetMasterRepositoryImpl(
    dataSource: ref.watch(_fleetMasterDataSourceProvider),
  ),
);

final _vehicleTypeMasterDataSourceForFleetProvider =
    Provider<VehicleTypeMasterMockDataSource>(
  (ref) => VehicleTypeMasterMockDataSourceImpl(),
);

final _vehicleTypeMasterRepositoryForFleetProvider =
    Provider<VehicleTypeMasterRepository>(
  (ref) => VehicleTypeMasterRepositoryImpl(
    dataSource: ref.watch(_vehicleTypeMasterDataSourceForFleetProvider),
  ),
);

final _vendorDataSourceForFleetProvider = Provider<VendorMockDataSource>(
  (ref) => VendorMockDataSourceImpl(),
);

final fleetMasterViewModelProvider =
    AsyncNotifierProvider<FleetMasterViewModel, FleetMasterUiState>(
  FleetMasterViewModel.new,
);

class FleetMasterViewModel extends AsyncNotifier<FleetMasterUiState> {
  @override
  Future<FleetMasterUiState> build() async {
    final fleets = await ref.watch(_fleetMasterRepositoryProvider).getFleets();
    final vehicleTypes = await ref
        .watch(_vehicleTypeMasterRepositoryForFleetProvider)
        .getVehicleTypes();
    final vendors =
        await ref.watch(_vendorDataSourceForFleetProvider).getVendors();

    return FleetMasterUiState(
      fleets: fleets,
      vehicleTypes: vehicleTypes,
      vendors: vendors.where((entry) => entry.isActive).toList(),
      searchQuery: '',
      availabilityFilter: null,
      complianceFilter: null,
      statusFilter: null,
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

  void setAvailabilityFilter(AvailabilityStatusType? value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(
      current.copyWith(
        availabilityFilter: value,
        clearAvailabilityFilter: value == null,
      ),
    );
  }

  void setComplianceFilter(ComplianceIndicatorType? value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(
      current.copyWith(
        complianceFilter: value,
        clearComplianceFilter: value == null,
      ),
    );
  }

  void setStatusFilter(RecordStatusType? value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(
      current.copyWith(
        statusFilter: value,
        clearStatusFilter: value == null,
      ),
    );
  }

  Future<String> addFleet(FleetMasterModel item) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Fleet state is not ready.';
    }
    final validation = _validate(item, current);
    if (validation != null) {
      return validation;
    }
    final fleets =
        await ref.read(_fleetMasterRepositoryProvider).addFleet(item);
    state = AsyncData(
      current.copyWith(fleets: fleets, lastUpdated: DateTime.now()),
    );
    return 'Fleet created successfully.';
  }

  Future<String> updateFleet(FleetMasterModel item) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Fleet state is not ready.';
    }
    final validation = _validate(
      item,
      current,
      others: current.fleets
          .where((entry) => entry.fleetId != item.fleetId)
          .toList(),
    );
    if (validation != null) {
      return validation;
    }
    final fleets =
        await ref.read(_fleetMasterRepositoryProvider).updateFleet(item);
    state = AsyncData(
      current.copyWith(fleets: fleets, lastUpdated: DateTime.now()),
    );
    return 'Fleet updated successfully.';
  }

  Future<String> deleteFleet(String fleetId) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Fleet state is not ready.';
    }
    final exists = current.fleets.any((entry) => entry.fleetId == fleetId);
    if (!exists) {
      return 'Fleet not found.';
    }

    final fleets =
        await ref.read(_fleetMasterRepositoryProvider).deleteFleet(fleetId);
    state = AsyncData(
      current.copyWith(fleets: fleets, lastUpdated: DateTime.now()),
    );
    return 'Fleet deleted successfully.';
  }

  String? _validate(
    FleetMasterModel item,
    FleetMasterUiState state, {
    List<FleetMasterModel>? others,
  }) {
    final existing = others ?? state.fleets;
    if (item.fleetNumber.trim().isEmpty) {
      return 'Fleet number is required.';
    }
    if (item.registrationNumber.trim().isEmpty) {
      return 'Registration number is required.';
    }
    if (_isPastOrToday(item.registrationExpiryDate) ||
        _isPastOrToday(item.insuranceExpiryDate) ||
        _isPastOrToday(item.permitExpiryDate) ||
        _isPastOrToday(item.rasExpiryDate) ||
        _isPastOrToday(item.inspectionDueDate)) {
      return 'All compliance expiry dates must be future dates.';
    }
    final duplicateFleetNumber = existing.any(
      (entry) =>
          entry.fleetNumber.toLowerCase() == item.fleetNumber.toLowerCase(),
    );
    if (duplicateFleetNumber) {
      return 'Fleet number must be unique.';
    }
    final duplicateRegistration = existing.any(
      (entry) =>
          entry.registrationNumber.toLowerCase() ==
          item.registrationNumber.toLowerCase(),
    );
    if (duplicateRegistration) {
      return 'Registration number must be unique.';
    }
    if (item.ownershipType != OwnershipType.owned &&
        item.vendorId.trim().isEmpty) {
      return 'Vendor is required for leased or contracted fleet.';
    }
    final vehicleType = state.vehicleTypeFor(item.vehicleTypeId);
    if (vehicleType == null) {
      return 'Vehicle Type selection is required.';
    }
    return null;
  }

  bool _isPastOrToday(DateTime value) {
    final now = DateTime.now();
    final currentDay = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(value.year, value.month, value.day);
    return !targetDay.isAfter(currentDay);
  }
}

class FleetMasterFormState {
  const FleetMasterFormState({
    required this.initialized,
    required this.fleetId,
    required this.fleetNumber,
    required this.vehicleTypeId,
    required this.ownershipType,
    required this.status,
    required this.registrationNumber,
    required this.registrationExpiryDate,
    required this.insuranceExpiryDate,
    required this.permitExpiryDate,
    required this.rasExpiryDate,
    required this.inspectionDueDate,
    required this.ivmsInstalled,
    required this.dfmsInstalled,
    required this.capacityOverride,
    required this.axleType,
    required this.fuelType,
    required this.bodyType,
    required this.availabilityStatus,
    required this.maintenanceStatus,
    required this.currentTripId,
    required this.vendorId,
    required this.createdBy,
    required this.updatedBy,
  });

  final bool initialized;
  final String? fleetId;
  final String fleetNumber;
  final String vehicleTypeId;
  final OwnershipType ownershipType;
  final RecordStatusType status;
  final String registrationNumber;
  final DateTime? registrationExpiryDate;
  final DateTime? insuranceExpiryDate;
  final DateTime? permitExpiryDate;
  final DateTime? rasExpiryDate;
  final DateTime? inspectionDueDate;
  final bool ivmsInstalled;
  final bool dfmsInstalled;
  final String capacityOverride;
  final AxleType axleType;
  final FuelType fuelType;
  final BodyType bodyType;
  final AvailabilityStatusType availabilityStatus;
  final MaintenanceStatusType maintenanceStatus;
  final String currentTripId;
  final String vendorId;
  final String createdBy;
  final String updatedBy;

  bool get isEditMode => fleetId != null;

  FleetMasterModel toModel() {
    final now = DateTime.now();
    return FleetMasterModel(
      fleetId: fleetId ?? '',
      fleetNumber: fleetNumber.trim(),
      vehicleTypeId: vehicleTypeId,
      ownershipType: ownershipType,
      status: status,
      registrationNumber: registrationNumber.trim(),
      registrationExpiryDate: registrationExpiryDate ?? now,
      insuranceExpiryDate: insuranceExpiryDate ?? now,
      permitExpiryDate: permitExpiryDate ?? now,
      rasExpiryDate: rasExpiryDate ?? now,
      inspectionDueDate: inspectionDueDate ?? now,
      ivmsInstalled: ivmsInstalled,
      dfmsInstalled: dfmsInstalled,
      capacityOverride: _optionalDouble(capacityOverride),
      axleType: axleType,
      fuelType: fuelType,
      bodyType: bodyType,
      availabilityStatus: availabilityStatus,
      maintenanceStatus: maintenanceStatus,
      currentTripId: currentTripId.trim(),
      vendorId: vendorId.trim(),
      createdAt: now,
      createdBy: createdBy.trim().isEmpty ? 'system' : createdBy.trim(),
      updatedAt: now,
      updatedBy: updatedBy.trim().isEmpty ? 'system' : updatedBy.trim(),
    );
  }

  FleetMasterFormState copyWith({
    bool? initialized,
    String? fleetId,
    bool clearFleetId = false,
    String? fleetNumber,
    String? vehicleTypeId,
    OwnershipType? ownershipType,
    RecordStatusType? status,
    String? registrationNumber,
    DateTime? registrationExpiryDate,
    DateTime? insuranceExpiryDate,
    DateTime? permitExpiryDate,
    DateTime? rasExpiryDate,
    DateTime? inspectionDueDate,
    bool? ivmsInstalled,
    bool? dfmsInstalled,
    String? capacityOverride,
    AxleType? axleType,
    FuelType? fuelType,
    BodyType? bodyType,
    AvailabilityStatusType? availabilityStatus,
    MaintenanceStatusType? maintenanceStatus,
    String? currentTripId,
    String? vendorId,
    String? createdBy,
    String? updatedBy,
  }) {
    return FleetMasterFormState(
      initialized: initialized ?? this.initialized,
      fleetId: clearFleetId ? null : (fleetId ?? this.fleetId),
      fleetNumber: fleetNumber ?? this.fleetNumber,
      vehicleTypeId: vehicleTypeId ?? this.vehicleTypeId,
      ownershipType: ownershipType ?? this.ownershipType,
      status: status ?? this.status,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      registrationExpiryDate:
          registrationExpiryDate ?? this.registrationExpiryDate,
      insuranceExpiryDate: insuranceExpiryDate ?? this.insuranceExpiryDate,
      permitExpiryDate: permitExpiryDate ?? this.permitExpiryDate,
      rasExpiryDate: rasExpiryDate ?? this.rasExpiryDate,
      inspectionDueDate: inspectionDueDate ?? this.inspectionDueDate,
      ivmsInstalled: ivmsInstalled ?? this.ivmsInstalled,
      dfmsInstalled: dfmsInstalled ?? this.dfmsInstalled,
      capacityOverride: capacityOverride ?? this.capacityOverride,
      axleType: axleType ?? this.axleType,
      fuelType: fuelType ?? this.fuelType,
      bodyType: bodyType ?? this.bodyType,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      maintenanceStatus: maintenanceStatus ?? this.maintenanceStatus,
      currentTripId: currentTripId ?? this.currentTripId,
      vendorId: vendorId ?? this.vendorId,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  static double? _optionalDouble(String value) {
    final raw = value.trim();
    if (raw.isEmpty) {
      return null;
    }
    return double.tryParse(raw);
  }
}

final fleetMasterFormProvider =
    AutoDisposeNotifierProvider<FleetMasterFormNotifier, FleetMasterFormState>(
  FleetMasterFormNotifier.new,
);

class FleetMasterFormNotifier
    extends AutoDisposeNotifier<FleetMasterFormState> {
  @override
  FleetMasterFormState build() {
    return const FleetMasterFormState(
      initialized: false,
      fleetId: null,
      fleetNumber: '',
      vehicleTypeId: '',
      ownershipType: OwnershipType.owned,
      status: RecordStatusType.active,
      registrationNumber: '',
      registrationExpiryDate: null,
      insuranceExpiryDate: null,
      permitExpiryDate: null,
      rasExpiryDate: null,
      inspectionDueDate: null,
      ivmsInstalled: false,
      dfmsInstalled: false,
      capacityOverride: '',
      axleType: AxleType.axle4x2,
      fuelType: FuelType.diesel,
      bodyType: BodyType.flatbed,
      availabilityStatus: AvailabilityStatusType.available,
      maintenanceStatus: MaintenanceStatusType.operational,
      currentTripId: '',
      vendorId: '',
      createdBy: 'fleet.admin',
      updatedBy: 'fleet.admin',
    );
  }

  void initialize(
    FleetMasterModel? item,
    List<VehicleTypeMasterModel> vehicleTypes,
  ) {
    if (state.initialized) {
      return;
    }
    if (item == null) {
      final firstTypeId =
          vehicleTypes.isEmpty ? '' : vehicleTypes.first.vehicleTypeId;
      state = state.copyWith(
        initialized: true,
        clearFleetId: true,
        vehicleTypeId: firstTypeId,
      );
      if (vehicleTypes.isNotEmpty) {
        _applyVehicleType(vehicleTypes.first, replaceCapacity: false);
      }
      return;
    }
    state = FleetMasterFormState(
      initialized: true,
      fleetId: item.fleetId,
      fleetNumber: item.fleetNumber,
      vehicleTypeId: item.vehicleTypeId,
      ownershipType: item.ownershipType,
      status: item.status,
      registrationNumber: item.registrationNumber,
      registrationExpiryDate: item.registrationExpiryDate,
      insuranceExpiryDate: item.insuranceExpiryDate,
      permitExpiryDate: item.permitExpiryDate,
      rasExpiryDate: item.rasExpiryDate,
      inspectionDueDate: item.inspectionDueDate,
      ivmsInstalled: item.ivmsInstalled,
      dfmsInstalled: item.dfmsInstalled,
      capacityOverride: item.capacityOverride?.toString() ?? '',
      axleType: item.axleType,
      fuelType: item.fuelType,
      bodyType: item.bodyType,
      availabilityStatus: item.availabilityStatus,
      maintenanceStatus: item.maintenanceStatus,
      currentTripId: item.currentTripId,
      vendorId: item.vendorId,
      createdBy: item.createdBy,
      updatedBy: item.updatedBy,
    );
  }

  void setFleetNumber(String value) =>
      state = state.copyWith(fleetNumber: value);
  void setOwnershipType(OwnershipType value) =>
      state = state.copyWith(ownershipType: value);
  void setStatus(RecordStatusType value) =>
      state = state.copyWith(status: value);
  void setRegistrationNumber(String value) =>
      state = state.copyWith(registrationNumber: value);
  void setRegistrationExpiryDate(DateTime value) =>
      state = state.copyWith(registrationExpiryDate: value);
  void setInsuranceExpiryDate(DateTime value) =>
      state = state.copyWith(insuranceExpiryDate: value);
  void setPermitExpiryDate(DateTime value) =>
      state = state.copyWith(permitExpiryDate: value);
  void setRasExpiryDate(DateTime value) =>
      state = state.copyWith(rasExpiryDate: value);
  void setInspectionDueDate(DateTime value) =>
      state = state.copyWith(inspectionDueDate: value);
  void setIvmsInstalled(bool value) =>
      state = state.copyWith(ivmsInstalled: value);
  void setDfmsInstalled(bool value) =>
      state = state.copyWith(dfmsInstalled: value);
  void setCapacityOverride(String value) =>
      state = state.copyWith(capacityOverride: value);
  void setAvailabilityStatus(AvailabilityStatusType value) =>
      state = state.copyWith(availabilityStatus: value);
  void setMaintenanceStatus(MaintenanceStatusType value) =>
      state = state.copyWith(maintenanceStatus: value);
  void setCurrentTripId(String value) =>
      state = state.copyWith(currentTripId: value);
  void setVendorId(String value) => state = state.copyWith(vendorId: value);
  void setCreatedBy(String value) => state = state.copyWith(createdBy: value);
  void setUpdatedBy(String value) => state = state.copyWith(updatedBy: value);

  void setVehicleType(
    String vehicleTypeId,
    List<VehicleTypeMasterModel> vehicleTypes,
  ) {
    state = state.copyWith(vehicleTypeId: vehicleTypeId);
    for (final item in vehicleTypes) {
      if (item.vehicleTypeId == vehicleTypeId) {
        _applyVehicleType(item, replaceCapacity: false);
        break;
      }
    }
  }

  void _applyVehicleType(
    VehicleTypeMasterModel item, {
    required bool replaceCapacity,
  }) {
    final autoCapacity = item.vehicleCategory == VehicleCategoryType.passenger
        ? '${item.seatingCapacity}'
        : '${item.loadCapacity}';
    state = state.copyWith(
      axleType: item.axleType,
      fuelType: item.fuelType,
      bodyType: item.bodyType,
      capacityOverride: replaceCapacity || state.capacityOverride.trim().isEmpty
          ? autoCapacity
          : state.capacityOverride,
    );
  }
}
