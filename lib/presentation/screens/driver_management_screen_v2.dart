import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/driver.dart';
import '../viewmodels/driver_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/auth_widgets.dart';
import '../../routes/route_paths.dart';

class DriverManagementScreenV2 extends ConsumerStatefulWidget {
  const DriverManagementScreenV2({super.key});

  @override
  ConsumerState<DriverManagementScreenV2> createState() => _DriverManagementScreenV2State();
}

class _DriverManagementScreenV2State extends ConsumerState<DriverManagementScreenV2> {
  String _searchQuery = '';
  String _filterStatus = 'All';
  String _sortBy = 'Name';

  @override
  Widget build(BuildContext context) {
    final driverState = ref.watch(driverViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return OpsShell(
      title: 'Driver Management',
      currentRoute: RoutePaths.driverManagement,
      actions: [
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Navigate to add driver form
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Driver'),
        ),
      ],
      child: driverState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (drivers) {
          // Filter and sort drivers
          var filteredDrivers = drivers.items.where((d) {
            final matchesSearch = _searchQuery.isEmpty ||
                d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                d.licenseNo.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesStatus = _filterStatus == 'All' || d.status == _filterStatus;
            return matchesSearch && matchesStatus;
          }).toList();

          if (_sortBy == 'Name') {
            filteredDrivers.sort((a, b) => a.name.compareTo(b.name));
          } else if (_sortBy == 'Experience') {
            filteredDrivers.sort((a, b) => b.experience.compareTo(a.experience));
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
                    title: 'Total Drivers',
                    value: drivers.items.length.toString(),
                    icon: Icons.badge_outlined,
                    color: colorScheme.primary,
                  ),
                  _SummaryCard(
                    title: 'Active',
                    value: drivers.items.where((d) => d.status == 'Active').length.toString(),
                    icon: Icons.check_circle_outlined,
                    color: colorScheme.tertiary,
                  ),
                  _SummaryCard(
                    title: 'On Leave',
                    value: drivers.items.where((d) => d.status == 'On Leave').length.toString(),
                    icon: Icons.event_busy_outlined,
                    color: colorScheme.secondary,
                  ),
                  _SummaryCard(
                    title: 'Inactive',
                    value: drivers.items.where((d) => d.status == 'Inactive').length.toString(),
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
                          hintText: 'Search by name or license number...',
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
                              items: ['All', 'Active', 'On Leave', 'Inactive']
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
                              items: ['Name', 'Experience']
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
              // Drivers List
              Text(
                'Drivers (${filteredDrivers.length})',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              if (filteredDrivers.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.badge_outlined, size: 48, color: colorScheme.outline),
                        const SizedBox(height: 12),
                        Text(
                          'No drivers found',
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
                  itemCount: filteredDrivers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final driver = filteredDrivers[index];
                    return _DriverCard(driver: driver);
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

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.driver});

  final DriverItem driver;

  Color _getStatusColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case 'Active':
        return colorScheme.tertiary;
      case 'On Leave':
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
    final statusColor = _getStatusColor(context, driver.status);

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
                UserAvatar(
                  initials: driver.name.split(' ').map((e) => e[0]).join(),
                  size: 50,
                  backgroundColor: colorScheme.primaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'License: ${driver.licenseNo}',
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
                    driver.status,
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
            // Driver Details Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _DetailItem(
                  label: 'Phone',
                  value: driver.phone,
                  icon: Icons.phone_outlined,
                ),
                _DetailItem(
                  label: 'Experience',
                  value: '${driver.experience} years',
                  icon: Icons.work_outline,
                ),
                _DetailItem(
                  label: 'License Expiry',
                  value: driver.expiryDate,
                  icon: Icons.calendar_today_outlined,
                ),
                _DetailItem(
                  label: 'DFMS Device',
                  value: driver.dfmsDeviceId,
                  icon: Icons.devices_outlined,
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
