import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/module_document_local_datasource.dart';
import '../../data/repositories/module_document_repository_impl.dart';
import '../../domain/entities/module_document.dart';
import '../../domain/repositories/module_document_repository.dart';
import '../../domain/usecases/module_document_usecases.dart';

class ModuleDocumentUiState {
  const ModuleDocumentUiState({
    required this.items,
    required this.query,
    required this.statusFilter,
    required this.applicableToFilter,
    required this.mandatoryFilter,
    required this.blockingFilter,
    required this.stageFilter,
    required this.expiryTrackingFilter,
    required this.lastUpdated,
  });

  final List<ModuleDocument> items;
  final String query;
  final String statusFilter;
  final String applicableToFilter;
  final String mandatoryFilter;
  final String blockingFilter;
  final String stageFilter;
  final String expiryTrackingFilter;
  final DateTime lastUpdated;

  List<ModuleDocument> get filteredItems {
    final normalized = query.trim().toLowerCase();
    return items.where((item) {
      if (statusFilter != 'All' && item.status != statusFilter) {
        return false;
      }
      if (applicableToFilter != 'All' &&
          item.applicableTo != applicableToFilter) {
        return false;
      }
      if (mandatoryFilter == 'Mandatory' && !item.mandatory) {
        return false;
      }
      if (mandatoryFilter == 'Optional' && item.mandatory) {
        return false;
      }
      if (blockingFilter != 'All' && item.blockingType != blockingFilter) {
        return false;
      }
      if (!_matchesStage(item, stageFilter)) {
        return false;
      }
      if (expiryTrackingFilter == 'Enabled' && !item.hasExpiry) {
        return false;
      }
      if (expiryTrackingFilter == 'Disabled' && item.hasExpiry) {
        return false;
      }

      if (normalized.isEmpty) {
        return true;
      }

      final text =
          '${item.documentCode} ${item.documentName} ${item.description} ${item.applicableTo} ${item.requiredStageLabel}'
              .toLowerCase();
      return text.contains(normalized);
    }).toList();
  }

  List<ModuleDocument> rulesForApplicableTo(String applicableTo) {
    return items
        .where((item) =>
            item.applicableTo.toLowerCase() == applicableTo.toLowerCase())
        .toList();
  }

