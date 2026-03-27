import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/inspection.dart';
import '../../domain/entities/inspection_master_v2.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/inspection_master_v2_viewmodel.dart';
import '../widgets/ops_shell.dart';

class InspectionMasterCatalogScreen extends ConsumerWidget {
  const InspectionMasterCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(inspectionMasterCatalogProvider);

    return OpsShell(
      title: 'Inspection Master Catalog',
      currentRoute: RoutePaths.inspectionMasterCatalog,
      actions: [
        TextButton.icon(
          onPressed: () => context.go(RoutePaths.inspectionBundleMaster),
          icon: const Icon(Icons.view_module_outlined),
          label: const Text('Bundle Master'),
        ),
        TextButton.icon(
          onPressed: () => context.go(RoutePaths.inspectionTypeMaster),
          icon: const Icon(Icons.category_outlined),
          label: const Text('Type Master'),
        ),
        TextButton.icon(
          onPressed: () =>
              context.go(RoutePaths.inspectionBundleTypeMappingMaster),
          icon: const Icon(Icons.account_tree_outlined),
          label: const Text('Bundle-Type Mapping'),
        ),
        TextButton.icon(
          onPressed: () => context.go(RoutePaths.inspectionTemplateMaster),
          icon: const Icon(Icons.description_outlined),
          label: const Text('Template Master'),
        ),
        TextButton.icon(
          onPressed: () =>
              context.go(RoutePaths.inspectionTemplateSectionMaster),
          icon: const Icon(Icons.segment_outlined),
          label: const Text('Section Master'),
        ),
        TextButton.icon(
          onPressed: () => context.go(RoutePaths.inspectionTemplateItemMaster),
          icon: const Icon(Icons.checklist_outlined),
          label: const Text('Item Master'),
        ),
        TextButton.icon(
          onPressed: () =>
              context.go(RoutePaths.inspectionApplicabilityRuleMaster),
          icon: const Icon(Icons.rule_outlined),
          label: const Text('Applicability Rules'),
        ),
        TextButton.icon(
          onPressed: () =>
              context.go(RoutePaths.inspectionValidationRuleMaster),
          icon: const Icon(Icons.verified_outlined),
          label: const Text('Validation Rules'),
        ),
        TextButton.icon(
          onPressed: () =>
              context.go(RoutePaths.inspectionResultLogicRuleMaster),
          icon: const Icon(Icons.functions_outlined),
          label: const Text('Result Logic Rules'),
        ),
        TextButton.icon(
          onPressed: () => context.go(RoutePaths.inspectionMediaRuleMaster),
          icon: const Icon(Icons.perm_media_outlined),
          label: const Text('Media Rules'),
        ),
        TextButton.icon(
          onPressed: () =>
              context.go(RoutePaths.inspectionApprovalMatrixMaster),
          icon: const Icon(Icons.how_to_reg_outlined),
          label: const Text('Approval Matrix'),
        ),
        TextButton.icon(
          onPressed: () => context.go(RoutePaths.inspectionTemplates),
          icon: const Icon(Icons.list_alt_outlined),
          label: const Text('Template Register'),
        ),
        FilledButton.icon(
          onPressed: () => context.go(RoutePaths.inspectionTemplateForm),
          icon: const Icon(Icons.add),
          label: const Text('Add Template'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            color: const Color(0xFFEEF6FF),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'This screen is a master catalog viewer. Add/Edit is enabled for Template Master through the top actions and row actions.',
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  _kpi('Bundles', '${catalog.bundles.length}'),
                  _kpi('Types', '${catalog.inspectionTypes.length}'),
                  _kpi('Templates', '${catalog.templates.length}'),
                  _kpi('Sections', '${catalog.sections.length}'),
                  _kpi('Items', '${catalog.items.length}'),
                  _kpi('Applicability Rules',
                      '${catalog.applicabilityRules.length}'),
                  _kpi('Validation Rules', '${catalog.validationRules.length}'),
                  _kpi('Result Rules', '${catalog.resultRules.length}'),
                  _kpi('Media Rules', '${catalog.mediaRules.length}'),
                  _kpi('Approval Rules', '${catalog.approvalRules.length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _section(
            title: 'Bundle Master',
            children: [
              for (final item in catalog.bundles)
                _line('${item.bundleCode} (${item.version})',
                    '${item.bundleName} | stage: ${_stage(item.stage)} | active: ${item.activeFlag ? 'Yes' : 'No'}'),
            ],
          ),
          _section(
            title: 'Inspection Type Master',
            children: [
              for (final item in catalog.inspectionTypes)
                _line(item.code,
                    '${item.name} | object: ${_object(item.objectType)} | stage: ${_stage(item.stage)}'),
            ],
          ),
          _section(
            title: 'Bundle-Type Mapping',
            children: [
              for (final item in catalog.bundleTypeMappings)
                _line(item.mappingId,
                    'bundle: ${item.bundleId} -> type: ${item.inspectionTypeId} | order: ${item.displayOrder} | mandatory: ${item.mandatoryFlag ? 'Yes' : 'No'}'),
            ],
          ),
          _section(
            title: 'Template Master',
            children: [
              for (final item in catalog.templates)
                _line(
                  item.templateCode,
                  '${item.templateName} | v${item.version} | client: ${item.clientId} | vehicle: ${item.vehicleType} | cargo: ${item.cargoType}',
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        tooltip: 'View template',
                        onPressed: () => context.go(
                          RoutePaths.inspectionTemplateViewById(
                              item.templateId),
                        ),
                        icon: const Icon(Icons.open_in_new_rounded),
                      ),
                      IconButton(
                        tooltip: 'Edit template',
                        onPressed: () => context.go(
                          RoutePaths.editInspectionTemplateById(
                              item.templateId),
                        ),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          _section(
            title: 'Section Master',
            children: [
              for (final item in catalog.sections)
                _line(item.sectionCode,
                    '${item.sectionName} | template: ${item.templateId} | order: ${item.displayOrder}'),
            ],
          ),
          _section(
            title: 'Item Master',
            children: [
              for (final item in catalog.items)
                _line(item.itemCode,
                    '${item.itemName} | type: ${_inputType(item.inputType)} | severity: ${item.severity.label} | mandatory: ${item.mandatoryFlag ? 'Yes' : 'No'}'),
            ],
          ),
          _section(
            title: 'Applicability Rules',
            children: [
              for (final item in catalog.applicabilityRules)
                _line(item.ruleId,
                    '${item.targetLevel.name}:${item.targetId} | ${item.conditionField} ${item.operator.name} ${item.conditionValue} -> ${item.action.name}'),
            ],
          ),
          _section(
            title: 'Validation Rules',
            children: [
              for (final item in catalog.validationRules)
                _line(item.validationId,
                    '${item.blockingType.name} | ${item.triggerEvent} | ${item.validationExpression}'),
            ],
          ),
          _section(
            title: 'Result Logic Rules',
            children: [
              for (final item in catalog.resultRules)
                _line(item.resultRuleId,
                    'priority ${item.priority} | ${item.conditionExpression} -> ${item.outputStatus.label}/${item.outputResult.label}'),
            ],
          ),
          _section(
            title: 'Media Requirement Rules',
            children: [
              for (final item in catalog.mediaRules)
                _line(item.mediaRuleId,
                    '${item.targetLevel.name}:${item.targetId} | ${item.mediaType.name} ${item.minCount}-${item.maxCount} | mandatory: ${item.mandatoryFlag ? 'Yes' : 'No'}'),
            ],
          ),
          _section(
            title: 'Approval Matrix Rules',
            children: [
              for (final item in catalog.approvalRules)
                _line(item.approvalRuleId,
                    '${item.conditionExpression} -> ${item.approverRole} (esc: ${item.escalationRole}) | override: ${item.overrideAllowedFlag ? 'Yes' : 'No'}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kpi(String label, String value) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFF4F7FE),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }

  Widget _section({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        initiallyExpanded:
            title == 'Bundle Master' || title == 'Template Master',
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        children: children,
      ),
    );
  }

  Widget _line(String title, String subtitle, {Widget? trailing}) {
    return ListTile(
      dense: true,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: trailing,
    );
  }

  String _stage(InspectionStage value) {
    switch (value) {
      case InspectionStage.beforeDispatch:
        return 'Before Dispatch';
      case InspectionStage.duringTrip:
        return 'During Trip';
      case InspectionStage.postTrip:
        return 'Post Trip';
    }
  }

  String _object(InspectionObjectType value) {
    switch (value) {
      case InspectionObjectType.fleet:
        return 'Fleet';
      case InspectionObjectType.trailer:
        return 'Trailer';
      case InspectionObjectType.driver:
        return 'Driver';
      case InspectionObjectType.workOrder:
        return 'Work Order';
      case InspectionObjectType.trip:
        return 'Trip';
      case InspectionObjectType.cargo:
        return 'Cargo';
    }
  }

  String _inputType(InspectionInputType value) {
    switch (value) {
      case InspectionInputType.passFail:
        return 'Pass/Fail';
      case InspectionInputType.yesNo:
        return 'Yes/No';
      case InspectionInputType.text:
        return 'Text';
      case InspectionInputType.number:
        return 'Number';
      case InspectionInputType.date:
        return 'Date';
      case InspectionInputType.expiryCheck:
        return 'Expiry Check';
      case InspectionInputType.dropdown:
        return 'Dropdown';
      case InspectionInputType.photoOnly:
        return 'Photo Only';
      case InspectionInputType.videoOnly:
        return 'Video Only';
    }
  }
}
