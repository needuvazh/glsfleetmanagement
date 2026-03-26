import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/compliance_assignment.dart';
import '../../domain/entities/inspection.dart';
import '../../domain/entities/logistics_flow.dart';
import '../../domain/entities/module_document.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/cargo_viewmodel.dart';
import '../viewmodels/compliance_assignment_viewmodel.dart';
import '../viewmodels/customer_viewmodel.dart';
import '../viewmodels/inspection_viewmodel.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../viewmodels/module_document_viewmodel.dart';
import '../widgets/ops_shell.dart';

class DispatchReadinessScreen extends ConsumerWidget {
  const DispatchReadinessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logistics = ref.watch(logisticsViewModelProvider);
    final inspections = ref.watch(inspectionViewModelProvider).items;
    final complianceState = ref.watch(moduleDocumentViewModelProvider);
    final customerState = ref.watch(customerViewModelProvider);
    final assignmentNotifier =
        ref.read(complianceAssignmentViewModelProvider.notifier);
    final customerRules =
        complianceState.valueOrNull?.rulesForApplicableTo('Customer') ??
            const <ModuleDocument>[];
    final cargoRules =
        complianceState.valueOrNull?.rulesForApplicableTo('Cargo') ??
            const <ModuleDocument>[];

    return OpsShell(
      title: 'Dispatch Readiness',
      currentRoute: RoutePaths.dispatchReadiness,
      child: logistics.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final rows = [
            for (final wo in data.workOrders)
              () {
                final customerId = _customerIdByName(
                  customerState,
                  wo.customer,
                );
                final cargoCode = ref
                    .read(cargoViewModelProvider.notifier)
                    .findByName(wo.cargo)
                    ?.cargoCode;
                final customerSummary = customerId == null
                    ? const ComplianceStageSummary(
                        stage: 'Dispatch',
                        enabledRules: 0,
                        warningRules: 0,
                        softBlockRules: 0,
                        hardBlockRules: 0,
                      )
                    : assignmentNotifier.evaluateStage(
                        entityType: 'Customer',
                        entityId: customerId,
                        stage: 'Dispatch',
                        rules: customerRules,
                      );
                final customerHardBlockRules = customerId == null
                    ? const <String>[]
                    : assignmentNotifier.listHardBlockRuleNames(
                        entityType: 'Customer',
                        entityId: customerId,
                        stage: 'Dispatch',
                        rules: customerRules,
                      );
                final cargoSummary = cargoCode == null
                    ? const ComplianceStageSummary(
                        stage: 'Dispatch',
                        enabledRules: 0,
                        warningRules: 0,
                        softBlockRules: 0,
                        hardBlockRules: 0,
                      )
                    : assignmentNotifier.evaluateStage(
                        entityType: 'Cargo',
                        entityId: cargoCode,
                        stage: 'Dispatch',
                        rules: cargoRules,
                      );
                final cargoHardBlockRules = cargoCode == null
                    ? const <String>[]
                    : assignmentNotifier.listHardBlockRuleNames(
                        entityType: 'Cargo',
                        entityId: cargoCode,
                        stage: 'Dispatch',
                        rules: cargoRules,
                      );
                return _DispatchRow.build(
                  wo: wo,
                  data: data,
                  inspections: inspections,
                  customerComplianceSummary: customerSummary,
                  cargoComplianceSummary: cargoSummary,
                  customerHardBlockRules: customerHardBlockRules,
                  cargoHardBlockRules: cargoHardBlockRules,
                );
              }(),
          ];

          return Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('WO Number')),
                  DataColumn(label: Text('Fleet')),
                  DataColumn(label: Text('Driver')),
                  DataColumn(label: Text('Inspection Status')),
                  DataColumn(label: Text('Compliance Readiness')),
                  DataColumn(label: Text('Dispatch Allowed')),
                  DataColumn(label: Text('Compliance Blocked By')),
                  DataColumn(label: Text('Validation')),
                ],
                rows: [
                  for (final row in rows)
                    DataRow(cells: [
                      DataCell(Text(row.woNumber)),
                      DataCell(Text(row.fleet)),
                      DataCell(Text(row.driver)),
                      DataCell(Text(row.inspectionStatus)),
                      DataCell(
                        Text(
                          row.complianceReadiness,
                          style: TextStyle(
                            color: row.allValid
                                ? const Color(0xFF15803D)
                                : const Color(0xFFD97706),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          row.dispatchAllowed ? 'Yes' : 'No',
                          style: TextStyle(
                            color: row.dispatchAllowed
                                ? const Color(0xFF15803D)
                                : const Color(0xFFB91C1C),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          row.blockRuleNames.isEmpty
                              ? '-'
                              : row.blockRuleNames.join(', '),
                          style: const TextStyle(
                            color: Color(0xFFB91C1C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DataCell(
                        TextButton.icon(
                          onPressed: () => _showValidationDialog(context, row),
                          icon: const Icon(Icons.rule_folder_outlined),
                          label: const Text('Checks'),
                        ),
                      ),
                    ]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showValidationDialog(BuildContext context, _DispatchRow row) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Validation • ${row.woNumber}'),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (row.blockRuleNames.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Text(
                      'Blocked by rules: ${row.blockRuleNames.join(', ')}',
                      style: const TextStyle(
                        color: Color(0xFFB91C1C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                for (final check in row.checks.entries)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      check.value
                          ? Icons.check_circle_outline
                          : Icons.block_outlined,
                      color: check.value
                          ? const Color(0xFF15803D)
                          : const Color(0xFFB91C1C),
                    ),
                    title: Text(check.key),
                    trailing: Text(check.value ? 'Yes' : 'No'),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _DispatchRow {
  const _DispatchRow({
    required this.woNumber,
    required this.fleet,
    required this.driver,
    required this.inspectionStatus,
    required this.complianceReadiness,
    required this.dispatchAllowed,
    required this.allValid,
    required this.checks,
    required this.complianceAlerts,
    required this.blockRuleNames,
  });

  final String woNumber;
  final String fleet;
  final String driver;
  final String inspectionStatus;
  final String complianceReadiness;
  final bool dispatchAllowed;
  final bool allValid;
  final Map<String, bool> checks;
  final List<String> complianceAlerts;
  final List<String> blockRuleNames;

  factory _DispatchRow.build({
    required WorkOrderFlowItem wo,
    required LogisticsUiState data,
    required List<InspectionRecord> inspections,
    required ComplianceStageSummary customerComplianceSummary,
    required ComplianceStageSummary cargoComplianceSummary,
    required List<String> customerHardBlockRules,
    required List<String> cargoHardBlockRules,
  }) {
    final isAssignedOrder = data.assignedOrderId == wo.woId;
    final fleet = isAssignedOrder ? (data.assignedVehicleNo ?? '-') : '-';
    final driver = isAssignedOrder ? (data.assignedDriverId ?? '-') : '-';

    InspectionRecord? latestInspection;
    for (final item in inspections) {
      if (item.workOrder == wo.woId) {
        latestInspection = item;
        break;
      }
    }

    final workOrderValid = wo.woId.trim().isNotEmpty;
    final assignmentCompleted = isAssignedOrder &&
        data.assignedVehicleNo != null &&
        data.assignedDriverId != null;
    final inspectionPassed = latestInspection != null &&
        latestInspection.overallResult == InspectionResult.passed &&
        !latestInspection.dispatchBlocked;
    final driverDocumentsValid = data.driverDocStatus == 'Valid' ||
        data.driverDocStatus == 'Expiring Soon';
    final fleetDocumentsValid = data.vehicleDocStatus == 'Valid' ||
        data.vehicleDocStatus == 'Expiring Soon';
    final journeyPlanReady = data.journeyApproved;
    final routeUsable = !wo.routeRestricted &&
        wo.routeOperationalStatus.toLowerCase() != 'inactive';

    final hash = wo.woId.codeUnits.fold<int>(0, (a, b) => a + b);
    final podRequired = hash % 2 == 0;
    final dnRequired = hash % 3 != 0;
    final proofRequirementsDefined = podRequired || dnRequired;

    final checks = <String, bool>{
      'Work Order Valid': workOrderValid,
      'Assignment Completed': assignmentCompleted,
      'Inspection Passed': inspectionPassed,
      'Driver Documents Valid': driverDocumentsValid,
      'Fleet Documents Valid': fleetDocumentsValid,
      'Journey Plan Ready': journeyPlanReady,
      'Route Usable': routeUsable,
      'Proof Requirements Defined': proofRequirementsDefined,
      'Customer Dispatch Compliance':
          customerComplianceSummary.hardBlockRules == 0,
      'Cargo Dispatch Compliance': cargoComplianceSummary.hardBlockRules == 0,
    };

    final complianceAlerts = <String>[];
    if (customerComplianceSummary.hardBlockRules > 0) {
      complianceAlerts.add('Customer');
    }
    if (cargoComplianceSummary.hardBlockRules > 0) {
      complianceAlerts.add('Cargo');
    }

    final blockRuleNames = <String>[
      for (final name in customerHardBlockRules) 'Customer: $name',
      for (final name in cargoHardBlockRules) 'Cargo: $name',
    ];

    final allValid = checks.values.every((value) => value);
    final dispatchAllowed = allValid;

    return _DispatchRow(
      woNumber: wo.woId,
      fleet: fleet,
      driver: driver,
      inspectionStatus: latestInspection == null
          ? 'Not Available'
          : latestInspection.overallResult.label,
      complianceReadiness: allValid ? 'Ready' : 'Attention Required',
      dispatchAllowed: dispatchAllowed,
      allValid: allValid,
      checks: checks,
      complianceAlerts: complianceAlerts,
      blockRuleNames: blockRuleNames,
    );
  }
}

String? _customerIdByName(CustomerState state, String customerName) {
  final normalized = customerName.trim().toLowerCase();
  if (normalized.isEmpty) {
    return null;
  }
  for (final customer in state.customers) {
    if (customer.name.trim().toLowerCase() == normalized) {
      return customer.id;
    }
  }
  return null;
}
