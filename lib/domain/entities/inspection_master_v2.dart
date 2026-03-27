import 'inspection.dart';

enum InspectionStage {
  beforeDispatch,
  duringTrip,
  postTrip,
}

enum InspectionObjectType {
  fleet,
  trailer,
  driver,
  workOrder,
  trip,
  cargo,
}

enum BundleInclusionMode {
  always,
  conditional,
  manual,
}

enum TemplateStatus {
  draft,
  published,
  retired,
}

enum InspectionInputType {
  passFail,
  yesNo,
  text,
  number,
  date,
  expiryCheck,
  dropdown,
  photoOnly,
  videoOnly,
}

enum RuleTargetLevel {
  bundle,
  template,
  section,
  item,
}

enum RuleOperator {
  equals,
  notEquals,
  contains,
  greaterThan,
  lessThan,
  inList,
}

enum RuleAction {
  include,
  exclude,
  show,
  hide,
  block,
}

enum BlockingType {
  saveBlocker,
  submitBlocker,
  dispatchBlocker,
  approvalBlocker,
}

enum MediaType { photo, video }

enum AllowedOnResult {
  any,
  failOnly,
  passOnly,
}

class InspectionBundleMaster {
  const InspectionBundleMaster({
    required this.bundleId,
    required this.bundleCode,
    required this.bundleName,
    required this.description,
    required this.stage,
    required this.activeFlag,
    required this.version,
    required this.effectiveFrom,
    required this.effectiveTo,
    required this.companyScope,
  });

  final String bundleId;
  final String bundleCode;
  final String bundleName;
  final String description;
  final InspectionStage stage;
  final bool activeFlag;
  final String version;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
  final List<String> companyScope;

  InspectionBundleMaster copyWith({
    String? bundleId,
    String? bundleCode,
    String? bundleName,
    String? description,
    InspectionStage? stage,
    bool? activeFlag,
    String? version,
    DateTime? effectiveFrom,
    DateTime? effectiveTo,
    List<String>? companyScope,
  }) {
    return InspectionBundleMaster(
      bundleId: bundleId ?? this.bundleId,
      bundleCode: bundleCode ?? this.bundleCode,
      bundleName: bundleName ?? this.bundleName,
      description: description ?? this.description,
      stage: stage ?? this.stage,
      activeFlag: activeFlag ?? this.activeFlag,
      version: version ?? this.version,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveTo: effectiveTo ?? this.effectiveTo,
      companyScope: companyScope ?? this.companyScope,
    );
  }
}

class InspectionTypeMasterV2 {
  const InspectionTypeMasterV2({
    required this.inspectionTypeId,
    required this.code,
    required this.name,
    required this.description,
    required this.stage,
    required this.objectType,
    required this.activeFlag,
  });

  final String inspectionTypeId;
  final String code;
  final String name;
  final String description;
  final InspectionStage stage;
  final InspectionObjectType objectType;
  final bool activeFlag;

  InspectionTypeMasterV2 copyWith({
    String? inspectionTypeId,
    String? code,
    String? name,
    String? description,
    InspectionStage? stage,
    InspectionObjectType? objectType,
    bool? activeFlag,
  }) {
    return InspectionTypeMasterV2(
      inspectionTypeId: inspectionTypeId ?? this.inspectionTypeId,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      stage: stage ?? this.stage,
      objectType: objectType ?? this.objectType,
      activeFlag: activeFlag ?? this.activeFlag,
    );
  }
}

class BundleInspectionTypeMapping {
  const BundleInspectionTypeMapping({
    required this.mappingId,
    required this.bundleId,
    required this.inspectionTypeId,
    required this.displayOrder,
    required this.mandatoryFlag,
    required this.inclusionMode,
    required this.activeFlag,
  });

  final String mappingId;
  final String bundleId;
  final String inspectionTypeId;
  final int displayOrder;
  final bool mandatoryFlag;
  final BundleInclusionMode inclusionMode;
  final bool activeFlag;