  ModuleDocumentUiState copyWith({
    List<ModuleDocument>? items,
    String? query,
    String? statusFilter,
    String? applicableToFilter,
    String? mandatoryFilter,
    String? blockingFilter,
    String? stageFilter,
    String? expiryTrackingFilter,
    DateTime? lastUpdated,
  }) {
    return ModuleDocumentUiState(
      items: items ?? this.items,
      query: query ?? this.query,
      statusFilter: statusFilter ?? this.statusFilter,
      applicableToFilter: applicableToFilter ?? this.applicableToFilter,
      mandatoryFilter: mandatoryFilter ?? this.mandatoryFilter,
      blockingFilter: blockingFilter ?? this.blockingFilter,
      stageFilter: stageFilter ?? this.stageFilter,
      expiryTrackingFilter: expiryTrackingFilter ?? this.expiryTrackingFilter,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  static bool _matchesStage(ModuleDocument item, String stageFilter) {
    if (stageFilter == 'All') {
      return true;
    }
    switch (stageFilter) {
      case 'Assignment':
        return item.checkAtAssignment;
      case 'Inspection':
        return item.checkAtInspection;
      case 'Dispatch':
        return item.checkAtDispatch;
      case 'Trip Start':
        return item.checkAtTripStart;
      case 'Delivery Closure':
        return item.checkAtDeliveryClosure;
      default:
        return true;
    }
  }
}

final _moduleDocumentLocalDataSourceProvider =
    Provider<ModuleDocumentLocalDataSource>(
  (ref) => ModuleDocumentLocalDataSourceImpl(),
);

final _moduleDocumentRepositoryProvider = Provider<ModuleDocumentRepository>(
  (ref) => ModuleDocumentRepositoryImpl(
    localDataSource: ref.watch(_moduleDocumentLocalDataSourceProvider),
  ),
);

final _getModuleDocumentsUseCaseProvider = Provider<GetModuleDocumentsUseCase>(
  (ref) =>
      GetModuleDocumentsUseCase(ref.watch(_moduleDocumentRepositoryProvider)),
);

final _addModuleDocumentUseCaseProvider = Provider<AddModuleDocumentUseCase>(
  (ref) =>
      AddModuleDocumentUseCase(ref.watch(_moduleDocumentRepositoryProvider)),
);

final _updateModuleDocumentUseCaseProvider =
    Provider<UpdateModuleDocumentUseCase>(
  (ref) =>
      UpdateModuleDocumentUseCase(ref.watch(_moduleDocumentRepositoryProvider)),
);

final _deleteModuleDocumentUseCaseProvider =
    Provider<DeleteModuleDocumentUseCase>(
  (ref) =>
      DeleteModuleDocumentUseCase(ref.watch(_moduleDocumentRepositoryProvider)),
);

final moduleDocumentViewModelProvider =
    AsyncNotifierProvider<ModuleDocumentViewModel, ModuleDocumentUiState>(
  ModuleDocumentViewModel.new,
);

class ModuleDocumentViewModel extends AsyncNotifier<ModuleDocumentUiState> {
  static const applicableToOptions = [
    'Driver',
    'Fleet',
    'Trailer',
    'Vehicle Types',
    'Vehicle Type',
    'Vendor',
    'Customer',
    'Cargo',
    'Route',
    'Location',
    'Inspection Template',
    'Inspection Templates',
    'Compliance Master',
    'Role Management',
    'User Management',
    'Work Order',
    'Trip',
  ];

  static const actionTypes = [
    'Ignore',
    'Warning',
    'Soft Block',
    'Hard Block',
  ];

  @override
  Future<ModuleDocumentUiState> build() async {
    List<ModuleDocument> items;
    try {
      items = await ref.watch(_getModuleDocumentsUseCaseProvider).call();
    } catch (_) {
      items = const [];
    }
    return ModuleDocumentUiState(
      items: items,
      query: '',
      statusFilter: 'All',
      applicableToFilter: 'All',
      mandatoryFilter: 'All',
      blockingFilter: 'All',
      stageFilter: 'All',
      expiryTrackingFilter: 'All',
      lastUpdated: DateTime.now(),
    );
  }

  void setQuery(String value) {
    _mutate((current) => current.copyWith(query: value));
  }

  void setStatusFilter(String value) {
    _mutate((current) => current.copyWith(statusFilter: value));
  }

  void setApplicableToFilter(String value) {
    _mutate((current) => current.copyWith(applicableToFilter: value));
  }

  void setMandatoryFilter(String value) {
    _mutate((current) => current.copyWith(mandatoryFilter: value));
  }

  void setBlockingFilter(String value) {
    _mutate((current) => current.copyWith(blockingFilter: value));
  }

  void setStageFilter(String value) {
    _mutate((current) => current.copyWith(stageFilter: value));
  }

  void setExpiryTrackingFilter(String value) {
    _mutate((current) => current.copyWith(expiryTrackingFilter: value));
  }

  Future<String> addDocument({
    required String documentCode,
    required String documentName,
    required String description,
    required String applicableTo,
    required bool mandatory,
    required bool hasExpiry,
    required int alertBeforeDays,
    required bool checkAtAssignment,
    required bool checkAtInspection,
    required bool checkAtDispatch,
    required bool checkAtTripStart,
    required bool checkAtDeliveryClosure,
    required String missingAction,
    required String expiredAction,
    required bool uploadRequired,
    required bool overrideAllowed,
    required String status,
  }) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Compliance state is not ready.';
    }

    final cleanCode = documentCode.trim();
    final cleanName = documentName.trim();
    final cleanApplicableTo = applicableTo.trim();
    final cleanStatus = status.trim();
    final cleanMissingAction = missingAction.trim();
    final cleanExpiredAction = expiredAction.trim();
    final cleanDescription = description.trim();

    if (cleanName.isEmpty || cleanApplicableTo.isEmpty || cleanStatus.isEmpty) {
      return 'Required compliance fields are missing.';
    }
    if (!actionTypes.contains(cleanMissingAction) ||
        !actionTypes.contains(cleanExpiredAction)) {
      return 'Invalid action type selected.';
    }

    final duplicate = current.items.any(
      (item) =>
          item.applicableTo.toLowerCase() == cleanApplicableTo.toLowerCase() &&
          item.documentName.toLowerCase() == cleanName.toLowerCase(),
    );
    if (duplicate) {
      return 'Rule name already exists for this applicability.';
    }

    final id = _nextId(current.items);
    final document = ModuleDocument(
      id: id,
      documentCode: cleanCode.isEmpty ? id : cleanCode,
      documentName: cleanName,
      description: cleanDescription,
      applicableTo: cleanApplicableTo,
      status: cleanStatus,
      mandatory: mandatory,
      hasExpiry: hasExpiry,
      alertBeforeDays: hasExpiry ? alertBeforeDays : 0,
      checkAtAssignment: checkAtAssignment,
      checkAtInspection: checkAtInspection,
      checkAtDispatch: checkAtDispatch,
      checkAtTripStart: checkAtTripStart,
      checkAtDeliveryClosure: checkAtDeliveryClosure,
      missingAction: cleanMissingAction,
      expiredAction: cleanExpiredAction,
      uploadRequired: uploadRequired,
      overrideAllowed: overrideAllowed,
    );

    final next =
        await ref.read(_addModuleDocumentUseCaseProvider).call(document);
    state =
        AsyncData(current.copyWith(items: next, lastUpdated: DateTime.now()));
    return 'Compliance rule created successfully.';
  }

