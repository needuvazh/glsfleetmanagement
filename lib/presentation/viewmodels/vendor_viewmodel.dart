import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/vendor_mock_datasource.dart';
import '../../data/vendor_repository.dart';
import '../../domain/vendor_model.dart';
import '../../domain/vendor_usecase.dart';

class VendorUiState {
  const VendorUiState({
    required this.vendors,
    required this.searchQuery,
    required this.lastUpdated,
  });

  final List<VendorModel> vendors;
  final String searchQuery;
  final DateTime lastUpdated;

  List<VendorModel> get filteredVendors {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return vendors;
    }
    return vendors
        .where((vendor) => vendor.vendorName.toLowerCase().contains(query))
        .toList();
  }

  VendorUiState copyWith({
    List<VendorModel>? vendors,
    String? searchQuery,
    DateTime? lastUpdated,
  }) {
    return VendorUiState(
      vendors: vendors ?? this.vendors,
      searchQuery: searchQuery ?? this.searchQuery,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final _vendorDataSourceProvider = Provider<VendorMockDataSource>(
  (ref) => VendorMockDataSourceImpl(),
);

final _vendorRepositoryProvider = Provider<VendorRepository>(
  (ref) => VendorRepositoryImpl(
    dataSource: ref.watch(_vendorDataSourceProvider),
  ),
);

final _vendorUseCaseProvider = Provider<VendorUseCase>(
  (ref) => VendorUseCase(ref.watch(_vendorRepositoryProvider)),
);

final vendorViewModelProvider =
    AsyncNotifierProvider<VendorViewModel, VendorUiState>(
  VendorViewModel.new,
);

class VendorViewModel extends AsyncNotifier<VendorUiState> {
  @override
  Future<VendorUiState> build() async {
    final list = await ref.watch(_vendorUseCaseProvider).getVendors();
    return VendorUiState(
      vendors: list,
      searchQuery: '',
      lastUpdated: DateTime.now(),
    );
  }

  Future<void> getVendors() async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    final list = await ref.read(_vendorUseCaseProvider).getVendors();
    state = AsyncData(
      current.copyWith(vendors: list, lastUpdated: DateTime.now()),
    );
  }

  Future<List<VendorModel>> getActiveVendors() {
    return ref.read(_vendorUseCaseProvider).getActiveVendors();
  }

  Future<List<VendorModel>> getActiveVendorsByServiceType(
    VendorServiceType serviceType,
  ) {
    return ref
        .read(_vendorUseCaseProvider)
        .getActiveVendorsByServiceType(serviceType);
  }

  Future<VendorModel?> getVendorById(String vendorId) {
    return ref.read(_vendorUseCaseProvider).getVendorById(vendorId);
  }

  Future<String> addVendor(VendorModel vendor) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Vendor state is not ready.';
    }
    final validation = _validateVendor(vendor, current.vendors);
    if (validation != null) {
      return validation;
    }

    final updated = await ref.read(_vendorUseCaseProvider).addVendor(vendor);
    state = AsyncData(
      current.copyWith(vendors: updated, lastUpdated: DateTime.now()),
    );
    return 'Vendor created successfully.';
  }

  Future<String> updateVendor(VendorModel vendor) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Vendor state is not ready.';
    }
    final remaining = current.vendors
        .where((entry) => entry.vendorId != vendor.vendorId)
        .toList();
    final validation = _validateVendor(vendor, remaining);
    if (validation != null) {
      return validation;
    }

    final updated = await ref.read(_vendorUseCaseProvider).updateVendor(vendor);
    state = AsyncData(
      current.copyWith(vendors: updated, lastUpdated: DateTime.now()),
    );
    return 'Vendor updated successfully.';
  }

  void setSearchQuery(String value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(searchQuery: value));
  }

  String? _validateVendor(VendorModel vendor, List<VendorModel> existing) {
    if (vendor.vendorName.trim().isEmpty) {
      return 'Vendor name is required.';
    }
    if (vendor.contactNumber.trim().isEmpty) {
      return 'Contact number is required.';
    }
    final duplicateName = existing.any(
      (entry) => entry.vendorName.toLowerCase() == vendor.vendorName.toLowerCase(),
    );
    if (duplicateName) {
      return 'Vendor name already exists.';
    }
    return null;
  }
}

