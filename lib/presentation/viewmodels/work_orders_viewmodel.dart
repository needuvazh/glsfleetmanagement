import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/data_source_mode_provider.dart';
import '../../data/datasources/local/work_order_local_datasource.dart';
import '../../data/datasources/remote/work_order_remote_datasource.dart';
import '../../data/repositories/work_order_repository_impl.dart';
import '../../domain/entities/journey_plan.dart';
import '../../domain/entities/work_order.dart';
import '../../domain/repositories/work_order_repository.dart';
import '../../domain/usecases/get_work_orders_usecase.dart';

enum WorkOrderStatusFilter { all, open, inProgress, completed }

extension WorkOrderStatusFilterX on WorkOrderStatusFilter {
  String get label {
    switch (this) {
      case WorkOrderStatusFilter.all:
        return 'All';
      case WorkOrderStatusFilter.open:
        return 'Open';
      case WorkOrderStatusFilter.inProgress:
        return 'In Progress';
      case WorkOrderStatusFilter.completed:
        return 'Completed';
    }
  }
}

enum WorkOrderPriorityFilter { all, high, medium, low }

extension WorkOrderPriorityFilterX on WorkOrderPriorityFilter {
  String get label {
    switch (this) {
      case WorkOrderPriorityFilter.all:
        return 'All';
      case WorkOrderPriorityFilter.high:
        return 'High';
      case WorkOrderPriorityFilter.medium:
        return 'Medium';
      case WorkOrderPriorityFilter.low:
        return 'Low';
    }
  }
}

class WorkOrdersUiState {
  const WorkOrdersUiState({
    required this.items,
    this.query = '',
    this.statusFilter = WorkOrderStatusFilter.all,
    this.priorityFilter = WorkOrderPriorityFilter.all,
    required this.lastUpdated,
  });

  final List<WorkOrder> items;
  final String query;
  final WorkOrderStatusFilter statusFilter;
  final WorkOrderPriorityFilter priorityFilter;
  final DateTime lastUpdated;

  List<WorkOrder> get filteredItems {
    final normalized = query.trim().toLowerCase();

    return items.where((order) {
      final statusOk = switch (statusFilter) {
        WorkOrderStatusFilter.all => true,
        WorkOrderStatusFilter.open => order.status == WorkOrderStatus.open,
        WorkOrderStatusFilter.inProgress =>
          order.status == WorkOrderStatus.inProgress,
        WorkOrderStatusFilter.completed =>
          order.status == WorkOrderStatus.completed,
      };

      final priorityOk = switch (priorityFilter) {
        WorkOrderPriorityFilter.all => true,
        WorkOrderPriorityFilter.high =>
          order.priority == WorkOrderPriority.high,
        WorkOrderPriorityFilter.medium =>
          order.priority == WorkOrderPriority.medium,
        WorkOrderPriorityFilter.low => order.priority == WorkOrderPriority.low,
      };

      if (!statusOk || !priorityOk) {
        return false;
      }

      if (normalized.isEmpty) {
        return true;
      }

      final searchable = [
        order.id,
        order.vehicleId,
        order.title,
        order.status.label,
        order.priority.label,
      ].join(' ').toLowerCase();

      return searchable.contains(normalized);
    }).toList();
  }

