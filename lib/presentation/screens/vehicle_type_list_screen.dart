import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/vehicle_type_master_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/vehicle_type_master_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class VehicleTypeListScreen extends ConsumerWidget {
  const VehicleTypeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vehicleTypeMasterViewModelProvider);

    return OpsShell(
      title: 'Vehicle Type Master',
      currentRoute: RoutePaths.vehicleTypes,
      actions: [
        FilledButton.icon(
          onPressed: () => context.go(RoutePaths.vehicleTypeForm),
          icon: const Icon(Icons.add),
          label: const Text('Create Vehicle Type'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final items = data.filteredItems;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: 'Search & Filter',
                subtitle:
                    'Reusable vehicle templates for pricing, feasibility, and request planning.',
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
                          labelText: 'Search Vehicle Type',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: ref
                            .read(vehicleTypeMasterViewModelProvider.notifier)
                            .setSearchQuery,
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: DropdownButtonFormField<VehicleCategoryType?>(
                        initialValue: data.categoryFilter,
                        decoration:
                            const InputDecoration(labelText: 'Category'),
                        items: [
                          const DropdownMenuItem<VehicleCategoryType?>(
                            value: null,
                            child: Text('All Categories'),
                          ),
                          for (final item in VehicleCategoryType.values)
                            DropdownMenuItem<VehicleCategoryType?>(
                              value: item,
                              child: Text(item.label),
                            ),
                        ],
                        onChanged: ref
                            .read(vehicleTypeMasterViewModelProvider.notifier)
                            .setCategoryFilter,
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: DropdownButtonFormField<RecordStatusType?>(
                        initialValue: data.statusFilter,
                        decoration: const InputDecoration(labelText: 'Status'),
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
                            .read(vehicleTypeMasterViewModelProvider.notifier)
                            .setStatusFilter,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              OpsSectionCard(
                title: 'Vehicle Type Master',
                subtitle:
                    '${items.length} templates available for operations readiness.',
                icon: Icons.local_shipping_outlined,
                accent: const Color(0xFF16A34A),
                child: items.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text('No vehicle types found.'),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Type ID')),
                            DataColumn(label: Text('Vehicle Type')),
                            DataColumn(label: Text('Category')),
                            DataColumn(label: Text('Capacity')),
                            DataColumn(label: Text('Configuration')),
                            DataColumn(label: Text('Base Fare')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: [
                            for (final item in items)
                              DataRow(
                                onSelectChanged: (_) => context.go(
                                  RoutePaths.vehicleTypeViewById(
                                    item.vehicleTypeId,
                                  ),
                                ),
                                cells: [
                                  DataCell(Text(item.vehicleTypeId)),
                                  DataCell(Text(item.vehicleTypeName)),
                                  DataCell(Text(item.vehicleCategory.label)),
                                  DataCell(Text(item.capacityLabel)),
                                  DataCell(
                                    Text(
                                      '${item.bodyType.label} | ${item.axleType.label} | ${item.fuelType.label}',
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      'KM ${item.baseFarePerKm.toStringAsFixed(2)} / HR ${item.baseFarePerHour.toStringAsFixed(2)}',
                                    ),
                                  ),
                                  DataCell(_statusChip(item.status)),
                                  DataCell(
                                    OpsTableActions(
                                      viewTooltip: 'View',
                                      editTooltip: 'Edit',
                                      moreTooltip: 'More',
                                      onView: () => context.go(
                                        RoutePaths.vehicleTypeViewById(
                                          item.vehicleTypeId,
                                        ),
                                      ),
                                      onEdit: () => context.go(
                                        '${RoutePaths.vehicleTypeForm}?id=${item.vehicleTypeId}',
                                      ),
                                      moreItems: const [
                                        OpsTableActionMenuItem(
                                          value: 'documents',
                                          label: 'View Documents',
                                          icon: Icons.folder_open_outlined,
                                        ),
                                        OpsTableActionMenuItem(
                                          value: 'delete',
                                          label: 'Delete',
                                          icon: Icons.delete_outline,
                                          destructive: true,
                                        ),
                                      ],
                                      onMoreSelected: (value) {
                                        final message = value == 'documents'
                                            ? 'Document library is handled in the Vehicle Type form.'
                                            : 'Delete is available once archive rules are enabled.';
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text(message)),
                                        );
                                      },
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

  Widget _statusChip(RecordStatusType status) {
    final color = status == RecordStatusType.active
        ? const Color(0xFF15803D)
        : const Color(0xFFB91C1C);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.12),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
