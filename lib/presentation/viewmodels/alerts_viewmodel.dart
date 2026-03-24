import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/data_source_mode_provider.dart';
import '../../data/datasources/local/alerts_local_datasource.dart';
import '../../data/datasources/remote/alerts_remote_datasource.dart';
import '../../data/repositories/alerts_repository_impl.dart';
import '../../domain/entities/alert_item.dart';
import '../../domain/repositories/alerts_repository.dart';
import '../../domain/usecases/get_alerts_usecase.dart';

enum AlertsSeverityFilter { all, high, medium, low }

extension AlertsSeverityFilterX on AlertsSeverityFilter {
  String get label {
    switch (this) {
      case AlertsSeverityFilter.all:
        return 'All';
      case AlertsSeverityFilter.high:
        return 'High';
      case AlertsSeverityFilter.medium:
        return 'Medium';
      case AlertsSeverityFilter.low:
        return 'Low';
    }
  }
}

enum AlertsReadFilter { all, unread }

extension AlertsReadFilterX on AlertsReadFilter {
  String get label {
    switch (this) {
      case AlertsReadFilter.all:
        return 'All';
      case AlertsReadFilter.unread:
        return 'Unread';
    }
  }
}

class AlertsUiState {
  const AlertsUiState({
    required this.items,
    this.query = '',
    this.severityFilter = AlertsSeverityFilter.all,
    this.readFilter = AlertsReadFilter.all,
    required this.lastUpdated,
  });

  final List<AlertItem> items;
  final String query;
  final AlertsSeverityFilter severityFilter;
  final AlertsReadFilter readFilter;
  final DateTime lastUpdated;

  int get unreadCount => items.where((item) => !item.isRead).length;

  int get highCount =>
      items.where((item) => item.severity == AlertSeverity.high).length;

  List<AlertItem> get filteredItems {
    final normalized = query.trim().toLowerCase();

    return items.where((alert) {
      final severityOk = switch (severityFilter) {
        AlertsSeverityFilter.all => true,
        AlertsSeverityFilter.high => alert.severity == AlertSeverity.high,
        AlertsSeverityFilter.medium => alert.severity == AlertSeverity.medium,
        AlertsSeverityFilter.low => alert.severity == AlertSeverity.low,
      };

      final readOk = switch (readFilter) {
        AlertsReadFilter.all => true,
        AlertsReadFilter.unread => !alert.isRead,
      };

      if (!severityOk || !readOk) {
        return false;
      }

      if (normalized.isEmpty) {
        return true;
      }

      final searchable = [
        alert.id,
        alert.vehicleId,
        alert.type,
        alert.message,
        alert.severity.label,
      ].join(' ').toLowerCase();

      return searchable.contains(normalized);
    }).toList();
  }

  AlertsUiState copyWith({
    List<AlertItem>? items,
    String? query,
    AlertsSeverityFilter? severityFilter,
    AlertsReadFilter? readFilter,
    DateTime? lastUpdated,
  }) {
    return AlertsUiState(
      items: items ?? this.items,
      query: query ?? this.query,
      severityFilter: severityFilter ?? this.severityFilter,
      readFilter: readFilter ?? this.readFilter,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final _alertsLocalDataSourceProvider = Provider<AlertsLocalDataSource>(
  (ref) => AlertsLocalDataSourceImpl(assetBundle: rootBundle),
);

final _alertsDioProvider = Provider<Dio>(
  (ref) => Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  ),
);

final _alertsRemoteDataSourceProvider = Provider<AlertsRemoteDataSource>(
  (ref) => AlertsRemoteDataSourceImpl(ref.read(_alertsDioProvider)),
);

final _alertsRepositoryProvider = Provider<AlertsRepository>(
  (ref) {
    final useLiveApi = ref.watch(useLiveApiProvider);
    return AlertsRepositoryImpl(
      localDataSource: ref.watch(_alertsLocalDataSourceProvider),
      remoteDataSource: ref.watch(_alertsRemoteDataSourceProvider),
      useLiveApi: useLiveApi,
    );
  },
);

final _getAlertsUseCaseProvider = Provider<GetAlertsUseCase>(
  (ref) => GetAlertsUseCase(ref.watch(_alertsRepositoryProvider)),
);

final alertsViewModelProvider =
    AsyncNotifierProvider<AlertsViewModel, AlertsUiState>(AlertsViewModel.new);

class AlertsViewModel extends AsyncNotifier<AlertsUiState> {
  Timer? _timer;
  final Random _random = Random();

  @override
  Future<AlertsUiState> build() async {
    ref.onDispose(() {
      _timer?.cancel();
    });

    final alerts = await ref.watch(_getAlertsUseCaseProvider).call();
    _startMockRealtimeUpdates();

    return AlertsUiState(items: alerts, lastUpdated: DateTime.now());
  }

  Future<void> refresh() async {
    final previous = state.valueOrNull;
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final alerts = await ref.read(_getAlertsUseCaseProvider).call();
      return AlertsUiState(
        items: alerts,
        query: previous?.query ?? '',
        severityFilter: previous?.severityFilter ?? AlertsSeverityFilter.all,
        readFilter: previous?.readFilter ?? AlertsReadFilter.all,
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

  void setSeverityFilter(AlertsSeverityFilter value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(severityFilter: value));
  }

  void setReadFilter(AlertsReadFilter value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(readFilter: value));
  }

  void toggleRead(String alertId) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final updated = current.items.map((alert) {
      if (alert.id != alertId) {
        return alert;
      }
      return alert.copyWith(isRead: !alert.isRead);
    }).toList();

    state = AsyncData(current.copyWith(items: updated, lastUpdated: DateTime.now()));
  }

  void markAllRead() {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(
      current.copyWith(
        items: current.items.map((item) => item.copyWith(isRead: true)).toList(),
        lastUpdated: DateTime.now(),
      ),
    );
  }

  void _startMockRealtimeUpdates() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 14), (_) {
      final current = state.valueOrNull;
      if (current == null || current.items.isEmpty) {
        return;
      }

      if (_random.nextInt(10) < 6) {
        final updated = [...current.items];
        final index = _random.nextInt(updated.length);
        updated[index] = updated[index].copyWith(isRead: false);

        state = AsyncData(
          current.copyWith(items: updated, lastUpdated: DateTime.now()),
        );
        return;
      }

      final nextNumber = 6000 + current.items.length + _random.nextInt(300);
      final types = ['Overspeed', 'Engine Fault', 'GeoFence Exit', 'Battery Low'];
      final messages = [
        'Speed threshold breached on highway segment.',
        'Diagnostic fault code received from ECU.',
        'Vehicle moved outside assigned service zone.',
        'Electrical battery level dropped below threshold.',
      ];

      final severities = AlertSeverity.values;
      final severity = severities[_random.nextInt(severities.length)];
      final type = types[_random.nextInt(types.length)];
      final message = messages[_random.nextInt(messages.length)];
      final vehicleIds = current.items.map((item) => item.vehicleId).toSet().toList();
      final vehicleId = vehicleIds[_random.nextInt(vehicleIds.length)];

      final newItem = AlertItem(
        id: 'AL-$nextNumber',
        vehicleId: vehicleId,
        type: type,
        severity: severity,
        message: message,
        timestamp: DateTime.now().toUtc(),
        isRead: false,
      );

      state = AsyncData(
        current.copyWith(
          items: [newItem, ...current.items],
          lastUpdated: DateTime.now(),
        ),
      );
    });
  }
}
