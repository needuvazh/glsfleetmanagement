import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/cargo_mock_datasource.dart';
import '../../data/cargo_repository.dart';
import '../../domain/cargo_model.dart';
import '../../domain/cargo_usecase.dart';

class CargoUiState {
  const CargoUiState({
    required this.items,
    required this.query,
    required this.statusFilter,
    required this.categoryFilter,
    required this.hazardFilter,
    required this.riskFilter,
    required this.specialHandlingFilter,
    required this.complianceFilter,
    required this.lastUpdated,
  });

  final List<CargoModel> items;
  final String query;
  final String statusFilter;
  final String categoryFilter;
  final String hazardFilter;
  final String riskFilter;
  final String specialHandlingFilter;
  final String complianceFilter;
  final DateTime lastUpdated;

  List<String> get categoryOptions {
    final set = <String>{'All'};
    for (final item in items) {
      if (item.category.trim().isNotEmpty) {
        set.add(item.category.trim());
      }
    }
    return set.toList()..sort();
  }

  List<CargoModel> get filteredItems {
    final normalized = query.trim().toLowerCase();
    return items.where((item) {
      if (statusFilter == 'Active' && item.status != CargoStatus.active) {
        return false;
      }
      if (statusFilter == 'Inactive' && item.status != CargoStatus.inactive) {
        return false;
      }

      if (categoryFilter != 'All' && item.category != categoryFilter) {
        return false;
      }

      if (hazardFilter == 'Hazardous' && !item.hazardous) {
        return false;
      }
      if (hazardFilter == 'Non-Hazardous' && item.hazardous) {
        return false;
      }

      if (riskFilter != 'All' && item.riskLevel.label != riskFilter) {
        return false;
      }

      if (specialHandlingFilter == 'Yes' && !item.specialHandlingRequired) {
        return false;
      }
      if (specialHandlingFilter == 'No' && item.specialHandlingRequired) {
        return false;
      }

      if (complianceFilter == 'Yes' && !item.specialComplianceRequired) {
        return false;
      }
      if (complianceFilter == 'No' && item.specialComplianceRequired) {
        return false;
      }

      if (normalized.isEmpty) {
        return true;
      }
      final text = '${item.cargoCode} ${item.cargoName} '
              '${item.category} ${item.subcategory}'
          .toLowerCase();
      return text.contains(normalized);
    }).toList();
  }

  List<CargoModel> get selectableItems =>
      items.where((item) => item.isSelectable).toList();

  CargoUiState copyWith({
    List<CargoModel>? items,
    String? query,
    String? statusFilter,
    String? categoryFilter,
    String? hazardFilter,
    String? riskFilter,
    String? specialHandlingFilter,
    String? complianceFilter,
    DateTime? lastUpdated,
  }) {
    return CargoUiState(
      items: items ?? this.items,
      query: query ?? this.query,
      statusFilter: statusFilter ?? this.statusFilter,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      hazardFilter: hazardFilter ?? this.hazardFilter,
      riskFilter: riskFilter ?? this.riskFilter,
      specialHandlingFilter:
          specialHandlingFilter ?? this.specialHandlingFilter,
      complianceFilter: complianceFilter ?? this.complianceFilter,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final _cargoDataSourceProvider = Provider<CargoMockDataSource>(
  (ref) => CargoMockDataSourceImpl(),
);

final _cargoRepositoryProvider = Provider<CargoRepository>(
  (ref) => CargoRepositoryImpl(dataSource: ref.watch(_cargoDataSourceProvider)),
);

final _cargoUseCaseProvider = Provider<CargoUseCase>(
  (ref) => CargoUseCase(ref.watch(_cargoRepositoryProvider)),
);

final cargoViewModelProvider =
    AsyncNotifierProvider<CargoViewModel, CargoUiState>(
  CargoViewModel.new,
);

class CargoViewModel extends AsyncNotifier<CargoUiState> {
  @override
  Future<CargoUiState> build() async {
    final list = await ref.watch(_cargoUseCaseProvider).getCargoTypes();
    return CargoUiState(
      items: list,
      query: '',
      statusFilter: 'All',
      categoryFilter: 'All',
      hazardFilter: 'All',
      riskFilter: 'All',
      specialHandlingFilter: 'All',
      complianceFilter: 'All',
      lastUpdated: DateTime.now(),
    );
  }

  CargoModel? findByCode(String? code) {
    final current = state.valueOrNull;
    if (current == null || code == null || code.trim().isEmpty) {
      return null;
    }
    final normalized = code.trim().toLowerCase();
    for (final item in current.items) {
      if (item.cargoCode.toLowerCase() == normalized) {
        return item;
      }
    }
    return null;
  }

  CargoModel? findByName(String? name) {
    final current = state.valueOrNull;
    if (current == null || name == null || name.trim().isEmpty) {
      return null;
    }
    final normalized = name.trim().toLowerCase();
    for (final item in current.items) {
      if (item.cargoName.toLowerCase() == normalized) {
        return item;
      }
    }
    return null;
  }

  void setQuery(String value) =>
      _mutate((current) => current.copyWith(query: value));

  void setStatusFilter(String value) =>
      _mutate((current) => current.copyWith(statusFilter: value));

  void setCategoryFilter(String value) =>
      _mutate((current) => current.copyWith(categoryFilter: value));

  void setHazardFilter(String value) =>
      _mutate((current) => current.copyWith(hazardFilter: value));

  void setRiskFilter(String value) =>
      _mutate((current) => current.copyWith(riskFilter: value));

  void setSpecialHandlingFilter(String value) =>
      _mutate((current) => current.copyWith(specialHandlingFilter: value));

  void setComplianceFilter(String value) =>
      _mutate((current) => current.copyWith(complianceFilter: value));

  Future<String> addCargo(CargoModel item) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Cargo state is not ready.';
    }
    final validation = _validate(item, current.items);
    if (validation != null) {
      return validation;
    }

    final updated = await ref.read(_cargoUseCaseProvider).addCargo(item);
    state = AsyncData(
      current.copyWith(items: updated, lastUpdated: DateTime.now()),
    );
    return 'Cargo type created successfully.';
  }

  Future<String> updateCargo(CargoModel item) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Cargo state is not ready.';
    }

