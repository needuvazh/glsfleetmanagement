import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/cargo_model.dart';
import '../../domain/entities/compliance_assignment.dart';
import '../../domain/entities/logistics_flow.dart';
import '../../domain/entities/module_document.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/cargo_policy_viewmodel.dart';
import '../viewmodels/cargo_viewmodel.dart';
import '../viewmodels/compliance_assignment_viewmodel.dart';
import '../viewmodels/customer_viewmodel.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../viewmodels/module_document_viewmodel.dart';
import '../widgets/ops_shell.dart';

class ResourceAssignmentScreen extends ConsumerStatefulWidget {
  const ResourceAssignmentScreen({super.key, this.workOrderId});

  final String? workOrderId;

  @override
  ConsumerState<ResourceAssignmentScreen> createState() => _ResourceAssignmentScreenState();
}

class _ResourceAssignmentScreenState extends ConsumerState<ResourceAssignmentScreen> {
  final TextEditingController _fleetSearchController = TextEditingController();
  final TextEditingController _driverSearchController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  String _fleetStatusFilter = 'All';
  String _driverStatusFilter = 'All';

  String? _selectedOrderId;
  String? _selectedVehicleNo;
  String? _selectedTrailerId;
  String? _selectedDriverId;
  bool _validated = false;
  bool _assignmentAllowed = false;

  @override
  void initState() {
    super.initState();
    _selectedOrderId = widget.workOrderId;
  }