  BundleInspectionTypeMapping copyWith({
    String? mappingId,
    String? bundleId,
    String? inspectionTypeId,
    int? displayOrder,
    bool? mandatoryFlag,
    BundleInclusionMode? inclusionMode,
    bool? activeFlag,
  }) {
    return BundleInspectionTypeMapping(
      mappingId: mappingId ?? this.mappingId,
      bundleId: bundleId ?? this.bundleId,
      inspectionTypeId: inspectionTypeId ?? this.inspectionTypeId,
      displayOrder: displayOrder ?? this.displayOrder,
      mandatoryFlag: mandatoryFlag ?? this.mandatoryFlag,
      inclusionMode: inclusionMode ?? this.inclusionMode,
      activeFlag: activeFlag ?? this.activeFlag,
    );
  }
}

class InspectionTemplateMasterV2 {
  const InspectionTemplateMasterV2({
    required this.templateId,
    required this.inspectionTypeId,
    required this.templateCode,
    required this.templateName,
    required this.version,
    required this.status,
    required this.effectiveFrom,
    required this.effectiveTo,
    required this.clientId,
    required this.vehicleType,
    required this.trailerType,
    required this.cargoType,
    required this.routeType,
    required this.requiresApproval,
    required this.blocksDispatchOnFail,
    required this.activeFlag,
    required this.clonedFromVersion,
    required this.publishedBy,
    required this.publishedAt,
  });

  final String templateId;
  final String inspectionTypeId;
  final String templateCode;
  final String templateName;
  final String version;
  final TemplateStatus status;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
  final String clientId;
  final String vehicleType;
  final String trailerType;
  final String cargoType;
  final String routeType;
  final bool requiresApproval;
  final bool blocksDispatchOnFail;
  final bool activeFlag;
  final String? clonedFromVersion;
  final String publishedBy;
  final DateTime publishedAt;

  InspectionTemplateMasterV2 copyWith({
    String? templateId,
    String? inspectionTypeId,
    String? templateCode,
    String? templateName,
    String? version,
    TemplateStatus? status,
    DateTime? effectiveFrom,
    DateTime? effectiveTo,
    String? clientId,
    String? vehicleType,
    String? trailerType,
    String? cargoType,
    String? routeType,
    bool? requiresApproval,
    bool? blocksDispatchOnFail,
    bool? activeFlag,
    String? clonedFromVersion,
    String? publishedBy,
    DateTime? publishedAt,
  }) {
    return InspectionTemplateMasterV2(
      templateId: templateId ?? this.templateId,
      inspectionTypeId: inspectionTypeId ?? this.inspectionTypeId,
      templateCode: templateCode ?? this.templateCode,
      templateName: templateName ?? this.templateName,
      version: version ?? this.version,
      status: status ?? this.status,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveTo: effectiveTo ?? this.effectiveTo,
      clientId: clientId ?? this.clientId,
      vehicleType: vehicleType ?? this.vehicleType,
      trailerType: trailerType ?? this.trailerType,
      cargoType: cargoType ?? this.cargoType,
      routeType: routeType ?? this.routeType,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      blocksDispatchOnFail: blocksDispatchOnFail ?? this.blocksDispatchOnFail,
      activeFlag: activeFlag ?? this.activeFlag,
      clonedFromVersion: clonedFromVersion ?? this.clonedFromVersion,
      publishedBy: publishedBy ?? this.publishedBy,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }
}

class TemplateSectionMasterV2 {
  const TemplateSectionMasterV2({
    required this.sectionId,
    required this.templateId,
    required this.sectionCode,
    required this.sectionName,
    required this.description,
    required this.displayOrder,
    required this.collapsibleFlag,
    required this.visibleInSummaryFlag,
    required this.stageTag,
    required this.activeFlag,
  });

  final String sectionId;
  final String templateId;
  final String sectionCode;
  final String sectionName;
  final String description;
  final int displayOrder;
  final bool collapsibleFlag;
  final bool visibleInSummaryFlag;
  final String stageTag;
  final bool activeFlag;