  Future<String> updateDocument({
    required String id,
    required String documentCode,
    required String documentName,
    required String description,
    required String applicableTo,
    required bool mandatory,
    required bool hasExpiry,
    required int alertBeforeDays,
    required bool checkAtAssignment,
    required bool checkAtInspection,
    required bool checkAtDispatch,
    required bool checkAtTripStart,
    required bool checkAtDeliveryClosure,
    required String missingAction,
    required String expiredAction,
    required bool uploadRequired,
    required bool overrideAllowed,
    required String status,
  }) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Compliance state is not ready.';
    }

    final cleanCode = documentCode.trim();
    final cleanName = documentName.trim();
    final cleanApplicableTo = applicableTo.trim();
    final cleanStatus = status.trim();
    final cleanMissingAction = missingAction.trim();
    final cleanExpiredAction = expiredAction.trim();
    final cleanDescription = description.trim();

    if (cleanName.isEmpty || cleanApplicableTo.isEmpty || cleanStatus.isEmpty) {
      return 'Required compliance fields are missing.';
    }
    if (!actionTypes.contains(cleanMissingAction) ||
        !actionTypes.contains(cleanExpiredAction)) {
      return 'Invalid action type selected.';
    }

    final duplicate = current.items.any(
      (item) =>
          item.id != id &&
          item.applicableTo.toLowerCase() == cleanApplicableTo.toLowerCase() &&
          item.documentName.toLowerCase() == cleanName.toLowerCase(),
    );
    if (duplicate) {
      return 'Rule name already exists for this applicability.';
    }

    ModuleDocument? existing;
    for (final item in current.items) {
      if (item.id == id) {
        existing = item;
        break;
      }
    }
    if (existing == null) {
      return 'Compliance rule not found.';
    }

    final document = existing.copyWith(
      documentCode: cleanCode.isEmpty ? existing.documentCode : cleanCode,
      documentName: cleanName,
      description: cleanDescription,
      applicableTo: cleanApplicableTo,
      status: cleanStatus,
      mandatory: mandatory,
      hasExpiry: hasExpiry,
      alertBeforeDays: hasExpiry ? alertBeforeDays : 0,
      checkAtAssignment: checkAtAssignment,
      checkAtInspection: checkAtInspection,
      checkAtDispatch: checkAtDispatch,
      checkAtTripStart: checkAtTripStart,
      checkAtDeliveryClosure: checkAtDeliveryClosure,
      missingAction: cleanMissingAction,
      expiredAction: cleanExpiredAction,
      uploadRequired: uploadRequired,
      overrideAllowed: overrideAllowed,
    );

    final next =
        await ref.read(_updateModuleDocumentUseCaseProvider).call(id, document);
    state =
        AsyncData(current.copyWith(items: next, lastUpdated: DateTime.now()));
    return 'Compliance rule updated successfully.';
  }

  Future<String> deleteDocument(String id) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Compliance state is not ready.';
    }

    final next = await ref.read(_deleteModuleDocumentUseCaseProvider).call(id);
    state =
        AsyncData(current.copyWith(items: next, lastUpdated: DateTime.now()));
    return 'Compliance rule deleted successfully.';
  }

  String _nextId(List<ModuleDocument> items) {
    int maxValue = 0;
    for (final item in items) {
      final raw = item.id.replaceAll('CDM-', '').replaceAll('DOC-', '');
      final parsed = int.tryParse(raw);
      if (parsed != null && parsed > maxValue) {
        maxValue = parsed;
      }
    }
    final next = maxValue + 1;
    return 'CDM-${next.toString().padLeft(3, '0')}';
  }

  void _mutate(
      ModuleDocumentUiState Function(ModuleDocumentUiState current) updater) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(updater(current));
  }
}
