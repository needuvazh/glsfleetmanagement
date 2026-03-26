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
      actions: const [],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final items = data.filteredItems;
          final isMobile = Responsive.isMobile(context);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OpsSectionCard(
                  title: 'Search & Filter',
                  subtitle: 'Search by name/code and filter by Oman category',
                  icon: Icons.tune_outlined,
                  accent: const Color(0xFF2563EB),
                  child: isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              initialValue: data.query,
                              decoration: const InputDecoration(
                                labelText:
                                    'Search (Name, Code, Class, Load Type)',
                                prefixIcon: Icon(Icons.search),
                              ),
                              onChanged: ref
                                  .read(vehicleTypeViewModelProvider.notifier)
                                  .setQuery,
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: data.categoryFilter,
                              decoration: const InputDecoration(
                                  labelText: 'Category Filter'),
                              items: const [
                                DropdownMenuItem(
                                    value: 'All', child: Text('All')),
                                DropdownMenuItem(
                                    value: 'Light Vehicle',
                                    child: Text('Light Vehicle')),
                                DropdownMenuItem(
                                    value: 'Heavy Vehicle',
                                    child: Text('Heavy Vehicle')),
                                DropdownMenuItem(
                                    value: 'Trailer', child: Text('Trailer')),
                                DropdownMenuItem(
                                    value: 'Tanker', child: Text('Tanker')),
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
                            const SizedBox(height: 10),
                            FilledButton.icon(
                              onPressed: () =>
                                  context.go(RoutePaths.vehicleTypeForm),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Oman Type'),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                initialValue: data.query,
                                decoration: const InputDecoration(
                                  labelText:
                                      'Search (Name, Code, Class, Load Type)',
                                  prefixIcon: Icon(Icons.search),
                                ),
                                onChanged: ref
                                    .read(vehicleTypeViewModelProvider.notifier)
                                    .setQuery,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: data.categoryFilter,
                                decoration: const InputDecoration(
                                  labelText: 'Category Filter',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'All', child: Text('All')),
                                  DropdownMenuItem(
                                      value: 'Light Vehicle',
                                      child: Text('Light Vehicle')),
                                  DropdownMenuItem(
                                      value: 'Heavy Vehicle',
                                      child: Text('Heavy Vehicle')),
                                  DropdownMenuItem(
                                      value: 'Trailer', child: Text('Trailer')),
                                  DropdownMenuItem(
                                      value: 'Tanker', child: Text('Tanker')),
                                ],
                                onChanged: (value) {
                                  if (value == null) {
                                    return;
                                  }
                                  ref
                                      .read(
                                          vehicleTypeViewModelProvider.notifier)
                                      .setCategoryFilter(value);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: () =>
                                  context.go(RoutePaths.vehicleTypeForm),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Oman Type'),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: OpsSectionCard(
                    title: 'Vehicle Types',
                    subtitle: 'Oman transport/JMP-ready vehicle type master',
                    icon: Icons.directions_car_outlined,
                    accent: const Color(0xFF16A34A),
                    child: items.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: Text('No vehicle types found.'),
                          )
                        : (isMobile
                            ? _MobileVehicleTypeList(items: items)
                            : _DesktopVehicleTypeTable(items: items)),
                  ),
                ),
              ],
            ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
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
                DataColumn(label: Text('Edit')),
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
                        Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              tooltip: 'Edit',
                              onPressed: () => context.go(
                                '${RoutePaths.vehicleTypeForm}?code=${item.code}',
                              ),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
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
