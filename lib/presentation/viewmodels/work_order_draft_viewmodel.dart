import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/work_order.dart';

class WorkOrderDraft {
  const WorkOrderDraft({
    this.title = '',
    this.vehicleId = '8603 BK',
    this.journeyPlanId,
    this.priority = WorkOrderPriority.medium,
  });

  final String title;
  final String vehicleId;
  final String? journeyPlanId;
  final WorkOrderPriority priority;

  bool get hasContent =>
      title.trim().isNotEmpty ||
      vehicleId.trim().isNotEmpty ||
      journeyPlanId != null;

  WorkOrderDraft copyWith({
    String? title,
    String? vehicleId,
    String? journeyPlanId,
    bool clearJourneyPlanId = false,
    WorkOrderPriority? priority,
  }) {
    return WorkOrderDraft(
      title: title ?? this.title,
      vehicleId: vehicleId ?? this.vehicleId,
      journeyPlanId:
          clearJourneyPlanId ? null : (journeyPlanId ?? this.journeyPlanId),
      priority: priority ?? this.priority,
    );
  }
}

final workOrderDraftProvider =
    NotifierProvider<WorkOrderDraftNotifier, WorkOrderDraft>(
  WorkOrderDraftNotifier.new,
);

class WorkOrderDraftNotifier extends Notifier<WorkOrderDraft> {
  static const _storageKey = 'work_order_draft_v1';
  bool _loaded = false;

  @override
  WorkOrderDraft build() {
    if (!_loaded) {
      _loaded = true;
      _restoreDraft();
    }
    return const WorkOrderDraft();
  }

  Future<void> saveDraft(WorkOrderDraft draft) async {
    state = draft;
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{
      'title': draft.title,
      'vehicleId': draft.vehicleId,
      'journeyPlanId': draft.journeyPlanId,
      'priority': draft.priority.name,
    };
    await prefs.setString(_storageKey, jsonEncode(payload));
  }

  Future<void> clearDraft() async {
    state = const WorkOrderDraft();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<void> _restoreDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return;
    }

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final priorityName = map['priority'] as String? ?? WorkOrderPriority.medium.name;
      final priority = WorkOrderPriority.values.firstWhere(
        (value) => value.name == priorityName,
        orElse: () => WorkOrderPriority.medium,
      );

      state = WorkOrderDraft(
        title: map['title'] as String? ?? '',
        vehicleId: map['vehicleId'] as String? ?? '8603 BK',
        journeyPlanId: map['journeyPlanId'] as String?,
        priority: priority,
      );
    } catch (_) {
      state = const WorkOrderDraft();
    }
  }
}
