class ComplianceAssignment {
  const ComplianceAssignment({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.ruleId,
    required this.enabled,
    required this.note,
    required this.updatedAt,
  });

  final String id;
  final String entityType;
  final String entityId;
  final String ruleId;
  final bool enabled;
  final String note;
  final DateTime updatedAt;

  factory ComplianceAssignment.fromJson(Map<String, dynamic> json) {
    return ComplianceAssignment(
      id: json['id'] as String? ?? '',
      entityType: json['entityType'] as String? ?? '',
      entityId: json['entityId'] as String? ?? '',
      ruleId: json['ruleId'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? false,
      note: json['note'] as String? ?? '',
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType,
      'entityId': entityId,
      'ruleId': ruleId,
      'enabled': enabled,
      'note': note,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ComplianceAssignment copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? ruleId,
    bool? enabled,
    String? note,
    DateTime? updatedAt,
  }) {
    return ComplianceAssignment(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      ruleId: ruleId ?? this.ruleId,
      enabled: enabled ?? this.enabled,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ComplianceStageSummary {
  const ComplianceStageSummary({
    required this.stage,
    required this.enabledRules,
    required this.warningRules,
    required this.softBlockRules,
    required this.hardBlockRules,
  });

  final String stage;
  final int enabledRules;
  final int warningRules;
  final int softBlockRules;
  final int hardBlockRules;
}
