import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/cargo_model.dart';
import '../../domain/entities/module_document.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/cargo_viewmodel.dart';
import '../viewmodels/compliance_assignment_viewmodel.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../viewmodels/module_document_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class CargoViewScreen extends ConsumerWidget {
  const CargoViewScreen({super.key, required this.cargoCode});

  final String cargoCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cargoState = ref.watch(cargoViewModelProvider);
    final logisticsState = ref.watch(logisticsViewModelProvider);
    final complianceState = ref.watch(moduleDocumentViewModelProvider);
    final assignmentState = ref.watch(complianceAssignmentViewModelProvider);
    final cargoComplianceRules =
        complianceState.valueOrNull?.rulesForApplicableTo('Cargo') ??
            const <ModuleDocument>[];
    final cargoAssignments = assignmentState.assignmentsFor(
      entityType: 'Cargo',
      entityId: cargoCode,
    );

    return OpsShell(
      title: 'Cargo Details',
      currentRoute: RoutePaths.cargoMaster,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.cargoMaster),
          child: const Text('Back to List'),
        ),
      ],
      child: cargoState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (_) {
          final cargo =
              ref.read(cargoViewModelProvider.notifier).findByCode(cargoCode);
          if (cargo == null) {
            return const Center(child: Text('Cargo not found.'));
          }

          final logData = logisticsState.valueOrNull;
          final workOrders = logData?.workOrders ?? const [];
          final usage = workOrders
              .where((entry) =>
                  entry.cargo.trim().toLowerCase() ==
                  cargo.cargoName.trim().toLowerCase())
              .toList();
          final activeTrips = usage
              .where((entry) =>
                  entry.status.toLowerCase().contains('assign') ||
                  entry.status.toLowerCase().contains('trip') ||
                  entry.status.toLowerCase().contains('open'))
              .length;
          final delayedJobs = usage
              .where((entry) => entry.status.toLowerCase().contains('delay'))
              .length;
          final assignedRules =
              cargoAssignments.where((entry) => entry.enabled).length;
          final dispatchSummary = ref
              .read(complianceAssignmentViewModelProvider.notifier)
              .evaluateStage(
                entityType: 'Cargo',
                entityId: cargo.cargoCode,
                stage: 'Dispatch',
                rules: cargoComplianceRules,
              );
          final inspectionSummary = ref
              .read(complianceAssignmentViewModelProvider.notifier)
              .evaluateStage(
                entityType: 'Cargo',
                entityId: cargo.cargoCode,
                stage: 'Inspection',
                rules: cargoComplianceRules,
              );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: cargo.cargoName,
                subtitle: 'Operational cargo profile',
                icon: Icons.inventory_2_outlined,
                accent: const Color(0xFF0EA5E9),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _pill('Code', cargo.cargoCode),
                    _pill('Category', cargo.category),
                    _pill('Subcategory', cargo.subcategory),
                    _pill('Risk', cargo.riskLevel.label),
                    _pill('Hazardous', cargo.hazardous ? 'Yes' : 'No'),
                    _pill('Fragile', cargo.fragile ? 'Yes' : 'No'),
                    _pill(
                        'Status', cargo.isSelectable ? 'Active' : 'Restricted'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _card(
                title: 'Physical Characteristics',
                child: Column(
                  children: [
                    _pair('Weight Range', cargo.standardWeightRange),
                    _pair('Length', _fmtNumber(cargo.length)),
                    _pair('Width', _fmtNumber(cargo.width)),
                    _pair('Height', _fmtNumber(cargo.height)),
                    _pair('Size Class', cargo.volumeSizeClass),
                    _pair('Oversized', cargo.oversized ? 'Yes' : 'No'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _card(
                title: 'Operational Rules',
                child: Column(
                  children: [
                    _pair('Preferred Vehicle', cargo.preferredVehicleType),
                    _pair('Preferred Trailer', cargo.preferredTrailerType),
                    _pair('Loading Method', cargo.loadingMethod),
                    _pair('Unloading Method', cargo.unloadingMethod),
                    _pair('Lashing Required',
                        cargo.lashingRequired ? 'Yes' : 'No'),
                    _pair(
                        'Escort Required', cargo.escortRequired ? 'Yes' : 'No'),
                    _pair('Special Equipment', cargo.specialEquipmentRequired),
                    _pair('Handling Instructions', cargo.handlingInstructions),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _card(
                title: 'Compliance View',
                child: Column(
                  children: [
                    _pair('Derived Rule Source',
                        'Compliance Document Master (Applicable To = Cargo)'),
                    _pair('Enabled Central Rules',
                        '${cargoComplianceRules.where((rule) => rule.status.toLowerCase() == 'active').length}'),
                    _pair('Assigned Rules', '$assignedRules'),
                    _pair('Hard Block Rules',
                        '${cargoComplianceRules.where((rule) => rule.blockingType == 'Hard Block').length}'),
                    _pair('Dispatch Preview',
                        'Enabled ${dispatchSummary.enabledRules}, Hard ${dispatchSummary.hardBlockRules}, Soft ${dispatchSummary.softBlockRules}, Warn ${dispatchSummary.warningRules}'),
                    _pair('Inspection Preview',
                        'Enabled ${inspectionSummary.enabledRules}, Hard ${inspectionSummary.hardBlockRules}, Soft ${inspectionSummary.softBlockRules}, Warn ${inspectionSummary.warningRules}'),
                    _pair(
                      'Central Cargo Rules',
                      cargoComplianceRules.isEmpty
                          ? '-'
                          : cargoComplianceRules
                              .map((rule) =>
                                  '${rule.documentName} [${rule.requiredStageLabel}] ${rule.blockingType}')
                              .join(' | '),
                    ),
                    _pair('Special Compliance',
                        cargo.specialComplianceRequired ? 'Yes' : 'No'),
                    _pair(
                        'Required Certifications',
                        cargo.requiredCertifications.isEmpty
                            ? '-'
                            : cargo.requiredCertifications.join(', ')),
                    _pair(
                        'Required Permits',
                        cargo.requiredPermits.isEmpty
                            ? '-'
                            : cargo.requiredPermits.join(', ')),
                    _pair('Authority Approval',
                        cargo.authorityApprovalNeeded ? 'Yes' : 'No'),
                    _pair('Customer/Industry Restrictions',
                        cargo.customerIndustryRestrictions),
                    _pair('Compliance Notes', cargo.complianceNotes),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _card(
                title: 'Cargo Compliance Assignment',
                child: _complianceAssignmentSection(
                  ref: ref,
                  cargo: cargo,
                  rules: cargoComplianceRules,
                ),
              ),
              const SizedBox(height: 12),
              _card(
                title: 'Inspection View',
                child: Column(
                  children: [
                    _pair('Inspection Required',
                        cargo.inspectionRequired ? 'Yes' : 'No'),
                    _pair('Template Type', cargo.inspectionTemplateType),
                    _pair('Pre-dispatch',
                        cargo.preDispatchInspectionRequired ? 'Yes' : 'No'),
                    _pair('In-transit',
                        cargo.inTransitCheckRequired ? 'Yes' : 'No'),
                    _pair('Post-delivery',
                        cargo.postDeliveryCheckRequired ? 'Yes' : 'No'),
                    _pair('Photo Evidence Mandatory',
                        cargo.photoEvidenceMandatory ? 'Yes' : 'No'),
                    _pair('Video Evidence Mandatory',
                        cargo.videoEvidenceMandatory ? 'Yes' : 'No'),
                    _pair('Inspection Notes', cargo.inspectionNotes),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _card(
                title: 'Usage View',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _pair('Recent Work Orders', '${usage.length}'),
                    _pair('Active Trips', '$activeTrips'),
                    _pair('Delayed Jobs', '$delayedJobs'),
                    _pair(
                        'High-risk Jobs',
                        cargo.riskLevel == CargoRiskLevel.high ||
                                cargo.riskLevel == CargoRiskLevel.critical
                            ? '${usage.length}'
                            : '0'),
                    const SizedBox(height: 8),
                    const Text('Latest Work Orders'),
                    const SizedBox(height: 6),
                    if (usage.isEmpty)
                      const Text('-')
                    else
                      for (final item in usage.take(5))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                              '${item.woId} - ${item.customer} - ${item.status}'),
                        ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return OpsSectionCard(
      title: title,
      subtitle: '',
      icon: Icons.checklist_outlined,
      accent: const Color(0xFF2563EB),
      child: child,
    );
  }

  Widget _pill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Text('$label: ${value.trim().isEmpty ? '-' : value}'),
    );
  }

  Widget _pair(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 220,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value.trim().isEmpty ? '-' : value)),
        ],
      ),
    );
  }

  Widget _complianceAssignmentSection({
    required WidgetRef ref,
    required CargoModel cargo,
    required List<ModuleDocument> rules,
  }) {
    if (rules.isEmpty) {
      return const Text('No cargo compliance rules configured in master.');
    }
    final assignmentNotifier =
        ref.read(complianceAssignmentViewModelProvider.notifier);

    return Column(
      children: [
        for (int index = 0; index < rules.length; index++) ...[
          _ruleAssignmentRow(
            ref: ref,
            cargo: cargo,
            rule: rules[index],
            assignmentNotifier: assignmentNotifier,
          ),
          if (index != rules.length - 1) const Divider(height: 16),
        ],
      ],
    );
  }

  Widget _ruleAssignmentRow({
    required WidgetRef ref,
    required CargoModel cargo,
    required ModuleDocument rule,
    required ComplianceAssignmentViewModel assignmentNotifier,
  }) {
    final enabled = assignmentNotifier.isRuleEnabled(
      entityType: 'Cargo',
      entityId: cargo.cargoCode,
      ruleId: rule.id,
    );
    final note = assignmentNotifier.noteForRule(
      entityType: 'Cargo',
      entityId: cargo.cargoCode,
      ruleId: rule.id,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rule.documentName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${rule.requiredStageLabel} | ${rule.blockingType}',
                    style: const TextStyle(color: Color(0xFF4B5563)),
                  ),
                ],
              ),
            ),
            Switch(
              value: enabled,
              onChanged: (value) async {
                final message = await assignmentNotifier.setRuleEnabled(
                  entityType: 'Cargo',
                  entityId: cargo.cargoCode,
                  ruleId: rule.id,
                  enabled: value,
                );
                if (!ref.context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(ref.context)
                    .showSnackBar(SnackBar(content: Text(message)));
              },
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                note.trim().isEmpty ? 'No cargo-specific note' : 'Note: $note',
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                await _editRuleNote(
                  context: ref.context,
                  ref: ref,
                  entityType: 'Cargo',
                  entityId: cargo.cargoCode,
                  rule: rule,
                  initialNote: note,
                );
              },
              icon: const Icon(Icons.edit_note_outlined),
              label: const Text('Note'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _editRuleNote({
    required BuildContext context,
    required WidgetRef ref,
    required String entityType,
    required String entityId,
    required ModuleDocument rule,
    required String initialNote,
  }) async {
    final controller = TextEditingController(text: initialNote);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Note - ${rule.documentName}'),
          content: TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Cargo-specific instruction',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (result == null) {
      return;
    }

    final message = await ref
        .read(complianceAssignmentViewModelProvider.notifier)
        .setRuleNote(
          entityType: entityType,
          entityId: entityId,
          ruleId: rule.id,
          note: result,
        );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _fmtNumber(double? value) {
    if (value == null) {
      return '-';
    }
    return value.toStringAsFixed(2);
  }
}