class VendorFormState {
  const VendorFormState({
    required this.initialized,
    required this.originalVendorId,
    required this.vendorName,
    required this.companyName,
    required this.contactNumber,
    required this.email,
    required this.address,
    required this.vendorType,
    required this.serviceType,
    required this.status,
  });

  final bool initialized;
  final String? originalVendorId;
  final String vendorName;
  final String companyName;
  final String contactNumber;
  final String email;
  final String address;
  final VendorType vendorType;
  final VendorServiceType serviceType;
  final VendorStatus status;

  bool get isEditMode => originalVendorId != null;

  VendorModel toVendorModel() {
    return VendorModel(
      vendorId: originalVendorId ?? '',
      vendorName: vendorName.trim(),
      companyName: companyName.trim(),
      contactNumber: contactNumber.trim(),
      email: email.trim(),
      address: address.trim(),
      vendorType: vendorType,
      serviceType: serviceType,
      status: status,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  VendorFormState copyWith({
    bool? initialized,
    String? originalVendorId,
    bool clearOriginalVendorId = false,
    String? vendorName,
    String? companyName,
    String? contactNumber,
    String? email,
    String? address,
    VendorType? vendorType,
    VendorServiceType? serviceType,
    VendorStatus? status,
  }) {
    return VendorFormState(
      initialized: initialized ?? this.initialized,
      originalVendorId: clearOriginalVendorId
          ? null
          : (originalVendorId ?? this.originalVendorId),
      vendorName: vendorName ?? this.vendorName,
      companyName: companyName ?? this.companyName,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      vendorType: vendorType ?? this.vendorType,
      serviceType: serviceType ?? this.serviceType,
      status: status ?? this.status,
    );
  }
}

final vendorFormProvider =
    AutoDisposeNotifierProvider<VendorFormNotifier, VendorFormState>(
  VendorFormNotifier.new,
);

class VendorFormNotifier extends AutoDisposeNotifier<VendorFormState> {
  @override
  VendorFormState build() {
    return const VendorFormState(
      initialized: false,
      originalVendorId: null,
      vendorName: '',
      companyName: '',
      contactNumber: '',
      email: '',
      address: '',
      vendorType: VendorType.thirdParty,
      serviceType: VendorServiceType.nonPdo,
      status: VendorStatus.active,
    );
  }

  void initialize(VendorModel? vendor) {
    if (state.initialized) {
      return;
    }
    if (vendor == null) {
      state = state.copyWith(initialized: true, clearOriginalVendorId: true);
      return;
    }

    state = VendorFormState(
      initialized: true,
      originalVendorId: vendor.vendorId,
      vendorName: vendor.vendorName,
      companyName: vendor.companyName,
      contactNumber: vendor.contactNumber,
      email: vendor.email,
      address: vendor.address,
      vendorType: vendor.vendorType,
      serviceType: vendor.serviceType,
      status: vendor.status,
    );
  }

  void setVendorName(String value) => state = state.copyWith(vendorName: value);
  void setCompanyName(String value) => state = state.copyWith(companyName: value);
  void setContactNumber(String value) =>
      state = state.copyWith(contactNumber: value);
  void setEmail(String value) => state = state.copyWith(email: value);
  void setAddress(String value) => state = state.copyWith(address: value);
  void setVendorType(VendorType value) => state = state.copyWith(vendorType: value);
  void setServiceType(VendorServiceType value) =>
      state = state.copyWith(serviceType: value);
  void setStatus(VendorStatus value) => state = state.copyWith(status: value);
}
