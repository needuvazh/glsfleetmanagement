import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/data_source_mode_provider.dart';
import '../../data/datasources/local/compliance_local_datasource.dart';
import '../../data/datasources/remote/compliance_remote_datasource.dart';
import '../../data/repositories/compliance_repository_impl.dart';
import '../../domain/entities/compliance_record.dart';
import '../../domain/repositories/compliance_repository.dart';
import '../../domain/usecases/get_compliance_records_usecase.dart';

enum ComplianceFilter { all, compliant, expiringSoon, overdue }

extension ComplianceFilterX on ComplianceFilter {
  String get label {
    switch (this) {
      case ComplianceFilter.all:
        return 'All';
      case ComplianceFilter.compliant:
        return 'Compliant';
      case ComplianceFilter.expiringSoon:
        return 'Expiring Soon';
      case ComplianceFilter.overdue:
        return 'Overdue';
    }
  }
}

class ComplianceUiState {
  const ComplianceUiState({
    required this.items,
    this.query = '',
    this.filter = ComplianceFilter.all,
    required this.lastUpdated,
  });

  final List<ComplianceRecord> items;
  final String query;
  final ComplianceFilter filter;
  final DateTime lastUpdated;

  int get compliantCount =>
      items.where((item) => item.complianceStatus == ComplianceStatus.compliant).length;
  int get expiringCount => items
      .where((item) => item.complianceStatus == ComplianceStatus.expiringSoon)
      .length;
  int get overdueCount =>
      items.where((item) => item.complianceStatus == ComplianceStatus.overdue).length;

  List<ComplianceRecord> get filteredItems {
    final normalized = query.trim().toLowerCase();

    return items.where((record) {
      final filterOk = switch (filter) {
        ComplianceFilter.all => true,
        ComplianceFilter.compliant =>
          record.complianceStatus == ComplianceStatus.compliant,
        ComplianceFilter.expiringSoon =>
          record.complianceStatus == ComplianceStatus.expiringSoon,
        ComplianceFilter.overdue =>
          record.complianceStatus == ComplianceStatus.overdue,
      };

      if (!filterOk) {
        return false;
      }

      if (normalized.isEmpty) {
        return true;
      }

      final searchable = [record.vehicleId, record.complianceStatus.label]
          .join(' ')
          .toLowerCase();

      return searchable.contains(normalized);
    }).toList();
  }

  ComplianceUiState copyWith({
    List<ComplianceRecord>? items,
    String? query,
    ComplianceFilter? filter,
    DateTime? lastUpdated,
  }) {
    return ComplianceUiState(
      items: items ?? this.items,
      query: query ?? this.query,
      filter: filter ?? this.filter,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final _complianceLocalDataSourceProvider = Provider<ComplianceLocalDataSource>(
  (ref) => ComplianceLocalDataSourceImpl(assetBundle: rootBundle),
);

final _complianceDioProvider = Provider<Dio>(
  (ref) => Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  ),
);

final _complianceRemoteDataSourceProvider =
    Provider<ComplianceRemoteDataSource>(
  (ref) => ComplianceRemoteDataSourceImpl(ref.read(_complianceDioProvider)),
);

final _complianceRepositoryProvider = Provider<ComplianceRepository>(
  (ref) {
    final useLiveApi = ref.watch(useLiveApiProvider);
    return ComplianceRepositoryImpl(
      localDataSource: ref.watch(_complianceLocalDataSourceProvider),
      remoteDataSource: ref.watch(_complianceRemoteDataSourceProvider),
      useLiveApi: useLiveApi,
    );
  },
);

final _getComplianceUseCaseProvider = Provider<GetComplianceRecordsUseCase>(
  (ref) => GetComplianceRecordsUseCase(ref.watch(_complianceRepositoryProvider)),
);

final complianceViewModelProvider =
    AsyncNotifierProvider<ComplianceViewModel, ComplianceUiState>(
  ComplianceViewModel.new,
);

class ComplianceViewModel extends AsyncNotifier<ComplianceUiState> {
  Timer? _timer;
  final Random _random = Random();

  @override
  Future<ComplianceUiState> build() async {
    ref.onDispose(() {
      _timer?.cancel();
    });

    final records = await ref.watch(_getComplianceUseCaseProvider).call();
    _startMockRealtimeUpdates();

    return ComplianceUiState(items: records, lastUpdated: DateTime.now());
  }

  Future<void> refresh() async {
    final previous = state.valueOrNull;
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final records = await ref.read(_getComplianceUseCaseProvider).call();
      return ComplianceUiState(
        items: records,
        query: previous?.query ?? '',
        filter: previous?.filter ?? ComplianceFilter.all,
        lastUpdated: DateTime.now(),
      );
    });
  }

  void setQuery(String value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(query: value));
  }

  void setFilter(ComplianceFilter value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(filter: value));
  }

  void _startMockRealtimeUpdates() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 18), (_) {
      final current = state.valueOrNull;
      if (current == null || current.items.isEmpty) {
        return;
      }

      final now = DateTime.now();
      final updated = current.items.map((record) {
        ComplianceStatus computedStatus;

        final nearestDue = [
          record.registrationExpiry,
          record.insuranceExpiry,
          record.inspectionDue,
        ].reduce((a, b) => a.isBefore(b) ? a : b);

        final days = nearestDue.difference(now).inDays;
        if (days < 0) {
          computedStatus = ComplianceStatus.overdue;
        } else if (days <= 30) {
          computedStatus = ComplianceStatus.expiringSoon;
        } else {
          computedStatus = ComplianceStatus.compliant;
        }

        if (_random.nextInt(30) == 0) {
          computedStatus = ComplianceStatus.values[
              _random.nextInt(ComplianceStatus.values.length)];
        }

        return record.copyWith(complianceStatus: computedStatus);
      }).toList();

      state = AsyncData(
        current.copyWith(items: updated, lastUpdated: DateTime.now()),
      );
    });
  }
}