  TemplateSectionMasterV2 copyWith({
    String? sectionId,
    String? templateId,
    String? sectionCode,
    String? sectionName,
    String? description,
    int? displayOrder,
    bool? collapsibleFlag,
    bool? visibleInSummaryFlag,
    String? stageTag,
    bool? activeFlag,
  }) {
    return TemplateSectionMasterV2(
      sectionId: sectionId ?? this.sectionId,
      templateId: templateId ?? this.templateId,
      sectionCode: sectionCode ?? this.sectionCode,
      sectionName: sectionName ?? this.sectionName,
      description: description ?? this.description,
      displayOrder: displayOrder ?? this.displayOrder,
      collapsibleFlag: collapsibleFlag ?? this.collapsibleFlag,
      visibleInSummaryFlag: visibleInSummaryFlag ?? this.visibleInSummaryFlag,
      stageTag: stageTag ?? this.stageTag,
      activeFlag: activeFlag ?? this.activeFlag,
    );
  }
}

class TemplateItemMasterV2 {
  const TemplateItemMasterV2({
    required this.itemId,
    required this.sectionId,
    required this.itemCode,
    required this.itemName,
    required this.itemDescription,
    required this.inputType,
    required this.severity,
    required this.mandatoryFlag,
    required this.requiresRemarkOnFail,
    required this.requiresPhotoOnFail,
    required this.requiresVideoOnFail,
    required this.dispatchBlockerFlag,
    required this.defaultExpectedValue,
    required this.displayOrder,
    required this.helpText,
    required this.activeFlag,
  });

  final String itemId;
  final String sectionId;
  final String itemCode;
  final String itemName;
  final String itemDescription;
  final InspectionInputType inputType;
  final InspectionFailureSeverity severity;
  final bool mandatoryFlag;
  final bool requiresRemarkOnFail;
  final bool requiresPhotoOnFail;
  final bool requiresVideoOnFail;
  final bool dispatchBlockerFlag;
  final String defaultExpectedValue;
  final int displayOrder;
  final String helpText;
  final bool activeFlag;

  TemplateItemMasterV2 copyWith({
    String? itemId,
    String? sectionId,
    String? itemCode,
    String? itemName,
    String? itemDescription,
    InspectionInputType? inputType,
    InspectionFailureSeverity? severity,
    bool? mandatoryFlag,
    bool? requiresRemarkOnFail,
    bool? requiresPhotoOnFail,
    bool? requiresVideoOnFail,
    bool? dispatchBlockerFlag,
    String? defaultExpectedValue,
    int? displayOrder,
    String? helpText,
    bool? activeFlag,
  }) {
    return TemplateItemMasterV2(
      itemId: itemId ?? this.itemId,
      sectionId: sectionId ?? this.sectionId,
      itemCode: itemCode ?? this.itemCode,
      itemName: itemName ?? this.itemName,
      itemDescription: itemDescription ?? this.itemDescription,
      inputType: inputType ?? this.inputType,
      severity: severity ?? this.severity,
      mandatoryFlag: mandatoryFlag ?? this.mandatoryFlag,
      requiresRemarkOnFail: requiresRemarkOnFail ?? this.requiresRemarkOnFail,
      requiresPhotoOnFail: requiresPhotoOnFail ?? this.requiresPhotoOnFail,
      requiresVideoOnFail: requiresVideoOnFail ?? this.requiresVideoOnFail,
      dispatchBlockerFlag: dispatchBlockerFlag ?? this.dispatchBlockerFlag,
      defaultExpectedValue: defaultExpectedValue ?? this.defaultExpectedValue,
      displayOrder: displayOrder ?? this.displayOrder,
      helpText: helpText ?? this.helpText,
      activeFlag: activeFlag ?? this.activeFlag,
    );
  }
}

class ApplicabilityRuleMaster {
  const ApplicabilityRuleMaster({
    required this.ruleId,
    required this.targetLevel,
    required this.targetId,
    required this.conditionField,
    required this.operator,
    required this.conditionValue,
    required this.action,
    required this.priority,
    required this.activeFlag,
  });

  final String ruleId;
  final RuleTargetLevel targetLevel;
  final String targetId;
  final String conditionField;
  final RuleOperator operator;
  final String conditionValue;
  final RuleAction action;
  final int priority;
  final bool activeFlag;