    final remaining = current.items
        .where((entry) =>
            entry.cargoCode.toLowerCase() != item.cargoCode.toLowerCase())
        .toList();
    final validation = _validate(item, remaining);
    if (validation != null) {
      return validation;
    }

    final updated = await ref.read(_cargoUseCaseProvider).updateCargo(item);
    state = AsyncData(
      current.copyWith(items: updated, lastUpdated: DateTime.now()),
    );
    return 'Cargo type updated successfully.';
  }

  Future<String> deactivateCargo(String code) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Cargo state is not ready.';
    }

    final target = findByCode(code);
    if (target == null) {
      return 'Cargo type not found.';
    }

    final updated = await ref.read(_cargoUseCaseProvider).updateCargo(
          target.copyWith(
            status: CargoStatus.inactive,
            restricted: true,
            restrictionReason: target.restrictionReason.trim().isEmpty
                ? 'Deactivated from cargo master list.'
                : target.restrictionReason,
            updatedAt: DateTime.now(),
          ),
        );

    state = AsyncData(
      current.copyWith(items: updated, lastUpdated: DateTime.now()),
    );
    return 'Cargo type deactivated successfully.';
  }

  String? _validate(CargoModel item, List<CargoModel> existing) {
    if (item.cargoName.trim().isEmpty) {
      return 'Cargo name is required.';
    }
    if (item.category.trim().isEmpty) {
      return 'Category is required.';
    }
    if (item.length != null && item.length! < 0) {
      return 'Length cannot be negative.';
    }
    if (item.width != null && item.width! < 0) {
      return 'Width cannot be negative.';
    }
    if (item.height != null && item.height! < 0) {
      return 'Height cannot be negative.';
    }

    final duplicateName = existing.any(
      (entry) => entry.cargoName.toLowerCase() == item.cargoName.toLowerCase(),
    );
    if (duplicateName) {
      return 'Cargo name already exists.';
    }

    if (item.cargoCode.trim().isNotEmpty) {
      final duplicateCode = existing.any(
        (entry) =>
            entry.cargoCode.toLowerCase() == item.cargoCode.toLowerCase(),
      );
      if (duplicateCode) {
        return 'Cargo code already exists.';
      }
    }

    if (item.restricted && item.restrictionReason.trim().isEmpty) {
      return 'Restriction reason is required when restricted is enabled.';
    }
    if (item.inspectionRequired && item.inspectionTemplateType.trim().isEmpty) {
      return 'Inspection template type is required when inspection is enabled.';
    }
    return null;
  }

  void _mutate(CargoUiState Function(CargoUiState current) updater) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(updater(current));
  }
}
