import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/compliance_assignment.dart';
import '../../domain/entities/module_document.dart';

class ComplianceAssignmentState {
  const ComplianceAssignmentState({
    required this.items,
    required this.isLoading,
    required this.lastUpdated,
    this.error,
  });

  final List<ComplianceAssignment> items;
  final bool isLoading;
  final DateTime lastUpdated;
  final String? error;

  List<ComplianceAssignment> assignmentsFor({
    required String entityType,
    required String entityId,
  }) {
    return items
        .where(
          (item) =>
              item.entityType.toLowerCase() == entityType.toLowerCase() &&
              item.entityId.toLowerCase() == entityId.toLowerCase(),
        )
        .toList();
  }

  ComplianceAssignmentState copyWith({
    List<ComplianceAssignment>? items,
    bool? isLoading,
    DateTime? lastUpdated,
    String? error,
    bool clearError = false,
  }) {
    return ComplianceAssignmentState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final complianceAssignmentViewModelProvider = StateNotifierProvider<
    ComplianceAssignmentViewModel, ComplianceAssignmentState>(
  (ref) => ComplianceAssignmentViewModel(),
);

class ComplianceAssignmentViewModel
    extends StateNotifier<ComplianceAssignmentState> {
  ComplianceAssignmentViewModel()
      : super(
          ComplianceAssignmentState(
            items: const [],
            isLoading: true,
            lastUpdated: DateTime.now(),
          ),
        ) {
    _load();
  }

  static const _cacheKey = 'compliance_rule_assignments_v1';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null || raw.trim().isEmpty) {
        state = state.copyWith(
          isLoading: false,
          lastUpdated: DateTime.now(),
          clearError: true,
        );
        return;
      }
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        state = state.copyWith(
          isLoading: false,
          items: const [],
          error: 'Failed to read compliance assignments. Using empty state.',
          lastUpdated: DateTime.now(),
        );
        return;
      }

      final list = decoded
          .whereType<Map>()
          .map((item) => item.map(
                (key, value) => MapEntry(key.toString(), value),
              ))
          .map(ComplianceAssignment.fromJson)
          .toList();