  ApplicabilityRuleMaster copyWith({
    String? ruleId,
    RuleTargetLevel? targetLevel,
    String? targetId,
    String? conditionField,
    RuleOperator? operator,
    String? conditionValue,
    RuleAction? action,
    int? priority,
    bool? activeFlag,
  }) {
    return ApplicabilityRuleMaster(
      ruleId: ruleId ?? this.ruleId,
      targetLevel: targetLevel ?? this.targetLevel,
      targetId: targetId ?? this.targetId,
      conditionField: conditionField ?? this.conditionField,
      operator: operator ?? this.operator,
      conditionValue: conditionValue ?? this.conditionValue,
      action: action ?? this.action,
      priority: priority ?? this.priority,
      activeFlag: activeFlag ?? this.activeFlag,
    );
  }
}

class ValidationRuleMaster {
  const ValidationRuleMaster({
    required this.validationId,
    required this.targetLevel,
    required this.targetId,
    required this.triggerEvent,
    required this.validationExpression,
    required this.errorMessage,
    required this.blockingType,
    required this.activeFlag,
  });

  final String validationId;
  final RuleTargetLevel targetLevel;
  final String targetId;
  final String triggerEvent;
  final String validationExpression;
  final String errorMessage;
  final BlockingType blockingType;
  final bool activeFlag;

  ValidationRuleMaster copyWith({
    String? validationId,
    RuleTargetLevel? targetLevel,
    String? targetId,
    String? triggerEvent,
    String? validationExpression,
    String? errorMessage,
    BlockingType? blockingType,
    bool? activeFlag,
  }) {
    return ValidationRuleMaster(
      validationId: validationId ?? this.validationId,
      targetLevel: targetLevel ?? this.targetLevel,
      targetId: targetId ?? this.targetId,
      triggerEvent: triggerEvent ?? this.triggerEvent,
      validationExpression: validationExpression ?? this.validationExpression,
      errorMessage: errorMessage ?? this.errorMessage,
      blockingType: blockingType ?? this.blockingType,
      activeFlag: activeFlag ?? this.activeFlag,
    );
  }
}

class ResultLogicRuleMaster {
  const ResultLogicRuleMaster({
    required this.resultRuleId,
    required this.targetScope,
    required this.targetId,
    required this.priority,
    required this.conditionExpression,
    required this.outputStatus,
    required this.outputResult,
    required this.activeFlag,
  });

  final String resultRuleId;
  final RuleTargetLevel targetScope;
  final String targetId;
  final int priority;
  final String conditionExpression;
  final InspectionStatus outputStatus;
  final InspectionResult outputResult;
  final bool activeFlag;

  ResultLogicRuleMaster copyWith({
    String? resultRuleId,
    RuleTargetLevel? targetScope,
    String? targetId,
    int? priority,
    String? conditionExpression,
    InspectionStatus? outputStatus,
    InspectionResult? outputResult,
    bool? activeFlag,
  }) {
    return ResultLogicRuleMaster(
      resultRuleId: resultRuleId ?? this.resultRuleId,
      targetScope: targetScope ?? this.targetScope,
      targetId: targetId ?? this.targetId,
      priority: priority ?? this.priority,
      conditionExpression: conditionExpression ?? this.conditionExpression,
      outputStatus: outputStatus ?? this.outputStatus,
      outputResult: outputResult ?? this.outputResult,
      activeFlag: activeFlag ?? this.activeFlag,
    );
  }
}

class MediaRequirementRuleMaster {
  const MediaRequirementRuleMaster({
    required this.mediaRuleId,
    required this.targetLevel,
    required this.targetId,
    required this.mediaType,
    required this.mandatoryFlag,
    required this.minCount,
    required this.maxCount,
    required this.allowedOnResult,
    required this.activeFlag,
  });

  final String mediaRuleId;
  final RuleTargetLevel targetLevel;
  final String targetId;
  final MediaType mediaType;
  final bool mandatoryFlag;
  final int minCount;
  final int maxCount;
  final AllowedOnResult allowedOnResult;
  final bool activeFlag;

