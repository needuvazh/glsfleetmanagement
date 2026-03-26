import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/compliance_assignment.dart';
import '../../domain/entities/logistics_flow.dart';
import '../../domain/entities/module_document.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/cargo_viewmodel.dart';
import '../viewmodels/compliance_assignment_viewmodel.dart';
import '../viewmodels/customer_viewmodel.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../viewmodels/module_document_viewmodel.dart';
import '../widgets/flow_stepper_card.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class ClosureScreen extends ConsumerStatefulWidget {
  const ClosureScreen({super.key});

  @override
  ConsumerState<ClosureScreen> createState() => _ClosureScreenState();
}

class _ClosureScreenState extends ConsumerState<ClosureScreen> {
  final _distance = TextEditingController(text: '350');
  final _fuelAvg = TextEditingController(text: '5.8');
  String _complianceStatus = 'Passed';
  bool _managerApproval = false;

  @override
  void dispose() {
    _distance.dispose();
    _fuelAvg.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logistics = ref.watch(logisticsViewModelProvider);
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

    final activeOrder = _resolveActiveOrder(logistics.valueOrNull);

    final customerId = _customerIdByName(customerState, activeOrder?.customer);
    final cargoCode = ref
        .read(cargoViewModelProvider.notifier)
        .findByName(activeOrder?.cargo)
        ?.cargoCode;

    final customerClosureSummary = customerId == null
        ? const ComplianceStageSummary(
            stage: 'Delivery Closure',
            enabledRules: 0,
            warningRules: 0,
            softBlockRules: 0,
            hardBlockRules: 0,
          )
        : assignmentNotifier.evaluateStage(
            entityType: 'Customer',
            entityId: customerId,
            stage: 'Delivery Closure',
            rules: customerRules,
          );
    final customerHardBlockRules = customerId == null
        ? const <String>[]
        : assignmentNotifier.listHardBlockRuleNames(
            entityType: 'Customer',
            entityId: customerId,
            stage: 'Delivery Closure',
            rules: customerRules,
          );

    final cargoClosureSummary = cargoCode == null
        ? const ComplianceStageSummary(
            stage: 'Delivery Closure',
            enabledRules: 0,
            warningRules: 0,
            softBlockRules: 0,
            hardBlockRules: 0,
          )
        : assignmentNotifier.evaluateStage(
            entityType: 'Cargo',
            entityId: cargoCode,
            stage: 'Delivery Closure',
            rules: cargoRules,
          );
    final cargoHardBlockRules = cargoCode == null
        ? const <String>[]
        : assignmentNotifier.listHardBlockRuleNames(
            entityType: 'Cargo',
            entityId: cargoCode,
            stage: 'Delivery Closure',
            rules: cargoRules,
          );

    final closureBlocked = customerClosureSummary.hardBlockRules > 0 ||
        cargoClosureSummary.hardBlockRules > 0;
    final closureBlockRuleNames = [
      for (final name in customerHardBlockRules) 'Customer: $name',
      for (final name in cargoHardBlockRules) 'Cargo: $name',
    ];

    return OpsShell(
      title: 'Closure',
      currentRoute: RoutePaths.closure,
      actions: [
        TextButton(
          onPressed:
              closureBlocked ? null : () => context.go(RoutePaths.invoice),
          child: const Text('Next'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const FlowStepperCard(currentStep: 11),
          const SizedBox(height: 12),
          OpsSectionCard(
            title: 'Compliance Rule Impact',
            subtitle:
                'Delivery closure now reads customer and cargo rule assignments from compliance master',
            icon: Icons.rule_folder_outlined,
            accent: const Color(0xFF2563EB),
            child: Column(
              children: [
                _pair('Work Order', activeOrder?.woId ?? '-'),
                _pair('Customer', activeOrder?.customer ?? '-'),
                _pair('Cargo', activeOrder?.cargo ?? '-'),
                _pair('Customer Closure Rules',
                    _summaryText(customerClosureSummary)),
                _pair('Cargo Closure Rules', _summaryText(cargoClosureSummary)),
                _pair('Closure Allowed', closureBlocked ? 'No' : 'Yes'),
                if (closureBlockRuleNames.isNotEmpty)
                  _pair('Blocked By Rules', closureBlockRuleNames.join(', ')),
                if (closureBlocked)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F1),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Blocked by compliance hard-block rules at delivery closure: ${closureBlockRuleNames.join(', ')}. Update assignments or compliance actions before invoice stage.',
                      style: const TextStyle(
                        color: Color(0xFFB91C1C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OpsSectionCard(
            title: 'Trip Closure Summary',
            subtitle: 'Distance, fuel average, compliance and approval',
            icon: Icons.task_alt_outlined,
            accent: const Color(0xFF16A34A),
            child: Column(
              children: [
                TextField(
                  controller: _distance,
                  decoration:
                      const InputDecoration(labelText: 'Distance Covered (km)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _fuelAvg,
                  decoration:
                      const InputDecoration(labelText: 'Fuel Average (km/l)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _complianceStatus,
                  items: const [
                    DropdownMenuItem(
                        value: 'Passed', child: Text('Compliance Passed')),
                    DropdownMenuItem(
                        value: 'Pending', child: Text('Compliance Pending')),
                    DropdownMenuItem(
                        value: 'Failed', child: Text('Compliance Failed')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _complianceStatus = value);
                    }
                  },
                  decoration:
                      const InputDecoration(labelText: 'Compliance Status'),
                ),
                const SizedBox(height: 10),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _managerApproval,
                  onChanged: (value) =>
                      setState(() => _managerApproval = value ?? false),
                  title: const Text('Manager Approval'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _summaryText(ComplianceStageSummary summary) {
    if (summary.enabledRules == 0) {
      return 'No assigned rules';
    }
    return 'Enabled ${summary.enabledRules}, Hard ${summary.hardBlockRules}, Soft ${summary.softBlockRules}, Warn ${summary.warningRules}';
  }

  WorkOrderFlowItem? _resolveActiveOrder(LogisticsUiState? data) {
    if (data == null || data.workOrders.isEmpty) {
      return null;
    }
    final assignedId = data.assignedOrderId;
    if (assignedId != null) {
      for (final order in data.workOrders) {
        if (order.woId == assignedId) {
          return order;
        }
      }
    }
    return data.workOrders.first;
  }

  String? _customerIdByName(CustomerState state, String? customerName) {
    final normalized = customerName?.trim().toLowerCase() ?? '';
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
}