  WorkOrdersUiState copyWith({
    List<WorkOrder>? items,
    String? query,
    WorkOrderStatusFilter? statusFilter,
    WorkOrderPriorityFilter? priorityFilter,
    DateTime? lastUpdated,
  }) {
    return WorkOrdersUiState(
      items: items ?? this.items,
      query: query ?? this.query,
      statusFilter: statusFilter ?? this.statusFilter,
      priorityFilter: priorityFilter ?? this.priorityFilter,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final _workOrderLocalDataSourceProvider = Provider<WorkOrderLocalDataSource>(
  (ref) => WorkOrderLocalDataSourceImpl(assetBundle: rootBundle),
);

final _workOrderDioProvider = Provider<Dio>(
  (ref) => Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  ),
);

final _workOrderRemoteDataSourceProvider = Provider<WorkOrderRemoteDataSource>(
  (ref) => WorkOrderRemoteDataSourceImpl(ref.read(_workOrderDioProvider)),
);

final _workOrderRepositoryProvider = Provider<WorkOrderRepository>(
  (ref) {
    final useLiveApi = ref.watch(useLiveApiProvider);
    return WorkOrderRepositoryImpl(
      localDataSource: ref.watch(_workOrderLocalDataSourceProvider),
      remoteDataSource: ref.watch(_workOrderRemoteDataSourceProvider),
      useLiveApi: useLiveApi,
    );
  },
);

final _getWorkOrdersUseCaseProvider = Provider<GetWorkOrdersUseCase>(
  (ref) => GetWorkOrdersUseCase(ref.watch(_workOrderRepositoryProvider)),
);

final workOrdersViewModelProvider =
    AsyncNotifierProvider<WorkOrdersViewModel, WorkOrdersUiState>(
  WorkOrdersViewModel.new,
);

class WorkOrdersViewModel extends AsyncNotifier<WorkOrdersUiState> {
  Timer? _timer;
  final Random _random = Random();

  @override
  Future<WorkOrdersUiState> build() async {
    ref.onDispose(() {
      _timer?.cancel();
    });

    final workOrders = await ref.watch(_getWorkOrdersUseCaseProvider).call();
    _startMockRealtimeUpdates();

    return WorkOrdersUiState(
      items: workOrders,
      lastUpdated: DateTime.now(),
    );
  }

  Future<void> refresh() async {
    final previous = state.valueOrNull;
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final workOrders = await ref.read(_getWorkOrdersUseCaseProvider).call();
      return WorkOrdersUiState(
        items: workOrders,
        query: previous?.query ?? '',
        statusFilter: previous?.statusFilter ?? WorkOrderStatusFilter.all,
        priorityFilter:
            previous?.priorityFilter ?? WorkOrderPriorityFilter.all,
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

  void setStatusFilter(WorkOrderStatusFilter value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(statusFilter: value));
  }

  void setPriorityFilter(WorkOrderPriorityFilter value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(priorityFilter: value));
  }

  void _startMockRealtimeUpdates() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 12), (_) {
      final current = state.valueOrNull;
      if (current == null || current.items.isEmpty) {
        return;
      }

      final index = _random.nextInt(current.items.length);
      final selected = current.items[index];

      final nextStatus = switch (selected.status) {
        WorkOrderStatus.open => WorkOrderStatus.inProgress,
        WorkOrderStatus.inProgress =>
          _random.nextInt(10) < 6 ? WorkOrderStatus.completed : selected.status,
        WorkOrderStatus.completed =>
          _random.nextInt(10) < 2 ? WorkOrderStatus.inProgress : selected.status,
      };

      final updated = [...current.items];
      updated[index] = selected.copyWith(status: nextStatus);

      state = AsyncData(
        current.copyWith(items: updated, lastUpdated: DateTime.now()),
      );
    });
  }

  void createOrderFromJourneyPlan({
    required JourneyPlan plan,
    required String vehicleId,
    required String title,
    WorkOrderPriority priority = WorkOrderPriority.medium,
  }) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final now = DateTime.now();
    final estimatedHours = plan.estimatedTime <= 0 ? 4.0 : plan.estimatedTime;

    final newOrder = WorkOrder(
      id: 'WO-${9000 + now.millisecondsSinceEpoch % 1000}',
      vehicleId: vehicleId,
      title: title,
      journeyPlanId: plan.id,
      estimatedDistance: plan.distance,
      estimatedTime: estimatedHours,
      priority: priority,
      status: WorkOrderStatus.open,
      createdAt: now,
      dueDate: now.add(Duration(hours: (estimatedHours * 2).round())),
    );

    state = AsyncData(
      current.copyWith(
        items: [newOrder, ...current.items],
        lastUpdated: DateTime.now(),
      ),
    );
  }
}