  MediaRequirementRuleMaster copyWith({
    String? mediaRuleId,
    RuleTargetLevel? targetLevel,
    String? targetId,
    MediaType? mediaType,
    bool? mandatoryFlag,
    int? minCount,
    int? maxCount,
    AllowedOnResult? allowedOnResult,
    bool? activeFlag,
  }) {
    return MediaRequirementRuleMaster(
      mediaRuleId: mediaRuleId ?? this.mediaRuleId,
      targetLevel: targetLevel ?? this.targetLevel,
      targetId: targetId ?? this.targetId,
      mediaType: mediaType ?? this.mediaType,
      mandatoryFlag: mandatoryFlag ?? this.mandatoryFlag,
      minCount: minCount ?? this.minCount,
      maxCount: maxCount ?? this.maxCount,
      allowedOnResult: allowedOnResult ?? this.allowedOnResult,
      activeFlag: activeFlag ?? this.activeFlag,
    );
  }
}

class ApprovalMatrixRuleMaster {
  const ApprovalMatrixRuleMaster({
    required this.approvalRuleId,
    required this.targetScope,
    required this.targetId,
    required this.conditionExpression,
    required this.approverRole,
    required this.escalationRole,
    required this.overrideAllowedFlag,
    required this.activeFlag,
  });

  final String approvalRuleId;
  final RuleTargetLevel targetScope;
  final String targetId;
  final String conditionExpression;
  final String approverRole;
  final String escalationRole;
  final bool overrideAllowedFlag;
  final bool activeFlag;

  ApprovalMatrixRuleMaster copyWith({
    String? approvalRuleId,
    RuleTargetLevel? targetScope,
    String? targetId,
    String? conditionExpression,
    String? approverRole,
    String? escalationRole,
    bool? overrideAllowedFlag,
    bool? activeFlag,
  }) {
    return ApprovalMatrixRuleMaster(
      approvalRuleId: approvalRuleId ?? this.approvalRuleId,
      targetScope: targetScope ?? this.targetScope,
      targetId: targetId ?? this.targetId,
      conditionExpression: conditionExpression ?? this.conditionExpression,
      approverRole: approverRole ?? this.approverRole,
      escalationRole: escalationRole ?? this.escalationRole,
      overrideAllowedFlag: overrideAllowedFlag ?? this.overrideAllowedFlag,
      activeFlag: activeFlag ?? this.activeFlag,
    );
  }
}

class InspectionMasterCatalog {
  const InspectionMasterCatalog({
    required this.bundles,
    required this.inspectionTypes,
    required this.bundleTypeMappings,
    required this.templates,
    required this.sections,
    required this.items,
    required this.applicabilityRules,
    required this.validationRules,
    required this.resultRules,
    required this.mediaRules,
    required this.approvalRules,
  });

  final List<InspectionBundleMaster> bundles;
  final List<InspectionTypeMasterV2> inspectionTypes;
  final List<BundleInspectionTypeMapping> bundleTypeMappings;
  final List<InspectionTemplateMasterV2> templates;
  final List<TemplateSectionMasterV2> sections;
  final List<TemplateItemMasterV2> items;
  final List<ApplicabilityRuleMaster> applicabilityRules;
  final List<ValidationRuleMaster> validationRules;
  final List<ResultLogicRuleMaster> resultRules;
  final List<MediaRequirementRuleMaster> mediaRules;
  final List<ApprovalMatrixRuleMaster> approvalRules;

  InspectionMasterCatalog copyWith({
    List<InspectionBundleMaster>? bundles,
    List<InspectionTypeMasterV2>? inspectionTypes,
    List<BundleInspectionTypeMapping>? bundleTypeMappings,
    List<InspectionTemplateMasterV2>? templates,
    List<TemplateSectionMasterV2>? sections,
    List<TemplateItemMasterV2>? items,
    List<ApplicabilityRuleMaster>? applicabilityRules,
    List<ValidationRuleMaster>? validationRules,
    List<ResultLogicRuleMaster>? resultRules,
    List<MediaRequirementRuleMaster>? mediaRules,
    List<ApprovalMatrixRuleMaster>? approvalRules,
  }) {
    return InspectionMasterCatalog(
      bundles: bundles ?? this.bundles,
      inspectionTypes: inspectionTypes ?? this.inspectionTypes,
      bundleTypeMappings: bundleTypeMappings ?? this.bundleTypeMappings,
      templates: templates ?? this.templates,
      sections: sections ?? this.sections,
      items: items ?? this.items,
      applicabilityRules: applicabilityRules ?? this.applicabilityRules,
      validationRules: validationRules ?? this.validationRules,
      resultRules: resultRules ?? this.resultRules,
      mediaRules: mediaRules ?? this.mediaRules,
      approvalRules: approvalRules ?? this.approvalRules,
    );
  }
}
