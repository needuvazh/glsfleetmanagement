import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/vehicle_type_master_mock_datasource.dart';
import '../../data/vehicle_type_master_repository.dart';
import '../../domain/vehicle_type_master_model.dart';

class VehicleTypeMasterUiState {
  const VehicleTypeMasterUiState({
    required this.items,
    required this.searchQuery,
    required this.categoryFilter,
    required this.statusFilter,
    required this.lastUpdated,
  });

  final List<VehicleTypeMasterModel> items;
  final String searchQuery;
  final VehicleCategoryType? categoryFilter;
  final RecordStatusType? statusFilter;
  final DateTime lastUpdated;

  List<VehicleTypeMasterModel> get filteredItems {
    final query = searchQuery.trim().toLowerCase();
    return items.where((item) {
      if (categoryFilter != null && item.vehicleCategory != categoryFilter) {
        return false;
      }
      if (statusFilter != null && item.status != statusFilter) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final text = [
        item.vehicleTypeId,
        item.vehicleTypeName,
        item.vehicleCategory.label,
        item.bodyType.label,
        item.axleType.label,
      ].join(' ').toLowerCase();
      return text.contains(query);
    }).toList();
  }

  VehicleTypeMasterUiState copyWith({
    List<VehicleTypeMasterModel>? items,
    String? searchQuery,
    VehicleCategoryType? categoryFilter,
    bool clearCategoryFilter = false,
    RecordStatusType? statusFilter,
    bool clearStatusFilter = false,
    DateTime? lastUpdated,
  }) {
    return VehicleTypeMasterUiState(
      items: items ?? this.items,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter:
          clearCategoryFilter ? null : (categoryFilter ?? this.categoryFilter),
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final _vehicleTypeMasterDataSourceProvider =
    Provider<VehicleTypeMasterMockDataSource>(
  (ref) => VehicleTypeMasterMockDataSourceImpl(),
);

final _vehicleTypeMasterRepositoryProvider =
    Provider<VehicleTypeMasterRepository>(
  (ref) => VehicleTypeMasterRepositoryImpl(
    dataSource: ref.watch(_vehicleTypeMasterDataSourceProvider),
  ),
);

final vehicleTypeMasterViewModelProvider =
    AsyncNotifierProvider<VehicleTypeMasterViewModel, VehicleTypeMasterUiState>(
  VehicleTypeMasterViewModel.new,
);

class VehicleTypeMasterViewModel
    extends AsyncNotifier<VehicleTypeMasterUiState> {
  @override
  Future<VehicleTypeMasterUiState> build() async {
    final items =
        await ref.watch(_vehicleTypeMasterRepositoryProvider).getVehicleTypes();
    return VehicleTypeMasterUiState(
      items: items,
      searchQuery: '',
      categoryFilter: null,
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

  void setCategoryFilter(VehicleCategoryType? value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(
      current.copyWith(
        categoryFilter: value,
        clearCategoryFilter: value == null,
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

  Future<String> addVehicleType(VehicleTypeMasterModel item) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Vehicle Type state is not ready.';
    }
    final validation = _validate(item, current.items);
    if (validation != null) {
      return validation;
    }
    final items =
        await ref.read(_vehicleTypeMasterRepositoryProvider).addVehicleType(item);
    state = AsyncData(
      current.copyWith(items: items, lastUpdated: DateTime.now()),
    );
    return 'Vehicle Type created successfully.';
  }

  Future<String> updateVehicleType(VehicleTypeMasterModel item) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Vehicle Type state is not ready.';
    }
    final others = current.items
        .where((entry) => entry.vehicleTypeId != item.vehicleTypeId)
        .toList();
    final validation = _validate(item, others);
    if (validation != null) {
      return validation;
    }
    final items = await ref
        .read(_vehicleTypeMasterRepositoryProvider)
        .updateVehicleType(item);
    state = AsyncData(
      current.copyWith(items: items, lastUpdated: DateTime.now()),
    );
    return 'Vehicle Type updated successfully.';
  }

  String? _validate(
    VehicleTypeMasterModel item,
    List<VehicleTypeMasterModel> existing,
  ) {
    if (item.vehicleTypeName.trim().isEmpty) {
      return 'Vehicle Type name is required.';
    }
    if (item.baseFarePerKm < 0 || item.baseFarePerHour < 0) {
      return 'Fare values cannot be negative.';
    }
    if (item.mileage <= 0) {
      return 'Mileage must be greater than zero.';
    }
    if (item.vehicleCategory == VehicleCategoryType.passenger &&
        item.seatingCapacity <= 0) {
      return 'Seating capacity is required for passenger vehicle types.';
    }
    if (item.vehicleCategory == VehicleCategoryType.goods &&
        item.loadCapacity <= 0) {
      return 'Load capacity is required for goods vehicle types.';
    }
    final duplicateName = existing.any(
      (entry) =>
          entry.vehicleTypeName.toLowerCase() ==
          item.vehicleTypeName.toLowerCase(),
    );
    if (duplicateName) {
      return 'Vehicle Type name already exists.';
    }
    return null;
  }
}

class VehicleTypeMasterFormState {
  const VehicleTypeMasterFormState({
    required this.initialized,
    required this.vehicleTypeId,
    required this.vehicleTypeName,
    required this.vehicleCategory,
    required this.description,
    required this.seatingCapacity,
    required this.loadCapacity,
    required this.axleType,
    required this.bodyType,
    required this.fuelType,
    required this.transmissionType,
    required this.acType,
    required this.baseFarePerKm,
    required this.baseFarePerHour,
    required this.mileage,
    required this.maxTripDistance,
    required this.maxDrivingHoursPerDay,
    required this.documents,
    required this.status,
  });

  final bool initialized;
  final String? vehicleTypeId;
  final String vehicleTypeName;
  final VehicleCategoryType vehicleCategory;
  final String description;
  final String seatingCapacity;
  final String loadCapacity;
  final AxleType axleType;
  final BodyType bodyType;
  final FuelType fuelType;
  final TransmissionType transmissionType;
  final AcType acType;
  final String baseFarePerKm;
  final String baseFarePerHour;
  final String mileage;
  final String maxTripDistance;
  final String maxDrivingHoursPerDay;
  final List<VehicleTypeTemplateDocument> documents;
  final RecordStatusType status;

  bool get isEditMode => vehicleTypeId != null;

  VehicleTypeMasterModel toModel() {
    return VehicleTypeMasterModel(
      vehicleTypeId: vehicleTypeId ?? '',
      vehicleTypeName: vehicleTypeName.trim(),
      vehicleCategory: vehicleCategory,
      description: description.trim(),
      seatingCapacity: int.tryParse(seatingCapacity.trim()) ?? 0,
      loadCapacity: double.tryParse(loadCapacity.trim()) ?? 0,
      axleType: axleType,
      bodyType: bodyType,
      fuelType: fuelType,
      transmissionType: transmissionType,
      acType: acType,
      baseFarePerKm: double.tryParse(baseFarePerKm.trim()) ?? 0,
      baseFarePerHour: double.tryParse(baseFarePerHour.trim()) ?? 0,
      mileage: double.tryParse(mileage.trim()) ?? 0,
      maxTripDistance: _optionalDouble(maxTripDistance),
      maxDrivingHoursPerDay: _optionalDouble(maxDrivingHoursPerDay),
      documents: documents,
      status: status,
    );
  }

  VehicleTypeMasterFormState copyWith({
    bool? initialized,
    String? vehicleTypeId,
    bool clearVehicleTypeId = false,
    String? vehicleTypeName,
    VehicleCategoryType? vehicleCategory,
    String? description,
    String? seatingCapacity,
    String? loadCapacity,
    AxleType? axleType,
    BodyType? bodyType,
    FuelType? fuelType,
    TransmissionType? transmissionType,
    AcType? acType,
    String? baseFarePerKm,
    String? baseFarePerHour,
    String? mileage,
    String? maxTripDistance,
    String? maxDrivingHoursPerDay,
    List<VehicleTypeTemplateDocument>? documents,
    RecordStatusType? status,
  }) {
    return VehicleTypeMasterFormState(
      initialized: initialized ?? this.initialized,
      vehicleTypeId:
          clearVehicleTypeId ? null : (vehicleTypeId ?? this.vehicleTypeId),
      vehicleTypeName: vehicleTypeName ?? this.vehicleTypeName,
      vehicleCategory: vehicleCategory ?? this.vehicleCategory,
      description: description ?? this.description,
      seatingCapacity: seatingCapacity ?? this.seatingCapacity,
      loadCapacity: loadCapacity ?? this.loadCapacity,
      axleType: axleType ?? this.axleType,
      bodyType: bodyType ?? this.bodyType,
      fuelType: fuelType ?? this.fuelType,
      transmissionType: transmissionType ?? this.transmissionType,
      acType: acType ?? this.acType,
      baseFarePerKm: baseFarePerKm ?? this.baseFarePerKm,
      baseFarePerHour: baseFarePerHour ?? this.baseFarePerHour,
      mileage: mileage ?? this.mileage,
      maxTripDistance: maxTripDistance ?? this.maxTripDistance,
      maxDrivingHoursPerDay:
          maxDrivingHoursPerDay ?? this.maxDrivingHoursPerDay,
      documents: documents ?? this.documents,
      status: status ?? this.status,
    );
  }

  static double? _optionalDouble(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return double.tryParse(trimmed);
  }
}

final vehicleTypeMasterFormProvider = AutoDisposeNotifierProvider<
    VehicleTypeMasterFormNotifier, VehicleTypeMasterFormState>(
  VehicleTypeMasterFormNotifier.new,
);

class VehicleTypeMasterFormNotifier
    extends AutoDisposeNotifier<VehicleTypeMasterFormState> {
  @override
  VehicleTypeMasterFormState build() {
    return const VehicleTypeMasterFormState(
      initialized: false,
      vehicleTypeId: null,
      vehicleTypeName: '',
      vehicleCategory: VehicleCategoryType.goods,
      description: '',
      seatingCapacity: '',
      loadCapacity: '',
      axleType: AxleType.axle4x2,
      bodyType: BodyType.flatbed,
      fuelType: FuelType.diesel,
      transmissionType: TransmissionType.manual,
      acType: AcType.nonAc,
      baseFarePerKm: '',
      baseFarePerHour: '',
      mileage: '',
      maxTripDistance: '',
      maxDrivingHoursPerDay: '',
      documents: [],
      status: RecordStatusType.active,
    );
  }

  void initialize(VehicleTypeMasterModel? item) {
    if (state.initialized) {
      return;
    }
    if (item == null) {
      state = state.copyWith(initialized: true, clearVehicleTypeId: true);
      return;
    }
    state = VehicleTypeMasterFormState(
      initialized: true,
      vehicleTypeId: item.vehicleTypeId,
      vehicleTypeName: item.vehicleTypeName,
      vehicleCategory: item.vehicleCategory,
      description: item.description,
      seatingCapacity:
          item.seatingCapacity == 0 ? '' : '${item.seatingCapacity}',
      loadCapacity: item.loadCapacity == 0 ? '' : '${item.loadCapacity}',
      axleType: item.axleType,
      bodyType: item.bodyType,
      fuelType: item.fuelType,
      transmissionType: item.transmissionType,
      acType: item.acType,
      baseFarePerKm: '${item.baseFarePerKm}',
      baseFarePerHour: '${item.baseFarePerHour}',
      mileage: '${item.mileage}',
      maxTripDistance: item.maxTripDistance?.toString() ?? '',
      maxDrivingHoursPerDay: item.maxDrivingHoursPerDay?.toString() ?? '',
      documents: item.documents,
      status: item.status,
    );
  }

  void setVehicleTypeName(String value) =>
      state = state.copyWith(vehicleTypeName: value);
  void setVehicleCategory(VehicleCategoryType value) =>
      state = state.copyWith(vehicleCategory: value);
  void setDescription(String value) => state = state.copyWith(description: value);
  void setSeatingCapacity(String value) =>
      state = state.copyWith(seatingCapacity: value);
  void setLoadCapacity(String value) => state = state.copyWith(loadCapacity: value);
  void setAxleType(AxleType value) => state = state.copyWith(axleType: value);
  void setBodyType(BodyType value) => state = state.copyWith(bodyType: value);
  void setFuelType(FuelType value) => state = state.copyWith(fuelType: value);
  void setTransmissionType(TransmissionType value) =>
      state = state.copyWith(transmissionType: value);
  void setAcType(AcType value) => state = state.copyWith(acType: value);
  void setBaseFarePerKm(String value) =>
      state = state.copyWith(baseFarePerKm: value);
  void setBaseFarePerHour(String value) =>
      state = state.copyWith(baseFarePerHour: value);
  void setMileage(String value) => state = state.copyWith(mileage: value);
  void setMaxTripDistance(String value) =>
      state = state.copyWith(maxTripDistance: value);
  void setMaxDrivingHoursPerDay(String value) =>
      state = state.copyWith(maxDrivingHoursPerDay: value);
  void setStatus(RecordStatusType value) => state = state.copyWith(status: value);

  void addDocument() {
    final next = List<VehicleTypeTemplateDocument>.from(state.documents)
      ..add(
        VehicleTypeTemplateDocument(
          documentId: '',
          documentType: VehicleTypeDocumentType.other,
          documentName: '',
          filePath: '',
          uploadedAt: DateTime.now(),
          uploadedBy: '',
          isMandatory: false,
        ),
      );
    state = state.copyWith(documents: next);
  }

  void removeDocument(int index) {
    if (index < 0 || index >= state.documents.length) {
      return;
    }
    final next = List<VehicleTypeTemplateDocument>.from(state.documents)
      ..removeAt(index);
    state = state.copyWith(documents: next);
  }

  void updateDocument(
    int index,
    VehicleTypeTemplateDocument Function(VehicleTypeTemplateDocument current)
        update,
  ) {
    if (index < 0 || index >= state.documents.length) {
      return;
    }
    final next = List<VehicleTypeTemplateDocument>.from(state.documents);
    next[index] = update(next[index]);
    state = state.copyWith(documents: next);
  }
}