      state = state.copyWith(
        items: list,
        isLoading: false,
        lastUpdated: DateTime.now(),
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        items: const [],
        isLoading: false,
        lastUpdated: DateTime.now(),
        error: 'Failed to read compliance assignments. Using empty state.',
      );
    }
  }

  Future<void> _persist(List<ComplianceAssignment> items) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = items.map((item) => item.toJson()).toList();
    await prefs.setString(_cacheKey, jsonEncode(payload));
  }

  bool isRuleEnabled({
    required String entityType,
    required String entityId,
    required String ruleId,
  }) {
    final assignments = state.assignmentsFor(
      entityType: entityType,
      entityId: entityId,
    );
    for (final item in assignments) {
      if (item.ruleId == ruleId) {
        return item.enabled;
      }
    }
    return false;
  }

  String noteForRule({
    required String entityType,
    required String entityId,
    required String ruleId,
  }) {
    final assignments = state.assignmentsFor(
      entityType: entityType,
      entityId: entityId,
    );
    for (final item in assignments) {
      if (item.ruleId == ruleId) {
        return item.note;
      }
    }
    return '';
  }

  Future<String> setRuleEnabled({
    required String entityType,
    required String entityId,
    required String ruleId,
    required bool enabled,
  }) async {
    final now = DateTime.now();
    final normalizedEntityType = entityType.trim();
    final normalizedEntityId = entityId.trim();
    if (normalizedEntityType.isEmpty || normalizedEntityId.isEmpty) {
      return 'Entity type and id are required.';
    }

    final updated = <ComplianceAssignment>[];
    var replaced = false;
    for (final item in state.items) {
      if (item.entityType.toLowerCase() == normalizedEntityType.toLowerCase() &&
          item.entityId.toLowerCase() == normalizedEntityId.toLowerCase() &&
          item.ruleId == ruleId) {
        updated.add(item.copyWith(enabled: enabled, updatedAt: now));
        replaced = true;
      } else {
        updated.add(item);
      }
    }

    if (!replaced) {
      updated.add(
        ComplianceAssignment(
          id: '${normalizedEntityType.toUpperCase()}-${normalizedEntityId.toUpperCase()}-$ruleId',
          entityType: normalizedEntityType,
          entityId: normalizedEntityId,
          ruleId: ruleId,
          enabled: enabled,
          note: '',
          updatedAt: now,
        ),
      );
    }

    state = state.copyWith(
      items: updated,
      lastUpdated: now,
      clearError: true,
    );
    await _persist(updated);
    return enabled ? 'Compliance rule enabled.' : 'Compliance rule disabled.';
  }

  Future<String> setRuleNote({
    required String entityType,
    required String entityId,
    required String ruleId,
    required String note,
  }) async {
    final now = DateTime.now();
    final normalizedEntityType = entityType.trim();
    final normalizedEntityId = entityId.trim();
    if (normalizedEntityType.isEmpty || normalizedEntityId.isEmpty) {
      return 'Entity type and id are required.';
    }

    final cleanNote = note.trim();
    final updated = <ComplianceAssignment>[];
    var replaced = false;
    for (final item in state.items) {
      if (item.entityType.toLowerCase() == normalizedEntityType.toLowerCase() &&
          item.entityId.toLowerCase() == normalizedEntityId.toLowerCase() &&
          item.ruleId == ruleId) {
        updated.add(item.copyWith(note: cleanNote, updatedAt: now));
        replaced = true;
      } else {
        updated.add(item);
      }
    }

    if (!replaced) {
      updated.add(
        ComplianceAssignment(
          id: '${normalizedEntityType.toUpperCase()}-${normalizedEntityId.toUpperCase()}-$ruleId',
          entityType: normalizedEntityType,
          entityId: normalizedEntityId,
          ruleId: ruleId,
          enabled: false,
          note: cleanNote,
          updatedAt: now,
        ),
      );
    }

    state = state.copyWith(
      items: updated,
      lastUpdated: now,
      clearError: true,
    );
    await _persist(updated);
    return 'Compliance note updated.';
  }

  ComplianceStageSummary evaluateStage({
    required String entityType,
    required String entityId,
    required String stage,
    required List<ModuleDocument> rules,
  }) {
    final enabledRules = <ModuleDocument>[];
    for (final rule in rules) {
      if (!_matchesEntityType(rule, entityType)) {
        continue;
      }
      if (!_matchesStage(rule, stage)) {
        continue;
      }
      if (!isRuleEnabled(
        entityType: entityType,
        entityId: entityId,
        ruleId: rule.id,
      )) {
        continue;
      }
      enabledRules.add(rule);
    }

    var warningCount = 0;
    var softBlockCount = 0;
    var hardBlockCount = 0;

    for (final rule in enabledRules) {
      final action = _maxSeverityAction(rule.missingAction, rule.expiredAction);
      if (action == 'Warning') {
        warningCount += 1;
      } else if (action == 'Soft Block') {
        softBlockCount += 1;
      } else if (action == 'Hard Block') {
        hardBlockCount += 1;
      }
    }

    return ComplianceStageSummary(
      stage: stage,
      enabledRules: enabledRules.length,
      warningRules: warningCount,
      softBlockRules: softBlockCount,
      hardBlockRules: hardBlockCount,
    );
  }

  List<String> listHardBlockRuleNames({
    required String entityType,
    required String entityId,
    required String stage,
    required List<ModuleDocument> rules,
  }) {
    final names = <String>[];
    for (final rule in rules) {
      if (!_matchesEntityType(rule, entityType)) {
        continue;
      }
      if (!_matchesStage(rule, stage)) {
        continue;
      }
      if (!isRuleEnabled(
        entityType: entityType,
        entityId: entityId,
        ruleId: rule.id,
      )) {
        continue;
      }
      final action = _maxSeverityAction(rule.missingAction, rule.expiredAction);
      if (action == 'Hard Block') {
        names.add(rule.documentName);
      }
    }
    return names;
  }

  bool _matchesEntityType(ModuleDocument rule, String entityType) {
    return rule.applicableTo.toLowerCase() == entityType.toLowerCase();
  }

  bool _matchesStage(ModuleDocument rule, String stage) {
    switch (stage.toLowerCase()) {
      case 'assignment':
        return rule.checkAtAssignment;
      case 'inspection':
        return rule.checkAtInspection;
      case 'dispatch':
        return rule.checkAtDispatch;
      case 'trip start':
        return rule.checkAtTripStart;
      case 'delivery closure':
        return rule.checkAtDeliveryClosure;
      default:
        return false;
    }
  }

  String _maxSeverityAction(String left, String right) {
    final severity = {
      'Ignore': 0,
      'Warning': 1,
      'Soft Block': 2,
      'Hard Block': 3,
    };
    final leftScore = severity[left] ?? 0;
    final rightScore = severity[right] ?? 0;
    return leftScore >= rightScore ? left : right;
  }
}
