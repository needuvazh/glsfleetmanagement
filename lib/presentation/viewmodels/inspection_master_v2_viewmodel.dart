import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/inspection_master_v2_mock_datasource.dart';
import '../../domain/entities/inspection_master_v2.dart';

final inspectionMasterCatalogProvider =
    NotifierProvider<InspectionMasterCatalogNotifier, InspectionMasterCatalog>(
  InspectionMasterCatalogNotifier.new,
);

class InspectionMasterCatalogNotifier
    extends Notifier<InspectionMasterCatalog> {
  @override
  InspectionMasterCatalog build() {
    return InspectionMasterV2MockDataSource.catalog();
  }

  void upsertBundle(InspectionBundleMaster bundle) {
    final next = [...state.bundles];
    final idx = next.indexWhere((item) => item.bundleId == bundle.bundleId);
    if (idx >= 0) {
      next[idx] = bundle;
    } else {
      next.insert(0, bundle);
    }
    state = state.copyWith(bundles: next);
  }

  void toggleBundleActive(String bundleId) {
    final next = [
      for (final item in state.bundles)
        if (item.bundleId == bundleId)
          item.copyWith(activeFlag: !item.activeFlag)
        else
          item,
    ];
    state = state.copyWith(bundles: next);
  }

  String nextBundleId() {
    return 'BND-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  void upsertInspectionType(InspectionTypeMasterV2 inspectionType) {
    final next = [...state.inspectionTypes];
    final idx = next.indexWhere(
      (item) => item.inspectionTypeId == inspectionType.inspectionTypeId,
    );
    if (idx >= 0) {
      next[idx] = inspectionType;
    } else {
      next.insert(0, inspectionType);
    }
    state = state.copyWith(inspectionTypes: next);
  }

  void toggleInspectionTypeActive(String inspectionTypeId) {
    final next = [
      for (final item in state.inspectionTypes)
        if (item.inspectionTypeId == inspectionTypeId)
          item.copyWith(activeFlag: !item.activeFlag)
        else
          item,
    ];
    state = state.copyWith(inspectionTypes: next);
  }

  String nextInspectionTypeId() {
    return 'IT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  void upsertBundleTypeMapping(BundleInspectionTypeMapping mapping) {
    final next = [...state.bundleTypeMappings];
    final idx = next.indexWhere((item) => item.mappingId == mapping.mappingId);
    if (idx >= 0) {
      next[idx] = mapping;
    } else {
      next.insert(0, mapping);
    }
    state = state.copyWith(bundleTypeMappings: next);
  }

  void toggleBundleTypeMappingActive(String mappingId) {
    final next = [
      for (final item in state.bundleTypeMappings)
        if (item.mappingId == mappingId)
          item.copyWith(activeFlag: !item.activeFlag)
        else
          item,
    ];
    state = state.copyWith(bundleTypeMappings: next);
  }

  String nextBundleTypeMappingId() {
    return 'MAP-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  void upsertTemplate(InspectionTemplateMasterV2 template) {
    final next = [...state.templates];
    final idx =
        next.indexWhere((item) => item.templateId == template.templateId);
    if (idx >= 0) {
      next[idx] = template;
    } else {
      next.insert(0, template);
    }
    state = state.copyWith(templates: next);
  }

  void toggleTemplateActive(String templateId) {
    final next = [
      for (final item in state.templates)
        if (item.templateId == templateId)
          item.copyWith(activeFlag: !item.activeFlag)
        else
          item,
    ];
    state = state.copyWith(templates: next);
  }

  String nextTemplateId() {
    return 'TPL2-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  void upsertSection(TemplateSectionMasterV2 section) {
    final next = [...state.sections];
    final idx = next.indexWhere((item) => item.sectionId == section.sectionId);
    if (idx >= 0) {
      next[idx] = section;
    } else {
      next.insert(0, section);
    }
    state = state.copyWith(sections: next);
  }

  void toggleSectionActive(String sectionId) {
    final next = [
      for (final item in state.sections)
        if (item.sectionId == sectionId)
          item.copyWith(activeFlag: !item.activeFlag)
        else
          item,
    ];
    state = state.copyWith(sections: next);
  }

  String nextSectionId() {
    return 'SEC-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  void upsertItem(TemplateItemMasterV2 item) {
    final next = [...state.items];
    final idx = next.indexWhere((entry) => entry.itemId == item.itemId);
    if (idx >= 0) {
      next[idx] = item;
    } else {
      next.insert(0, item);
    }
    state = state.copyWith(items: next);
  }

  void toggleItemActive(String itemId) {
    final next = [
      for (final item in state.items)
        if (item.itemId == itemId)
          item.copyWith(activeFlag: !item.activeFlag)
        else
          item,
    ];
    state = state.copyWith(items: next);
  }

  String nextItemId() {
    return 'ITM-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  void upsertApplicabilityRule(ApplicabilityRuleMaster rule) {
    final next = [...state.applicabilityRules];
    final idx = next.indexWhere((entry) => entry.ruleId == rule.ruleId);
    if (idx >= 0) {
      next[idx] = rule;
    } else {
      next.insert(0, rule);
    }
    state = state.copyWith(applicabilityRules: next);
  }

  void toggleApplicabilityRuleActive(String ruleId) {
    final next = [
      for (final item in state.applicabilityRules)
        if (item.ruleId == ruleId)
          item.copyWith(activeFlag: !item.activeFlag)
        else
          item,
    ];
    state = state.copyWith(applicabilityRules: next);
  }

  String nextApplicabilityRuleId() {
    return 'APP-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  void upsertValidationRule(ValidationRuleMaster rule) {
    final next = [...state.validationRules];
    final idx =
        next.indexWhere((entry) => entry.validationId == rule.validationId);
    if (idx >= 0) {
      next[idx] = rule;
    } else {
      next.insert(0, rule);
    }
    state = state.copyWith(validationRules: next);
  }

  void toggleValidationRuleActive(String validationId) {
    final next = [
      for (final item in state.validationRules)
        if (item.validationId == validationId)
          item.copyWith(activeFlag: !item.activeFlag)
        else
          item,
    ];
    state = state.copyWith(validationRules: next);
  }

  String nextValidationRuleId() {
    return 'VAL-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  void upsertResultRule(ResultLogicRuleMaster rule) {
    final next = [...state.resultRules];
    final idx =
        next.indexWhere((entry) => entry.resultRuleId == rule.resultRuleId);
    if (idx >= 0) {
      next[idx] = rule;
    } else {
      next.insert(0, rule);
    }
    state = state.copyWith(resultRules: next);
  }

  void toggleResultRuleActive(String resultRuleId) {
    final next = [
      for (final item in state.resultRules)
        if (item.resultRuleId == resultRuleId)
          item.copyWith(activeFlag: !item.activeFlag)
        else
          item,
    ];
    state = state.copyWith(resultRules: next);
  }

  String nextResultRuleId() {
    return 'RES-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  void upsertMediaRule(MediaRequirementRuleMaster rule) {
    final next = [...state.mediaRules];
    final idx =
        next.indexWhere((entry) => entry.mediaRuleId == rule.mediaRuleId);
    if (idx >= 0) {
      next[idx] = rule;
    } else {
      next.insert(0, rule);
    }
    state = state.copyWith(mediaRules: next);
  }

  void toggleMediaRuleActive(String mediaRuleId) {
    final next = [
      for (final item in state.mediaRules)
        if (item.mediaRuleId == mediaRuleId)
          item.copyWith(activeFlag: !item.activeFlag)
        else
          item,
    ];
    state = state.copyWith(mediaRules: next);
  }

  String nextMediaRuleId() {
    return 'MED-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  void upsertApprovalRule(ApprovalMatrixRuleMaster rule) {
    final next = [...state.approvalRules];
    final idx =
        next.indexWhere((entry) => entry.approvalRuleId == rule.approvalRuleId);
    if (idx >= 0) {
      next[idx] = rule;
    } else {
      next.insert(0, rule);
    }
    state = state.copyWith(approvalRules: next);
  }

  void toggleApprovalRuleActive(String approvalRuleId) {
    final next = [
      for (final item in state.approvalRules)
        if (item.approvalRuleId == approvalRuleId)
          item.copyWith(activeFlag: !item.activeFlag)
        else
          item,
    ];
    state = state.copyWith(approvalRules: next);
  }

  String nextApprovalRuleId() {
    return 'APR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }
}

final dispatchReadinessBundleProvider =
    Provider<InspectionBundleMaster?>((ref) {
  final catalog = ref.watch(inspectionMasterCatalogProvider);
  for (final bundle in catalog.bundles) {
    if (bundle.bundleCode == 'DISPATCH_READY' && bundle.activeFlag) {
      return bundle;
    }
  }
  return null;
});

final dispatchBundleTypeMappingsProvider =
    Provider<List<BundleInspectionTypeMapping>>((ref) {
  final catalog = ref.watch(inspectionMasterCatalogProvider);
  final bundle = ref.watch(dispatchReadinessBundleProvider);
  if (bundle == null) {
    return const [];
  }

  final mapped = catalog.bundleTypeMappings
      .where((item) => item.bundleId == bundle.bundleId && item.activeFlag)
      .toList()
    ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  return mapped;
});

final dispatchBundleTemplatesProvider =
    Provider<List<InspectionTemplateMasterV2>>((ref) {
  final catalog = ref.watch(inspectionMasterCatalogProvider);
  final mappings = ref.watch(dispatchBundleTypeMappingsProvider);
  final mappedTypeIds = mappings.map((item) => item.inspectionTypeId).toSet();

  return catalog.templates
      .where(
        (template) =>
            template.activeFlag &&
            mappedTypeIds.contains(template.inspectionTypeId),
      )
      .toList(growable: false);
});
