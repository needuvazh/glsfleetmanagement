import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/fleet_master_model.dart';
import '../../domain/vehicle_type_master_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/fleet_master_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class FleetManagementScreen extends ConsumerWidget {
  const FleetManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fleetMasterViewModelProvider);

    return OpsShell(
      title: 'Fleet Master',
      currentRoute: RoutePaths.fleetManagement,
      actions: [
        FilledButton.icon(
          onPressed: () => context.go(RoutePaths.fleetForm),
          icon: const Icon(Icons.add),
          label: const Text('Create Fleet'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final fleets = data.filteredFleets;
          final now = DateTime.now();
          final total = data.fleets.length;
          final available = data.fleets
              .where(
                (item) =>
                    item.availabilityStatus == AvailabilityStatusType.available,
              )
              .length;
          final assigned = data.fleets
              .where(
                (item) =>
                    item.availabilityStatus == AvailabilityStatusType.assigned,
              )
              .length;
          final maintenance = data.fleets
              .where(
                (item) =>
                    item.availabilityStatus ==
                    AvailabilityStatusType.maintenance,
              )
              .length;
          final expired = data.fleets
              .where(
                (item) =>
                    item.overallCompliance(now) ==
                    ComplianceIndicatorType.expired,
              )
              .length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: 'Fleet Readiness Overview',
                subtitle:
                    'Live operational snapshot for assignment and compliance readiness.',
                icon: Icons.insights_outlined,
                accent: const Color(0xFF7C3AED),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _metric('Total Fleet', '$total', const Color(0xFF1D4ED8)),
                    _metric('Available', '$available', const Color(0xFF15803D)),
                    _metric('Assigned', '$assigned', const Color(0xFF0369A1)),
                    _metric(
                        'Maintenance', '$maintenance', const Color(0xFFF59E0B)),
                    _metric('Compliance Expired', '$expired',
                        const Color(0xFFB91C1C)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              OpsSectionCard(
                title: 'Search & Filter',
                subtitle:
                    'Readiness-oriented fleet control with compliance visibility.',
                icon: Icons.tune_outlined,
                accent: const Color(0xFF2563EB),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: 320,
                      child: TextFormField(
                        initialValue: data.searchQuery,
                        decoration: const InputDecoration(
                          labelText: 'Search Fleet',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: ref
                            .read(fleetMasterViewModelProvider.notifier)
                            .setSearchQuery,
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: DropdownButtonFormField<AvailabilityStatusType?>(
                        initialValue: data.availabilityFilter,
                        decoration: const InputDecoration(
                          labelText: 'Availability',
                        ),
                        items: [
                          const DropdownMenuItem<AvailabilityStatusType?>(
                            value: null,
                            child: Text('All Availability'),
                          ),
                          for (final item in AvailabilityStatusType.values)
                            DropdownMenuItem<AvailabilityStatusType?>(
                              value: item,
                              child: Text(item.label),
                            ),
                        ],
                        onChanged: ref
                            .read(fleetMasterViewModelProvider.notifier)
                            .setAvailabilityFilter,
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: DropdownButtonFormField<ComplianceIndicatorType?>(
                        initialValue: data.complianceFilter,
                        decoration: const InputDecoration(
                          labelText: 'Compliance',
                        ),
                        items: [
                          const DropdownMenuItem<ComplianceIndicatorType?>(
                            value: null,
                            child: Text('All Compliance'),
                          ),
                          for (final item in ComplianceIndicatorType.values)
                            DropdownMenuItem<ComplianceIndicatorType?>(
                              value: item,
                              child: Text(item.label),
                            ),
                        ],
                        onChanged: ref
                            .read(fleetMasterViewModelProvider.notifier)
                            .setComplianceFilter,
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: DropdownButtonFormField<RecordStatusType?>(
                        initialValue: data.statusFilter,
                        decoration:
                            const InputDecoration(labelText: 'Record Status'),
                        items: [
                          const DropdownMenuItem<RecordStatusType?>(
                            value: null,
                            child: Text('All Statuses'),
                          ),
                          for (final item in RecordStatusType.values)
                            DropdownMenuItem<RecordStatusType?>(
                              value: item,
                              child: Text(item.label),
                            ),
                        ],
                        onChanged: ref
                            .read(fleetMasterViewModelProvider.notifier)
                            .setStatusFilter,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        final vm =
                            ref.read(fleetMasterViewModelProvider.notifier);
                        vm.setSearchQuery('');
                        vm.setAvailabilityFilter(null);
                        vm.setComplianceFilter(null);
                        vm.setStatusFilter(null);
                      },
                      icon: const Icon(Icons.filter_alt_off_outlined),
                      label: const Text('Clear Filters'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              OpsSectionCard(
                title: 'Fleet Master',
                subtitle:
                    '${fleets.length} live records with assignment readiness and compliance state.',
                icon: Icons.local_shipping_outlined,
                accent: const Color(0xFF16A34A),
                child: fleets.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text('No fleet records found.'),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Fleet No')),
                            DataColumn(label: Text('Vehicle Type')),
                            DataColumn(label: Text('Ownership')),
                            DataColumn(label: Text('Availability')),
                            DataColumn(label: Text('Compliance')),
                            DataColumn(label: Text('Vendor')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: [
                            for (final fleet in fleets)
                              DataRow(
                                onSelectChanged: (_) => context.go(
                                  RoutePaths.fleetDetailById(fleet.fleetId),
                                ),
                                cells: [
                                  DataCell(Text(fleet.fleetNumber)),
                                  DataCell(
                                    Text(
                                      data
                                              .vehicleTypeFor(
                                                  fleet.vehicleTypeId)
                                              ?.vehicleTypeName ??
                                          fleet.vehicleTypeId,
                                    ),
                                  ),
                                  DataCell(Text(fleet.ownershipType.label)),
                                  DataCell(
                                    _chip(
                                      fleet.availabilityStatus.label,
                                      _availabilityColor(
                                          fleet.availabilityStatus),
                                    ),
                                  ),
                                  DataCell(
                                    _chip(
                                      fleet
                                          .overallCompliance(DateTime.now())
                                          .label,
                                      _complianceColor(
                                        fleet.overallCompliance(DateTime.now()),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      fleet.vendorId.isEmpty
                                          ? '-'
                                          : (data
                                                  .vendorFor(fleet.vendorId)
                                                  ?.vendorName ??
                                              fleet.vendorId),
                                    ),
                                  ),
                                  DataCell(
                                    OpsTableActions(
                                      viewTooltip: 'View Fleet',
                                      editTooltip: 'Edit Fleet',
                                      onView: () => context.go(
                                        RoutePaths.fleetDetailById(
                                            fleet.fleetId),
                                      ),
                                      onEdit: () => context.go(
                                        RoutePaths.editFleetById(fleet.fleetId),
                                      ),
                                      moreItems: const [
                                        OpsTableActionMenuItem(
                                          value: 'documents',
                                          label: 'Compliance Readiness',
                                          icon: Icons.folder_open_outlined,
                                        ),
                                        OpsTableActionMenuItem(
                                          value: 'history',
                                          label: 'Inspection History',
                                          icon: Icons.history_outlined,
                                        ),
                                        OpsTableActionMenuItem(
                                          value: 'createInspection',
                                          label: 'Create Inspection',
                                          icon: Icons.fact_check_outlined,
                                        ),
                                        OpsTableActionMenuItem(
                                          value: 'delete',
                                          label: 'Delete',
                                          icon: Icons.delete_outline,
                                          destructive: true,
                                        ),
                                      ],
                                      onMoreSelected: (value) =>
                                          _handleMoreAction(
                                        context: context,
                                        ref: ref,
                                        fleet: fleet,
                                        action: value,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.12),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }

  Color _availabilityColor(AvailabilityStatusType status) {
    switch (status) {
      case AvailabilityStatusType.available:
        return const Color(0xFF15803D);
      case AvailabilityStatusType.assigned:
        return const Color(0xFF1D4ED8);
      case AvailabilityStatusType.maintenance:
        return const Color(0xFFF59E0B);
      case AvailabilityStatusType.underReview:
        return const Color(0xFFB91C1C);
    }
  }

  Color _complianceColor(ComplianceIndicatorType state) {
    switch (state) {
      case ComplianceIndicatorType.valid:
        return const Color(0xFF15803D);
      case ComplianceIndicatorType.expiringSoon:
        return const Color(0xFFF59E0B);
      case ComplianceIndicatorType.expired:
        return const Color(0xFFB91C1C);
    }
  }

  void _handleMoreAction({
    required BuildContext context,
    required WidgetRef ref,
    required FleetMasterModel fleet,
    required String action,
  }) async {
    switch (action) {
      case 'documents':
        context.go(RoutePaths.complianceReadiness);
        return;
      case 'history':
        context.go(RoutePaths.inspections);
        return;
      case 'createInspection':
        context.go(
          '${RoutePaths.inspectionCreate}?fleetId=${Uri.encodeComponent(fleet.fleetNumber)}',
        );
        return;
      case 'delete':
        final confirmed = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Delete Fleet'),
                content: Text(
                    'Are you sure you want to delete ${fleet.fleetNumber}?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ??
            false;
        if (!confirmed) {
          return;
        }
        final message =
            await ref.read(fleetMasterViewModelProvider.notifier).deleteFleet(
                  fleet.fleetId,
                );
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
        }
        return;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Action not available.')));
    }
  }

  Widget _metric(String label, String value, Color color) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              )),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}
