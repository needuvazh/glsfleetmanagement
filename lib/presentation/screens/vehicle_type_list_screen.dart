import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/responsive.dart';
import '../../domain/entities/vehicle_type.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/vehicle_type_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class VehicleTypeListScreen extends ConsumerWidget {
  const VehicleTypeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vehicleTypeViewModelProvider);

    return OpsShell(
      title: 'Vehicle Type List',
      currentRoute: RoutePaths.vehicleTypes,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.vehicleTypeForm),
          child: const Text('Add Vehicle Type'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final items = data.filteredItems;
          final isMobile = Responsive.isMobile(context);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: 'Search & Filter',
                subtitle: 'Search by name/code and filter by Oman category',
                icon: Icons.tune_outlined,
                accent: const Color(0xFF2563EB),
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: data.query,
                      decoration: const InputDecoration(
                        labelText: 'Search (Name, Code, Class, Load Type)',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: ref
                          .read(vehicleTypeViewModelProvider.notifier)
                          .setQuery,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: data.categoryFilter,
                      decoration:
                          const InputDecoration(labelText: 'Category Filter'),
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All')),
                        DropdownMenuItem(
                            value: 'Light Vehicle',
                            child: Text('Light Vehicle')),
                        DropdownMenuItem(
                            value: 'Heavy Vehicle',
                            child: Text('Heavy Vehicle')),
                        DropdownMenuItem(
                            value: 'Trailer', child: Text('Trailer')),
                        DropdownMenuItem(value: 'Tanker', child: Text('Tanker')),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        ref
                            .read(vehicleTypeViewModelProvider.notifier)
                            .setCategoryFilter(value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'Vehicle Types',
                subtitle: 'Oman transport/JMP-ready vehicle type master',
                icon: Icons.directions_car_outlined,
                accent: const Color(0xFF16A34A),
                trailing: FilledButton.icon(
                  onPressed: () => context.go(RoutePaths.vehicleTypeForm),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Vehicle Type'),
                ),
                child: items.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Text('No vehicle types found.'),
                      )
                    : (isMobile
                        ? _MobileVehicleTypeList(items: items)
                        : _DesktopVehicleTypeTable(items: items)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DesktopVehicleTypeTable extends ConsumerWidget {
  const _DesktopVehicleTypeTable({required this.items});

  final List<VehicleType> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFEFF4FF)),
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Code')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Class')),
          DataColumn(label: Text('Ownership')),
          DataColumn(label: Text('Load Type')),
          DataColumn(label: Text('Max Trips/Day')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (final item in items)
            DataRow(
              cells: [
                DataCell(Text(item.name)),
                DataCell(Text(item.code)),
                DataCell(Text(item.category)),
                DataCell(Text(item.vehicleClass)),
                DataCell(Text(item.ownershipTypes.join(', '))),
                DataCell(Text(item.loadType)),
                DataCell(Text('${item.maxTripsPerDay}')),
                DataCell(Text(item.status)),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Edit',
                        onPressed: () => context.go(
                          '${RoutePaths.vehicleTypeForm}?code=${item.code}',
                        ),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        onPressed: () =>
                            _confirmDelete(context, ref, item.code),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MobileVehicleTypeList extends ConsumerWidget {
  const _MobileVehicleTypeList({required this.items});

  final List<VehicleType> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFF8FAFC),
              border: Border.all(color: const Color(0xFFDCE6F7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${items[i].name} (${items[i].code})',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text('Category: ${items[i].category}'),
                Text('Class: ${items[i].vehicleClass}'),
                Text('Ownership: ${items[i].ownershipTypes.join(', ')}'),
                Text('Load Type: ${items[i].loadType}'),
                Text('Status: ${items[i].status}'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => context.go(
                        '${RoutePaths.vehicleTypeForm}?code=${items[i].code}',
                      ),
                      child: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () =>
                          _confirmDelete(context, ref, items[i].code),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (i != items.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

Future<void> _confirmDelete(
    BuildContext context, WidgetRef ref, String code) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Vehicle Type'),
      content: Text('Delete vehicle type $code?'),
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
  );

  if (confirmed != true) {
    return;
  }

  final message = await ref
      .read(vehicleTypeViewModelProvider.notifier)
      .deleteVehicleType(code);
  if (!context.mounted) {
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
