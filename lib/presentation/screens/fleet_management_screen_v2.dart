import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/fleet.dart';
import '../viewmodels/fleet_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../../routes/route_paths.dart';

class FleetManagementScreenV2 extends ConsumerStatefulWidget {
  const FleetManagementScreenV2({super.key});

  @override
  ConsumerState<FleetManagementScreenV2> createState() => _FleetManagementScreenV2State();
}

class _FleetManagementScreenV2State extends ConsumerState<FleetManagementScreenV2> {
  String _searchQuery = '';
  String _filterStatus = 'All';
  String _sortBy = 'Vehicle Number';

  @override
  Widget build(BuildContext context) {
    final fleetState = ref.watch(fleetViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return OpsShell(
      title: 'Fleet Management',
      currentRoute: RoutePaths.fleetManagement,
      actions: [
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Navigate to add vehicle form
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Vehicle'),
        ),
      ],
      child: fleetState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (fleet) {
          final vehicles = fleet.items;

          // Filter and sort vehicles
          var filteredVehicles = vehicles.where((v) {
            final matchesSearch = _searchQuery.isEmpty ||
                v.vehicleNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                v.type.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesStatus = _filterStatus == 'All' || v.status == _filterStatus;
            return matchesSearch && matchesStatus;
          }).toList();

          if (_sortBy == 'Vehicle Number') {
            filteredVehicles.sort((a, b) => a.vehicleNumber.compareTo(b.vehicleNumber));
          } else if (_sortBy == 'Status') {
            filteredVehicles.sort((a, b) => a.status.compareTo(b.status));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary Cards
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width < 720 ? 2 : 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _SummaryCard(
                    title: 'Total Vehicles',
                    value: vehicles.length.toString(),
                    icon: Icons.local_shipping_outlined,
                    color: colorScheme.primary,
                  ),
                  _SummaryCard(
                    title: 'Active',
                    value: vehicles.where((v) => v.status == 'Active').length.toString(),
                    icon: Icons.check_circle_outlined,
                    color: colorScheme.tertiary,
                  ),
                  _SummaryCard(
                    title: 'Maintenance',
                    value: vehicles.where((v) => v.status == 'Maintenance').length.toString(),
                    icon: Icons.build_outlined,
                    color: colorScheme.secondary,
                  ),
                  _SummaryCard(
                    title: 'Inactive',
                    value: vehicles.where((v) => v.status == 'Inactive').length.toString(),
                    icon: Icons.block_outlined,
                    color: colorScheme.error,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Search and Filter Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Search & Filter',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Search Field
                      TextField(
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Search by vehicle number or type...',
                          prefixIcon: Icon(Icons.search_outlined, color: colorScheme.onSurfaceVariant),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_outlined),
                                  onPressed: () => setState(() => _searchQuery = ''),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Filter and Sort Row
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _filterStatus,
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                prefixIcon: Icon(Icons.filter_list_outlined),
                              ),
                              items: ['All', 'Active', 'Maintenance', 'Inactive']
                                  .map((status) => DropdownMenuItem(
                                        value: status,
                                        child: Text(status),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) setState(() => _filterStatus = value);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _sortBy,
                              decoration: const InputDecoration(
                                labelText: 'Sort By',
                                prefixIcon: Icon(Icons.sort_outlined),
                              ),
                              items: ['Vehicle Number', 'Status']
                                  .map((sort) => DropdownMenuItem(
                                        value: sort,
                                        child: Text(sort),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) setState(() => _sortBy = value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Vehicles List
              Text(
                'Vehicles (${filteredVehicles.length})',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              if (filteredVehicles.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.local_shipping_outlined, size: 48, color: colorScheme.outline),
                        const SizedBox(height: 12),
                        Text(
                          'No vehicles found',
                          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredVehicles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final vehicle = filteredVehicles[index];
                    return _VehicleCard(vehicle: vehicle);
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.15),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.vehicle});

  final FleetItem vehicle;

  Color _getStatusColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case 'Active':
        return colorScheme.tertiary;
      case 'Maintenance':
        return colorScheme.secondary;
      case 'Inactive':
        return colorScheme.error;
      default:
        return colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColor = _getStatusColor(context, vehicle.status);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                  ),
                  child: Icon(Icons.local_shipping_rounded, color: colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.vehicleNumber,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicle.type,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    vehicle.status,
                    style: textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            // Vehicle Details Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _DetailItem(
                  label: 'Capacity',
                  value: vehicle.capacity,
                  icon: Icons.storage_outlined,
                ),
                _DetailItem(
                  label: 'Fuel Type',
                  value: vehicle.fuelType,
                  icon: Icons.local_gas_station_outlined,
                ),
                _DetailItem(
                  label: 'IVMS Device',
                  value: vehicle.ivmsDeviceId,
                  icon: Icons.gps_fixed_outlined,
                ),
                _DetailItem(
                  label: 'Last Service',
                  value: '15 days ago',
                  icon: Icons.calendar_today_outlined,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Details'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