  @override
  void didUpdateWidget(covariant ResourceAssignmentScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.workOrderId != oldWidget.workOrderId) {
      setState(() {
        _selectedOrderId = widget.workOrderId;
        _validated = false;
      });
    }
  }

  static const _trailers = [
    'TRL-88 (Flatbed)',
    'TRL-44 (Lowbed)',
    'TRL-11 (Tanker)',
    'TRL-52 (Container)',
  ];

  @override
  void dispose() {
    _fleetSearchController.dispose();
    _driverSearchController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logisticsViewModelProvider);
    final policy = ref.watch(cargoPolicyViewModelProvider);
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
      title: 'Assignments',
      currentRoute: RoutePaths.resourceAssignment,
      actions: [
        IconButton(
          onPressed: () => context.go(RoutePaths.assignmentList),
          icon: const Icon(Icons.close),
          tooltip: 'Back to List',
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final selectedOrder = _selectedWorkOrder(data.workOrders);
          
          // Initial hydration if coming from a work order link
          if (_selectedOrderId != null && _selectedVehicleNo == null && selectedOrder != null) {
            if (selectedOrder.assignedVehicleNo.isNotEmpty) {
               _selectedVehicleNo = selectedOrder.assignedVehicleNo;
               _selectedDriverId = selectedOrder.assignedDriverId;
               _selectedTrailerId = selectedOrder.assignedTrailerId.isNotEmpty ? selectedOrder.assignedTrailerId : null;
            }
          }

          final selectedCargoProfile = ref
              .read(cargoViewModelProvider.notifier)
              .findByName(selectedOrder?.cargo);
          final selectedVehicle = _selectedVehicle(data.vehicles);
          final selectedDriver = _selectedDriver(data.drivers);
          final selectedCustomerId = _customerIdByName(
            customerState,
            selectedOrder?.customer,
          );
          final selectedCargoCode = selectedCargoProfile?.cargoCode;
          final customerAssignmentSummary = selectedCustomerId == null
              ? const ComplianceStageSummary(
                  stage: 'Assignment',
                  enabledRules: 0,
                  warningRules: 0,
                  softBlockRules: 0,
                  hardBlockRules: 0,
                )
              : assignmentNotifier.evaluateStage(
                  entityType: 'Customer',
                  entityId: selectedCustomerId,
                  stage: 'Assignment',
                  rules: customerRules,
                );
          final customerHardBlockRules = selectedCustomerId == null
              ? const <String>[]
              : assignmentNotifier.listHardBlockRuleNames(
                  entityType: 'Customer',
                  entityId: selectedCustomerId,
                  stage: 'Assignment',
                  rules: customerRules,
                );
          final cargoAssignmentSummary = selectedCargoCode == null
              ? const ComplianceStageSummary(
                  stage: 'Assignment',
                  enabledRules: 0,
                  warningRules: 0,
                  softBlockRules: 0,
                  hardBlockRules: 0,
                )
              : assignmentNotifier.evaluateStage(
                  entityType: 'Cargo',
                  entityId: selectedCargoCode,
                  stage: 'Assignment',
                  rules: cargoRules,
                );
          final cargoHardBlockRules = selectedCargoCode == null
              ? const <String>[]
              : assignmentNotifier.listHardBlockRuleNames(
                  entityType: 'Cargo',
                  entityId: selectedCargoCode,
                  stage: 'Assignment',
                  rules: cargoRules,
                );

          final fleetRows = _filteredFleet(data.vehicles);
          final driverRows = _filteredDrivers(data.drivers);

          final checks = _buildValidationChecks(
            data: data,
            hardBlockMode: policy.hardBlockMode,
            selectedOrder: selectedOrder,
            selectedCargo: selectedCargoProfile,
            selectedVehicle: selectedVehicle,
            selectedDriver: selectedDriver,
            customerCompliancePass:
                customerAssignmentSummary.hardBlockRules == 0,
            cargoCompliancePass: cargoAssignmentSummary.hardBlockRules == 0,
          );

          final isDesktop = MediaQuery.of(context).size.width > 1200;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Work Order Summary (Full Row)
                _buildLeftPanel(
                  data,
                  selectedOrder,
                  selectedCargoProfile,
                  selectedVehicle,
                  selectedDriver,
                  customerAssignmentSummary,
                  cargoAssignmentSummary,
                  customerHardBlockRules,
                  cargoHardBlockRules,
                ),
                const SizedBox(height: 16),

                // Row 2: Fleet Selection (Full Row)
                _buildMiddlePanel(
                  fleetRows,
                  selectedVehicle,
                ),
                const SizedBox(height: 16),

                // Row 3: Driver Selection (Full Row)
                _buildRightPanel(
                  driverRows,
                  selectedDriver,
                ),
                const SizedBox(height: 16),

                // Row 4: Validation Section (Full Row)
                _buildValidationSection(
                  checks,
                  customerHardBlockRules,
                  cargoHardBlockRules,
                ),
                const SizedBox(height: 20),

                // Row 5: Actions
                _buildActionsBar(
                  onValidate: () {
                    final allowed = checks.values.every((v) => v);
                    setState(() {
                      _validated = true;
                      _assignmentAllowed = allowed;
                    });
                    _toast(allowed
                        ? 'Validation successful. Assignment allowed.'
                        : 'Validation failed. Assignment blocked.');
                  },
                  onAssign: () => _assignOrReassign(data),
                  onSaveRemarks: () => _toast('Assignment remarks saved.'),
                  onReassign: () => _assignOrReassign(data, forceReassign: true),
                  canAssign: _selectedOrderId != null &&
                      _selectedVehicleNo != null &&
                      _selectedDriverId != null &&
                      _selectedTrailerId != null,
                  hasExistingAssignment: _selectedOrderId == data.assignedOrderId,
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeftPanel(
    LogisticsUiState data,
    WorkOrderFlowItem? selectedOrder,
    CargoModel? selectedCargo,
    FleetVehicleData? selectedVehicle,
    DriverData? selectedDriver,
    ComplianceStageSummary customerSummary,
    ComplianceStageSummary cargoSummary,
    List<String> customerHardBlockRules,
    List<String> cargoHardBlockRules,
  ) {
    if (selectedOrder == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text('Work Order Summary',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              _buildOrderDropdown(data),
              const SizedBox(height: 20),
              const Center(child: Text('Please select a work order.')),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Work Order Summary',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            _buildOrderDropdown(data),
            const SizedBox(height: 16),
            
            // Headline Section
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _headlineChip('WO', selectedOrder.woId),
                _headlineChip('Customer', selectedOrder.customer),
                _headlineChip('Status', selectedOrder.status),
              ],
            ),
            const SizedBox(height: 16),

            // Planning Details
            _SectionHeader(title: 'PLANNING DETAILS', icon: Icons.calendar_today_outlined),
            const SizedBox(height: 8),
            _detailGrid([
              _detailItem('Route', selectedOrder.route),
              _detailItem('Risk Level', selectedOrder.routeRiskLevel),
              _detailItem('Planned Start', _formatDate(selectedOrder.serviceStartDate)),
              _detailItem('Planned End', _formatDate(selectedOrder.serviceEndDate)),
            ]),
            const SizedBox(height: 16),

            // Cargo Details
            _SectionHeader(title: 'CARGO DETAILS', icon: Icons.inventory_2_outlined),
            const SizedBox(height: 8),
            _detailGrid([
              _detailItem('Cargo Profile', selectedOrder.cargo),
              if (selectedCargo != null) ...[
                _detailItem('Hazardous', selectedCargo.hazardous ? 'Yes' : 'No'),
                _detailItem('Cargo Risk', selectedCargo.riskLevel.label),
                _detailItem('Preferred Trailer', selectedCargo.preferredTrailerType.isEmpty ? '-' : selectedCargo.preferredTrailerType),
                _detailItem('Lashing Req.', selectedCargo.lashingRequired ? 'Yes' : 'No'),
                _detailItem('Escort Req.', selectedCargo.escortRequired ? 'Yes' : 'No'),
              ],
            ]),
            const SizedBox(height: 16),

            // Operational Context
            _SectionHeader(title: 'OPERATIONAL CONTEXT', icon: Icons.analytics_outlined),
            const SizedBox(height: 8),
            _detailGrid([
              _detailItem('Inspection', 'Required'),
              _detailItem('Trip Readiness', data.canStartTrip ? 'Ready' : 'Pending'),
              _detailItem('Cust. Compliance', _stageSummaryText(customerSummary)),
              _detailItem('Cargo Compliance', _stageSummaryText(cargoSummary)),
            ]),
            
            if (customerHardBlockRules.isNotEmpty || cargoHardBlockRules.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Hard Block Rules Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.red)),
              const SizedBox(height: 4),
              for (final rule in [...customerHardBlockRules, ...cargoHardBlockRules])
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text('• $rule', style: const TextStyle(fontSize: 11, color: Colors.red)),
                ),
            ],

            if (selectedCargo != null && _cargoWarnings(selectedCargo).isNotEmpty)
              _WarningBox(
                title: 'Cargo Assignment Guidance',
                warnings: _cargoWarnings(selectedCargo),
              ),
            
            if (selectedCargo != null)
              _GapBox(
                gaps: _missingComplianceForCargo(
                  cargo: selectedCargo,
                  vehicle: selectedVehicle,
                  driver: selectedDriver,
                ),
              ),

            const SizedBox(height: 16),
            TextFormField(
              controller: _remarksController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Assignment Remarks',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDropdown(LogisticsUiState data) {
    return DropdownButtonFormField<String>(
      value: _selectedOrderId,
      decoration: const InputDecoration(labelText: 'Change Work Order'),
      items: [
        for (final item in data.workOrders)
          DropdownMenuItem(
            value: item.woId,
            child: Text('${item.woId} (${item.customer})'),
          ),
      ],
      onChanged: (value) {
        final order = data.workOrders.where((wo) => wo.woId == value).firstOrNull;
        setState(() {
          _selectedOrderId = value;
          if (order != null && order.assignedVehicleNo.isNotEmpty) {
            _selectedVehicleNo = order.assignedVehicleNo;
            _selectedDriverId = order.assignedDriverId;
            _selectedTrailerId = order.assignedTrailerId.isNotEmpty ? order.assignedTrailerId : null;
          }
          _validated = false;
        });
      },
    );
  }

  Widget _headlineChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        border: Border.all(color: const Color(0xFFBFDBFE)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 11, color: Color(0xFF1E40AF)),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _detailGrid(List<Widget> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 500 ? 2 : 1);
        return Wrap(
          spacing: 24,
          runSpacing: 16,
          children: items.map((item) {
            final itemWidth = (constraints.maxWidth - (crossCount - 1) * 24) / crossCount - 1;
            return SizedBox(
              width: itemWidth > 0 ? itemWidth : 140,
              child: item,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _detailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
                letterSpacing: 0.8)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  List<String> _cargoWarnings(CargoModel cargo) {
    final warnings = <String>[];
    if (cargo.hazardous) {
      warnings
          .add('Hazardous cargo selected. Ensure hazmat compliant resources.');
    }
    if (cargo.riskLevel == CargoRiskLevel.high ||
        cargo.riskLevel == CargoRiskLevel.critical) {
      warnings.add('High-risk cargo. Increase planner and dispatcher review.');
    }
    if (cargo.specialComplianceRequired) {
      warnings.add('Special compliance/certification checks are recommended.');
    }
    if (cargo.inspectionRequired && cargo.photoEvidenceMandatory) {
      warnings.add('Inspection should include mandatory photo evidence.');
    }
    if (cargo.inspectionRequired && cargo.videoEvidenceMandatory) {
      warnings.add('Inspection should include mandatory video evidence.');
    }
    return warnings;
  }

  Widget _buildMiddlePanel(
      List<FleetVehicleData> rows, FleetVehicleData? selectedVehicle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fleet Selection',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fleetSearchController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search truck / type',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 140,
                  child: DropdownButtonFormField<String>(
                    value: _fleetStatusFilter,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(
                          value: 'Available', child: Text('Available')),
                      DropdownMenuItem(value: 'Busy', child: Text('Busy')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _fleetStatusFilter = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedVehicleNo,
              decoration: const InputDecoration(labelText: 'Available Trucks'),
              items: [
                for (final item in rows)
                  DropdownMenuItem(
                    value: item.vehicleNo,
                    child: Text(
                        '${item.vehicleNo} • ${item.type} • ${item.status}'),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedVehicleNo = value;
                  _validated = false;
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedTrailerId,
              decoration: const InputDecoration(labelText: 'Trailer List'),
              items: [
                for (final trailer in _trailers)
                  DropdownMenuItem(value: trailer, child: Text(trailer)),
              ],
              onChanged: (value) => setState(() => _selectedTrailerId = value),
            ),
            const SizedBox(height: 20),
            _SectionHeader(title: 'FLEET DETAILS PREVIEW', icon: Icons.local_shipping_outlined),
            const SizedBox(height: 10),
            _detailGrid([
              _detailItem('Vehicle Number', selectedVehicle?.vehicleNo ?? '-'),
              _detailItem('Vehicle Type', selectedVehicle?.type ?? '-'),
              _detailItem('Capacity', selectedVehicle?.capacity ?? '-'),
              _detailItem('Fuel Type', selectedVehicle?.fuelType ?? '-'),
              _detailItem('IVMS Device', selectedVehicle?.ivmsDeviceId ?? '-'),
              _detailItem('Status', selectedVehicle?.status ?? '-'),
              _detailItem(
                'Permits',
                selectedVehicle == null || selectedVehicle.permits.isEmpty
                    ? '-'
                    : selectedVehicle.permits.join(', '),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildRightPanel(List<DriverData> rows, DriverData? selectedDriver) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Driver Selection',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _driverSearchController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search driver / id',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 140,
                  child: DropdownButtonFormField<String>(
                    value: _driverStatusFilter,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(
                          value: 'Available', child: Text('Available')),
                      DropdownMenuItem(value: 'Busy', child: Text('Busy')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _driverStatusFilter = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedDriverId,
              decoration: const InputDecoration(labelText: 'Driver List'),
              items: [
                for (final item in rows)
                  DropdownMenuItem(
                    value: item.driverId,
                    child: Text('${item.name} • ${item.status}'),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedDriverId = value;
                  _validated = false;
                });
              },
            ),
            const SizedBox(height: 20),
            _SectionHeader(title: 'DRIVER DETAILS PREVIEW', icon: Icons.person_outline),
            const SizedBox(height: 10),
            _detailGrid([
              _detailItem('Driver Name', selectedDriver?.name ?? '-'),
              _detailItem('License Number', selectedDriver?.licenseNo ?? '-'),
              _detailItem('License Expiry', selectedDriver?.expiryDate ?? '-'),
              _detailItem('Availability', selectedDriver?.status ?? '-'),
              _detailItem('Compliance', _driverComplianceReady(selectedDriver) ? 'Ready' : 'Action required'),
              _detailItem(
                'Certifications',
                selectedDriver == null || selectedDriver.certifications.isEmpty
                    ? '-'
                    : selectedDriver.certifications.join(', '),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  bool _driverComplianceReady(DriverData? driver) {
    if (driver == null) return false;
    return driver.assignmentEligible;
  }

  Widget _buildValidationSection(
    Map<String, bool> checks,
    List<String> customerHardBlockRules,
    List<String> cargoHardBlockRules,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Validation Section',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossCount = constraints.maxWidth > 800 ? 5 : (constraints.maxWidth > 500 ? 3 : 2);
                final items = checks.entries.toList();
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: items.map((entry) {
                    final itemWidth = (constraints.maxWidth - (crossCount - 1) * 12) / crossCount - 1;
                    return SizedBox(
                      width: itemWidth > 0 ? itemWidth : 120,
                      child: _validationChip(entry.key, entry.value),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 10),
            Text(
              _validated
                  ? (_assignmentAllowed
                      ? 'Assignment allowed'
                      : 'Assignment blocked')
                  : 'Run validation before assignment.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (checks.values.any((value) => !value)) ...[
              const SizedBox(height: 8),
              Text(
                'Blocked by: ${checks.entries.where((entry) => !entry.value).map((entry) => entry.key).join(', ')}',
                style: const TextStyle(
                  color: Color(0xFFB91C1C),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (customerHardBlockRules.isNotEmpty ||
                  cargoHardBlockRules.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Hard-block rules: ${[
                    for (final name in customerHardBlockRules)
                      'Customer: $name',
                    for (final name in cargoHardBlockRules) 'Cargo: $name',
                  ].join(', ')}',
                  style: const TextStyle(
                    color: Color(0xFFB91C1C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionsBar({
    required VoidCallback onValidate,
    required VoidCallback onAssign,
    required VoidCallback onSaveRemarks,
    required VoidCallback onReassign,
    required bool canAssign,
    required bool hasExistingAssignment,
  }) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: onValidate,
          icon: const Icon(Icons.rule_folder_outlined),
          label: const Text('Validate'),
        ),
        const SizedBox(width: 10),
        FilledButton.icon(
          onPressed: canAssign ? onAssign : null,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Assign'),
        ),
        const SizedBox(width: 10),
        TextButton.icon(
          onPressed: onSaveRemarks,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save Remarks'),
        ),
        const SizedBox(width: 10),
        FilledButton.tonalIcon(
          onPressed: hasExistingAssignment ? onReassign : null,
          icon: const Icon(Icons.swap_horiz_outlined),
          label: const Text('Reassign'),
        ),
      ],
    );
  }


  Widget _validationChip(String label, bool pass) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: pass ? const Color(0xFFE9F9EF) : const Color(0xFFFFF1F1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            pass ? Icons.check_circle_outline : Icons.block_outlined,
            size: 16,
            color: pass ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }

  List<FleetVehicleData> _filteredFleet(List<FleetVehicleData> source) {
    final query = _fleetSearchController.text.trim().toLowerCase();
    return source.where((item) {
      if (_fleetStatusFilter == 'Available' && !_isAvailable(item.status)) {
        return false;
      }
      if (_fleetStatusFilter == 'Busy' && _isAvailable(item.status)) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final text =
          '${item.vehicleNo} ${item.type} ${item.status}'.toLowerCase();
      return text.contains(query);
    }).toList();
  }

  List<DriverData> _filteredDrivers(List<DriverData> source) {
    final query = _driverSearchController.text.trim().toLowerCase();
    return source.where((item) {
      if (_driverStatusFilter == 'Available' && !_isAvailable(item.status)) {
        return false;
      }
      if (_driverStatusFilter == 'Busy' && _isAvailable(item.status)) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final text = '${item.driverId} ${item.name} ${item.status}'.toLowerCase();
      return text.contains(query);
    }).toList();
  }

  WorkOrderFlowItem? _selectedWorkOrder(List<WorkOrderFlowItem> orders) {
    for (final item in orders) {
      if (item.woId == _selectedOrderId) {
        return item;
      }
    }
    return null;
  }

  FleetVehicleData? _selectedVehicle(List<FleetVehicleData> vehicles) {
    for (final item in vehicles) {
      if (item.vehicleNo == _selectedVehicleNo) {
        return item;
      }
    }
    return null;
  }

  DriverData? _selectedDriver(List<DriverData> drivers) {
    for (final item in drivers) {
      if (item.driverId == _selectedDriverId) {
        return item;
      }
    }
    return null;
  }

  Map<String, bool> _buildValidationChecks({
    required LogisticsUiState data,
    required bool hardBlockMode,
    required WorkOrderFlowItem? selectedOrder,
    required CargoModel? selectedCargo,
    required FleetVehicleData? selectedVehicle,
    required DriverData? selectedDriver,
    required bool customerCompliancePass,
    required bool cargoCompliancePass,
  }) {
    final fleetSelected = selectedVehicle != null;
    final trailerSelected = _selectedTrailerId != null;
    final driverSelected = selectedDriver != null;
    
    final fleetAvailable =
        selectedVehicle != null && _isAvailable(selectedVehicle.status);
    final fleetDocsValid = selectedVehicle != null; // Mock: assume valid for now
    
    final driverAvailable =
        selectedDriver != null && _isAvailable(selectedDriver.status);
    final driverDocsValid = _licenseValid(selectedDriver);
    
    final cargoRulePass = hardBlockMode
        ? _cargoHardBlockPass(
            selectedOrder: selectedOrder,
            selectedCargo: selectedCargo,
            selectedVehicle: selectedVehicle,
            selectedDriver: selectedDriver,
          )
        : true;

    final assignmentAllowed = fleetSelected &&
        trailerSelected &&
        driverSelected &&
        fleetAvailable &&
        fleetDocsValid &&
        driverAvailable &&
        driverDocsValid &&
        cargoRulePass &&
        customerCompliancePass &&
        cargoCompliancePass;

    return {
      'Fleet Selected': fleetSelected,
      'Trailer Selected': trailerSelected,
      'Driver Selected': driverSelected,
      'Fleet Available': fleetAvailable,
      'Trailer Available': trailerSelected, // Mock: Available if selected
      'Driver Available': driverAvailable,
      'Fleet Docs Valid': fleetDocsValid,
      'Driver Docs Valid': driverDocsValid,
      'Customer Compliance': customerCompliancePass,
      'Cargo Compliance': cargoCompliancePass,
    };
  }

  String _stageSummaryText(ComplianceStageSummary summary) {
    if (summary.enabledRules == 0) {
      return 'No assigned rules';
    }
    return 'Enabled ${summary.enabledRules}, Hard ${summary.hardBlockRules}, Soft ${summary.softBlockRules}, Warn ${summary.warningRules}';
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

  bool _cargoHardBlockPass({
    required WorkOrderFlowItem? selectedOrder,
    required CargoModel? selectedCargo,
    required FleetVehicleData? selectedVehicle,
    required DriverData? selectedDriver,
  }) {
    if (selectedOrder == null || selectedCargo == null) {
      return true;
    }
    if (!selectedCargo.isSelectable) {
      return false;
    }
    if (selectedCargo.restricted) {
      return false;
    }

    if (selectedVehicle == null || selectedDriver == null) {
      return false;
    }

    final selectedVehicleType = selectedVehicle.type.toLowerCase();
    final preferredVehicle = selectedCargo.preferredVehicleType.toLowerCase();
    if (preferredVehicle.isNotEmpty &&
        !selectedVehicleType.contains(preferredVehicle)) {
      return false;
    }

    final selectedTrailer = _selectedTrailerId?.toLowerCase() ?? '';
    final preferredTrailer = selectedCargo.preferredTrailerType.toLowerCase();
    if (preferredTrailer.isNotEmpty) {
      if (selectedTrailer.isEmpty ||
          !selectedTrailer.contains(preferredTrailer)) {
        return false;
      }
    }

    if ((selectedCargo.riskLevel == CargoRiskLevel.high ||
            selectedCargo.riskLevel == CargoRiskLevel.critical) &&
        selectedDriver.experience < 3) {
      return false;
    }

    if (selectedCargo.hazardous && selectedDriver.experience < 2) {
      return false;
    }

    if (selectedCargo.specialComplianceRequired &&
        selectedDriver.licenseNo.trim().isEmpty) {
      return false;
    }

    if (_missingComplianceForCargo(
      cargo: selectedCargo,
      vehicle: selectedVehicle,
      driver: selectedDriver,
    ).isNotEmpty) {
      return false;
    }

    if (selectedCargo.inspectionRequired &&
        selectedCargo.photoEvidenceMandatory &&
        selectedCargo.inspectionTemplateType.trim().isEmpty) {
      return false;
    }

    return true;
  }

  List<String> _missingComplianceForCargo({
    required CargoModel cargo,
    required FleetVehicleData? vehicle,
    required DriverData? driver,
  }) {
    final gaps = <String>[];

    final requiredCerts = cargo.requiredCertifications
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    final requiredPermits = cargo.requiredPermits
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    final availableCerts = (driver?.certifications ?? const <String>[])
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    final availablePermits = (vehicle?.permits ?? const <String>[])
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    for (final cert in requiredCerts) {
      if (!_containsFuzzyMatch(availableCerts, cert)) {
        gaps.add('Missing driver certification: $cert');
      }
    }

    for (final permit in requiredPermits) {
      if (!_containsFuzzyMatch(availablePermits, permit)) {
        gaps.add('Missing vehicle permit: $permit');
      }
    }

    return gaps;
  }

  bool _containsFuzzyMatch(List<String> candidates, String required) {
    final requiredTokens = _normalizedTokens(required);
    if (requiredTokens.isEmpty) {
      return true;
    }
    for (final candidate in candidates) {
      final sourceTokens = _normalizedTokens(candidate);
      if (sourceTokens.isEmpty) {
        continue;
      }
      final intersects = requiredTokens.any(sourceTokens.contains);
      if (intersects) {
        return true;
      }
    }
    return false;
  }

  Set<String> _normalizedTokens(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((item) => item.trim().isNotEmpty)
        .toSet();
  }

  bool _isAvailable(String status) {
    return status.toLowerCase().contains('available');
  }

  bool _licenseValid(DriverData? driver) {
    if (driver == null) {
      return false;
    }
    final parsed = DateTime.tryParse(driver.expiryDate);
    if (parsed == null) {
      return true;
    }
    return parsed.isAfter(DateTime.now());
  }

  String _plannedDate(String? orderId) {
    if (orderId == null) {
      return '-';
    }
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    return '$day/$month/${now.year}';
  }

  String _formatDate(String iso) {
    if (iso.isEmpty) return '-';
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    final year = parsed.year;
    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    return '$day/$month/$year';
  }

  String _formatDateTime(String iso) {
    if (iso.isEmpty) return '-';
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    final year = parsed.year;
    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    final hour = parsed.hour.toString().padLeft(2, '0');
    final min = parsed.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$min';
  }

  void _assignOrReassign(LogisticsUiState data, {bool forceReassign = false}) {
    if (_selectedOrderId == null ||
        _selectedVehicleNo == null ||
        _selectedDriverId == null) {
      _toast('Select work order, truck, and driver before assigning.');
      return;
    }

    final msg = ref.read(logisticsViewModelProvider.notifier).assignFleetDriver(
          orderId: _selectedOrderId!,
          vehicleNo: _selectedVehicleNo!,
          driverId: _selectedDriverId!,
          trailerId: _selectedTrailerId!,
        );
    
    _showSuccessDialog(forceReassign ? 'Reassignment Successful' : 'Assignment Successful', msg);
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              context.go(RoutePaths.assignmentList); // Redirect to list
            },
            child: const Text('Back to List'),
          ),
        ],
      ),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _pair(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.blueGrey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.blueGrey),
        const SizedBox(width: 6),
        Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.0)),
      ],
    );
  }
}

class _WarningBox extends StatelessWidget {
  final String title;
  final List<String> warnings;

  const _WarningBox({required this.title, required this.warnings});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        border: Border.all(color: const Color(0xFFF59E0B)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 6),
          for (final note in warnings)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text('• $note', style: const TextStyle(fontSize: 11)),
            ),
        ],
      ),
    );
  }
}

class _GapBox extends StatelessWidget {
  final List<String> gaps;

  const _GapBox({required this.gaps});

  @override
  Widget build(BuildContext context) {
    if (gaps.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        border: Border.all(color: const Color(0xFFB91C1C)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Compliance Gaps', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFFB91C1C))),
          const SizedBox(height: 6),
          for (final gap in gaps)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text('• $gap', style: const TextStyle(fontSize: 11, color: Color(0xFFB91C1C))),
            ),
        ],
      ),
    );
  }
}
